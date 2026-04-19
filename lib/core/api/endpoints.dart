/// API endpoint constants for Thaiprompt backend.
/// Base URL is resolved at runtime in [ApiClient].
class Api {
  const Api._();

  // Auth
  static const login = '/v1/login';
  static const register = '/v1/register';
  static const logout = '/v1/logout';
  static const me = '/v1/me';

  // LINE auth
  static const lineNativeConfig = '/v1/auth/line-native/config';
  static const lineNativeVerify = '/v1/auth/line-native/verify';
  static const mobileAuthInit = '/v1/auth/mobile/init';
  static const mobileAuthExchange = '/v1/auth/mobile/exchange';
  static const mobileAuthStatus = '/v1/auth/mobile/status';

  // Profile
  static const profile = '/v1/profile';
  static const changePassword = '/v1/profile/change-password';
  static const referralCode = '/v1/profile/referral-code';
  static const avatar = '/v1/profile/avatar';

  // Products
  static const products = '/v1/products';
  static const productCategories = '/v1/products/categories';
  static String product(dynamic id) => '/v1/products/$id';

  // Cart
  static const cart = '/v1/cart';
  static const cartAdd = '/v1/cart/add';
  static String cartItem(dynamic id) => '/v1/cart/items/$id';
  static const cartClear = '/v1/cart/clear';
  static const cartPromo = '/v1/cart/promo';
  static const cartCheckout = '/v1/cart/checkout';

  // Wallet
  static const wallet = '/v1/wallet';
  static const walletBalance = '/v1/wallet/balance';
  static const walletTransactions = '/v1/wallet/transactions';
  static const walletTopup = '/v1/wallet/topup';
  static const walletLookup = '/v1/wallet/lookup';
  static const walletTransfer = '/v1/wallet/transfer';

  // Orders
  static const orders = '/v1/orders';
  static String order(dynamic id) => '/v1/orders/$id';
  static String orderCancel(dynamic id) => '/v1/orders/$id/cancel';
  static String orderTracking(dynamic id) => '/v1/orders/$id/tracking';
  static String orderMessages(dynamic id) => '/v1/orders/$id/messages';
  static const ordersUnreadMessages = '/v1/orders/unread-messages';

  // Dashboard (affiliate)
  static const dashboardStatistics = '/v1/dashboard/statistics';
  static const dashboardCommissions = '/v1/dashboard/commissions';
  static const dashboardReferrals = '/v1/dashboard/referrals';
  static const dashboardCharts = '/v1/dashboard/charts';
  static const dashboardReferralLink = '/v1/dashboard/referral-link';
  static const ranks = '/v1/ranks';

  // App control (to add in backend patches)
  static const appConfig = '/v1/app/config';
  static const appFlags = '/v1/app/flags';
  static const appMenus = '/v1/app/menus';
  static const appSliders = '/v1/app/sliders';
  static const appPromotions = '/v1/app/promotions';
  static const appBanners = '/v1/app/banners';
  static const appLatestVersion = '/v1/app/latest-version';

  // Analytics (to add)
  static const eventsBatch = '/v1/events/batch';

  // AI fallback (to add)
  static const aiChat = '/v1/ai/chat';

  // Public
  static const settings = '/v1/settings';
  static const provinces = '/thai-addresses/provinces';
  static String districts(dynamic provinceCode) =>
      '/thai-addresses/districts/$provinceCode';
}
