import 'package:equatable/equatable.dart';
import '../../../domain/entities/search_result.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {
  final List<SearchResult> oldResults;
  final bool isFirstFetch;

  const SearchLoading(this.oldResults, {this.isFirstFetch = true});

  @override
  List<Object?> get props => [oldResults, isFirstFetch];
}

class SearchLoaded extends SearchState {
  final List<SearchResult> results;
  final bool hasReachedMax;
  final int currentPage;
  final String query;
  final String languageCode;

  const SearchLoaded({
    required this.results,
    this.hasReachedMax = false,
    required this.currentPage,
    required this.query,
    this.languageCode = 'id',
  });

  @override
  List<Object?> get props => [
    results,
    hasReachedMax,
    currentPage,
    query,
    languageCode,
  ];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object> get props => [message];
}
