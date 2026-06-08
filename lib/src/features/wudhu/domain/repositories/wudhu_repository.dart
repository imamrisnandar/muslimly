import '../../data/models/wudhu_model.dart';

abstract interface class WudhuRepository {
  Future<List<WudhuModel>> getWudhuContent(String locale);
}
