import 'package:dartz/dartz.dart';
import '../entities/ayah.dart';
import '../entities/surah.dart';

abstract class QuranRepository {
  Future<Either<String, List<Surah>>> getSurahs();
  Future<Either<String, List<Ayah>>> getAyahs(int surahId);
}
