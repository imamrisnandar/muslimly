class PrayerGuideCategory {
  final String id;
  final String title;
  final String description;
  final List<PrayerGuideItem> items;

  const PrayerGuideCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.items,
  });

  factory PrayerGuideCategory.fromJson(Map<String, dynamic> json) {
    return PrayerGuideCategory(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      items: (json['items'] as List)
          .map((e) => PrayerGuideItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PrayerGuideItem {
  final String id;
  final String title;
  final String description;
  final String? contentMarkdown;
  final String? imagePath;

  const PrayerGuideItem({
    required this.id,
    required this.title,
    required this.description,
    this.contentMarkdown,
    this.imagePath,
  });

  factory PrayerGuideItem.fromJson(Map<String, dynamic> json) {
    return PrayerGuideItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      contentMarkdown: json['content_markdown'] as String?,
      imagePath: json['image_path'] as String?,
    );
  }
}
