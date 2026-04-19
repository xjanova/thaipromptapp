import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../shared/models/fresh_market.dart';

/// Repository for the buyer-side Fresh Market (ตลาดสด) endpoints.
///
/// Wraps everything under `App\Http\Controllers\Api\V1\FreshMarketApiController`
/// that the mobile app needs in v1.0.4. Seller-only and Rider GPS endpoints
/// are deliberately NOT wrapped here — those will get their own repository
/// when we build the seller/rider experience.
class FreshMarketRepository {
  FreshMarketRepository(this._api);
  final ApiClient _api;

  /// Top-level categories with one level of children.
  Future<List<TmCategory>> categories() async {
    final res = await _api.get<Map<String, dynamic>>(Api.fmCategories);
    final list = (res['data'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(TmCategory.fromJson)
        .toList(growable: false);
    return list;
  }

  /// Paginated listings with optional filters.
  ///
  /// `sort` accepts `newest` (default) | `price_asc` | `price_desc` |
  /// `popular` | `distance`. Distance sort needs `lat` + `lng` to be
  /// supplied or it's a no-op.
  Future<TmPaginatedListings> listings({
    int page = 1,
    int perPage = 20,
    int? categoryId,
    String? search,
    double? lat,
    double? lng,
    double? radiusKm,
    double? minPrice,
    double? maxPrice,
    bool organicOnly = false,
    String sort = 'newest',
  }) async {
    final res = await _api.get<Map<String, dynamic>>(
      Api.fmListings,
      query: {
        'page': page,
        'per_page': perPage,
        if (categoryId != null) 'category_id': categoryId,
        if (search != null && search.trim().isNotEmpty) 'q': search.trim(),
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (radiusKm != null) 'radius': radiusKm,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
        if (organicOnly) 'organic': 1,
        'sort': sort,
      },
    );
    return TmPaginatedListings.fromBody(res);
  }

  /// Listings within `radiusKm` (default 10km) of the buyer's location.
  /// Backend uses a flat list shape — not paginated — for the homepage strip.
  Future<List<TmListing>> nearby({
    required double lat,
    required double lng,
    double radiusKm = 10,
  }) async {
    final res = await _api.get<Map<String, dynamic>>(
      Api.fmNearby,
      query: {'lat': lat, 'lng': lng, 'radius': radiusKm},
    );
    final list = (res['data'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(TmListing.fromJson)
        .toList(growable: false);
    return list;
  }

  /// Listing detail bundle = listing + seller + category + related (≤ 6).
  Future<TmListingDetail> listingDetail(int id) async {
    final res = await _api.get<Map<String, dynamic>>(Api.fmListing(id));
    return TmListingDetail.fromBody(res);
  }

  /// Seller profile + their latest 20 active listings.
  Future<TmSellerProfile> seller(int id) async {
    final res = await _api.get<Map<String, dynamic>>(Api.fmSeller(id));
    final data = res['data'] as Map<String, dynamic>? ?? const {};
    final listings = (res['listings'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(TmListing.fromJson)
        .toList(growable: false);
    return TmSellerProfile(
      seller: TmSeller.fromJson(data),
      listings: listings,
    );
  }

  /// Place an order for a single listing. Server enforces stock + auth.
  ///
  /// Returns the freshly-created order summary on success. Throws
  /// [ApiException] subclasses for stock/payment/validation errors.
  Future<TmOrderSummary> placeOrder({
    required int listingId,
    required int quantity,
    required TmDeliveryType deliveryType,
    required TmPaymentMethod paymentMethod,
    String? deliveryAddress,
    String? deliveryNotes,
    double? buyerLatitude,
    double? buyerLongitude,
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      Api.fmOrders,
      data: {
        'listing_id': listingId,
        'quantity': quantity,
        'delivery_type': deliveryType.apiValue,
        'payment_method': paymentMethod.apiValue,
        if (deliveryAddress != null) 'delivery_address': deliveryAddress,
        if (deliveryNotes != null) 'delivery_notes': deliveryNotes,
        if (buyerLatitude != null) 'buyer_latitude': buyerLatitude,
        if (buyerLongitude != null) 'buyer_longitude': buyerLongitude,
      },
    );
    return TmOrderSummary.fromJson(
      (res['data'] as Map<String, dynamic>? ?? const {}),
    );
  }

  /// Buyer's own order history. `status` filters server-side.
  Future<List<TmOrderListItem>> myOrders({String? status, int page = 1}) async {
    final res = await _api.get<Map<String, dynamic>>(
      Api.fmOrders,
      query: {
        'page': page,
        if (status != null) 'status': status,
      },
    );
    final outer = res['data'] as Map<String, dynamic>? ?? const {};
    return (outer['data'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(TmOrderListItem.fromJson)
        .toList(growable: false);
  }
}

/// Bundle returned by [FreshMarketRepository.seller] — full seller profile
/// with their latest in-stock listings.
class TmSellerProfile {
  const TmSellerProfile({required this.seller, required this.listings});
  final TmSeller seller;
  final List<TmListing> listings;
}

// ---------------------------------------------------------------------------
// Riverpod plumbing
// ---------------------------------------------------------------------------

final freshMarketRepositoryProvider = FutureProvider<FreshMarketRepository>(
  (ref) async {
    final api = await ref.watch(apiClientProvider.future);
    return FreshMarketRepository(api);
  },
);

/// Cached categories — rarely change, fine to memoise across the session.
final fmCategoriesProvider = FutureProvider<List<TmCategory>>((ref) async {
  final repo = await ref.watch(freshMarketRepositoryProvider.future);
  return repo.categories();
});

/// Default recent listings for the home strip (page 1, 20 items, no filters).
final fmRecentListingsProvider = FutureProvider<TmPaginatedListings>(
  (ref) async {
    final repo = await ref.watch(freshMarketRepositoryProvider.future);
    return repo.listings();
  },
);
