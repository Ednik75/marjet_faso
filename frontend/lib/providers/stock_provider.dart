import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class StockProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<Stock> _stocks = [];
  List<Stock> _alerts = [];
  bool _isLoading = false;

  List<Stock> get stocks => _stocks;
  List<Stock> get alerts => _alerts;
  bool get isLoading => _isLoading;

  Future<void> fetchStocks() async {
    _isLoading = true;
    notifyListeners();
    try {
      final list = await _api.getList(ApiConfig.stocks);
      _stocks = list.map((j) => Stock.fromJson(j)).toList();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAlerts() async {
    try {
      final list = await _api.getList(ApiConfig.stockAlerts);
      _alerts = list.map((j) => Stock.fromJson(j)).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> recordMovement(int stockId, StockMovement movement) async {
    try {
      await _api.post(
        '${ApiConfig.stocks}$stockId/movement/',
        body: movement.toJson(),
      );
      await fetchStocks();
      return true;
    } catch (_) {
      return false;
    }
  }
}
