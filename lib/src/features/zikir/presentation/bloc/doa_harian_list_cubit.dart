import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_zikir_content.dart';
import 'doa_harian_list_state.dart';

class DoaHarianListCubit extends Cubit<DoaHarianListState> {
  final GetZikirContent _getZikirContent;

  DoaHarianListCubit(this._getZikirContent)
    : super(const DoaHarianListState());

  Future<void> loadContent(Locale locale) async {
    final items = await _getZikirContent(ZikirCategory.daily, locale);
    emit(state.copyWith(allItems: items, isLoading: false));
  }

  void search(String query) {
    emit(state.copyWith(searchQuery: query));
  }
}
