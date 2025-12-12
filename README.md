# Sunnah Tracker 🕌

Aplikasi mobile berbasis Flutter untuk membantu umat Muslim melacak dan membangun kebiasaan beribadah sesuai sunnah Nabi Muhammad SAW. Aplikasi ini menyediakan fitur pelacakan amalan harian, jadwal sholat, dan pembacaan Al-Quran dengan terjemahan.

## 📱 Fitur Utama

### 1. **Tracker Sunnah Harian**
- ✅ Checklist amalan sunnah harian
- 🔥 Sistem streak untuk memotivasi konsistensi
- ⭐ Badge bintang untuk pencapaian (setiap 10 hari berturut-turut)
- 📊 Progress tracking harian
- 🎯 Kategorisasi amalan: Ibadah, Dzikir, Kebersihan, Adab, Kebiasaan
- 📅 Calendar view untuk melihat riwayat amalan
- 🔍 Fitur pencarian sunnah

### 2. **Al-Quran Digital**
- 📖 Daftar lengkap 114 surah
- 🔤 Teks Arab dengan terjemahan Bahasa Indonesia
- 🔍 Fitur pencarian surah
- 📱 Interface yang clean dan mudah dibaca
- 🌙 Informasi detail setiap surah (jumlah ayat, tempat turun)

### 3. **Jadwal Sholat**
- ⏰ Waktu sholat berdasarkan lokasi (Malang, Indonesia)
- 🕌 Tampilan waktu: Subuh, Dzuhur, Ashar, Maghrib, Isya
- 🌅 Informasi waktu terbit matahari
- 📅 Tanggal Hijriah dan Masehi
- 🎨 Highlight waktu sholat yang sedang berlangsung

### 4. **Profil Pengguna**
- 👤 Customize nama dan foto profil
- 📸 Upload foto dari kamera atau galeri
- 💾 Data tersimpan secara lokal

### 5. **Fitur Tambahan**
- ✨ Quote/renungan Islami harian
- 🏆 Top Streaks - tampilan 3 amalan dengan streak tertinggi
- 🎨 UI/UX modern dengan animasi smooth
- 🌈 Gradient design yang menarik
- 📱 Bottom navigation untuk navigasi mudah

## 🔌 API yang Digunakan

### 1. **Al-Quran Cloud API**
Endpoint utama:
```
https://api.alquran.cloud/v1/
```

**Endpoints yang digunakan:**
- `GET /surah` - Mendapatkan daftar semua surah
- `GET /surah/{surahNumber}` - Mendapatkan ayat dalam bahasa Arab
- `GET /surah/{surahNumber}/id.indonesian` - Mendapatkan terjemahan Indonesia
- `GET /search/{keyword}/all/id.indonesian` - Pencarian ayat

**Dokumentasi:** https://alquran.cloud/api

### 2. **Aladhan Prayer Times API**
Endpoint utama:
```
https://api.aladhan.com/v1/
```

**Endpoints yang digunakan:**
- `GET /timings/{date}?latitude={lat}&longitude={lng}&method=2` - Jadwal sholat berdasarkan koordinat

Parameter yang digunakan:
- `latitude`: -7.9797 (Malang)
- `longitude`: 112.6304 (Malang)
- `method`: 2 (ISNA - Islamic Society of North America)

**Dokumentasi:** https://aladhan.com/prayer-times-api

### 3. **Hadith API Indonesia**
Endpoint utama:
```
https://hadis-api-id.vercel.app/
```

**Endpoints yang digunakan:**
- `GET /hadith/bukhari?page=1&limit=50` - Mendapatkan hadith dari Shahih Bukhari

**Dokumentasi:** https://github.com/gadingnst/hadith-api

### 4. **Sunnah List API (Custom)**
Endpoint utama:
```
https://raw.githubusercontent.com/hasna102/sunnag-api/main/hadist.json
```

Data JSON berisi:
- Daftar amalan sunnah
- Kategori amalan
- Deskripsi lengkap
- Manfaat & pahala
- Cara melakukan
- Waktu pelaksanaan

## 🛠️ Teknologi yang Digunakan

### Framework & Language
- **Flutter** 3.x - Framework utama
- **Dart** 3.x - Bahasa pemrograman

### Packages Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Network & API
  http: ^1.1.0
  
  # State Management & Storage
  shared_preferences: ^2.2.2
  
  # UI Components
  intl: ^0.18.1
  
  # Image Handling
  image_picker: ^1.0.7
```

### Local Storage
- **SharedPreferences** - Menyimpan data amalan harian, profil pengguna, dan cache

### Architecture
- **Service Layer Pattern** - Pemisahan logic API dan business logic
- **Widget Composition** - Reusable components
- **State Management** - StatefulWidget dengan setState

## 📦 Instalasi

### Prerequisites
- Flutter SDK (versi 3.0.0 atau lebih baru)
- Dart SDK (versi 3.0.0 atau lebih baru)
- Android Studio / VS Code
- Android SDK (untuk build Android)
- Xcode (untuk build iOS, hanya di macOS)

### Langkah Instalasi

1. **Clone Repository**
```bash
git clone https://github.com/username/sunnah-tracker.git
cd sunnah-tracker
```

2. **Install Dependencies**
```bash
flutter pub get
```

3. **Jalankan Aplikasi**
```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

