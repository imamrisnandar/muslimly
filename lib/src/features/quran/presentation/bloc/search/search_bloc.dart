import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/search_ayahs.dart';
import 'search_event.dart';
import 'search_state.dart';
import 'package:rxdart/rxdart.dart'; // For debounce

@injectable
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchAyahs _searchAyahs;

  SearchBloc(this._searchAyahs) : super(SearchInitial()) {
    on<SearchSubmitted>(
      _onSearchSubmitted,
      transformer: (events, mapper) {
        return events
            .debounceTime(const Duration(milliseconds: 300))
            .asyncExpand(mapper);
      },
    );

    on<SearchLoadMore>(_onSearchLoadMore);
  }

  Future<void> _onSearchSubmitted(
    SearchSubmitted event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading([], isFirstFetch: true));

    final result = await _searchAyahs(
      event.query,
      page: 1,
      languageCode: event.languageCode,
    );

    result.fold(
      (failure) => emit(SearchError(failure)),
      (results) => emit(
        SearchLoaded(
          results: results,
          hasReachedMax: results.isEmpty,
          currentPage: 1,
          query: event.query,
          languageCode: event.languageCode, // Store for pagination
        ),
      ),
    );
  }

  Future<void> _onSearchLoadMore(
    SearchLoadMore event,
    Emitter<SearchState> emit,
  ) async {
    if (state is SearchLoaded) {
      final currentState = state as SearchLoaded;
      if (currentState.hasReachedMax) return;

      final nextPage = currentState.currentPage + 1;

      // Emit Loading but keep old results?
      // Actually standard pattern is to keep showing loaded state but maybe show loading indicator at bottom.
      // But here we need to emit a new state if we want to update UI heavily.
      // Simplest: Just append results in Loaded state. Or use separate loading status field.
      // For now, let's just do the fetch and emit new Loaded.

      final result = await _searchAyahs(
        currentState.query,
        page: nextPage,
        languageCode: currentState.languageCode,
      );

      result.fold(
        (failure) {
          // On error during pagination, maybe show snackbar?
          // Or emit Error state? Ideally just ignore or show separate error.
          // For MVP, if error, stop pagination.
        },
        (newResults) {
          emit(
            SearchLoaded(
              results: currentState.results + newResults,
              hasReachedMax: newResults.isEmpty,
              currentPage: nextPage,
              query: currentState.query,
            ),
          );
        },
      );
    }
  }
}
