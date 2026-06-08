import '../../data/models/fasting_model.dart';

enum FastingStatus { initial, loading, loaded, error }

class FastingState {
  final List<FastingModel> items;
  final String query;
  final FastingStatus status;
  final String? errorMessage;

  const FastingState({
    this.items = const [],
    this.query = '',
    this.status = FastingStatus.initial,
    this.errorMessage,
  });

  List<FastingModel> get filteredItems {
    if (query.isEmpty) return items;
    final q = query.toLowerCase();
    return items.where((item) {
      return item.title.toLowerCase().contains(q) ||
          item.description.toLowerCase().contains(q);
    }).toList();
  }

  FastingState copyWith({
    List<FastingModel>? items,
    String? query,
    FastingStatus? status,
    String? errorMessage,
  }) {
    return FastingState(
      items: items ?? this.items,
      query: query ?? this.query,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
