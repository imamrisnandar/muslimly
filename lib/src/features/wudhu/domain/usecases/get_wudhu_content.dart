import '../repositories/wudhu_repository.dart';
import '../../data/models/wudhu_model.dart';

class GetWudhuContent {
  final WudhuRepository _repository;
  const GetWudhuContent(this._repository);

  Future<List<WudhuModel>> call(String locale) =>
      _repository.getWudhuContent(locale);
}
