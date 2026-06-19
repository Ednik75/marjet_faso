class ApiConfig {
  static const String _environmentBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String _androidEmulatorBaseUrl = 'http://10.0.2.2:8000/api';
  static const String _webLocalBaseUrl = 'http://localhost:8000/api';

  static String get baseUrl =>
      _environmentBaseUrl.isNotEmpty ? _environmentBaseUrl : _androidEmulatorBaseUrl;

  static String get webBaseUrl =>
      _environmentBaseUrl.isNotEmpty ? _environmentBaseUrl : _webLocalBaseUrl;

  static String get effectiveBaseUrl {
    if (_environmentBaseUrl.isNotEmpty) {
      return _environmentBaseUrl;
    }

    return const bool.fromEnvironment('dart.library.html')
        ? _webLocalBaseUrl
        : _androidEmulatorBaseUrl;
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
