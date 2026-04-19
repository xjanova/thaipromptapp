// Fresh Market (ตลาดสด) models — buyer-side surface only for v1.
//
// Mirrors the JSON shape produced by
// `App\Http\Controllers\Api\V1\FreshMarketApiController` in the backend repo.
// Hand-written `fromJson` (no codegen) consistent with other models in this
// folder. Only fields the buyer UI consumes are deserialised — server may
// add new keys without breaking us.

import 'package:equatable/equatable.dart';

// ---------------------------------------------------------------------------
// Shared helpers (lightweight clones of the ones in commerce.dart so this
// file stays self-contained)
// ---------------------------------------------------------------------------

int _asInt(dynamic v, [int fallback = 0]) =>
    v is int ? v : (v is num ? v.toInt() : (v is String ? int.tryParse(v) ?? fallback : fallback));

double _asDouble(dynamic v, [double fallback = 0]) => v is num
    ? v.toDouble()
    : (v is String ? double.tryParse(v) ?? fallback : fallback);

String _asStr(dynamic v, [String fallback = '']) =>
    v == null ? fallback : v.toString();

String? _asNullableStr(dynamic v) =>
    v == null ? null : v.toString();

bool _asBool(dynamic v, [bool fallback = false]) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) return v == '1' || v.toLowerCase() == 'true';
  return fallback;
}

List<String> _asStrList(dynamic v) {
  if (v is List) return v.map(_asStr).where((s) => s.isNotEmpty).toList();
  return const [];
}

// ---------------------------------------------------------------------------
// Category
// ---------------------------------------------------------------------------

class TmCategory extends Equatable {
  const TmCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.imageUrl,
    this.children = const [],
  });

  final int id;
  final String name;
  final String slug;
  final String? icon;
  final String? imageUrl;
  final List<TmCategory> children;

  factory TmCategory.fromJson(Map<String, dynamic> j) => TmCategory(
        id: _asInt(j['id']),
        name: _asStr(j['name']),
        slug: _asStr(j['slug']),
        icon: _asNullableStr(j['icon']),
        imageUrl: _asNullableStr(j['image_url']),
        children: (j['children'] is List)
            ? (j['children'] as List)
                .whereType<Map<String, dynamic>>()
                .map(TmCategory.fromJson)
                .toList()
            : const [],
      );

  @override
  List<Object?> get props => [id, name, slug, icon, imageUrl];
}

// ---------------------------------------------------------------------------
// Seller (mini + full)
// ---------------------------------------------------------------------------

class TmSellerMini extends Equatable {
  const TmSellerMini({
    required this.id,
    required this.shopName,
    this.ratingAverage,
  });

  final int id;
  final String shopName;
  final double? ratingAverage;

  factory TmSellerMini.fromJson(Map<String, dynamic> j) => TmSellerMini(
        id: _asInt(j['id']),
        shopName: _asStr(j['shop_name']),
        ratingAverage: j['rating_average'] == null
            ? null
            : _asDouble(j['rating_average']),
      );

  @override
  List<Object?> get props => [id, shopName, ratingAverage];
}

class TmSeller extends Equatable {
  const TmSeller({
    required this.id,
    required this.shopName,
    this.shopDescription,
    this.shopImage,
    this.ratingAverage,
    this.ratingCount = 0,
    this.totalSales = 0,
    this.latitude,
    this.longitude,
    this.province,
    this.phone,
    this.isVerified = false,
  });

  final int id;
  final String shopName;
  final String? shopDescription;
  final String? shopImage;
  final double? ratingAverage;
  final int ratingCount;
  final int totalSales;
  final double? latitude;
  final double? longitude;
  final String? province;
  final String? phone;
  final bool isVerified;

