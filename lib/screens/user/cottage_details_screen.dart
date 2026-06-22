import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cottage_model.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'booking_screen.dart';

class CottageDetailsScreen extends StatelessWidget {
  final CottageModel cottage;

  const CottageDetailsScreen({super.key, required this.cottage});

  void _handleBooking(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.user == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Required'),
          content: const Text(
            'You need an account to book a cottage. Would you like to login or register now?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              child: const Text('LOGIN'),
            ),
          ],
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookingScreen(cottage: cottage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'cottage-${cottage.id}',
              child: Container(
                height: 220,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Color(0xFFF1F8E9)),
                child: _buildCottageImage(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          cottage.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'PHP ${cottage.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 22,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 18,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people, color: Colors.grey.shade600),
                          const SizedBox(width: 5),
                          Text('Capacity: ${cottage.capacity} Guests'),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: cottage.status == 'available'
                                ? const Color(0xFF81C784)
                                : Colors.red,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            cottage.status == 'available'
                                ? 'Available'
                                : 'Unavailable',
                            style: TextStyle(
                              color: cottage.status == 'available'
                                  ? const Color(0xFF81C784)
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 40),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    cottage.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade800,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: cottage.status == 'available'
                          ? () => _handleBooking(context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'BOOK NOW',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCottageImage() {
    if (cottage.image.startsWith('http')) {
      return Image.network(
        cottage.image,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 90, color: Color(0xFF81C784)),
      );
    }

    return Image.asset(
      cottage.image,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.pool, size: 90, color: Color(0xFF81C784)),
    );
  }
}
