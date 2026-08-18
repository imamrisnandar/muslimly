import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/search_response.dart';
import '../repositories/quran_repository.dart';

class SearchAyahs {
  final QuranRepository repository;

  SearchAyahs(this.repository);

  Future<Either<Failure, SearchResponse>> call(
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
