import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sunnah_item.dart';
import '../services/islamic_api_service.dart';
import '../services/sunnah_api_service.dart';
import '../services/profile_service.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/sunnah_card.dart';
import 'category_screen.dart';
import 'detail_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  List<SunnahItem> sunnahItems = [];
  final IslamicApiService _apiService = IslamicApiService();
  final SunnahApiService _sunnahService = SunnahApiService();
  final ProfileService _profileService = ProfileService();
  final TextEditingController _searchController = TextEditingController();
  
  IslamicQuote? _dailyQuote;
  bool _isLoadingQuote = true;
  bool _isLoadingSunnah = true;
  String? _errorMessage;
  String? _userName;
  String? _userPhoto;
  bool _isSearching = false;
  String _searchQuery = '';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadProfile();
    _loadData();
    _loadDailyContent();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final name = await _profileService.getName();
    final photo = await _profileService.getPhoto();
    
    setState(() {
      _userName = name;
      _userPhoto = photo;
    });
  }

  void _navigateToProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          onProfileUpdated: () {
            _loadProfile();
          },
        ),
      ),
    );
  }

  Future<void> _loadDailyContent() async {
    setState(() {
      _isLoadingQuote = true;
    });

    try {
      _dailyQuote = await _apiService.getRandomQuote();
      
      setState(() {
        _isLoadingQuote = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingQuote = false;
        _dailyQuote = IslamicQuote(
          text: 'Sesunggahnya bersama kesulitan ada kemudahan.',
          author: 'QS. Al-Insyirah: 6',
        );
      });
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingSunnah = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);
      final savedData = prefs.getString('sunnah_$dateKey');

      if (savedData != null) {
        final List<dynamic> jsonData = json.decode(savedData);
        setState(() {
          sunnahItems = jsonData.map((item) => SunnahItem.fromJson(item)).toList();
          _isLoadingSunnah = false;
        });
      } else {
        await _createDataForDate(dateKey);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data: ${e.toString()}';
        _isLoadingSunnah = false;
      });
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> _createDataForDate(String dateKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedDateTime = DateFormat('yyyy-MM-dd').parse(dateKey);
      
      final baseItems = await _sunnahService.fetchAllSunnahItems();
      
      final yesterday = selectedDateTime.subtract(const Duration(days: 1));
      final yesterdayKey = DateFormat('yyyy-MM-dd').format(yesterday);
      final yesterdayData = prefs.getString('sunnah_$yesterdayKey');

      List<SunnahItem> todayItems = [];

      if (yesterdayData != null) {
        final List<dynamic> jsonData = json.decode(yesterdayData);
        final yesterdayItems = jsonData.map((item) => SunnahItem.fromJson(item)).toList();

        for (var baseItem in baseItems) {
          try {
            final yesterdayItem = yesterdayItems.firstWhere(
              (item) => item.id == baseItem.id,
            );
            
            if (yesterdayItem.isCompleted) {
              todayItems.add(baseItem.copyWith(
                streakDays: yesterdayItem.streakDays,
                isCompleted: false,
              ));
            } else {
              todayItems.add(baseItem.copyWith(
                streakDays: 0,
                isCompleted: false,
              ));
            }
          } catch (e) {
            todayItems.add(baseItem.copyWith(
              streakDays: 0,
              isCompleted: false,
            ));
          }
        }
      } else {
        todayItems = baseItems.map((item) => item.copyWith(
          streakDays: 0,
          isCompleted: false,
        )).toList();
      }

      setState(() {
        sunnahItems = todayItems;
        _isLoadingSunnah = false;
      });
      
      final jsonData = sunnahItems.map((item) => item.toJson()).toList();
      await prefs.setString('sunnah_$dateKey', json.encode(jsonData));
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal membuat data: ${e.toString()}';
        _isLoadingSunnah = false;
      });
      debugPrint('Error creating data for date: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);
      final jsonData = sunnahItems.map((item) => item.toJson()).toList();
      await prefs.setString('sunnah_$dateKey', json.encode(jsonData));
    } catch (e) {
      debugPrint('Error saving data: $e');
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
        
        int newStreak = item.streakDays;
        if (newCompleted) {
          newStreak = item.streakDays + 1;
        } else {
          newStreak = item.streakDays > 0 ? item.streakDays - 1 : 0;
        }

        sunnahItems[index] = item.copyWith(
          isCompleted: newCompleted,
          streakDays: newStreak,
        );
        
        if (newCompleted && newStreak % 10 == 0 && newStreak > 0) {
          _showStreakCelebration(item, newStreak);
        }
      }
    });
    await _saveData();
  }

  void _showStreakCelebration(SunnahItem item, int streak) {
    final starCount = streak ~/ 10;
    final stars = '⭐' * starCount;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(35),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFF8F0),
                  Color(0xFFFFF0E6),
                  Color(0xFFFFE8DC),
                ],
              ),
              borderRadius: BorderRadius.circular(59),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFFFD4B8).withOpacity(0.3),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Text(item.icon, style: const TextStyle(fontSize: 56)),
                ),
                const SizedBox(height: 24),
                Text(
                  stars,
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  'Masha Allah! 🎉',
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD4A574),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$streak Hari Berturut-turut',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD4A574),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Inter',
                          color: Color(0xFF8B7B6F),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 54),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFFD4A574),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Alhamdulillah ✨',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<SunnahItem> _getTopStreaks() {
    final sorted = List<SunnahItem>.from(sunnahItems)
      ..sort((a, b) => b.streakDays.compareTo(a.streakDays));
    final filtered = sorted.where((item) => item.streakDays >= 10).toList();
    return filtered.take(3).toList();
  }

  void _showDetail(SunnahItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailScreen(item: item)),
    );
  }

  void _showCalendarDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih Tanggal',
                      style: TextStyle(
                        fontSize: 20, 
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600
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
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Color(0xFFFFFBF8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Color(0xFFE8DFD6),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Text(
                      'Semua Sunnah',
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A4238),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
    _loadData();
  }

  int _getCompletedCount() {
    return sunnahItems.where((item) => item.isCompleted).length;
  }

  Future<void> _refreshData() async {
    _sunnahService.clearCache();
    _apiService.clearCache();
    await _loadData();
    await _loadDailyContent();
  }

  Map<String, int> _getCategoryCount() {
    final Map<String, int> counts = {};
    for (var item in sunnahItems) {
      counts[item.category] = (counts[item.category] ?? 0) + 1;
    }
    return counts;
  }

  // Filter sunnah berdasarkan search query
  List<SunnahItem> _getFilteredSunnahItems() {
    if (_searchQuery.isEmpty) {
      return sunnahItems;
    }
    
    final lowerQuery = _searchQuery.toLowerCase();
    return sunnahItems.where((item) {
      return item.title.toLowerCase().contains(lowerQuery) ||
             item.subtitle.toLowerCase().contains(lowerQuery) ||
             item.category.toLowerCase().contains(lowerQuery) ||
             item.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _getCompletedCount();
    final totalCount = sunnahItems.length;
    final progressPercentage = totalCount > 0 ? completedCount / totalCount : 0.0;
    final topStreaks = _getTopStreaks();

    return Scaffold(
      backgroundColor: Color(0xFFFFFBF8),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Color(0xFFB8A5D6),
        child: Column(
          children: [
            Flexible(
              child: _buildModernHeader(),
            ),
            Expanded(
              child: _buildContent(completedCount, totalCount, progressPercentage, topStreaks),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    final displayName = _userName ?? 'Sobat Muslim';
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB8A5D6),
            Color(0xFFCCBFE0),
            Color(0xFFE0D9EA),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFB8A5D6).withOpacity(0.12),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: _isSearching ? _buildSearchBar() : _buildHeaderContent(displayName),
            ),
            if (!_isSearching) ...[
              CalendarWidget(
                selectedDate: selectedDate,
                onDateSelected: _onDateSelected,
                onShowCalendar: _showCalendarDialog,
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderContent(String displayName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assalamualaikum 🌙',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayName,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                DateFormat('EEEE, d MMM yyyy').format(selectedDate),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        // Search Button
        GestureDetector(
          onTap: _startSearch,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.search_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _navigateToProfile,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white,
              backgroundImage: _userPhoto != null
                  ? MemoryImage(base64Decode(_userPhoto!))
                  : null,
              child: _userPhoto == null
                  ? Text(
                      '👤',
                      style: TextStyle(fontSize: 26),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: TextStyle(
                color: Color(0xFF4A4238),
                fontSize: 16,
                fontFamily: 'Inter',
              ),
              decoration: InputDecoration(
                hintText: 'Cari sunnah...',
                hintStyle: TextStyle(
                  color: Color(0xFFB8B5C3),
                  fontFamily: 'Inter',
                ),
                border: InputBorder.none,
                icon: Icon(
                  Icons.search_rounded,
                  color: Color(0xFFB8A5D6),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: Color(0xFFB8B5C3),
                        ),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _stopSearch,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(int completedCount, int totalCount, double progressPercentage, List<SunnahItem> topStreaks) {
    if (_errorMessage != null && sunnahItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Color(0xFFFFEEEE),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline, size: 56, color: Color(0xFFD4A5A5)),
              ),
              const SizedBox(height: 24),
              Text(
                'Terjadi Kesalahan',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A4238),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14, 
                  fontFamily: 'Inter',
                  color: Color(0xFF8B7B6F)
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _refreshData,
                icon: const Icon(Icons.refresh_rounded),
                label: Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB8A5D6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoadingSunnah) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFB8A5D6),
                    Color(0xFFCCBFE0),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Memuat data...',
              style: TextStyle(
                color: Color(0xFFB8A5D6),
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 24),
            if (!_isSearching) ...[
              _buildProgressCard(completedCount, totalCount, progressPercentage),
              const SizedBox(height: 16),
              if (topStreaks.isNotEmpty) ...[
                _buildTopStreaksCard(topStreaks),
                const SizedBox(height: 16),
              ],
              _buildQuoteCard(),
              const SizedBox(height: 24),
              _buildCategoriesSection(),
              const SizedBox(height: 24),
            ],
            _buildSunnahList(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    List<Map<String, dynamic>> categories = [
      {'name': 'Ibadah', 'icon': '🕌', 'color': Color(0xFF9B87E8)},
      {'name': 'Dzikir', 'icon': '✨', 'color': Color(0xFFE89B87)},
      {'name': 'Kebersihan', 'icon': '🧼', 'color': Color(0xFF87C4E8)},
      {'name': 'Adab', 'icon': '❤️', 'color': Color(0xFFE887C4)},
      {'name': 'Kebiasaan', 'icon': '⏰', 'color': Color(0xFFB8E887)},
    ];

    final categoryCounts = _getCategoryCount();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Kategori Sunnah',
            style: TextStyle(
              fontSize: 22,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A4238),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 135,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final Map<String, dynamic> category = categories[index];
              final int count = categoryCounts[category['name']] ?? 0;

              return GestureDetector(
                onTap: () => _navigateToCategory(category['name'] as String),
                child: Container(
                  width: 100,
                  margin: EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        (category['color'] as Color).withOpacity(0.1),
                        (category['color'] as Color).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (category['color'] as Color).withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (category['color'] as Color).withOpacity(0.08),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: (category['color'] as Color).withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: (category['color'] as Color).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            category['icon'] as String,
                            style: TextStyle(fontSize: 26),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Flexible(
                        child: Text(
                          category['name'] as String,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: category['color'] as Color,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (category['color'] as Color).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            color: category['color'] as Color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(int completedCount, int totalCount, double progressPercentage) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFA8C9E8),
            Color(0xFFBFDBF0),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFA8C9E8).withOpacity(0.2),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${(progressPercentage * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress Hari Ini',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedCount dari $totalCount amalan',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progressPercentage,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStreaksCard(List<SunnahItem> topStreaks) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF8F0),
            Color(0xFFFFF0E6),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Color(0xFFFFD4B8).withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFFD4B8).withOpacity(0.12),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFD4B8), Color(0xFFFFC29F)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFFFD4B8).withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Text('🏆', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Sunnah Terbaik',
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD4A574),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...topStreaks.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final starCount = SunnahApiService.getStarCount(item.streakDays);
            final stars = SunnahApiService.getStarEmoji(starCount);
            
            return Padding(
              padding: EdgeInsets.only(bottom: idx < topStreaks.length - 1 ? 12 : 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(0xFFFFD4B8).withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFFFD4B8).withOpacity(0.08),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(item.icon, style: TextStyle(fontSize: 36)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A4238),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (stars.isNotEmpty) ...[
                                Text(stars, style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                              ],
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFFFF8F0), Color(0xFFFFEEE6)],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${item.streakDays} hari',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFD4A574),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildQuoteCard() {
    if (_isLoadingQuote) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB8A5D6)),
          ),
        ),
      );
    }

    if (_dailyQuote == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFAF8FC),
            Color(0xFFF5F2F8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0xFFB8A5D6).withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFB8A5D6), Color(0xFFCCBFE0)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFB8A5D6).withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Text('✨', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Renungan Hari Ini',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB8A5D6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '"${_dailyQuote!.text}"',
            style: TextStyle(
              fontSize: 16,
              height: 1.7,
              color: Color(0xFF4A4238),
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFFB8A5D6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '— ${_dailyQuote!.author}',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB8A5D6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunnahList() {
    final filteredItems = _getFilteredSunnahItems();
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isSearching 
                    ? 'Hasil Pencarian (${filteredItems.length})'
                    : 'Sunnah Routine',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A4238),
                ),
              ),
              if (!_isSearching)
                GestureDetector(
                  onTap: _showAllSunnah,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFFB8A5D6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Lihat Semua',
                          style: TextStyle(
                            color: Color(0xFFB8A5D6),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Color(0xFFB8A5D6),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        filteredItems.isEmpty
            ? Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      _isSearching ? Icons.search_off : Icons.inbox_outlined,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isSearching 
                          ? 'Tidak ada hasil untuk "$_searchQuery"'
                          : 'Tidak ada data',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: Color(0xFF8B7B6F),
                      ),
                    ),
                    if (_isSearching) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Coba kata kunci lain',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Color(0xFFB8B5C3),
                        ),
                      ),
                    ],
                  ],
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return SunnahCard(
                    item: item,
                    onToggle: () => _toggleCompletion(item.id),
                    onInfo: () => _showDetail(item),
                  );
                },
              ),
      ],
    );
  }
}