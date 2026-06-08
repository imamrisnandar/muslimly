import '../../data/models/fasting_model.dart';

abstract interface class FastingRepository {
  Future<List<FastingModel>> getFastingContent(String locale);
}
