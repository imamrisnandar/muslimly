import '../../data/models/tajweed_model.dart';

abstract class TajweedRepository {
  Future<List<TajweedCategory>> getTajweedContent(String languageCode);
}
