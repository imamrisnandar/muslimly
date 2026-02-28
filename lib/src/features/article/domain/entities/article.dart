import 'package:equatable/equatable.dart';

class Article extends Equatable {
  final String id;
  final String title;
  final String content;
  final String summary;
  final String category;
  final String author;
  final DateTime publishedAt;
  final int orderPriority;

  const Article({
    required this.id,
    required this.title,
    required this.content,
    required this.summary,
    required this.category,
    required this.author,
    required this.publishedAt,
    required this.orderPriority,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    summary,
    category,
    author,
    publishedAt,
    orderPriority,
  ];
}
