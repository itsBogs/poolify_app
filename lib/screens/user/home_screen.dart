import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cottage_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'cottage_details_screen.dart';
import '../../models/cottage_model.dart';
import '../../widgets/app_logo_title.dart';

//.\watch_live_db.bat
class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  String _searchQuery = '';
  String _filterSize = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<CottageProvider>(context, listen: false).fetchCottages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final cottageProvider = Provider.of<CottageProvider>(context);

    final filteredCottages = cottageProvider.cottages.where((c) {
      final matchesSearch = c.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      var matchesFilter = true;
      if (_filterSize == 'Small') matchesFilter = c.capacity <= 6;
      if (_filterSize == 'Medium') {
        matchesFilter = c.capacity > 6 && c.capacity <= 12;
      }
      if (_filterSize == 'Large') matchesFilter = c.capacity > 12;
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const AppLogoTitle('Poolify Resort'),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => cottageProvider.fetchCottages(),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF81C784)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Explore',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  authProvider.user != null
                                      ? 'Hi, ${authProvider.user!.name}!'
                                      : 'Guest Mode',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (authProvider.user == null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => LoginScreen(),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.login, size: 16),
                                      label: const Text('Login / Register'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: const BorderSide(
                                          color: Colors.white54,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          const CircleAvatar(
                            backgroundColor: Colors.white24,
                            child: Icon(
                              Icons.notifications,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: const InputDecoration(
                          hintText: 'Search cottages...',
                          prefixIcon: Icon(
                            Icons.search,
                            color: Color(0xFF2E7D32),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 150,
                  child: PageView(
                    children: [
                      _buildPromotionCard(
                        'kids swim free',
                        'try our new kiddie pool area',
                        const Color(0xFF81C784),
                        'assets/images/slide1.jpg',
                      ),
                      _buildPromotionCard(
                        'VIP Experience',
                        'Exclusive pool access for groups.',
                        const Color(0xFF2E7D32),
                        'assets/images/slide2.jpg',
                      ),
                      _buildPromotionCard(
                        'Adult Swim Pool',
                        'try it now.',
                        const Color(0xFF1B5E20),
                        'assets/images/slide3.jpg',
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['All', 'Small', 'Medium', 'Large'].map((size) {
                      return ChoiceChip(
                        label: Text(size),
                        selected: _filterSize == size,
                        selectedColor: const Color(0xFFF1F8E9),
                        onSelected: (selected) {
                          if (selected) setState(() => _filterSize = size);
                        },
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choose your cottage',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Find the best spot for your swim day.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => cottageProvider.fetchCottages(),
                        icon: const Icon(Icons.tune),
                        color: const Color(0xFF2E7D32),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (cottageProvider.isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (filteredCottages.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No cottages found.')),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final cottage = filteredCottages[index];
                  return Card(
                    elevation: 2,
                    clipBehavior: Clip.antiAlias,
                    margin: const EdgeInsets.only(bottom: 14),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CottageDetailsScreen(cottage: cottage),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 140,
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                color: const Color(0xFFF1F8E9),
                                child: Hero(
                                  tag: 'cottage-${cottage.id}',
                                  child: _buildCottageImage(cottage),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            cottage.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'PHP ${cottage.price.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF2E7D32),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      cottage.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _MetaChip(
                                          icon: Icons.people,
                                          label: 'Max ${cottage.capacity}',
                                        ),
                                        _MetaChip(
                                          icon: Icons.eco,
                                          label: _filterSize == 'All'
                                              ? 'Nature view'
                                              : _filterSize,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: const [
                                        Text(
                                          'View details',
                                          style: TextStyle(
                                            color: Color(0xFF2E7D32),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward,
                                          size: 16,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: cottage.status == 'available'
                                    ? Colors.green.withValues(alpha: 0.9)
                                    : Colors.red.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                cottage.status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: filteredCottages.length),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCottageImage(CottageModel cottage) {
    if (cottage.image.startsWith('http')) {
      return Image.network(
        cottage.image,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image),
      );
    }

    return Image.asset(
      cottage.image,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
    );
  }

  Widget _buildPromotionCard(
    String title,
    String subtitle,
    Color color,
    String imagePath,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.25),
            BlendMode.darken,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF81C784)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}
