import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/cottage_model.dart';
import 'dart:async'; // Add this

class CottageProvider with ChangeNotifier {
  List<CottageModel> _cottages = [];
  bool _isLoading = false;
  StreamSubscription? _updateSubscription; // Add this

  List<CottageModel> get cottages => _cottages;
  bool get isLoading => _isLoading;

  CottageProvider() {
    _listenToUpdates();
  }

  void _listenToUpdates() {
    _updateSubscription = DatabaseHelper().databaseUpdates.listen((table) {
      if (table == 'cottages') {
        fetchCottages();
      }
    });
  }

  @override
  void dispose() {
    _updateSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchCottages() async {
    _isLoading = true;
    notifyListeners();
    _cottages = await DatabaseHelper().getCottages();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addCottage(CottageModel cottage) async {
    int id = await DatabaseHelper().addCottage(cottage);
    if (id > 0) {
      await fetchCottages();
      return true;
    }
    return false;
  }

  Future<bool> updateCottage(CottageModel cottage) async {
    int count = await DatabaseHelper().updateCottage(cottage);
    if (count > 0) {
      await fetchCottages();
      return true;
    }
    return false;
  }

  Future<bool> updateCottageStatus(CottageModel cottage, String status) async {
    return updateCottage(cottage.copyWith(status: status));
  }

  Future<bool> deleteCottage(int id) async {
    int count = await DatabaseHelper().deleteCottage(id);
    if (count > 0) {
      await fetchCottages();
      return true;
    }
    return false;
  }
}
