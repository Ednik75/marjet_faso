import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/boutique.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/payment.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class AdminProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  Map<String, dynamic> _stats = {};
  List<Order> _recentOrders = [];
  List<Boutique> _recentBoutiques = [];

  List<User> _users = [];
  List<Boutique> _boutiques = [];
  List<Product> _products = [];
  List<Order> _orders = [];
  List<Payment> _payments = [];

  bool _isLoading = false;
  String? _error;

  Map<String, dynamic> get stats => _stats;
  List<Order> get recentOrders => _recentOrders;
  List<Boutique> get recentBoutiques => _recentBoutiques;

  List<User> get users => _users;
  List<Boutique> get boutiques => _boutiques;
  List<Product> get products => _products;
  List<Order> get orders => _orders;
  List<Payment> get payments => _payments;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get(ApiConfig.adminStats);
      _stats = response['stats'] ?? {};
      final recentOrdersJson = response['recent_orders'] as List? ?? [];
      final recentBoutiquesJson = response['recent_boutiques'] as List? ?? [];

      _recentOrders = recentOrdersJson.map((j) => Order.fromJson(j)).toList();
      _recentBoutiques = recentBoutiquesJson.map((j) => Boutique.fromJson(j)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.getList(ApiConfig.adminUsers);
      _users = response.map((j) => User.fromJson(j)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBoutiques() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.getList(ApiConfig.adminBoutiques);
      _boutiques = response.map((j) => Boutique.fromJson(j)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.getList(ApiConfig.adminProducts);
      _products = response.map((j) => Product.fromJson(j)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.getList(ApiConfig.adminOrders);
      _orders = response.map((j) => Order.fromJson(j)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPayments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.getList(ApiConfig.adminPayments);
      _payments = response.map((j) => Payment.fromJson(j)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveBoutique(int boutiqueId) async {
    try {
      await _api.post('${ApiConfig.adminBoutiques}$boutiqueId/approve/');
      await fetchBoutiques();
      await fetchStats();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectBoutique(int boutiqueId) async {
    try {
      await _api.post('${ApiConfig.adminBoutiques}$boutiqueId/reject/');
      await fetchBoutiques();
      await fetchStats();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBoutique(int boutiqueId) async {
    try {
      await _api.delete('${ApiConfig.adminBoutiques}$boutiqueId/');
      await fetchBoutiques();
      await fetchStats();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(int userId) async {
    try {
      await _api.delete('${ApiConfig.adminUsers}$userId/');
      await fetchUsers();
      await fetchStats();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUserRole(int userId, String role) async {
    try {
      await _api.patch('${ApiConfig.adminUsers}$userId/', body: {'role': role});
      await fetchUsers();
      await fetchStats();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(int productId) async {
    try {
      await _api.delete('${ApiConfig.adminProducts}$productId/');
      await fetchProducts();
      await fetchStats();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateOrderStatus(int orderId, String status) async {
    try {
      await _api.patch('${ApiConfig.adminOrders}$orderId/', body: {'status': status});
      await fetchOrders();
      await fetchStats();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePaymentStatus(int paymentId, String status) async {
    try {
      await _api.patch('${ApiConfig.adminPayments}$paymentId/', body: {'status': status});
      await fetchPayments();
      await fetchStats();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
