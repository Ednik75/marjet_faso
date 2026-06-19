import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<Product> _products = [];
  List<Product> _searchResults = [];
  List<Product> _myProducts = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  List<Product> get searchResults => _searchResults;
  List<Product> get myProducts => _myProducts;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts({String? boutiqueId, String? category}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final params = <String, String>{};
      if (boutiqueId != null) params['boutique'] = boutiqueId;
      if (category != null) params['category'] = category;
      final list = await _api.getList(ApiConfig.products, queryParams: params);
      _products = list.map((j) => Product.fromJson(j)).toList();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchProducts(String query, {String? category}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final params = <String, String>{'q': query};
      if (category != null) params['category'] = category;
      final list = await _api.getList(
        ApiConfig.searchProducts,
        queryParams: params,
      );
      _searchResults = list.map((j) => Product.fromJson(j)).toList();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMyProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final list = await _api.getList(ApiConfig.myProducts);
      _myProducts = list.map((j) => Product.fromJson(j)).toList();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<Product?> createProduct(Map<String, dynamic> data) async {
    try {
      final response = await _api.post(ApiConfig.products, body: data);
      final product = Product.fromJson(response);
      _myProducts.add(product);
      notifyListeners();
      return product;
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      await _api.put('${ApiConfig.products}$id/', body: data);
      await fetchMyProducts();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      await _api.delete('${ApiConfig.products}$id/');
      _myProducts.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
