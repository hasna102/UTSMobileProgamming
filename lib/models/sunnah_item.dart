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

  factory SunnahItem.fromJson(Map<String, dynamic> json) {
    return SunnahItem(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      category: json['category'],
      description: json['description'],
      icon: json['icon'],
      streakDays: json['streakDays'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
    );
  }

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