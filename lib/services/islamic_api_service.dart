import 'dart:convert';
import 'package:http/http.dart' as http;

// Model untuk Ayat Al-Quran
class Ayah {
  final int number;
  final String text;
  final String translation;
  final int surahNumber;
  final String surahName;

  Ayah({
    required this.number,
    required this.text,
    required this.translation,
    required this.surahNumber,
    required this.surahName,
  });

  factory Ayah.fromJson(Map<String, dynamic> json, Map<String, dynamic>? translationJson) {
    return Ayah(
      number: json['numberInSurah'] ?? json['number'] ?? 0,
      text: json['text'] ?? '',
      translation: translationJson?['text'] ?? '',
      surahNumber: json['surah']?['number'] ?? 0,
      surahName: json['surah']?['name'] ?? '',
    );
  }
}

// Model untuk Surah
class Surah {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] ?? 0,
      name: json['name'] ?? '',
      englishName: json['englishName'] ?? '',
      englishNameTranslation: json['englishNameTranslation'] ?? '',
      numberOfAyahs: json['numberOfAyahs'] ?? 0,
      revelationType: json['revelationType'] ?? 'Meccan',
    );
  }
}

// Model untuk Waktu Sholat
class PrayerTimes {
  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String sunrise;
  final String date;
  final String hijriDate;

  PrayerTimes({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.sunrise,
    required this.date,
    required this.hijriDate,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    final timings = json['data']['timings'];
    final date = json['data']['date'];
    
    return PrayerTimes(
      fajr: timings['Fajr'],
      dhuhr: timings['Dhuhr'],
      asr: timings['Asr'],
      maghrib: timings['Maghrib'],
      isha: timings['Isha'],
      sunrise: timings['Sunrise'],
      date: date['readable'],
      hijriDate: '${date['hijri']['day']} ${date['hijri']['month']['en']} ${date['hijri']['year']}',
    );
  }
}

// Model untuk Quote Islami dari API
class IslamicQuote {
  final String text;
  final String author;

  IslamicQuote({
    required this.text,
    required this.author,
  });

  factory IslamicQuote.fromJson(Map<String, dynamic> json) {
    return IslamicQuote(
      text: json['arab'] ?? json['text'] ?? '',
      author: json['source'] ?? json['author'] ?? 'Al-Quran',
    );
  }
}

// Model untuk Hadith dari API
class Hadith {
  final String id;
  final String arab;
  final String indonesian;
  final String narrator;

  Hadith({
    required this.id,
    required this.arab,
    required this.indonesian,
    required this.narrator,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      id: json['number']?.toString() ?? '',
      arab: json['arab'] ?? '',
      indonesian: json['id'] ?? '',
      narrator: json['name'] ?? 'Hadith',
    );
  }
}

// Model untuk Daily Islamic Content
class DailyContent {
  final IslamicQuote? quote;
  final Ayah? ayah;
  final Hadith? hadith;

  DailyContent({
    this.quote,
    this.ayah,
    this.hadith,
  });
}

// Service untuk API
class IslamicApiService {
  static const String quranApiBase = 'https://api.alquran.cloud/v1';
  static const String prayerApiBase = 'https://api.aladhan.com/v1';
  static const String hadithApiBase = 'https://hadis-api-id.vercel.app';
  
  // Cache untuk mengurangi request
  static DateTime? _lastFetchTime;
  static DailyContent? _cachedDailyContent;
  static List<Surah>? _cachedSurahs;

