class SunnahItem {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String description;
  final String icon;
  int streakDays;
  bool isCompleted;

  SunnahItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.description,
    required this.icon,
    this.streakDays = 0,
    this.isCompleted = false,
  });

  /// Convert object → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'description': description,
      'icon': icon,
      'streakDays': streakDays,
      'isCompleted': isCompleted,
    };
  }

  /// Convert JSON → Object (FIXED)
  factory SunnahItem.fromJson(Map<String, dynamic> json) {
    return SunnahItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',

      /// FIX: hadist.json kadang kasih angka → harus dipaksa jadi int
      streakDays: json['streakDays'] is int
          ? json['streakDays']
          : int.tryParse(json['streakDays']?.toString() ?? '0') ?? 0,

      /// FIX: kadang boolean dikirim sebagai string “true”
      isCompleted: json['isCompleted'] is bool
          ? json['isCompleted']
          : json['isCompleted']?.toString() == 'true',
    );
  }

  /// Untuk update sebagian field
  SunnahItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? category,
    String? description,
    String? icon,
    int? streakDays,
    bool? isCompleted,
  }) {
    return SunnahItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      streakDays: streakDays ?? this.streakDays,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
