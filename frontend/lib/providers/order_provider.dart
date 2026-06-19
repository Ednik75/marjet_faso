import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<Order> _orders = [];
  List<Order> _orderHistory = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = false;

  List<Order> get orders => _orders;
  List<Order> get orderHistory => _orderHistory;
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;

  // Cart
  final List<OrderItem> _cartItems = [];
  int? _cartBoutiqueId;

  List<OrderItem> get cartItems => _cartItems;
  int? get cartBoutiqueId => _cartBoutiqueId;

  double get cartTotal =>
      _cartItems.fold(0, (sum, item) => sum + (item.unitPrice * item.quantity));

  void addToCart(
    int productId,
    String productName,
    double price,
    int boutiqueId,
  ) {
    if (_cartBoutiqueId != null && _cartBoutiqueId != boutiqueId) {
      _cartItems.clear();
    }
    _cartBoutiqueId = boutiqueId;

    final existingIndex = _cartItems.indexWhere(
      (i) => i.productId == productId,
    );
    if (existingIndex >= 0) {
      final existing = _cartItems[existingIndex];
      _cartItems[existingIndex] = OrderItem(
        productId: productId,
        productName: productName,
        quantity: existing.quantity + 1,
        unitPrice: price,
        subtotal: price * (existing.quantity + 1),
      );
    } else {
      _cartItems.add(
        OrderItem(
          productId: productId,
          productName: productName,
          quantity: 1,
          unitPrice: price,
          subtotal: price,
        ),
      );
    }
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _cartItems.removeWhere((i) => i.productId == productId);
    if (_cartItems.isEmpty) _cartBoutiqueId = null;
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _cartBoutiqueId = null;
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    final index = _cartItems.indexWhere((i) => i.productId == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        removeFromCart(productId);
      } else {
        final item = _cartItems[index];
        _cartItems[index] = OrderItem(
          productId: productId,
          productName: item.productName,
          quantity: quantity,
          unitPrice: item.unitPrice,
          subtotal: item.unitPrice * quantity,
        );
        notifyListeners();
      }
    }
  }

  Future<Order?> placeOrder(String deliveryAddress, String notes) async {
    if (_cartItems.isEmpty || _cartBoutiqueId == null) return null;
    try {
      final response = await _api.post(
        ApiConfig.orders,
        body: {
          'boutique': _cartBoutiqueId,
          'delivery_address': deliveryAddress,
          'notes': notes,
          'items': _cartItems.map((i) => i.toJson()).toList(),
        },
      );
      final order = Order.fromJson(response);
      clearCart();
      await fetchOrders();
      return order;
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final list = await _api.getList(ApiConfig.orders);
      _orders = list.map((j) => Order.fromJson(j)).toList();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchOrderHistory() async {
    try {
      final list = await _api.getList(ApiConfig.orderHistory);
      _orderHistory = list.map((j) => Order.fromJson(j)).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> updateOrderStatus(int orderId, String status) async {
    try {
      await _api.patch(
        '${ApiConfig.orders}$orderId/update_status/',
        body: {'status': status},
      );
      await fetchOrders();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> fetchStats() async {
    try {
      final response = await _api.get(ApiConfig.orderStats);
      _stats = response;
      notifyListeners();
    } catch (_) {}
  }
}
