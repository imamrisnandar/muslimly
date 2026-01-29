import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}

class SearchSubmitted extends SearchEvent {
  final String query;
  final String languageCode;

  const SearchSubmitted(this.query, {this.languageCode = 'id'});

  @override
  List<Object> get props => [query, languageCode];
}

class SearchLoadMore extends SearchEvent {}
