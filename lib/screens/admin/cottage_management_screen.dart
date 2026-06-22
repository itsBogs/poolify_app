import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cottage_provider.dart';
import '../../widgets/app_logo_title.dart';
import 'add_edit_cottage_screen.dart';

class CottageManagementScreen extends StatefulWidget {
  const CottageManagementScreen({super.key});

  @override
  State<CottageManagementScreen> createState() =>
      _CottageManagementScreenState();
}

class _CottageManagementScreenState extends State<CottageManagementScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: const AppLogoTitle('Cottages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEditCottageScreen()),
            ),
          ),
        ],
      ),
      body: Consumer<CottageProvider>(
        builder: (context, provider, _) {
          if (provider.cottages.isEmpty) {
            return const Center(child: Text('No cottages yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.cottages.length,
            itemBuilder: (context, index) {
              final cottage = provider.cottages[index];
              final isAvailable = cottage.status == 'available';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 88,
                          height: 88,
                          color: const Color(0xFFF1F8E9),
                          padding: const EdgeInsets.all(6),
                          child: Image.asset(
                            cottage.image,
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
                              cottage.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'PHP ${cottage.price.toStringAsFixed(0)} | Max ${cottage.capacity}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _StatusBadge(isAvailable: isAvailable),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Available',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    Switch(
                                      value: isAvailable,
                                      activeThumbColor: const Color(0xFF81C784),
                                      onChanged: (value) {
                                        provider.updateCottageStatus(
                                          cottage,
                                          value ? 'available' : 'unavailable',
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Color(0xFF2E7D32),
                            ),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddEditCottageScreen(cottage: cottage),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete Cottage?'),
                                  content: const Text(
                                    'Are you sure you want to remove this listing?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        provider.deleteCottage(cottage.id!);
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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

class _StatusBadge extends StatelessWidget {
  final bool isAvailable;

  const _StatusBadge({required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    final color = isAvailable ? const Color(0xFF81C784) : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        isAvailable ? 'AVAILABLE' : 'UNAVAILABLE',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
