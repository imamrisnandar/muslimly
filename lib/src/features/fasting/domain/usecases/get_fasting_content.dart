import '../repositories/fasting_repository.dart';
import '../../data/models/fasting_model.dart';

class GetFastingContent {
  final FastingRepository _repository;
  const GetFastingContent(this._repository);

  Future<List<FastingModel>> call(String locale) =>
      _repository.getFastingContent(locale);
}
