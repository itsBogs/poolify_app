import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_logo_title.dart';
import '../auth/login_screen.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  int? _loadedUserId;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadReservationsForCurrentUser);
  }

  Future<void> _uploadReceipt(int reservationId) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (mounted) {
        final provider = Provider.of<ReservationProvider>(
          context,
          listen: false,
        );
        await provider.updatePaymentReceipt(reservationId, pickedFile.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Receipt uploaded successfully.')),
          );
          _loadReservationsForCurrentUser();
        }
      }
    }
  }

  void _showReceipt(String receiptPath) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Payment Receipt'),
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(File(receiptPath), fit: BoxFit.contain),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = Provider.of<AuthProvider>(context).user?.id;
    if (userId != null && userId != _loadedUserId) {
      Future.microtask(_loadReservationsForCurrentUser);
    }
  }

  Future<void> _loadReservationsForCurrentUser() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    if (userId == null) return;

    _loadedUserId = userId;
    await Provider.of<ReservationProvider>(
      context,
      listen: false,
    ).fetchUserReservations(userId);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (auth.user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const AppLogoTitle('My Reservations'),
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 76,
                  color: Color(0xFF81C784),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Please login to see your reservations.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(180, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('LOGIN / REGISTER'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const AppLogoTitle('My Reservations'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF81C784)),
            );
          }
          if (provider.userReservations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note, size: 80, color: Color(0xFF81C784)),
                  SizedBox(height: 10),
                  Text(
                    'No reservations found.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: provider.userReservations.length,
            itemBuilder: (context, index) {
              final reservation = provider.userReservations[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              reservation.cottageName ?? 'Cottage',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'PHP ${reservation.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Date: ${reservation.reservationDate}'),
                      Text(
                        'Time: ${reservation.timeSlot}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _StatusPill(
                            label: reservation.status.toUpperCase(),
                            color: reservation.status == 'approved'
                                ? const Color(0xFF2E7D32)
                                : reservation.status == 'rejected'
                                ? Colors.red
                                : Colors.orange,
                          ),
                          _StatusPill(
                            label:
                                'PAYMENT ${reservation.paymentStatus.toUpperCase()}',
                            color: reservation.paymentStatus == 'Received'
                                ? Colors.green.shade700
                                : reservation.paymentStatus == 'Not Received'
                                ? Colors.red.shade700
                                : Colors.orange.shade900,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (reservation.paymentReceipt != null)
                        OutlinedButton.icon(
                          onPressed: () =>
                              _showReceipt(reservation.paymentReceipt!),
                          icon: const Icon(Icons.receipt_long, size: 18),
                          label: const Text('VIEW RECEIPT'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2E7D32),
                            side: const BorderSide(color: Color(0xFF2E7D32)),
                          ),
                        )
                      else if (reservation.paymentStatus != 'Received')
                        ElevatedButton.icon(
                          onPressed: () => _uploadReceipt(reservation.id!),
                          icon: const Icon(Icons.upload_file, size: 18),
                          label: const Text('UPLOAD GCASH RECEIPT'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
