import 'package:equatable/equatable.dart';
import '../../domain/entities/zikir_item.dart';

class DoaHarianListState extends Equatable {
  final List<ZikirItem> allItems;
  final String searchQuery;
  final bool isLoading;

  const DoaHarianListState({
    this.allItems = const [],
    this.searchQuery = '',
    this.isLoading = true,
  });

  List<ZikirItem> get filteredItems {
    if (searchQuery.isEmpty) return allItems;
    final query = searchQuery.toLowerCase();
    return allItems
        .where(
          (item) =>
              item.title.toLowerCase().contains(query) ||
              item.translation.toLowerCase().contains(query),
        )
        .toList();
  }

  DoaHarianListState copyWith({
    List<ZikirItem>? allItems,
    String? searchQuery,
    bool? isLoading,
  }) {
    return DoaHarianListState(
      allItems: allItems ?? this.allItems,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [allItems, searchQuery, isLoading];
}
