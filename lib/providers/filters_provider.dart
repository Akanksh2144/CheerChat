import 'package:flutter_riverpod/legacy.dart';

class FiltersNotifier extends StateNotifier<List<String>> {
  FiltersNotifier() : super([]);
}

final filtersProvider =
    StateNotifierProvider<FiltersNotifier, List<String>>(
      (ref) => FiltersNotifier(),
    );
