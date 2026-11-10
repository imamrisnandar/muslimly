import '../../../../core/database/database_service.dart';
import '../../domain/entities/excused_period.dart';
import '../../domain/repositories/excused_period_repository.dart';

class ExcusedPeriodRepositoryImpl implements ExcusedPeriodRepository {
  final DatabaseService _db;
  ExcusedPeriodRepositoryImpl(this._db);

  @override
  Future<List<ExcusedPeriod>> all() async =>
      (await _db.getExcusedPeriods()).map(ExcusedPeriod.fromMap).toList();

  @override
  Future<void> add(ExcusedPeriod p) async {
    await _db.insertExcusedPeriod(p.toMap());
  }

  @override
  Future<void> end(int id, String endDate) =>
      _db.updateExcusedPeriod(id, {'end_date': endDate});

  @override
  Future<void> delete(int id) => _db.deleteExcusedPeriod(id);
}
