import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../entities/zikir_item.dart';
import '../repositories/zikir_repository.dart';

enum ZikirCategory { morning, evening, prayer, daily }

@injectable
class GetZikirContent {
  final ZikirRepository _repository;
  const GetZikirContent(this._repository);

  Future<List<ZikirItem>> call(ZikirCategory category, Locale locale) {
    return switch (category) {
      ZikirCategory.morning => _repository.getMorningZikir(locale),
      ZikirCategory.evening => _repository.getEveningZikir(locale),
      ZikirCategory.prayer  => _repository.getPrayerZikir(locale),
      ZikirCategory.daily   => _repository.getDailyDzikir(locale),
    };
  }
}
