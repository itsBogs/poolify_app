import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reservation_provider.dart';
import '../../widgets/app_logo_title.dart';

class ReservationManagementScreen extends StatefulWidget {
  const ReservationManagementScreen({super.key});

  @override
  State<ReservationManagementScreen> createState() =>
      _ReservationManagementScreenState();
}

class _ReservationManagementScreenState
    extends State<ReservationManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<ReservationProvider>(
        context,
        listen: false,
      ).fetchAllReservations();
    });
  }

  void _showReceipt(String receiptPath) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('User Payment Receipt'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AppLogoTitle('Reservations')),
      body: Consumer<ReservationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.reservations.isEmpty) {
            return const Center(child: Text('No reservations yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.reservations.length,
            itemBuilder: (context, index) {
              final res = provider.reservations[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 82,
                              height: 82,
                              color: const Color(0xFFF1F8E9),
                              padding: const EdgeInsets.all(6),
                              child: Image.asset(
                                res.cottageImage ?? '',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  res.cottageName ?? 'Cottage',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'User: ${res.userName}\nDate: ${res.reservationDate}\nSlot: ${res.timeSlot}',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'PHP ${res.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Downpayment Actions:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                ChoiceChip(
                                  label: const Text('Pending'),
                                  selected: res.paymentStatus == 'Pending',
                                  onSelected: (val) => provider
                                      .updatePaymentStatus(res.id!, 'Pending'),
                                ),
                                ChoiceChip(
                                  label: const Text('Received'),
                                  selected: res.paymentStatus == 'Received',
                                  selectedColor: Colors.green.shade200,
                                  onSelected: (val) => provider
                                      .updatePaymentStatus(res.id!, 'Received'),
                                ),
                                ChoiceChip(
                                  label: const Text('Not Received'),
                                  selected: res.paymentStatus == 'Not Received',
                                  selectedColor: Colors.red.shade200,
                                  onSelected: (val) =>
                                      provider.updatePaymentStatus(
                                        res.id!,
                                        'Not Received',
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (res.paymentReceipt != null)
                            IconButton(
                              onPressed: () =>
                                  _showReceipt(res.paymentReceipt!),
                              icon: const Icon(
                                Icons.receipt_long,
                                color: Color(0xFF2E7D32),
                              ),
                              tooltip: 'View Receipt',
                            ),
                        ],
                      ),
                      const Divider(),
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (res.status == 'pending') ...[
                            TextButton(
                              onPressed: () =>
                                  provider.updateStatus(res.id!, 'rejected'),
                              child: const Text(
                                'REJECT',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  provider.updateStatus(res.id!, 'approved'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text('APPROVE'),
                            ),
                          ] else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: res.status == 'approved'
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                res.status.toUpperCase(),
                                style: TextStyle(
                                  color: res.status == 'approved'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.grey),
                            onPressed: () =>
                                provider.deleteReservation(res.id!),
                          ),
                        ],
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
