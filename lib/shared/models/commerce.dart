// Commerce models — Product, Shop, Cart, Order, Tracking, Chat.
//
// Hand-written fromJson / toJson (no freezed codegen yet) to keep Phase 2
// iteration fast. Migrate to freezed in Phase 6 before release.

import 'package:equatable/equatable.dart';

import '../widgets/blob_3d.dart';

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

int _asInt(dynamic v, [int fallback = 0]) =>
    v is int ? v : (v is num ? v.toInt() : (v is String ? int.tryParse(v) ?? fallback : fallback));

double _asDouble(dynamic v, [double fallback = 0]) => v is num
    ? v.toDouble()
    : (v is String ? double.tryParse(v) ?? fallback : fallback);

String _asStr(dynamic v, [String fallback = '']) =>
    v == null ? fallback : v.toString();

/// Rendering hint for the puffy product thumbnail when we have no real image.
/// Derived deterministically from product id so the same product always gets
/// the same color.
BlobHue hueForId(int id) {
  const hues = [
    BlobHue.pink,
    BlobHue.mint,
    BlobHue.mango,
    BlobHue.purple,
    BlobHue.tomato,
    BlobHue.leaf,
    BlobHue.sky,
  ];
  return hues[id.abs() % hues.length];
}

// ---------------------------------------------------------------------------
// Product
// ---------------------------------------------------------------------------

class ProductVariant extends Equatable {
  const ProductVariant({required this.id, required this.label, required this.priceThb});
  final int id;
  final String label;
  final double priceThb;

  factory ProductVariant.fromJson(Map<String, dynamic> j) => ProductVariant(
        id: _asInt(j['id']),
        label: _asStr(j['label'] ?? j['name']),
        priceThb: _asDouble(j['price']),
      );

  @override
  List<Object?> get props => [id, label, priceThb];
}

class ProductAddon extends Equatable {
  const ProductAddon({
    required this.id,
    required this.label,
    required this.priceThb,
    this.defaultSelected = false,
  });
  final int id;
  final String label;
  final double priceThb;
  final bool defaultSelected;

  factory ProductAddon.fromJson(Map<String, dynamic> j) => ProductAddon(
        id: _asInt(j['id']),
        label: _asStr(j['label'] ?? j['name']),
        priceThb: _asDouble(j['price']),
        defaultSelected: j['default'] == true,
      );

  @override
  List<Object?> get props => [id, label, priceThb, defaultSelected];
}

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.priceThb,
    required this.shopId,
    required this.shopName,
    this.category,
    this.rating,
    this.reviewCount = 0,
    this.imageUrl,
    this.variants = const [],
    this.addons = const [],
    this.freeDelivery = false,
    this.affiliateCommissionPercent,
  });

  final int id;
  final String name;
  final String description;
  final double priceThb;
  final int shopId;
  final String shopName;
  final String? category;
  final double? rating;
  final int reviewCount;
  final String? imageUrl;
  final List<ProductVariant> variants;
  final List<ProductAddon> addons;
  final bool freeDelivery;
  final double? affiliateCommissionPercent;

  BlobHue get hue => hueForId(id);

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: _asInt(j['id']),
        name: _asStr(j['name']),
        description: _asStr(j['description']),
        priceThb: _asDouble(j['price']),
        shopId: _asInt(j['shop_id'] ?? j['seller_id']),
        shopName: _asStr(j['shop_name'] ?? j['seller_name'] ?? j['shop']?['name']),
        category: j['category']?.toString(),
        rating: j['rating'] == null ? null : _asDouble(j['rating']),
        reviewCount: _asInt(j['review_count']),
        imageUrl: j['image'] ?? j['image_url'],
        variants: (j['variants'] as List?)
                ?.map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
                .toList() ??
            const [],
        addons: (j['addons'] as List?)
                ?.map((v) => ProductAddon.fromJson(v as Map<String, dynamic>))
                .toList() ??
            const [],
        freeDelivery: j['free_delivery'] == true,
        affiliateCommissionPercent: j['affiliate_commission'] == null
            ? null
            : _asDouble(j['affiliate_commission']),
      );

  @override
  List<Object?> get props => [id, name, priceThb, variants, addons];
}

// ---------------------------------------------------------------------------
// Shop
// ---------------------------------------------------------------------------

class Shop extends Equatable {
  const Shop({
    required this.id,
    required this.name,
    this.avatar,
    this.coverUrl,
    this.verifiedLevel,
    this.rating,
    this.orderCount = 0,
    this.replyWithinMinutes,
    this.followerCount = 0,
    this.productCount = 0,
    this.reviewReplyPercent,
    this.openHoursText,
    this.cuisine,
    this.isOpen = true,
  });

