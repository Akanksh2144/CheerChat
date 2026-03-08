// lib/providers/filters_provider.dart
//
// Holds the active filter state for the hosts grid.
// FiltersScreen writes to this — HostsGridViewScreen reads from it.
// No Navigator.pop() result-passing needed.

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class FiltersState {
  const FiltersState({
    this.selectedCountry, // null = "All"
    this.selectedLanguage, // null = "All"
    this.searchId, // null = no ID search active
  });

  final String? selectedCountry;
  final String? selectedLanguage;
  final String? searchId;

  bool get hasActiveFilter =>
      selectedCountry != null ||
      selectedLanguage != null ||
      (searchId != null && searchId!.isNotEmpty);

  FiltersState copyWith({
    String? selectedCountry,
    String? selectedLanguage,
    String? searchId,
    // Pass explicit null to CLEAR a field:
    bool clearCountry = false,
    bool clearLanguage = false,
    bool clearId = false,
  }) {
    return FiltersState(
      selectedCountry: clearCountry
          ? null
          : (selectedCountry ?? this.selectedCountry),
      selectedLanguage: clearLanguage
          ? null
          : (selectedLanguage ?? this.selectedLanguage),
      searchId: clearId ? null : (searchId ?? this.searchId),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FiltersState &&
      other.selectedCountry == selectedCountry &&
      other.selectedLanguage == selectedLanguage &&
      other.searchId == searchId;

  @override
  int get hashCode =>
      Object.hash(selectedCountry, selectedLanguage, searchId);
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class FiltersNotifier extends Notifier<FiltersState> {
  @override
  FiltersState build() => const FiltersState();

  void setCountry(String? country) {
    state = FiltersState(selectedCountry: country);
  }

  void setLanguage(String? language) {
    state = FiltersState(selectedLanguage: language);
  }

  void setSearchId(String? id) {
    state = FiltersState(
      searchId: id?.isEmpty == true ? null : id,
    );
  }

  void clearAll() {
    state = const FiltersState();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final filtersProvider =
    NotifierProvider<FiltersNotifier, FiltersState>(
      FiltersNotifier.new,
    );
