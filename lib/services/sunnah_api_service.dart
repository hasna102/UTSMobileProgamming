import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sunnah_item.dart';

class SunnahApiService {
  static const String apiUrl =
      "https://raw.githubusercontent.com/hasna102/sunnag-api/main/hadist.json";

  static List<SunnahItem>? _cachedSunnahItems;
  static DateTime? _lastFetchTime;

  Future<List<SunnahItem>> fetchAllSunnahItems() async {
    if (_lastFetchTime != null &&
        _cachedSunnahItems != null &&
        DateTime.now().difference(_lastFetchTime!).inHours < 24) {
      print("📦 Using cached Sunnah items");
      return _cachedSunnahItems!;
    }

    try {
      print("🌐 Fetching Sunnah JSON from GitHub...");

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode != 200) {
        throw Exception("Gagal mengambil data dari API JSON");
      }

      final Map<String, dynamic> root = jsonDecode(response.body);
      final List<dynamic> data = root['sunnah_list'] ?? [];

      final items = data.map((json) {
        // Tentukan icon berdasarkan kategori
        String icon = _getIconForCategory(json['kategori'] ?? '');
        
        return SunnahItem(
          id: json['id']?.toString() ?? '',
          title: json['judul'] ?? '',
          subtitle: json['deskripsi'] ?? '', // Gunakan deskripsi sebagai subtitle
          category: json['kategori'] ?? '',
          description: _buildFullDescription(json), // Gabungkan semua info
          icon: icon,
        );
      }).toList();

      _cachedSunnahItems = items;
      _lastFetchTime = DateTime.now();

      print("✅ Loaded ${items.length} sunnah items");

      return items;
    } catch (e) {
      print("❌ ERROR fetchAllSunnahItems(): $e");
      rethrow;
    }
  }

  // Helper function untuk membuat deskripsi lengkap
  static String _buildFullDescription(Map<String, dynamic> json) {
    final StringBuffer description = StringBuffer();
    
    // Deskripsi utama
    if (json['deskripsi'] != null && json['deskripsi'].toString().isNotEmpty) {
      description.write(json['deskripsi']);
      description.write('\n\n');
    }
    
    // Manfaat & Pahala
    if (json['manfaat_pahala'] != null && json['manfaat_pahala'].toString().isNotEmpty) {
      description.write('📿 Manfaat & Pahala:\n');
      description.write(json['manfaat_pahala']);
      description.write('\n\n');
    }
    
    // Cara Melakukan
    if (json['cara_melakukan'] != null && json['cara_melakukan'].toString().isNotEmpty) {
      description.write('✨ Cara Melakukan:\n');
      description.write(json['cara_melakukan']);
      description.write('\n\n');
    }
    
    // Waktu
    if (json['waktu'] != null && json['waktu'].toString().isNotEmpty) {
      description.write('⏰ Waktu:\n');
      description.write(json['waktu']);
    }
    
    return description.toString().trim();
  }

  // Helper function untuk mendapatkan icon berdasarkan kategori
  static String _getIconForCategory(String category) {
    switch (category) {
      case 'Ibadah':
        return '🕌';
      case 'Dzikir':
        return '✨';
      case 'Amalan':
        return '⭐';
      case 'Kebersihan':
        return '🧼';
      case 'Adab':
        return '❤️';
      case 'Kebiasaan':
        return '⏰';
      default:
        return '📿';
    }
  }

  Future<List<SunnahItem>> fetchSunnahByCategory(String category) async {
    final all = await fetchAllSunnahItems();
    return all.where((item) => item.category == category).toList();
  }

  Future<List<SunnahItem>> searchSunnah(String query) async {
    final all = await fetchAllSunnahItems();
    final lower = query.toLowerCase();

    return all.where((item) {
      return item.title.toLowerCase().contains(lower) ||
          item.subtitle.toLowerCase().contains(lower) ||
          item.description.toLowerCase().contains(lower);
    }).toList();
  }

  List<String> getCategories() {
    return ['Ibadah', 'Amalan', 'Kebersihan', 'Adab', 'Kebiasaan'];
  }

  void clearCache() {
    _cachedSunnahItems = null;
    _lastFetchTime = null;
    print("🗑️ Cache cleared");
  }

  static int getStarCount(int streakDays) {
    if (streakDays >= 30) return 5;
    if (streakDays >= 20) return 4;
    if (streakDays >= 14) return 3;
    if (streakDays >= 7) return 2;
    if (streakDays >= 3) return 1;
    return 0;
  }

  static String getStarEmoji(int count) {
    if (count == 0) return '';
    return '⭐' * count;
  }

  static String getMotivationalMessage(int streakDays) {
    if (streakDays >= 30) return '🎉 Luar biasa! Konsistensimu hebat!';
    if (streakDays >= 20) return '💪 Keren! Terus lanjutkan!';
    if (streakDays >= 14) return '👍 Dua minggu penuh!';
    if (streakDays >= 7) return '🔥 Seminggu berturut-turut!';
    if (streakDays >= 3) return '✨ Mulai konsisten!';
    return '🌱 Awali hari dengan semangat!';
  }
}