  final int id;
  final String name;
  final String? avatar;
  final String? coverUrl;
  final int? verifiedLevel;
  final double? rating;
  final int orderCount;
  final int? replyWithinMinutes;
  final int followerCount;
  final int productCount;
  final double? reviewReplyPercent;
  final String? openHoursText;
  final String? cuisine;
  final bool isOpen;

  factory Shop.fromJson(Map<String, dynamic> j) => Shop(
        id: _asInt(j['id']),
        name: _asStr(j['name']),
        avatar: j['avatar']?.toString(),
        coverUrl: j['cover']?.toString(),
        verifiedLevel:
            j['verified_level'] == null ? null : _asInt(j['verified_level']),
        rating: j['rating'] == null ? null : _asDouble(j['rating']),
        orderCount: _asInt(j['order_count']),
        replyWithinMinutes: j['reply_minutes'] == null
            ? null
            : _asInt(j['reply_minutes']),
        followerCount: _asInt(j['follower_count']),
        productCount: _asInt(j['product_count']),
        reviewReplyPercent: j['review_reply_percent'] == null
            ? null
            : _asDouble(j['review_reply_percent']),
        openHoursText: j['open_hours']?.toString(),
        cuisine: j['cuisine']?.toString(),
        isOpen: j['is_open'] != false,
      );

  @override
  List<Object?> get props => [id, name];
}

// ---------------------------------------------------------------------------
// Cart
// ---------------------------------------------------------------------------

class CartItem extends Equatable {
  const CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.priceThb,
    required this.quantity,
    required this.shopName,
    this.variantLabel,
    this.imageUrl,
  });

  final int id;
  final int productId;
  final String name;
  final double priceThb;
  final int quantity;
  final String shopName;
  final String? variantLabel;
  final String? imageUrl;

  double get lineTotal => priceThb * quantity;
  BlobHue get hue => hueForId(productId);

  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
        id: _asInt(j['id']),
        productId: _asInt(j['product_id']),
        name: _asStr(j['name'] ?? j['product_name']),
        priceThb: _asDouble(j['price']),
        quantity: _asInt(j['quantity'] ?? j['qty'], 1),
        shopName: _asStr(j['shop_name'] ?? j['seller_name']),
        variantLabel: j['variant']?.toString() ?? j['size']?.toString(),
        imageUrl: j['image']?.toString(),
      );

  @override
  List<Object?> get props => [id, productId, quantity];
}

class Cart extends Equatable {
  const Cart({
    required this.items,
    required this.subtotalThb,
    required this.deliveryFeeThb,
    required this.discountThb,
    required this.totalThb,
    this.coinsAvailable = 0,
    this.coinsApplied = 0,
    this.walletBalanceThb = 0,
    this.deliveryEta,
    this.deliveryAddress,
  });

  final List<CartItem> items;
  final double subtotalThb;
  final double deliveryFeeThb;
  final double discountThb;
  final double totalThb;
  final int coinsAvailable;
  final int coinsApplied;
  final double walletBalanceThb;
  final String? deliveryEta;
  final String? deliveryAddress;

  int get itemCount => items.fold(0, (a, b) => a + b.quantity);

  factory Cart.fromJson(Map<String, dynamic> j) => Cart(
        items: (j['items'] as List?)
                ?.map((v) => CartItem.fromJson(v as Map<String, dynamic>))
                .toList() ??
            const [],
        subtotalThb: _asDouble(j['subtotal']),
        deliveryFeeThb: _asDouble(j['delivery_fee']),
        discountThb: _asDouble(j['discount']),
        totalThb: _asDouble(j['total']),
        coinsAvailable: _asInt(j['coins_available']),
        coinsApplied: _asInt(j['coins_applied']),
        walletBalanceThb: _asDouble(j['wallet_balance']),
        deliveryEta: j['delivery_eta']?.toString(),
        deliveryAddress: j['delivery_address']?.toString(),
      );

  static const empty = Cart(
    items: [],
    subtotalThb: 0,
    deliveryFeeThb: 0,
    discountThb: 0,
    totalThb: 0,
  );

  @override
  List<Object?> get props => [items, subtotalThb, deliveryFeeThb, discountThb, totalThb];
}

// ---------------------------------------------------------------------------
// Order + Tracking
// ---------------------------------------------------------------------------

enum OrderStatus { pending, accepted, preparing, pickedUp, delivering, delivered, cancelled }

OrderStatus _statusFromRaw(String? raw) {
  return switch (raw) {
    'accepted' => OrderStatus.accepted,
    'preparing' => OrderStatus.preparing,
    'picked_up' => OrderStatus.pickedUp,
    'delivering' => OrderStatus.delivering,
    'delivered' || 'completed' => OrderStatus.delivered,
    'cancelled' || 'canceled' => OrderStatus.cancelled,
    _ => OrderStatus.pending,
  };
}

class TrackingStep extends Equatable {
  const TrackingStep({
    required this.label,
    this.timeText,
    this.done = false,
    this.active = false,
  });
  final String label;
  final String? timeText;
  final bool done;
  final bool active;

