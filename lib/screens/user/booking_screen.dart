import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/cottage_model.dart';
import '../../models/reservation_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../widgets/app_logo_title.dart';

class BookingScreen extends StatefulWidget {
  final CottageModel cottage;

  const BookingScreen({super.key, required this.cottage});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  String _selectedTimeSlot = 'Day Swim (8AM - 5PM)';
  int _guests = 1;

  final List<String> _timeSlots = [
    'Day Swim (8AM - 5PM)',
    'Night Swim (6PM - 2AM)',
    'Overnight (8AM - 6AM next day)',
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _confirmBooking() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a date')));
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reservationProvider = Provider.of<ReservationProvider>(
      context,
      listen: false,
    );
    final user = authProvider.user;

    if (user?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login before booking.')),
      );
      return;
    }

    ReservationModel reservation = ReservationModel(
      userId: user!.id!,
      cottageId: widget.cottage.id!,
      reservationDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      timeSlot: _selectedTimeSlot,
      guests: _guests,
      totalPrice:
          widget.cottage.price, // Simplifying: base price for the cottage
      status: 'pending',
      createdAt: DateTime.now().toString(),
    );

    bool success = await reservationProvider.addReservation(reservation);

    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Booking Successful!'),
          content: const Text(
            'Your reservation is pending approval from the admin.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to details
                Navigator.of(context).pop(); // Go back to home
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to book. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final downpayment = widget.cottage.price * 0.10;

    return Scaffold(
      appBar: AppBar(
        title: const AppLogoTitle('Book Reservation'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.cottage.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Select Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFC8E6C9)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF2E7D32),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedDate == null
                              ? 'Touch to select date'
                              : DateFormat(
                                  'MMM dd, yyyy',
                                ).format(_selectedDate!),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'Select Time Slot',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedTimeSlot,
                items: _timeSlots
                    .map(
                      (slot) => DropdownMenuItem(
                        value: slot,
                        child: Text(slot, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedTimeSlot = val!),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF81C784)),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Text(
                'Number of Guests (Max: ${widget.cottage.capacity})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _guests > 1
                        ? () => setState(() => _guests--)
                        : null,
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  Text(
                    '$_guests',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _guests < widget.cottage.capacity
                        ? () => setState(() => _guests++)
                        : null,
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),

              const Divider(height: 40),

              const Text(
                'Downpayment (GCash)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Required downpayment is 10% of the cottage price: PHP ${downpayment.toStringAsFixed(0)}. Admin will approve once payment is confirmed.',
                style: const TextStyle(color: Colors.grey, height: 1.35),
              ),
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFC8E6C9)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/gcashqr.jpg', // User will replace this
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_2,
                                size: 50,
                                color: Color(0xFF81C784),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'GCash QR Code Here',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Total Price',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          'PHP ${widget.cottage.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 17,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 22),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Downpayment Due (10%)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          'PHP ${downpayment.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xFF81C784),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Remaining balance is payable at the resort.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'CONFIRM RESERVATION',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
