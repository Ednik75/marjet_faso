class ApiConfig {
  /// Production URL passed at build time:
  /// flutter run --dart-define=API_BASE_URL=https://xxx.up.railway.app/api
  static const String productionUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const String devMobileUrl = 'http://10.0.2.2:8000/api';
  static const String devWebUrl = 'http://localhost:8000/api';

  static String get baseUrl =>
      productionUrl.isNotEmpty ? productionUrl : devMobileUrl;

  static String get webBaseUrl =>
      productionUrl.isNotEmpty ? productionUrl : devWebUrl;

  static String get effectiveBaseUrl {
    return const bool.fromEnvironment('dart.library.html')
        ? webBaseUrl
        : baseUrl;
  }

  // Auth
  static const String register = '/auth/register/';
  static const String login = '/auth/login/';
  static const String tokenRefresh = '/auth/token/refresh/';
  static const String profile = '/auth/profile/';

  // Boutiques
  static const String boutiques = '/boutiques/';
  static const String myShops = '/boutiques/my_shops/';
  static const String nearbyShops = '/boutiques/nearby/';

  // Products
  static const String products = '/products/';
  static const String searchProducts = '/products/search/';
  static const String myProducts = '/products/my_products/';

  // Stocks
  static const String stocks = '/stocks/';
  static const String stockAlerts = '/stocks/alerts/';

  // Orders
  static const String orders = '/orders/';
  static const String orderHistory = '/orders/history/';
  static const String orderStats = '/orders/stats/';

  // Payments
  static const String payments = '/payments/';
  static const String paymentHistory = '/payments/history/';

  // Reviews
  static const String reviews = '/reviews/';
}
