import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/reservation_model.dart';
import 'dart:async'; // Add this

class ReservationProvider with ChangeNotifier {
  List<ReservationModel> _reservations = [];
  List<ReservationModel> _userReservations = [];
  bool _isLoading = false;
  StreamSubscription? _updateSubscription; // Add this

  List<ReservationModel> get reservations => _reservations;
  List<ReservationModel> get userReservations => _userReservations;
  bool get isLoading => _isLoading;

  ReservationProvider() {
    _listenToUpdates();
  }

  void _listenToUpdates() {
    _updateSubscription = DatabaseHelper().databaseUpdates.listen((table) {
      if (table == 'reservations') {
        fetchAllReservations();
        // Option: refresh user reservations if we have a userId
      }
    });
  }

  @override
  void dispose() {
    _updateSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchAllReservations() async {
    _isLoading = true;
    notifyListeners();
    _reservations = await DatabaseHelper().getAllReservations();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUserReservations(int userId) async {
    _isLoading = true;
    notifyListeners();
    _userReservations = await DatabaseHelper().getUserReservations(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addReservation(ReservationModel reservation) async {
    int id = await DatabaseHelper().addReservation(reservation);
    if (id > 0) {
      await fetchUserReservations(reservation.userId);
      _reservations = await DatabaseHelper().getAllReservations();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updateStatus(int id, String status) async {
    int count = await DatabaseHelper().updateReservationStatus(id, status);
    if (count > 0) {
      await fetchAllReservations();
      return true;
    }
    return false;
  }

  Future<bool> updatePaymentStatus(int id, String paymentStatus) async {
    int count = await DatabaseHelper().updatePaymentStatus(id, paymentStatus);
    if (count > 0) {
      await fetchAllReservations();
      return true;
    }
    return false;
  }

  Future<bool> updatePaymentReceipt(int id, String? receiptPath) async {
    int count = await DatabaseHelper().updateReservationReceipt(
      id,
      receiptPath,
    );
    if (count > 0) {
      await fetchAllReservations();
      return true;
    }
    return false;
  }

  Future<bool> deleteReservation(int id) async {
    int count = await DatabaseHelper().deleteReservation(id);
    if (count > 0) {
      await fetchAllReservations();
      return true;
    }
    return false;
  }
}
