import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/ayah.dart';
import '../../domain/entities/surah.dart';
import '../../domain/repositories/quran_repository.dart';
import '../datasources/quran_local_data_source.dart';

@LazySingleton(as: QuranRepository)
class QuranRepositoryImpl implements QuranRepository {
  final QuranLocalDataSource _localDataSource;

  QuranRepositoryImpl(this._localDataSource);

  @override
  Future<Either<String, List<Surah>>> getSurahs() async {
    try {
      final surahs = await _localDataSource.getSurahs();
      return Right(surahs);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Ayah>>> getAyahs(int surahId) async {
    try {
      final ayahs = await _localDataSource.getAyahs(surahId);
      return Right(ayahs);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