  factory TmSeller.fromJson(Map<String, dynamic> j) => TmSeller(
        id: _asInt(j['id']),
        shopName: _asStr(j['shop_name']),
        shopDescription: _asNullableStr(j['shop_description']),
        shopImage: _asNullableStr(j['shop_image']),
        ratingAverage: j['rating_average'] == null
            ? null
            : _asDouble(j['rating_average']),
        ratingCount: _asInt(j['rating_count']),
        totalSales: _asInt(j['total_sales']),
        latitude: j['latitude'] == null ? null : _asDouble(j['latitude']),
        longitude: j['longitude'] == null ? null : _asDouble(j['longitude']),
        province: _asNullableStr(j['province']),
        phone: _asNullableStr(j['phone']),
        isVerified: _asBool(j['is_verified']),
      );

  @override
  List<Object?> get props => [id, shopName, ratingAverage, ratingCount, isVerified];
}

// ---------------------------------------------------------------------------
// Listing — list item (from /listings paginated) + full detail
// ---------------------------------------------------------------------------

class TmListing extends Equatable {
  const TmListing({
    required this.id,
    required this.title,
    required this.price,
    required this.unit,
    required this.quantityAvailable,
    this.slug,
    this.description,
    this.compareAtPrice,
    this.mainImageUrl,
    this.images = const [],
    this.isOrganic = false,
    this.isFeatured = false,
    this.freshnessLevel,
    this.distanceKm,
    this.cashbackAmount,
    this.seller,
    this.category,
  });

  final int id;
  final String? slug;
  final String title;
  final String? description;
  final double price;
  final double? compareAtPrice;
  final String unit;
  final int quantityAvailable;
  final String? mainImageUrl;
  final List<String> images;
  final bool isOrganic;
  final bool isFeatured;
  final String? freshnessLevel;
  final double? distanceKm;
  final double? cashbackAmount;
  final TmSellerMini? seller;
  final TmCategory? category;

  bool get inStock => quantityAvailable > 0;
  bool get hasDiscount =>
      compareAtPrice != null && compareAtPrice! > price;
  int get discountPercent => hasDiscount
      ? (((compareAtPrice! - price) / compareAtPrice!) * 100).round()
      : 0;

  factory TmListing.fromJson(Map<String, dynamic> j) => TmListing(
        id: _asInt(j['id']),
        slug: _asNullableStr(j['slug']),
        title: _asStr(j['title']),
        description: _asNullableStr(j['description']),
        price: _asDouble(j['price']),
        compareAtPrice: j['compare_at_price'] == null
            ? null
            : _asDouble(j['compare_at_price']),
        unit: _asStr(j['unit'], 'ชิ้น'),
        quantityAvailable: _asInt(j['quantity_available']),
        mainImageUrl: _asNullableStr(j['main_image_url']),
        images: _asStrList(j['images']),
        isOrganic: _asBool(j['is_organic']),
        isFeatured: _asBool(j['is_featured']),
        freshnessLevel: _asNullableStr(j['freshness_level']),
        distanceKm: j['distance_km'] == null
            ? null
            : _asDouble(j['distance_km']),
        cashbackAmount: j['cashback_amount'] == null
            ? null
            : _asDouble(j['cashback_amount']),
        seller: (j['seller'] is Map<String, dynamic>)
            ? TmSellerMini.fromJson(j['seller'] as Map<String, dynamic>)
            : null,
        category: (j['category'] is Map<String, dynamic>)
            ? TmCategory.fromJson(j['category'] as Map<String, dynamic>)
            : null,
      );

  @override
  List<Object?> get props =>
      [id, title, price, unit, quantityAvailable, mainImageUrl];
}

class TmListingDetail extends Equatable {
  const TmListingDetail({
    required this.listing,
    required this.seller,
    this.category,
    this.related = const [],
    this.deliveryRadiusKm,
    this.cashbackPercentage,
    this.viewCount = 0,
    this.orderCount = 0,
  });

  final TmListing listing;
  final TmSeller? seller;
  final TmCategory? category;
  final List<TmRelatedListing> related;
  final double? deliveryRadiusKm;
  final double? cashbackPercentage;
  final int viewCount;
  final int orderCount;