  factory TrackingStep.fromJson(Map<String, dynamic> j) => TrackingStep(
        label: _asStr(j['label'] ?? j['name']),
        timeText: j['time']?.toString(),
        done: j['done'] == true,
        active: j['active'] == true,
      );

  @override
  List<Object?> get props => [label, timeText, done, active];
}

class Rider extends Equatable {
  const Rider({
    required this.name,
    this.role = 'Rider',
    this.plate,
    this.vehicle,
    this.rating,
    this.phone,
  });
  final String name;
  final String role;
  final String? plate;
  final String? vehicle;
  final double? rating;
  final String? phone;

  factory Rider.fromJson(Map<String, dynamic> j) => Rider(
        name: _asStr(j['name']),
        role: _asStr(j['role'] ?? 'Rider', 'Rider'),
        plate: j['plate']?.toString(),
        vehicle: j['vehicle']?.toString(),
        rating: j['rating'] == null ? null : _asDouble(j['rating']),
        phone: j['phone']?.toString(),
      );

  @override
  List<Object?> get props => [name, plate, vehicle];
}

class Tracking extends Equatable {
  const Tracking({
    required this.orderRef,
    required this.steps,
    this.etaMinutes,
    this.rider,
  });

  final String orderRef;
  final List<TrackingStep> steps;
  final int? etaMinutes;
  final Rider? rider;

  factory Tracking.fromJson(Map<String, dynamic> j) => Tracking(
        orderRef: _asStr(j['order_ref'] ?? j['order_id']?.toString()),
        steps: (j['steps'] as List?)
                ?.map((v) => TrackingStep.fromJson(v as Map<String, dynamic>))
                .toList() ??
            const [],
        etaMinutes: j['eta_minutes'] == null ? null : _asInt(j['eta_minutes']),
        rider: j['rider'] is Map<String, dynamic>
            ? Rider.fromJson(j['rider'] as Map<String, dynamic>)
            : null,
      );

  @override
  List<Object?> get props => [orderRef, steps, etaMinutes];
}

class OrderSummary extends Equatable {
  const OrderSummary({
    required this.id,
    required this.ref,
    required this.status,
    required this.totalThb,
    required this.itemCount,
    this.shopName,
    this.placedAt,
  });

  final int id;
  final String ref;
  final OrderStatus status;
  final double totalThb;
  final int itemCount;
  final String? shopName;
  final DateTime? placedAt;

  factory OrderSummary.fromJson(Map<String, dynamic> j) => OrderSummary(
        id: _asInt(j['id']),
        ref: _asStr(j['ref'] ?? j['order_ref'] ?? j['id'].toString()),
        status: _statusFromRaw(j['status']?.toString()),
        totalThb: _asDouble(j['total']),
        itemCount: _asInt(j['item_count']),
        shopName: j['shop_name']?.toString(),
        placedAt: j['placed_at'] == null ? null : DateTime.tryParse(j['placed_at'].toString()),
      );

  @override
  List<Object?> get props => [id, status, totalThb];
}

// ---------------------------------------------------------------------------
// Chat message
// ---------------------------------------------------------------------------

enum MessageSide { me, them }

class ChatAttachment extends Equatable {
  const ChatAttachment({
    required this.productId,
    required this.productName,
    required this.priceThb,
    this.freeDelivery = false,
    this.imageUrl,
  });
  final int productId;
  final String productName;
  final double priceThb;
  final bool freeDelivery;
  final String? imageUrl;

  factory ChatAttachment.fromJson(Map<String, dynamic> j) => ChatAttachment(
        productId: _asInt(j['product_id']),
        productName: _asStr(j['product_name'] ?? j['name']),
        priceThb: _asDouble(j['price']),
        freeDelivery: j['free_delivery'] == true,
        imageUrl: j['image']?.toString(),
      );

  @override
  List<Object?> get props => [productId, productName, priceThb];
}

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.side,
    required this.text,
    required this.timeText,
    this.attachment,
  });

  final String id;
  final MessageSide side;
  final String text;
  final String timeText;
  final ChatAttachment? attachment;

  factory ChatMessage.fromJson(Map<String, dynamic> j, {required int currentUserId}) {
    final senderId = _asInt(j['sender_id']);
    return ChatMessage(
      id: _asStr(j['id'] ?? j['ref']),
      side: senderId == currentUserId ? MessageSide.me : MessageSide.them,
      text: _asStr(j['text'] ?? j['body']),
      timeText: _formatTime(j['created_at']),
      attachment: j['attachment'] is Map<String, dynamic>
          ? ChatAttachment.fromJson(j['attachment'] as Map<String, dynamic>)
          : null,
    );
  }

  static String _formatTime(dynamic ts) {
    final dt = DateTime.tryParse(ts?.toString() ?? '');
    if (dt == null) return '';
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [id, side, text];
}
