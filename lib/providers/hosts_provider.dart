// // // lib/providers/hosts_provider.dart
// // //
// // // Replaces dummyHosts with a real API call to GET /api/hosts.
// // // Supports filtering, pagination, and pull-to-refresh.
// // //
// // // Usage in hosts_grid_view.dart:
// // //   final hostsAsync = ref.watch(hostsProvider);
// // //   hostsAsync.when(data: ..., loading: ..., error: ...);

// // import 'package:flutter/foundation.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';

// // import 'package:cheerchat/models/host_model.dart';
// // import 'package:cheerchat/providers/filters_provider.dart';
// // import 'package:cheerchat/services/api_service.dart';

// // // ─────────────────────────────────────────────────────────────────────────────
// // // Main provider — watches filters and re-fetches automatically
// // // ─────────────────────────────────────────────────────────────────────────────

// // final hostsProvider =
// //     AsyncNotifierProvider<HostsNotifier, List<HostModel>>(
// //       HostsNotifier.new,
// //     );

// // class HostsNotifier extends AsyncNotifier<List<HostModel>> {
// //   int _currentPage = 1;
// //   bool _hasMore = true;

// //   @override
// //   Future<List<HostModel>> build() async {
// //     final filters = ref.watch(filtersProvider);
// //     _currentPage = 1;
// //     _hasMore = true;
// //     return _fetchHosts(filters, page: 1);
// //   }

// //   // FiltersScreen stores display names ("India") — API needs ISO codes ("IN")
// //   static const _countryNameToCode = {
// //     'India': 'IN', 'Bangladesh': 'BD', 'Pakistan': 'PK',
// //     'Argentina': 'AR', 'Australia': 'AU', 'Brazil': 'BR',
// //     'Bahrain': 'BH', 'Canada': 'CA', 'Colombia': 'CO',
// //     'Egypt': 'EG', 'Germany': 'DE', 'Indonesia': 'ID',
// //     'Morocco': 'MA', 'Nepal': 'NP', 'Philippines': 'PH',
// //     'Saudi Arabia': 'SA', 'Turkey': 'TR', 'United States': 'US',
// //     'United Kingdom': 'GB', 'United Arab Emirates': 'AE',
// //     'Ukraine': 'UA', 'Venezuela': 'VE', 'Vietnam': 'VN',
// //   };

// //   Future<List<HostModel>> _fetchHosts(
// //     FiltersState filters, {
// //     required int page,
// //   }) async {
// //     final api = ref.read(apiServiceProvider);

// //     final query = <String, String>{
// //       'page': page.toString(),
// //       'limit': '20',
// //     };

// //     if (filters.selectedCountry != null) {
// //       query['country'] =
// //           _countryNameToCode[filters.selectedCountry] ??
// //           filters.selectedCountry!;
// //     }
// //     if (filters.selectedLanguage != null) {
// //       query['language'] = filters.selectedLanguage!;
// //     }

// //     final res = await api.get('/api/hosts', query: query);

// //     if (!res.ok) {
// //       debugPrint('[HostsProvider] API error: ${res.error}');
// //       throw Exception(res.error ?? 'Failed to load hosts');
// //     }

// //     final hostMaps = res.list('hosts');
// //     final hosts = hostMaps.map((m) => HostModel.fromJson(m)).toList();

// //     _hasMore = hosts.length >= 20;
// //     return hosts;
// //   }

// //   /// Load next page (for infinite scroll).
// //   Future<void> loadMore() async {
// //     if (!_hasMore) return;

// //     final currentHosts = state.asData?.value ?? [];
// //     final filters = ref.read(filtersProvider);
// //     _currentPage++;

// //     try {
// //       final moreHosts = await _fetchHosts(filters, page: _currentPage);
// //       state = AsyncData([...currentHosts, ...moreHosts]);
// //     } catch (e) {
// //       _currentPage--; // Revert on failure
// //       debugPrint('[HostsProvider] loadMore failed: $e');
// //     }
// //   }

// //   /// Pull-to-refresh — resets to page 1.
// //   Future<void> refresh() async {
// //     _currentPage = 1;
// //     _hasMore = true;
// //     ref.invalidateSelf();
// //   }

// //   bool get hasMore => _hasMore;
// // }

// // // ─────────────────────────────────────────────────────────────────────────────
// // // Single host detail provider
// // // ─────────────────────────────────────────────────────────────────────────────

