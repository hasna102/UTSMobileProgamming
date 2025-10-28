import '../models/sunnah_item.dart';

class SunnahData {
  static List<SunnahItem> getSunnahItems() {
    return [
      // Ibadah
      SunnahItem(
        id: 'solat_witir',
        title: 'Solat Witir',
        subtitle: 'Streak 3 days',
        category: 'Ibadah',
        description: '''
Solat Witir adalah salat sunnah yang sangat dianjurkan untuk dilakukan setelah salat Isya hingga sebelum Subuh.

Keutamaan Solat Witir:
• Rasulullah ﷺ tidak pernah meninggalkan salat witir baik dalam perjalanan maupun di rumah
• Merupakan penutup salat malam yang paling baik
• Minimal 1 rakaat, paling utama 3 rakaat

Waktu Pelaksanaan:
Dari setelah salat Isya hingga sebelum waktu Subuh masuk.

Anjuran:
"Wahai ahli Al-Qur'an, lakukanlah witir karena Allah mencintai yang ganjil." (HR. Abu Dawud)
''',
        icon: '🕌',
        streakDays: 3,
      ),
      SunnahItem(
        id: 'solat_duha',
        title: 'Solat Duha',
        subtitle: 'Streak 7 days',
        category: 'Ibadah',
        description: '''
Solat Duha adalah salat sunnah yang dikerjakan pada pagi hari setelah matahari terbit hingga sebelum waktu Zuhur.

Keutamaan Solat Duha:
• Sebagai sedekah bagi setiap persendian tubuh
• Mendatangkan rezeki dan keberkahan
• Dihitung sebagai sedekah untuk 360 persendian

Waktu Pelaksanaan:
Mulai dari matahari setinggi tombak (sekitar 15-20 menit setelah terbit) hingga sebelum waktu Zuhur. Waktu paling utama adalah saat matahari sudah tinggi dan terik (sekitar pukul 9-11 pagi).

Jumlah Rakaat:
Minimal 2 rakaat, paling utama 8 rakaat.
''',
        icon: '🕌',
        streakDays: 7,
      ),
      SunnahItem(
        id: 'qiyamul_lail',
        title: 'Qiyamul Lail',
        subtitle: 'Streak 5 days',
        category: 'Ibadah',
        description: '''
Qiyamul Lail adalah salat malam yang dilakukan setelah tidur hingga sebelum Subuh.

Keutamaan Qiyamul Lail:
• Waktu mustajab untuk berdoa
• Menghapus dosa-dosa
• Allah turun ke langit dunia pada sepertiga malam terakhir

Cara Pelaksanaan:
• Tidur sejenak setelah Isya
• Bangun di sepertiga malam terakhir
• Salat minimal 2 rakaat
• Dapat dilakukan hingga 8-12 rakaat
• Ditutup dengan witir

Firman Allah:
"Mereka meninggalkan tempat tidurnya untuk berdoa kepada Tuhannya dengan rasa takut dan penuh harap." (QS. As-Sajdah: 16)
''',
        icon: '🕌',
        streakDays: 5,
      ),
      SunnahItem(
        id: 'solat_rawatib',
        title: 'Solat Rawatib',
        subtitle: 'Streak 1 days',
        category: 'Ibadah',
        description: '''
Solat Rawatib adalah salat sunnah yang dikerjakan sebelum atau sesudah salat fardhu.

Jenis Solat Rawatib:

Rawatib Mu'akkad (sangat dianjurkan):
• 2 rakaat sebelum Subuh
• 2 rakaat sebelum Zuhur
• 2 rakaat sesudah Zuhur
• 2 rakaat sesudah Maghrib
• 2 rakaat sesudah Isya

Rawatib Ghairu Mu'akkad:
• 2-4 rakaat sebelum Ashar
• 2 rakaat sebelum Maghrib

Keutamaan:
Rasulullah ﷺ bersabda: "Barangsiapa yang salat 12 rakaat dalam sehari semalam, maka akan dibangunkan baginya rumah di surga."
''',
        icon: '🕌',
        streakDays: 1,
      ),
      
      // Adab
      SunnahItem(
        id: 'doa_sebelum_tidur',
        title: 'Doa sebelum tidur',
        subtitle: 'Streak 6 days',
        category: 'Adab',
        description: '''
Membaca doa sebelum tidur adalah sunnah yang sangat dianjurkan untuk menjaga diri dari gangguan setan.

Adab Sebelum Tidur:
1. Berwudhu
2. Membaca Ayat Kursi
3. Membaca Surah Al-Ikhlas, Al-Falaq, dan An-Nas (3x)
4. Tidur dalam keadaan miring ke kanan
5. Meletakkan tangan kanan di bawah pipi

Doa Sebelum Tidur:
"Bismika Allahumma amutu wa ahya"
(Dengan menyebut nama-Mu ya Allah, aku mati dan aku hidup)

Keutamaan:
• Dilindungi dari gangguan setan
• Tidur lebih berkah dan nyenyak
• Jika meninggal dalam tidur, mati dalam keadaan fitrah
''',
        icon: '🌙',
        streakDays: 0,
      ),
      SunnahItem(
        id: 'salam',
        title: 'Mengucap Salam',
        subtitle: 'Salam kepada sesama',
        category: 'Adab',
        description: '''
Mengucapkan salam adalah sunnah yang sangat dianjurkan dalam Islam.

Keutamaan Salam:
• Menyebarkan cinta dan kasih sayang
• Mendapat pahala dari Allah
• Menambah keakraban antar muslim

Cara Mengucap Salam:
"Assalamu'alaikum Warahmatullahi Wabarakatuh"

Menjawab Salam:
"Wa'alaikumussalam Warahmatullahi Wabarakatuh"

Hadits:
"Kalian tidak akan masuk surga hingga kalian beriman, dan kalian tidak beriman hingga kalian saling mencintai. Maukah aku tunjukkan sesuatu yang jika kalian lakukan akan saling mencintai? Sebarkanlah salam di antara kalian." (HR. Muslim)
''',
        icon: '👋',
        streakDays: 0,
      ),
      
      // Dzikir & Kebiasaan
      SunnahItem(
        id: 'witir',
        title: 'Witir',
        subtitle: 'Streak 2 days',
        category: 'Ibadah',
        description: '''
Solat Witir adalah salat sunnah ganjil yang menjadi penutup salat malam.

Waktu Pelaksanaan:
Dari setelah salat Isya hingga sebelum Subuh. Paling utama di akhir malam bagi yang yakin bisa bangun.

Jumlah Rakaat:
• Minimal 1 rakaat
• Paling utama 3 rakaat (dengan 2 salam atau 1 salam)
• Bisa hingga 11 rakaat

Doa Qunut:
Dibaca pada rakaat terakhir setelah ruku sebelum sujud.

"Allahumma ihdini fiman hadait, wa 'afini fiman 'afait..."
(Ya Allah, berilah aku petunjuk sebagaimana orang-orang yang Engkau beri petunjuk...)
''',
        icon: '📿',
        streakDays: 0,
      ),
      SunnahItem(
        id: 'tilawah_quran',
        title: 'Tilawah Quran',
        subtitle: 'Streak 5 days',
        category: 'Kebiasaan',
        description: '''
Membaca Al-Qur'an adalah ibadah yang sangat mulia dan penuh berkah.

Keutamaan Tilawah:
• Setiap huruf bernilai 10 kebaikan
• Al-Qur'an akan menjadi syafaat di hari kiamat
• Meninggikan derajat di surga

Adab Membaca Al-Qur'an:
1. Dalam keadaan suci (berwudhu)
2. Memilih tempat yang bersih
3. Menghadap kiblat (diutamakan)
4. Membaca ta'awudz dan basmalah
5. Tartil (pelan dan jelas)

Target Harian:
Minimal 1 lembar (1 halaman) setiap hari, sehingga dapat khatam dalam 1 bulan.

Hadits:
"Bacalah Al-Qur'an, karena ia akan datang pada hari kiamat sebagai pemberi syafaat bagi pembacanya." (HR. Muslim)
''',
        icon: '📖',
        streakDays: 0,
      ),
      SunnahItem(
        id: 'dzikir_pagi',
        title: 'Dzikir Pagi',
        subtitle: 'Streak 4 days',
        category: 'Kebiasaan',
        description: '''
Dzikir pagi adalah rangkaian dzikir dan doa yang dibaca setelah Subuh hingga terbit matahari.

Dzikir-dzikir Penting:
• Ayat Kursi (1x)
• Al-Ikhlas, Al-Falaq, An-Nas (3x)
• Tasbih, Tahmid, Takbir (33x atau 100x)
• Shalawat kepada Nabi ﷺ
• Istighfar

Waktu Pelaksanaan:
Setelah salat Subuh hingga matahari terbit (sekitar pukul 05:30-06:30)

Keutamaan:
• Dilindungi dari bahaya sepanjang hari
• Dicukupkan segala kebutuhan
• Mendapat pahala yang berlimpah
• Hati menjadi tenang dan tenteram

"Orang-orang yang berdzikir kepada Allah sambil berdiri, duduk, atau berbaring." (QS. Ali Imran: 191)
''',
        icon: '📿',
        streakDays: 0,
      ),
      
      // Kebersihan & Amalan
      SunnahItem(
        id: 'baca_quran',
        title: 'Baca Al-Quran',
        subtitle: 'Streak 5 days',
        category: 'Amalan',
        description: '''
Membaca Al-Qur'an setiap hari adalah amalan yang sangat dianjurkan.

Target Membaca:
• Minimal 1 halaman per hari
• Usahakan khatam 1 bulan sekali
• Pahami artinya secara bertahap

Waktu-waktu Utama:
• Setelah Subuh
• Setelah Maghrib
• Sebelum tidur
• Waktu luang lainnya

Tips Istiqomah:
1. Tentukan waktu khusus setiap hari
2. Mulai dari target kecil (1 halaman)
3. Baca dengan tartil dan tadabbur
4. Pahami artinya secara perlahan

"Sesungguhnya waktu fajar itu disaksikan (oleh malaikat)." (QS. Al-Isra: 78)
''',
        icon: '📖',
        streakDays: 0,
      ),
      SunnahItem(
        id: 'bersedekah',
        title: 'Bersedekah',
        subtitle: 'Streak 4 days',
        category: 'Amalan',
        description: '''
Sedekah adalah memberikan sebagian harta kepada yang berhak dengan tujuan mendekatkan diri kepada Allah.

Keutamaan Sedekah:
• Menghapus dosa
• Menambah rezeki
• Mengobati penyakit
• Mendapat naungan di hari kiamat

Jenis-jenis Sedekah:
• Sedekah harta (uang, makanan, pakaian)
• Sedekah ilmu
• Sedekah tenaga
• Senyum kepada sesama

Sedekah Harian:
Tidak harus banyak, yang penting rutin dan ikhlas. Bisa dimulai dari Rp 1.000 per hari.

Hadits:
"Sedekah tidak akan mengurangi harta." (HR. Muslim)

"Senyummu di hadapan saudaramu adalah sedekah." (HR. Tirmidzi)
''',
        icon: '💰',
        streakDays: 0,
      ),
      SunnahItem(
        id: 'shalawat',
        title: 'Shalawat',
        subtitle: 'Streak 2 days',
        category: 'Kebiasaan',
        description: '''
Membaca shalawat kepada Nabi Muhammad ﷺ adalah ibadah yang sangat dianjurkan.

Keutamaan Shalawat:
• Mendapat 10 shalawat dari Allah untuk setiap 1 shalawat
• Diangkat 10 derajat
• Dihapus 10 kesalahan
• Mendapat syafaat Nabi ﷺ

Bentuk Shalawat:
• Shalawat Ibrahimiyah (paling utama)
• "Allahumma shalli 'ala Muhammad"
• Shalawat Nariyah
• Shalawat Fatih

Target Harian:
Minimal 100x sehari, terutama di hari Jumat.

Waktu Utama:
• Setelah adzan
• Di hari Jumat
• Pagi dan petang
• Saat disebutkan nama Nabi ﷺ

Hadits:
"Barangsiapa bershalawat kepadaku satu kali, Allah akan bershalawat kepadanya sepuluh kali." (HR. Muslim)
''',
        icon: '📿',
        streakDays: 0,
      ),
      
      // Tambahan Kebersihan
      SunnahItem(
        id: 'wudhu_sebelum_tidur',
        title: 'Wudhu sebelum tidur',
        subtitle: 'Membersihkan diri',
        category: 'Kebersihan',
        description: '''
Berwudhu sebelum tidur adalah sunnah yang sangat dianjurkan.

Keutamaan:
• Tidur dalam keadaan suci
• Dilindungi malaikat sepanjang malam
• Jika meninggal, mati dalam keadaan suci

Hadits:
"Apabila kamu hendak tidur, maka berwudhulah seperti wudhu untuk shalat." (HR. Bukhari Muslim)

Manfaat:
• Lebih berkah dan nyenyak
• Jiwa dan raga lebih tenang
• Mimpi lebih baik
''',
        icon: '💧',
        streakDays: 0,
      ),
      SunnahItem(
        id: 'sikat_gigi',
        title: 'Bersiwak/Sikat Gigi',
        subtitle: 'Kebersihan mulut',
        category: 'Kebersihan',
        description: '''
Bersiwak atau menyikat gigi adalah sunnah yang sangat dianjurkan.

Waktu-waktu Bersiwak:
• Sebelum wudhu
• Sebelum shalat
• Saat bangun tidur
• Saat bau mulut

Keutamaan:
• Membersihkan mulut
• Menyehatkan gigi
• Diridhai Allah

Hadits:
"Siwak itu membersihkan mulut dan diridhai oleh Allah." (HR. Bukhari)
''',
        icon: '🪥',
        streakDays: 0,
      ),
    ];
  }
  
  static List<String> getCategories() {
    return ['Ibadah', 'Amalan', 'Kebersihan', 'Adab', 'Kebiasaan'];
  }
}