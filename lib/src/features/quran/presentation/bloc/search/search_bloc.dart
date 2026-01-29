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
      (response) => emit(
        SearchLoaded(
          results: response.results,
          hasReachedMax: response.currentPage >= response.totalPages,
          currentPage: response.currentPage,
          query: event.query,
          languageCode: event.languageCode,
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

      final result = await _searchAyahs(
        currentState.query,
        page: nextPage,
        languageCode: currentState.languageCode,
      );

      result.fold(
        (failure) {
          // Ignore pagination error
        },
        (response) {
          emit(
            SearchLoaded(
              results: currentState.results + response.results,
              hasReachedMax: response.currentPage >= response.totalPages,
              currentPage: response.currentPage,
              query: currentState.query,
              languageCode: currentState.languageCode,
            ),
          );
        },
      );
    }
  }
}
