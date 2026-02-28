import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/article_repository.dart';
import '../datasources/article_local_data_source.dart';
import '../datasources/article_remote_data_source.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleLocalDataSource localDataSource;
  final ArticleRemoteDataSource remoteDataSource;

  ArticleRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<Article>>> getCachedArticles() async {
    try {
      final result = await localDataSource.getCachedArticles();
      return Right(result.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<Article>>> fetchRemoteArticles({
    String? lang,
    String? search,
    int? limit,
    int? offset,
  }) async {
    try {
      final articles = await remoteDataSource.getArticles(
        lang: lang,
        search: search,
        limit: limit,
        offset: offset,
      );
      // Only cache if it's the default fetch (no search, no offset, default limit)
      // or deciding not to cache pagination for simplicity now
      if (search == null && offset == null) {
        await localDataSource.cacheArticles(articles);
      }
      return Right(articles.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
