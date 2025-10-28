import 'package:flutter/material.dart';
import '../models/sunnah_item.dart';
import '../widgets/sunnah_card.dart';

class CategoryScreen extends StatefulWidget {
  final String category;
  final List<SunnahItem> initialItems;
  final Function(String) onToggle;
  final Function(SunnahItem) onShowDetail;
  final Function(String) onRefresh; // Tambah callback untuk refresh data

  const CategoryScreen({
    super.key,
    required this.category,
    required this.initialItems,
    required this.onToggle,
    required this.onShowDetail,
    required this.onRefresh,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late List<SunnahItem> items;

  @override
  void initState() {
    super.initState();
    items = widget.initialItems;
  }

  Color _getCategoryColor() {
    switch (widget.category) {
      case 'Ibadah':
        return Colors.purple;
      case 'Amalan':
        return Colors.orange;
      case 'Kebersihan':
        return Colors.green;
      case 'Adab':
        return Colors.pink;
      case 'Kebiasaan':
        return Colors.blue;
      default:
        return Colors.purple;
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.category) {
      case 'Ibadah':
        return Icons.mosque;
      case 'Amalan':
        return Icons.auto_awesome;
      case 'Kebersihan':
        return Icons.cleaning_services;
      case 'Adab':
        return Icons.favorite;
      case 'Kebiasaan':
        return Icons.access_time;
      default:
        return Icons.grid_view;
    }
  }

  void _refreshData() {
    // Panggil callback untuk ambil data terbaru
    final updatedItems = widget.onRefresh(widget.category);
    setState(() {
      items = updatedItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor();

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.6),
                  color,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sunnah ${widget.category}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Icon Category
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getCategoryIcon(),
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${items.length} Sunnah',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // List Items
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada sunnah di kategori ini',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return SunnahCard(
                        item: item,
                        onToggle: () {
                          // Panggil onToggle dari HomeScreen
                          widget.onToggle(item.id);
                          // Refresh data untuk update UI
                          _refreshData();
                        },
                        onInfo: () => widget.onShowDetail(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}