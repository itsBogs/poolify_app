import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reservation_provider.dart';
import '../../widgets/app_logo_title.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AppLogoTitle('Business Reports')),
      body: Consumer<ReservationProvider>(
        builder: (context, provider, _) {
          final approved = provider.reservations
              .where((r) => r.status == 'approved')
              .toList();
          final totalRevenue = approved.fold<double>(
            0,
            (sum, item) => sum + item.totalPrice,
          );

          final counts = <String, int>{};
          for (var r in provider.reservations) {
            counts[r.cottageName ?? 'Unknown'] =
                (counts[r.cottageName ?? 'Unknown'] ?? 0) + 1;
          }

          var mostBooked = 'N/A';
          var maxCount = 0;
          counts.forEach((key, value) {
            if (value > maxCount) {
              maxCount = value;
              mostBooked = key;
            }
          });

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _ReportCard(
                    label: 'Total Bookings',
                    value: provider.reservations.length.toString(),
                    icon: Icons.event_note,
                    color: const Color(0xFF2E7D32),
                  ),
                  _ReportCard(
                    label: 'Approved',
                    value: approved.length.toString(),
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                  _ReportCard(
                    label: 'Revenue',
                    value: 'PHP ${totalRevenue.toStringAsFixed(0)}',
                    icon: Icons.payments_outlined,
                    color: const Color(0xFF81C784),
                  ),
                  _ReportCard(
                    label: 'Most Booked',
                    value: mostBooked,
                    icon: Icons.house_outlined,
                    color: Colors.orange,
                    wide: true,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: const Text(
                  'Revenue breakdown is based on approved reservations.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool wide;

  const _ReportCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = wide || screenWidth < 430
        ? screenWidth - 32
        : (screenWidth - 44) / 2;

    return SizedBox(
      width: cardWidth,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                foregroundColor: color,
                child: Icon(icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: wide ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
