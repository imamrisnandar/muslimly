import '../../domain/entities/article.dart';

class ArticleModel extends Article {
  const ArticleModel({
    required super.id,
    required super.title,
    required super.content,
    required super.summary,
    required super.category,
    required super.author,
    required super.publishedAt,
    required super.orderPriority,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      summary: json['summary'] as String,
      category: json['category'] as String,
      author: json['author'] as String,
      publishedAt: DateTime.parse(json['published_at'] as String),
      orderPriority: json['order_priority'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'summary': summary,
      'category': category,
      'author': author,
      'published_at': publishedAt.toIso8601String(),
      'order_priority': orderPriority,
    };
  }

  Article toEntity() {
    return Article(
      id: id,
      title: title,
      content: content,
      summary: summary,
      category: category,
      author: author,
      publishedAt: publishedAt,
      orderPriority: orderPriority,
    );
  }
}