// // final hostDetailProvider = FutureProvider.family<Map<String, dynamic>?, String>(
// //   (ref, userId) async {
// //     final api = ref.read(apiServiceProvider);
// //     final res = await api.get('/api/hosts/$userId');
// //     if (!res.ok) return null;
// //     return res.data;
// //   },
// // );
// // lib/providers/hosts_provider.dart
// //
// // Replaces dummyHosts with a real API call to GET /api/hosts.
// // Supports filtering, pagination, and pull-to-refresh.
// //
// // Usage in hosts_grid_view.dart:
// //   final hostsAsync = ref.watch(hostsProvider);
// //   hostsAsync.when(data: ..., loading: ..., error: ...);

// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:cheerchat/models/host_model.dart';
// import 'package:cheerchat/providers/filters_provider.dart';
// import 'package:cheerchat/providers/follow_provider.dart';
// import 'package:cheerchat/services/api_service.dart';

// // ─────────────────────────────────────────────────────────────────────────────
// // Main provider — watches filters and re-fetches automatically
// // ─────────────────────────────────────────────────────────────────────────────

// final hostsProvider =
//     AsyncNotifierProvider<HostsNotifier, List<HostModel>>(
//       HostsNotifier.new,
//     );

// class HostsNotifier extends AsyncNotifier<List<HostModel>> {
//   int _currentPage = 1;
//   bool _hasMore = true;

//   @override
//   Future<List<HostModel>> build() async {
//     final filters = ref.watch(filtersProvider);
//     _currentPage = 1;
//     _hasMore = true;
//     return _fetchHosts(filters, page: 1);
//   }

//   // FiltersScreen stores display names ("India") — API needs ISO codes ("IN")
//   static const _countryNameToCode = {
//     'India': 'IN',
//     'Bangladesh': 'BD',
//     'Pakistan': 'PK',
//     'Argentina': 'AR',
//     'Australia': 'AU',
//     'Brazil': 'BR',
//     'Bahrain': 'BH',
//     'Canada': 'CA',
//     'Colombia': 'CO',
//     'Egypt': 'EG',
//     'Germany': 'DE',
//     'Indonesia': 'ID',
//     'Morocco': 'MA',
//     'Nepal': 'NP',
//     'Philippines': 'PH',
//     'Saudi Arabia': 'SA',
//     'Turkey': 'TR',
//     'United States': 'US',
//     'United Kingdom': 'GB',
//     'United Arab Emirates': 'AE',
//     'Ukraine': 'UA',
//     'Venezuela': 'VE',
//     'Vietnam': 'VN',
//   };

//   Future<List<HostModel>> _fetchHosts(
//     FiltersState filters, {
//     required int page,
//   }) async {
//     final api = ref.read(apiServiceProvider);

//     final query = <String, String>{
//       'page': page.toString(),
//       'limit': '20',
//     };

//     if (filters.selectedCountry != null) {
//       query['country'] =
//           _countryNameToCode[filters.selectedCountry] ??
//           filters.selectedCountry!;
//     }
//     if (filters.selectedLanguage != null) {
//       query['language'] = filters.selectedLanguage!;
//     }

//     final res = await api.get('/api/hosts', query: query);

//     if (!res.ok) {
//       debugPrint('[HostsProvider] API error: ${res.error}');
//       throw Exception(res.error ?? 'Failed to load hosts');
//     }

//     final hostMaps = res.list('hosts');
//     final hosts = hostMaps
//         .map((m) => HostModel.fromJson(m))
//         .toList();

//     // Seed follow state from API so host_card hearts are correct on app start
//     final followNotifier = ref.read(
//       followNotifierProvider.notifier,
//     );
//     for (final host in hosts) {
//       followNotifier.setInitial(host.userId, host.isFollowing);
//     }

//     _hasMore = hosts.length >= 20;
//     return hosts;
//   }

//   /// Load next page (for infinite scroll).
//   Future<void> loadMore() async {
//     if (!_hasMore) return;

//     final currentHosts = state.asData?.value ?? [];
//     final filters = ref.read(filtersProvider);
//     _currentPage++;

//     try {
//       final moreHosts = await _fetchHosts(
//         filters,
//         page: _currentPage,
//       );
//       state = AsyncData([...currentHosts, ...moreHosts]);
//     } catch (e) {
//       _currentPage--; // Revert on failure
//       debugPrint('[HostsProvider] loadMore failed: $e');
//     }
//   }

//   /// Pull-to-refresh — resets to page 1.
//   Future<void> refresh() async {
//     _currentPage = 1;
//     _hasMore = true;
//     ref.invalidateSelf();
//   }

//   bool get hasMore => _hasMore;
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Single host detail provider
// // ─────────────────────────────────────────────────────────────────────────────

