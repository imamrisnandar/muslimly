import '../../data/models/tajweed_model.dart';
import '../../data/repositories/tajweed_repository.dart';

class GetTajweedContent {
  final TajweedRepository _repository;
  const GetTajweedContent(this._repository);

  Future<List<TajweedCategory>> call(String languageCode) {
    return _repository.getTajweedContent(languageCode);
  }
}
