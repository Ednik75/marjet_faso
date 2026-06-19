import 'package:flutter/material.dart';
import '../models/payment.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class PaymentProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<Payment> _payments = [];
  bool _isLoading = false;

  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;

  Future<Payment?> createPayment(int orderId, String method) async {
    try {
      final response = await _api.post(
        ApiConfig.payments,
        body: {'order': orderId, 'method': method},
      );
      final payment = Payment.fromJson(response);
      _payments.add(payment);
      notifyListeners();
      return payment;
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchPayments() async {
    _isLoading = true;
    notifyListeners();
    try {
      final list = await _api.getList(ApiConfig.payments);
      _payments = list.map((j) => Payment.fromJson(j)).toList();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> validatePayment(int paymentId) async {
    try {
      await _api.patch(
        '${ApiConfig.payments}$paymentId/validate_payment/',
        body: {'status': 'completed'},
      );
      await fetchPayments();
      return true;
    } catch (_) {
      return false;
    }
  }
}
