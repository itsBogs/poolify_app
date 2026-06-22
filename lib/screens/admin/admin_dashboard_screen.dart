import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cottage_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_logo_title.dart';
import '../auth/login_screen.dart';
import 'cottage_management_screen.dart';
import 'reservation_management_screen.dart';
import 'reports_screen.dart';
import 'user_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<CottageProvider>(context, listen: false).fetchCottages();
      Provider.of<ReservationProvider>(
        context,
        listen: false,
      ).fetchAllReservations();
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final cottages = Provider.of<CottageProvider>(context);
    final reservations = Provider.of<ReservationProvider>(context);
    final users = Provider.of<UserProvider>(context);

    int pendingBookings = reservations.reservations
        .where((r) => r.status == 'pending')
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const AppLogoTitle('Admin Dashboard'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildStatCard(
                  'Reservations',
                  reservations.reservations.length.toString(),
                  Icons.book_online,
                  const Color(0xFF2E7D32),
                ),
                _buildStatCard(
                  'Cottages',
                  cottages.cottages.length.toString(),
                  Icons.house,
                  const Color(0xFF81C784),
                ),
                _buildStatCard(
                  'Total Users',
                  users.users.length.toString(),
                  Icons.people,
                  Colors.orange.shade700,
                ),
                _buildStatCard(
                  'Pending',
                  pendingBookings.toString(),
                  Icons.pending_actions,
                  const Color(0xFF1B5E20),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Menu List
            ListTile(
              leading: const Icon(Icons.people, color: Color(0xFF2E7D32)),
              title: const Text('Manage Users'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserManagementScreen()),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.house, color: Color(0xFF2E7D32)),
              title: const Text('Manage Cottages'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CottageManagementScreen(),
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.list_alt, color: Color(0xFF2E7D32)),
              title: const Text('Manage Reservations'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReservationManagementScreen(),
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Color(0xFF2E7D32)),
              title: const Text('View Reports'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
