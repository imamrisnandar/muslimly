import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/article.dart';

abstract class ArticleRepository {
  Future<Either<Failure, List<Article>>> getCachedArticles();
  Future<Either<Failure, List<Article>>> fetchRemoteArticles({
    String? lang,
    String? search,
    int? limit,
    int? offset,
  });
}
