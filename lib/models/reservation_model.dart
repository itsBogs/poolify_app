class ReservationModel {
  final int? id;
  final int userId;
  final int cottageId;
  final String reservationDate;
  final String timeSlot;
  final int guests;
  final double totalPrice;
  final String status;
  final String paymentStatus;
  final String? paymentReceipt;
  final String createdAt;

  // Extra fields for displaying in UI
  final String? userName;
  final String? cottageName;
  final String? cottageImage;

  ReservationModel({
    this.id,
    required this.userId,
    required this.cottageId,
    required this.reservationDate,
    required this.timeSlot,
    required this.guests,
    required this.totalPrice,
    required this.status,
    this.paymentStatus = 'Pending',
    this.paymentReceipt,
    required this.createdAt,
    this.userName,
    this.cottageName,
    this.cottageImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'cottage_id': cottageId,
      'reservation_date': reservationDate,
      'time_slot': timeSlot,
      'guests': guests,
      'total_price': totalPrice,
      'status': status,
      'payment_status': paymentStatus,
      'payment_receipt': paymentReceipt,
      'created_at': createdAt,
    };
  }

  factory ReservationModel.fromMap(Map<String, dynamic> map) {
    return ReservationModel(
      id: map['id'],
      userId: map['user_id'],
      cottageId: map['cottage_id'],
      reservationDate: map['reservation_date'],
      timeSlot: map['time_slot'],
      guests: map['guests'],
      totalPrice: map['total_price'].toDouble(),
      status: map['status'],
      paymentStatus: map['payment_status'] ?? 'Pending',
      paymentReceipt: map['payment_receipt'],
      createdAt: map['created_at'],
      userName: map['userName'],
      cottageName: map['cottageName'],
      cottageImage: map['cottageImage'],
    );
  }
}
