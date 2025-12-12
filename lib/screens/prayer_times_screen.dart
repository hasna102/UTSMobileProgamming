import 'package:flutter/material.dart';
import '../services/islamic_api_service.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final IslamicApiService _apiService = IslamicApiService();

  // Koordinat Malang, Indonesia (sesuai dengan lokasi user)
  final double latitude = -7.9797;
  final double longitude = 112.6304;

  String _getCurrentPrayer(PrayerTimes times) {
    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;

    final prayers = {
      'Subuh': _timeToMinutes(times.fajr),
      'Terbit': _timeToMinutes(times.sunrise),
      'Dzuhur': _timeToMinutes(times.dhuhr),
      'Ashar': _timeToMinutes(times.asr),
      'Maghrib': _timeToMinutes(times.maghrib),
      'Isya': _timeToMinutes(times.isha),
    };

    String currentPrayer = 'Isya';
    for (var entry in prayers.entries) {
      if (currentMinutes < entry.value) {
        return entry.key;
      }
      currentPrayer = entry.key;
    }
    return currentPrayer;
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1].split(' ')[0]);
    return hours * 60 + minutes;
  }

  String _formatTime(String time) {
    // Format dari "HH:MM (TIMEZONE)" ke "HH:MM"
    return time.split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
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
                  Color(0xFFB8A5D6),
                  Color(0xFFCCBFE0),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jadwal Sholat',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Malang, Indonesia',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mosque,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: FutureBuilder<PrayerTimes>(
              future: _apiService.fetchPrayerTimes(
                latitude: latitude,
                longitude: longitude,
              ),
              builder: (context, snapshot) {
                // Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.indigo.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Memuat jadwal sholat...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // Error State
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Terjadi Kesalahan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tidak dapat memuat jadwal sholat',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {});
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Success State
                final times = snapshot.data!;
                final currentPrayer = _getCurrentPrayer(times);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.indigo.shade50,
                              Colors.purple.shade50,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.indigo.shade200,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              times.date,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              times.hijriDate,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.indigo[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Prayer Times List
                      _buildPrayerCard(
                        icon: Icons.brightness_5,
                        name: 'Subuh',
                        time: _formatTime(times.fajr),
                        isActive: currentPrayer == 'Subuh',
                        color: Colors.indigo,
                      ),
                      const SizedBox(height: 12),
                      _buildPrayerCard(
                        icon: Icons.wb_sunny,
                        name: 'Terbit',
                        time: _formatTime(times.sunrise),
                        isActive: currentPrayer == 'Terbit',
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildPrayerCard(
                        icon: Icons.wb_sunny_outlined,
                        name: 'Dzuhur',
                        time: _formatTime(times.dhuhr),
                        isActive: currentPrayer == 'Dzuhur',
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 12),
                      _buildPrayerCard(
                        icon: Icons.wb_twilight,
                        name: 'Ashar',
                        time: _formatTime(times.asr),
                        isActive: currentPrayer == 'Ashar',
                        color: Colors.deepOrange,
                      ),
                      const SizedBox(height: 12),
                      _buildPrayerCard(
                        icon: Icons.brightness_3,
                        name: 'Maghrib',
                        time: _formatTime(times.maghrib),
                        isActive: currentPrayer == 'Maghrib',
                        color: Colors.red,
                      ),
                      const SizedBox(height: 12),
                      _buildPrayerCard(
                        icon: Icons.nights_stay,
                        name: 'Isya',
                        time: _formatTime(times.isha),
                        isActive: currentPrayer == 'Isya',
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(height: 24),

                      // Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Jadwal sholat disesuaikan dengan lokasi Anda di Malang, Indonesia',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerCard({
    required IconData icon,
    required String name,
    required String time,
    required bool isActive,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? color : Colors.grey.shade200,
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? color : color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                color: isActive ? color : Colors.grey[800],
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isActive ? color : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}