import 'package:bloc/bloc.dart';
import '../../domain/repositories/article_repository.dart';
import '../../domain/entities/article.dart';
import 'package:equatable/equatable.dart';

// --- Events ---
abstract class ArticleEvent extends Equatable {
  const ArticleEvent();
}

class LoadArticles extends ArticleEvent {
  final String? lang;
  final int? limit;
  final int? offset;

  const LoadArticles({this.lang, this.limit, this.offset});

  @override
  List<Object?> get props => [lang, limit, offset];
}

class SearchArticles extends ArticleEvent {
  final String query;
  final String? lang;
  const SearchArticles({required this.query, this.lang});
  @override
  List<Object?> get props => [query, lang];
}

// --- States ---
abstract class ArticleState extends Equatable {
  const ArticleState();
}

class ArticleInitial extends ArticleState {
  @override
  List<Object?> get props => [];
}

class ArticleLoading extends ArticleState {
  @override
  List<Object?> get props => [];
}

class ArticleLoaded extends ArticleState {
  final List<Article> articles;
  final bool isCache;
  final bool hasReachedMax;

  const ArticleLoaded(
    this.articles, {
    this.isCache = false,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [articles, isCache, hasReachedMax];

  ArticleLoaded copyWith({
    List<Article>? articles,
    bool? isCache,
    bool? hasReachedMax,
  }) {
    return ArticleLoaded(
      articles ?? this.articles,
      isCache: isCache ?? this.isCache,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class ArticleError extends ArticleState {
  final String message;
  const ArticleError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final ArticleRepository repository;

  ArticleBloc({required this.repository}) : super(ArticleInitial()) {
    on<LoadArticles>(_onLoadArticles);
    on<SearchArticles>(_onSearchArticles);
  }

  Future<void> _onLoadArticles(
    LoadArticles event,
    Emitter<ArticleState> emit,
  ) async {
    // 1. Initial Load vs Load More
    final isLoadMore = event.offset != null && event.offset! > 0;

    if (!isLoadMore) {
      // Only emit Initial Loading if strictly necessary or refreshing
      if (state is ArticleInitial) {
        emit(ArticleLoading());
      }

      // 2. Fetch Cache First (Only for initial load)
      // Check cache if limit is reasonable (e.g. <= 10) to support Carousel
      if (event.limit == null || (event.limit != null && event.limit! <= 10)) {
        final cacheResult = await repository.getCachedArticles();
        cacheResult.fold((failure) {}, (articles) {
          if (articles.isNotEmpty) {
            // If we asked for specific limit (e.g. 5) but cache has 10, slice it
            var finalArticles = articles;
            if (event.limit != null && articles.length > event.limit!) {
              finalArticles = articles.take(event.limit!).toList();
            }
            emit(ArticleLoaded(finalArticles, isCache: true));
          }
        });
      }
    }

    // 3. Fetch Remote & Update
    final remoteResult = await repository.fetchRemoteArticles(
      lang: event.lang,
      limit: event.limit,
      offset: event.offset,
    );

    remoteResult.fold(
      (failure) {
        if (!isLoadMore && state is! ArticleLoaded) {
          emit(const ArticleError("articleErrorLoad"));
        }
        // If load more fails, we optionally could emit a specific state or just do nothing
      },
      (newArticles) {
        final hasReachedMax =
            newArticles.isEmpty ||
            (event.limit != null && newArticles.length < event.limit!);

        if (state is ArticleLoaded && isLoadMore) {
          final currentArticles = (state as ArticleLoaded).articles;
          emit(
            ArticleLoaded(
              currentArticles + newArticles,
              isCache: false,
              hasReachedMax: hasReachedMax,
            ),
          );
        } else {
          emit(
            ArticleLoaded(
              newArticles,
              isCache: false,
              hasReachedMax: hasReachedMax,
            ),
          );
        }
      },
    );
  }

  Future<void> _onSearchArticles(
    SearchArticles event,
    Emitter<ArticleState> emit,
  ) async {
    emit(ArticleLoading());

    final result = await repository.fetchRemoteArticles(
      lang: event.lang,
      search: event.query,
    );

    result.fold(
      (failure) => emit(
        const ArticleError("articleErrorSearch"),
      ), // Key for localization
      (articles) => emit(ArticleLoaded(articles, isCache: false)),
    );
  }
}
