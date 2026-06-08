import '../../data/models/wudhu_model.dart';

enum WudhuStatus { initial, loading, loaded, error }

class WudhuState {
  final List<WudhuModel> items;
  final String query;
  final WudhuStatus status;
  final String? errorMessage;

  const WudhuState({
    this.items = const [],
    this.query = '',
    this.status = WudhuStatus.initial,
    this.errorMessage,
  });

  List<WudhuModel> get filteredItems {
    if (query.isEmpty) return items;
    final q = query.toLowerCase();
    return items.where((item) {
      return item.title.toLowerCase().contains(q) ||
          item.description.toLowerCase().contains(q);
    }).toList();
  }

  WudhuState copyWith({
    List<WudhuModel>? items,
    String? query,
    WudhuStatus? status,
    String? errorMessage,
  }) {
    return WudhuState(
      items: items ?? this.items,
      query: query ?? this.query,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
