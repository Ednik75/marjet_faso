import 'package:flutter/material.dart';
import '../models/boutique.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class BoutiqueProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<Boutique> _boutiques = [];
  List<Boutique> _nearbyBoutiques = [];
  List<Boutique> _myBoutiques = [];
  bool _isLoading = false;

  List<Boutique> get boutiques => _boutiques;
  List<Boutique> get nearbyBoutiques => _nearbyBoutiques;
  List<Boutique> get myBoutiques => _myBoutiques;
  bool get isLoading => _isLoading;

  Future<void> fetchBoutiques() async {
    _isLoading = true;
    notifyListeners();
    try {
      final list = await _api.getList(ApiConfig.boutiques);
      _boutiques = list.map((j) => Boutique.fromJson(j)).toList();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchNearby(double lat, double lng, {double radius = 10}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final list = await _api.getList(
        ApiConfig.nearbyShops,
        queryParams: {
          'lat': lat.toString(),
          'lng': lng.toString(),
          'radius': radius.toString(),
        },
      );
      _nearbyBoutiques = list.map((j) => Boutique.fromJson(j)).toList();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMyShops() async {
    _isLoading = true;
    notifyListeners();
    try {
      final list = await _api.getList(ApiConfig.myShops);
      _myBoutiques = list.map((j) => Boutique.fromJson(j)).toList();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<Boutique?> createBoutique(Map<String, dynamic> data) async {
    try {
      final response = await _api.post(ApiConfig.boutiques, body: data);
      final boutique = Boutique.fromJson(response);
      _myBoutiques.add(boutique);
      notifyListeners();
      return boutique;
    } catch (_) {
      return null;
    }
  }
}