  /// `body['data']` is the listing-with-extra-fields object; `body['related']`
  /// is a separate sibling list (per controller shape).
  factory TmListingDetail.fromBody(Map<String, dynamic> body) {
    final data = (body['data'] as Map<String, dynamic>? ?? const {});
    final related = (body['related'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(TmRelatedListing.fromJson)
        .toList();
    return TmListingDetail(
      listing: TmListing.fromJson(data),
      seller: (data['seller'] is Map<String, dynamic>)
          ? TmSeller.fromJson(data['seller'] as Map<String, dynamic>)
          : null,
      category: (data['category'] is Map<String, dynamic>)
          ? TmCategory.fromJson(data['category'] as Map<String, dynamic>)
          : null,
      related: related,
      deliveryRadiusKm: data['delivery_radius_km'] == null
          ? null
          : _asDouble(data['delivery_radius_km']),
      cashbackPercentage: data['cashback_percentage'] == null
          ? null
          : _asDouble(data['cashback_percentage']),
      viewCount: _asInt(data['view_count']),
      orderCount: _asInt(data['order_count']),
    );
  }

  @override
  List<Object?> get props =>
      [listing, seller, category, related.length];
}

class TmRelatedListing extends Equatable {
  const TmRelatedListing({
    required this.id,
    required this.title,
    required this.price,
    required this.unit,
    this.slug,
    this.mainImageUrl,
    this.shopName,
  });

  final int id;
  final String? slug;
  final String title;
  final double price;
  final String unit;
  final String? mainImageUrl;
  final String? shopName;

  factory TmRelatedListing.fromJson(Map<String, dynamic> j) => TmRelatedListing(
        id: _asInt(j['id']),
        slug: _asNullableStr(j['slug']),
        title: _asStr(j['title']),
        price: _asDouble(j['price']),
        unit: _asStr(j['unit'], 'ชิ้น'),
        mainImageUrl: _asNullableStr(j['main_image_url']),
        shopName: _asNullableStr(j['shop_name']),
      );

  @override
  List<Object?> get props => [id, title, price];
}

// ---------------------------------------------------------------------------
// Pagination meta
// ---------------------------------------------------------------------------

class TmPaginatedListings extends Equatable {
  const TmPaginatedListings({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  final List<TmListing> items;
  final int currentPage;
  final int lastPage;
  final int total;

  bool get hasMore => currentPage < lastPage;

  /// Backend wraps the paginator under `data.data[]` AND surfaces a top-level
  /// `meta` block. We accept either source for resilience against shape drift.
  factory TmPaginatedListings.fromBody(Map<String, dynamic> body) {
    final outer = (body['data'] as Map<String, dynamic>? ?? const {});
    final rawItems = (outer['data'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(TmListing.fromJson)
        .toList();
    final meta = (body['meta'] as Map<String, dynamic>? ?? outer);
    return TmPaginatedListings(
      items: rawItems,
      currentPage: _asInt(meta['current_page'], 1),
      lastPage: _asInt(meta['last_page'], 1),
      total: _asInt(meta['total']),
    );
  }

  @override
  List<Object?> get props => [items.length, currentPage, lastPage, total];
}

// ---------------------------------------------------------------------------
// Order (buyer side)
// ---------------------------------------------------------------------------

enum TmDeliveryType { pickup, rider, shipping }

extension TmDeliveryTypeX on TmDeliveryType {
  String get apiValue => switch (this) {
        TmDeliveryType.pickup => 'pickup',
        TmDeliveryType.rider => 'rider',
        TmDeliveryType.shipping => 'shipping',
      };

  String get label => switch (this) {
        TmDeliveryType.pickup => 'รับเอง',
        TmDeliveryType.rider => 'ไรเดอร์ส่ง',
        TmDeliveryType.shipping => 'ขนส่ง',
      };
}

enum TmPaymentMethod { wallet, cod, transfer, escrow }

extension TmPaymentMethodX on TmPaymentMethod {
  String get apiValue => switch (this) {
        TmPaymentMethod.wallet => 'wallet',
        TmPaymentMethod.cod => 'cod',
        TmPaymentMethod.transfer => 'transfer',
        TmPaymentMethod.escrow => 'escrow',
      };

  String get label => switch (this) {
        TmPaymentMethod.wallet => 'Wallet',
        TmPaymentMethod.cod => 'เก็บปลายทาง',
        TmPaymentMethod.transfer => 'โอน',
        TmPaymentMethod.escrow => 'Escrow',
      };
}

class TmOrderSummary extends Equatable {
  const TmOrderSummary({
    required this.id,
    required this.orderNumber,
    required this.totalAmount,
    required this.deliveryFee,
    required this.orderStatus,
    required this.paymentMethod,
    this.cashbackAmount,
  });

  final int id;
  final String orderNumber;
  final double totalAmount;
  final double deliveryFee;
  final String orderStatus;
  final String paymentMethod;
  final double? cashbackAmount;

  factory TmOrderSummary.fromJson(Map<String, dynamic> j) => TmOrderSummary(
        id: _asInt(j['id']),
        orderNumber: _asStr(j['order_number']),
        totalAmount: _asDouble(j['total_amount']),
        deliveryFee: _asDouble(j['delivery_fee']),
        orderStatus: _asStr(j['order_status']),
        paymentMethod: _asStr(j['payment_method']),
        cashbackAmount: j['cashback_amount'] == null
            ? null
            : _asDouble(j['cashback_amount']),
      );

  @override
  List<Object?> get props =>
      [id, orderNumber, totalAmount, orderStatus];
}

class TmOrderListItem extends Equatable {
  const TmOrderListItem({
    required this.id,
    required this.orderNumber,
    required this.quantity,
    required this.totalAmount,
    required this.deliveryFee,
    required this.orderStatus,
    required this.paymentStatus,
    required this.deliveryType,
    this.listingTitle,
    this.listingImage,
    this.shopName,
    this.cashbackAmount,
    this.createdAt,
  });

  final int id;
  final String orderNumber;
  final String? listingTitle;
  final String? listingImage;
  final int quantity;
  final double totalAmount;
  final double deliveryFee;
  final String orderStatus;
  final String paymentStatus;
  final String deliveryType;
  final String? shopName;
  final double? cashbackAmount;
  final DateTime? createdAt;

  factory TmOrderListItem.fromJson(Map<String, dynamic> j) => TmOrderListItem(
        id: _asInt(j['id']),
        orderNumber: _asStr(j['order_number']),
        listingTitle: _asNullableStr(j['listing_title']),
        listingImage: _asNullableStr(j['listing_image']),
        quantity: _asInt(j['quantity']),
        totalAmount: _asDouble(j['total_amount']),
        deliveryFee: _asDouble(j['delivery_fee']),
        orderStatus: _asStr(j['order_status']),
        paymentStatus: _asStr(j['payment_status']),
        deliveryType: _asStr(j['delivery_type']),
        shopName: _asNullableStr(j['shop_name']),
        cashbackAmount: j['cashback_amount'] == null
            ? null
            : _asDouble(j['cashback_amount']),
        createdAt: j['created_at'] == null
            ? null
            : DateTime.tryParse(j['created_at'].toString()),
      );

  /// Maps the server's slug-y status to a Thai-readable label.
  String get statusLabel => switch (orderStatus) {
        'pending' => 'รอผู้ขายยืนยัน',
        'accepted' => 'ผู้ขายรับออเดอร์',
        'preparing' => 'กำลังเตรียมของ',
        'ready' => 'พร้อมส่ง / รับ',
        'on_the_way' => 'ไรเดอร์กำลังไปส่ง',
        'delivered' => 'ส่งของแล้ว',
        'completed' => 'สำเร็จ',
        'cancelled' => 'ยกเลิก',
        'refunded' => 'คืนเงินแล้ว',
        _ => orderStatus,
      };

  @override
  List<Object?> get props => [id, orderNumber, orderStatus];
}
