import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/search_response.dart';
import '../repositories/quran_repository.dart';

@lazySingleton
class SearchAyahs {
  final QuranRepository repository;

  SearchAyahs(this.repository);

  Future<Either<String, SearchResponse>> call(
    String query, {
    int page = 1,
    String languageCode = 'id',
  }) {
    return repository.searchAyahs(
      query,
      page: page,
      languageCode: languageCode,
    );
  }
}