  // Fetch daftar Surah
  Future<List<Surah>> fetchSurahs() async {
    // Check cache
    if (_cachedSurahs != null) {
      return _cachedSurahs!;
    }

    try {
      final response = await http.get(
        Uri.parse('$quranApiBase/surah'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> surahsJson = data['data'];
        _cachedSurahs = surahsJson.map((json) => Surah.fromJson(json)).toList();
        return _cachedSurahs!;
      } else {
        throw Exception('Failed to load surahs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching surahs: $e');
    }
  }

  // Fetch ayat dari surah tertentu dengan terjemahan - FIXED
  Future<List<Ayah>> fetchAyahsBySurah(int surahNumber) async {
    try {
      print('Fetching ayahs for surah $surahNumber...');
      
      // Fetch teks Arab
      final arabResponse = await http.get(
        Uri.parse('$quranApiBase/surah/$surahNumber'),
      ).timeout(const Duration(seconds: 15));

      // Fetch terjemahan Indonesia
      final translationResponse = await http.get(
        Uri.parse('$quranApiBase/surah/$surahNumber/id.indonesian'),
      ).timeout(const Duration(seconds: 15));

      if (arabResponse.statusCode != 200 || translationResponse.statusCode != 200) {
        throw Exception('Failed to load ayahs');
      }

      final Map<String, dynamic> arabData = json.decode(arabResponse.body);
      final Map<String, dynamic> translationData = json.decode(translationResponse.body);
      
      if (arabData['data'] == null || arabData['data']['ayahs'] == null ||
          translationData['data'] == null || translationData['data']['ayahs'] == null) {
        throw Exception('Invalid response structure');
      }
      
      final List<dynamic> arabAyahs = arabData['data']['ayahs'];
      final List<dynamic> translationAyahs = translationData['data']['ayahs'];
      
      if (arabAyahs.isEmpty || translationAyahs.isEmpty) {
        throw Exception('No ayahs found');
      }

      List<Ayah> ayahs = [];
      for (int i = 0; i < arabAyahs.length; i++) {
        try {
          final arabAyah = arabAyahs[i];
          final transAyah = translationAyahs[i];
          
          ayahs.add(Ayah(
            number: arabAyah['numberInSurah'] ?? i + 1,
            text: arabAyah['text'] ?? '', // Teks Arab
            translation: transAyah['text'] ?? '', // Terjemahan Indonesia
            surahNumber: arabAyah['surah']?['number'] ?? surahNumber,
            surahName: arabAyah['surah']?['name'] ?? '',
          ));
        } catch (e) {
          print('Error parsing ayah $i: $e');
          continue;
        }
      }

      print('Successfully parsed ${ayahs.length} ayahs');
      return ayahs;
    } catch (e) {
      print('Error in fetchAyahsBySurah: $e');
      throw Exception('Error fetching ayahs: $e');
    }
  }

  // Search ayat berdasarkan keyword
  Future<List<Ayah>> searchAyahs(String keyword) async {
    try {
      final response = await http.get(
        Uri.parse('$quranApiBase/search/$keyword/all/id.indonesian'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> matches = data['data']['matches'];

        List<Ayah> ayahs = [];
        for (var match in matches.take(20)) {
          try {
            ayahs.add(Ayah(
              number: match['numberInSurah'] ?? 0,
              text: match['text'] ?? '',
              translation: match['text'] ?? '',
              surahNumber: match['surah']?['number'] ?? 0,
              surahName: match['surah']?['name'] ?? '',
            ));
          } catch (e) {
            continue;
          }
        }

        return ayahs;
      } else {
        throw Exception('Failed to search ayahs');
      }
    } catch (e) {
      throw Exception('Error searching ayahs: $e');
    }
  }

  // Fetch jadwal sholat berdasarkan lokasi
  Future<PrayerTimes> fetchPrayerTimes({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final now = DateTime.now();
      final response = await http.get(
        Uri.parse(
          '$prayerApiBase/timings/${now.day}-${now.month}-${now.year}?latitude=$latitude&longitude=$longitude&method=2',
        ),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PrayerTimes.fromJson(data);
      } else {
        throw Exception('Failed to load prayer times: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching prayer times: $e');
    }
  }

  // Fetch random hadith dari API
  Future<Hadith> fetchRandomHadith() async {
    try {
      final response = await http.get(
        Uri.parse('$hadithApiBase/hadith/bukhari?page=1&limit=50'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> hadiths = data['items'] ?? [];
        
        if (hadiths.isNotEmpty) {
          final index = DateTime.now().day % hadiths.length;
          return Hadith.fromJson(hadiths[index]);
        }
      }
      
      throw Exception('No hadith found');
    } catch (e) {
      throw Exception('Error fetching hadith: $e');
    }
  }

  // Fetch ayat of the day dari API
  Future<Ayah> fetchAyahOfTheDay() async {
    try {
      final day = DateTime.now().day;
      final surahNumber = (day % 114) + 1;
      
      final ayahs = await fetchAyahsBySurah(surahNumber);
      
      if (ayahs.isNotEmpty) {
        final index = DateTime.now().hour % ayahs.length;
        return ayahs[index];
      }
      
      throw Exception('No ayah found');
    } catch (e) {
      throw Exception('Error fetching ayah of the day: $e');
    }
  }

  // Fetch daily Islamic content (Quote + Ayah)
  Future<DailyContent> fetchDailyContent() async {
    // Check cache - refresh setiap 6 jam
    if (_lastFetchTime != null && _cachedDailyContent != null) {
      final difference = DateTime.now().difference(_lastFetchTime!);
      if (difference.inHours < 6) {
        return _cachedDailyContent!;
      }
    }

    try {
      final ayah = await fetchAyahOfTheDay();
      
      final quote = IslamicQuote(
        text: ayah.translation,
        author: ayah.surahName,
      );

      Hadith? hadith;
      try {
        hadith = await fetchRandomHadith();
      } catch (e) {
        hadith = null;
      }

      final content = DailyContent(
        quote: quote,
        ayah: ayah,
        hadith: hadith,
      );

      _lastFetchTime = DateTime.now();
      _cachedDailyContent = content;

      return content;
    } catch (e) {
      throw Exception('Error fetching daily content: $e');
    }
  }

  // Get Islamic quote dari ayah random
  Future<IslamicQuote> getRandomQuote() async {
    try {
      final content = await fetchDailyContent();
      return content.quote ?? IslamicQuote(
        text: 'Sesungguhnya bersama kesulitan ada kemudahan.',
        author: 'QS. Al-Insyirah: 6',
      );
    } catch (e) {
      return IslamicQuote(
        text: 'Sesungguhnya bersama kesulitan ada kemudahan.',
        author: 'QS. Al-Insyirah: 6',
      );
    }
  }

  // Clear cache
  void clearCache() {
    _lastFetchTime = null;
    _cachedDailyContent = null;
    _cachedSurahs = null;
  }
}