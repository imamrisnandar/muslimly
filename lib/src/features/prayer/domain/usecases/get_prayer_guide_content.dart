import '../../data/models/prayer_guide_model.dart';
import '../../data/repositories/prayer_guide_repository.dart';

class GetPrayerGuideContent {
  final PrayerGuideRepository _repository;
  const GetPrayerGuideContent(this._repository);

  Future<List<PrayerGuideCategory>> call(String locale) {
    return _repository.getPrayerContent(locale);
  }
}
