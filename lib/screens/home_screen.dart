import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sunnah_item.dart';
import '../data/sunnah_data.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/sunnah_card.dart';
import 'category_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();
  List<SunnahItem> sunnahItems = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);
      final savedData = prefs.getString('sunnah_$dateKey');

      if (savedData != null) {
        final List<dynamic> jsonData = json.decode(savedData);
        setState(() {
          sunnahItems = jsonData.map((item) => SunnahItem.fromJson(item)).toList();
        });
      } else {
        // Load data sebelumnya untuk streak
        final yesterday = selectedDate.subtract(const Duration(days: 1));
        final yesterdayKey = DateFormat('yyyy-MM-dd').format(yesterday);
        final yesterdayData = prefs.getString('sunnah_$yesterdayKey');

        List<SunnahItem> baseItems = SunnahData.getSunnahItems();

        if (yesterdayData != null) {
          final List<dynamic> jsonData = json.decode(yesterdayData);
          final yesterdayItems = jsonData.map((item) => SunnahItem.fromJson(item)).toList();

          // Update streak dari data kemarin
          for (int i = 0; i < baseItems.length; i++) {
            try {
              final yesterdayItem = yesterdayItems.firstWhere(
                (item) => item.id == baseItems[i].id,
              );
              baseItems[i] = baseItems[i].copyWith(
                streakDays: yesterdayItem.streakDays,
              );
            } catch (e) {
              // Item tidak ditemukan, pakai default
            }
          }
        }

        setState(() {
          sunnahItems = baseItems;
        });
      }
    } catch (e) {
      // Error handling
      setState(() {
        sunnahItems = SunnahData.getSunnahItems();
      });
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);
      final jsonData = sunnahItems.map((item) => item.toJson()).toList();
      await prefs.setString('sunnah_$dateKey', json.encode(jsonData));
    } catch (e) {
      // Error handling
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
    _loadData();
  }

  void _toggleCompletion(String id) async {
    setState(() {
      final index = sunnahItems.indexWhere((item) => item.id == id);
      if (index != -1) {
        final item = sunnahItems[index];
        final newCompleted = !item.isCompleted;
        
        // Update streak
        int newStreak = item.streakDays;
        if (newCompleted) {
          newStreak += 1;
        } else {
          newStreak = newStreak > 0 ? newStreak - 1 : 0;
        }

        sunnahItems[index] = item.copyWith(
          isCompleted: newCompleted,
          streakDays: newStreak,
        );
      }
    });
    await _saveData();
  }

  void _showDetail(SunnahItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(item: item),
      ),
    );
  }

  void _showCalendarDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pilih Tanggal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CalendarDatePicker(
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  onDateChanged: (DateTime date) {
                    Navigator.pop(context);
                    _onDateSelected(date);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAllSunnah() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.shade300,
                      Colors.purple.shade500,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Semua Sunnah',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: sunnahItems.length,
                  itemBuilder: (context, index) {
                    final item = sunnahItems[index];
                    return SunnahCard(
                      item: item,
                      onToggle: () {
                        _toggleCompletion(item.id);
                        Navigator.pop(context);
                      },
                      onInfo: () {
                        Navigator.pop(context);
                        _showDetail(item);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<SunnahItem> _getCategoryItems(String category) {
    return sunnahItems.where((item) => item.category == category).toList();
  }

  void _navigateToCategory(String category) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryScreen(
          category: category,
          initialItems: _getCategoryItems(category),
          onToggle: _toggleCompletion,
          onShowDetail: _showDetail,
          onRefresh: _getCategoryItems,
        ),
      ),
    );
    // Reload data setelah kembali dari CategoryScreen
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header dengan gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.shade300,
                  Colors.purple.shade500,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Header Text
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Assalamualaikum, Hasna!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('EEEE, d MMMM yyyy').format(selectedDate),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            color: Colors.purple.shade500,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Calendar
                  CalendarWidget(
                    selectedDate: selectedDate,
                    onDateSelected: _onDateSelected,
                    onShowCalendar: _showCalendarDialog,
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: Column(
              children: [
                // Motivational Quote Card
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.purple.shade50,
                        Colors.pink.shade50,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.purple.shade100,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          '✨',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Setiap kali kamu menandai satu sunnah itu tanda cintamu kepada Allah! 💛',
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: Colors.purple.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Header Sunnah Routine
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sunnah Routine',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showAllSunnah,
                        child: Text(
                          'See all',
                          style: TextStyle(
                            color: Colors.purple.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // List Sunnah Items
                Expanded(
                  child: sunnahItems.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: sunnahItems.length,
                          itemBuilder: (context, index) {
                            final item = sunnahItems[index];
                            return SunnahCard(
                              item: item,
                              onToggle: () => _toggleCompletion(item.id),
                              onInfo: () => _showDetail(item),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // Bottom Category Buttons
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCategoryButton(
                  icon: Icons.mosque,
                  label: 'Ibadah',
                  color: Colors.purple,
                  onTap: () => _navigateToCategory('Ibadah'),
                ),
                _buildCategoryButton(
                  icon: Icons.auto_awesome,
                  label: 'Amalan',
                  color: Colors.orange,
                  onTap: () => _navigateToCategory('Amalan'),
                ),
                _buildCategoryButton(
                  icon: Icons.cleaning_services,
                  label: 'Kebersihan',
                  color: Colors.green,
                  onTap: () => _navigateToCategory('Kebersihan'),
                ),
                _buildCategoryButton(
                  icon: Icons.favorite,
                  label: 'Adab',
                  color: Colors.pink,
                  onTap: () => _navigateToCategory('Adab'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}