// final hostDetailProvider =
//     FutureProvider.family<Map<String, dynamic>?, String>((
//       ref,
//       userId,
//     ) async {
//       final api = ref.read(apiServiceProvider);
//       final res = await api.get('/api/hosts/$userId');
//       if (!res.ok) return null;
//       return res.data;
//     });
// lib/providers/hosts_provider.dart
//
// Replaces dummyHosts with a real API call to GET /api/hosts.
// Supports filtering, pagination, and pull-to-refresh.
//
// Usage in hosts_grid_view.dart:
//   final hostsAsync = ref.watch(hostsProvider);
//   hostsAsync.when(data: ..., loading: ..., error: ...);

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cheerchat/models/host_model.dart';
import 'package:cheerchat/providers/filters_provider.dart';
import 'package:cheerchat/providers/follow_provider.dart';
import 'package:cheerchat/services/api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Main provider — watches filters and re-fetches automatically
// ─────────────────────────────────────────────────────────────────────────────

final hostsProvider =
    AsyncNotifierProvider<HostsNotifier, List<HostModel>>(
      HostsNotifier.new,
    );

class HostsNotifier extends AsyncNotifier<List<HostModel>> {
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  Future<List<HostModel>> build() async {
    final filters = ref.watch(filtersProvider);
    _currentPage = 1;
    _hasMore = true;
    return _fetchHosts(filters, page: 1);
  }

  // FiltersScreen stores display names ("India") — API needs ISO codes ("IN")
  static const _countryNameToCode = {
    'India': 'IN',
    'Bangladesh': 'BD',
    'Pakistan': 'PK',
    'Argentina': 'AR',
    'Australia': 'AU',
    'Brazil': 'BR',
    'Bahrain': 'BH',
    'Canada': 'CA',
    'Colombia': 'CO',
    'Egypt': 'EG',
    'Germany': 'DE',
    'Indonesia': 'ID',
    'Morocco': 'MA',
    'Nepal': 'NP',
    'Philippines': 'PH',
    'Saudi Arabia': 'SA',
    'Turkey': 'TR',
    'United States': 'US',
    'United Kingdom': 'GB',
    'United Arab Emirates': 'AE',
    'Ukraine': 'UA',
    'Venezuela': 'VE',
    'Vietnam': 'VN',
  };

  Future<List<HostModel>> _fetchHosts(
    FiltersState filters, {
    required int page,
  }) async {
    final api = ref.read(apiServiceProvider);

    final query = <String, String>{
      'page': page.toString(),
      'limit': '20',
    };

    if (filters.selectedCountry != null) {
      query['country'] =
          _countryNameToCode[filters.selectedCountry] ??
          filters.selectedCountry!;
    }
    if (filters.selectedLanguage != null) {
      query['language'] = filters.selectedLanguage!;
    }

    final res = await api.get('/api/hosts', query: query);

    if (!res.ok) {
      debugPrint('[HostsProvider] API error: ${res.error}');
      throw Exception(res.error ?? 'Failed to load hosts');
    }

    final hostMaps = res.list('hosts');
    final hosts = hostMaps
        .map((m) => HostModel.fromJson(m))
        .toList();

    // Seed follow state from API so host_card hearts are correct on app start
    final followNotifier = ref.read(
      followNotifierProvider.notifier,
    );
    for (final host in hosts) {
      followNotifier.setInitial(host.userId, host.isFollowing);
    }

    _hasMore = hosts.length >= 20;
    return hosts;
  }

  /// Load next page (for infinite scroll).
  Future<void> loadMore() async {
    if (!_hasMore) return;

    final currentHosts = state.asData?.value ?? [];
    final filters = ref.read(filtersProvider);
    _currentPage++;

    try {
      final moreHosts = await _fetchHosts(
        filters,
        page: _currentPage,
      );
      state = AsyncData([...currentHosts, ...moreHosts]);
    } catch (e) {
      _currentPage--; // Revert on failure
      debugPrint('[HostsProvider] loadMore failed: $e');
    }
  }

  /// Pull-to-refresh — resets to page 1.
  Future<void> refresh() async {
    _currentPage = 1;
    _hasMore = true;
    ref.invalidateSelf();
  }

  bool get hasMore => _hasMore;
}

// ─────────────────────────────────────────────────────────────────────────────
// Single host detail provider
// ─────────────────────────────────────────────────────────────────────────────

final hostDetailProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((
      ref,
      userId,
    ) async {
      final api = ref.read(apiServiceProvider);
      final res = await api.get('/api/hosts/$userId');
      if (!res.ok) return null;
      return res.data;
    });
