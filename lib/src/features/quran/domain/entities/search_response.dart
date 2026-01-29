import 'package:equatable/equatable.dart';
import 'search_result.dart';

class SearchResponse extends Equatable {
  final List<SearchResult> results;
  final int totalResults;
  final int totalPages;
  final int currentPage;

  const SearchResponse({
    required this.results,
    required this.totalResults,
    required this.totalPages,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [results, totalResults, totalPages, currentPage];
}
