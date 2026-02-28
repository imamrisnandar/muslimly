import 'package:dio/dio.dart';
import '../models/article_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class ArticleRemoteDataSource {
  Future<List<ArticleModel>> getArticles({
    String? lang,
    String? search,
    int? limit,
    int? offset,
  });
}

class ArticleRemoteDataSourceImpl implements ArticleRemoteDataSource {
  final Dio client;

  ArticleRemoteDataSourceImpl(this.client);

  @override
  Future<List<ArticleModel>> getArticles({
    String? lang,
    String? search,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, dynamic>{};
    if (lang != null) queryParams['lang'] = lang;
    if (search != null) queryParams['search'] = search;
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;

    final response = await client.get(
      'articles',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = response.data;
      return jsonList.map((json) => ArticleModel.fromJson(json)).toList();
    } else {
      throw ServerException();
    }
  }
}
