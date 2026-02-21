import '../../../../core/database/database_service.dart';
import '../models/article_model.dart';

abstract class ArticleLocalDataSource {
  Future<List<ArticleModel>> getCachedArticles();
  Future<void> cacheArticles(List<ArticleModel> articles);
}

class ArticleLocalDataSourceImpl implements ArticleLocalDataSource {
  final DatabaseService databaseService;

  ArticleLocalDataSourceImpl(this.databaseService);

  @override
  Future<List<ArticleModel>> getCachedArticles() async {
    final list = await databaseService.getCachedArticles();
    return list.map((json) => ArticleModel.fromJson(json)).toList();
  }

  @override
  Future<void> cacheArticles(List<ArticleModel> articles) async {
    final list = articles.map((article) => article.toJson()).toList();
    await databaseService.cacheArticles(list);
  }
}
