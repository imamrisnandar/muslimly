import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_wudhu_content.dart';
import 'wudhu_state.dart';

@injectable
class WudhuCubit extends Cubit<WudhuState> {
  final GetWudhuContent _getWudhuContent;

  WudhuCubit(this._getWudhuContent) : super(const WudhuState());

  Future<void> loadContent(String locale) async {
    if (state.status == WudhuStatus.loading) return;
    emit(state.copyWith(status: WudhuStatus.loading));
    try {
      final items = await _getWudhuContent(locale);
      emit(state.copyWith(items: items, status: WudhuStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: WudhuStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void onSearchChanged(String query) {
    emit(state.copyWith(query: query));
  }
}