4. **Build APK (Android)**
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split APK per ABI (ukuran lebih kecil)
flutter build apk --split-per-abi
```

5. **Build App Bundle (Android - untuk Play Store)**
```bash
flutter build appbundle
```

6. **Build IPA (iOS)**
```bash
flutter build ios --release
```

## 📁 Struktur Proyek

```
lib/
├── main.dart                    # Entry point aplikasi
├── models/
│   └── sunnah_item.dart        # Model data amalan sunnah
├── screens/
│   ├── home_screen.dart        # Halaman utama tracker
│   ├── category_screen.dart    # Halaman kategori sunnah
│   ├── detail_screen.dart      # Detail amalan sunnah
│   ├── profile_screen.dart     # Halaman profil pengguna
│   ├── quran_screen.dart       # Daftar surah Al-Quran
│   ├── surah_detail_screen.dart # Detail surah & ayat
│   └── prayer_times_screen.dart # Jadwal sholat
├── services/
│   ├── sunnah_api_service.dart # Service untuk Sunnah API
│   ├── islamic_api_service.dart # Service untuk Quran & Prayer API
│   └── profile_service.dart    # Service untuk data profil
└── widgets/
    ├── sunnah_card.dart        # Card component amalan
    └── calendar_widget.dart    # Widget kalender mingguan
```

## 🎨 Fitur Design

### Color Palette
- **Primary Purple**: `#9B87E8` - Warna utama aplikasi
- **Sky Blue**: `#87C4E8` - Untuk kategori Kebersihan
- **Warm Orange**: `#E89B87` - Untuk kategori Amalan
- **Soft Pink**: `#E887C4` - Untuk kategori Adab
- **Fresh Green**: `#B8E887` - Untuk kategori Kebiasaan
- **Gold**: `#FFD88A` - Untuk badge dan achievements

### Typography
- **Heading**: Poppins (600-700)
- **Body**: Inter (400-500)
- **Arabic Text**: Amiri (600)

### Animations
- Smooth page transitions
- Scale animation pada card press
- Fade animation untuk labels
- Progress indicator animations

## 📊 Data Persistence

### SharedPreferences Storage
Aplikasi menggunakan SharedPreferences untuk menyimpan:

1. **Data Amalan per Tanggal**
   - Key format: `sunnah_YYYY-MM-DD`
   - Value: JSON array of SunnahItem

2. **Data Profil**
   - `user_name`: Nama pengguna
   - `user_photo`: Foto profil (base64)

3. **Cache API**
   - Quote harian (refresh setiap 6 jam)
   - Daftar surah (cache permanent)

### Data Flow
```
User Action → State Update → Save to SharedPreferences
                ↓
         Update UI
```

## 🔐 Privacy & Permissions

### Android Permissions
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### iOS Permissions (Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>Aplikasi memerlukan akses kamera untuk foto profil</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Aplikasi memerlukan akses galeri untuk memilih foto profil</string>
```

## 🐛 Known Issues & Limitations

1. **Lokasi Fixed**: Saat ini jadwal sholat fixed untuk Malang, Indonesia
2. **Offline Mode**: Fitur Al-Quran dan jadwal sholat memerlukan koneksi internet
3. **Notifikasi**: Belum ada reminder otomatis untuk amalan
4. **Backup**: Data tersimpan lokal, belum ada cloud sync

## 🚀 Roadmap

### Future Features
- [ ] Notifikasi reminder untuk amalan
- [ ] Custom lokasi untuk jadwal sholat
- [ ] Kiblat compass
- [ ] Audio bacaan Al-Quran
- [ ] Dark mode
- [ ] Multi-language support
- [ ] Cloud backup & sync
- [ ] Widget untuk home screen
- [ ] Statistics & analytics
- [ ] Social sharing achievements

## 👨‍💻 Developer

**Nama Developer:** [Nama Anda]  
**Email:** [email@example.com]  
**GitHub:** [github.com/username](https://github.com/username)

## 📄 License

Proyek ini dilisensikan under MIT License - lihat file [LICENSE](LICENSE) untuk detail.

## 🙏 Acknowledgments

- API dari AlQuran Cloud
- API dari Aladhan
- Hadith API Indonesia
- Sunnah List API
- Icon dari Material Icons
- Font dari Google Fonts (Poppins, Inter, Amiri)
- Inspirasi design dari berbagai aplikasi Islamic modern

## 📞 Support

Jika Anda menemukan bug atau memiliki saran:
1. Buka issue di GitHub
2. Kirim email ke [email@example.com]
3. Buat pull request untuk kontribusi

---

**Dibuat dengan ❤️ untuk umat Muslim di seluruh dunia**

*"Sebaik-baik manusia adalah yang paling bermanfaat bagi manusia lainnya" - HR. Ahmad*