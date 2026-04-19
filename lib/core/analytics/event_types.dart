/// Canonical analytics event names.
///
/// Keep this list short — use `props` for dimensions rather than exploding
/// the name space. Backend rollups key off these names so any rename is a
/// schema migration.
abstract final class EventNames {
  // App lifecycle
  static const sessionStart = 'session_start';
  static const sessionEnd = 'session_end';
  static const appOpen = 'app_open';
  static const appBackground = 'app_background';

  // Navigation
  static const screenView = 'screen_view';

  // Commerce
  static const productView = 'product_view';
  static const productTap = 'product_tap';
  static const shopView = 'shop_view';
  static const search = 'search';
  static const cartAdd = 'cart_add';
  static const cartRemove = 'cart_remove';
  static const checkoutStart = 'checkout_start';
  static const checkoutComplete = 'checkout_complete';

  // Money
  static const walletView = 'wallet_view';
  static const walletTopupStart = 'wallet_topup_start';
  static const walletTransferStart = 'wallet_transfer_start';

  // Affiliate
  static const affiliateView = 'affiliate_view';
  static const affiliateShare = 'affiliate_share';
  static const referralCopy = 'referral_copy';

  // AI
  static const aiQuery = 'ai_query';
  static const aiFallback = 'ai_fallback';

  // Update
  static const updateAvailable = 'update_available';
  static const updateDownload = 'update_download';
  static const updateInstall = 'update_install';
}
