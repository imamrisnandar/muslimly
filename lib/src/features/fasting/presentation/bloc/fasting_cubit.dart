import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_fasting_content.dart';
import 'fasting_state.dart';

@injectable
class FastingCubit extends Cubit<FastingState> {
  final GetFastingContent _getFastingContent;

  FastingCubit(this._getFastingContent) : super(const FastingState());

  Future<void> loadContent(String locale) async {
    if (state.status == FastingStatus.loading) return;
    emit(state.copyWith(status: FastingStatus.loading));
    try {
      final items = await _getFastingContent(locale);
      items.sort((a, b) => a.order.compareTo(b.order));
      emit(state.copyWith(items: items, status: FastingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: FastingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void onSearchChanged(String query) {
    emit(state.copyWith(query: query));
  }
}
