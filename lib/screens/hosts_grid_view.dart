// // import "package:flutter/material.dart";
// // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:cheerchat/data/hosts_data.dart';
// // import 'package:cheerchat/screens/filters_screen.dart';
// // import 'package:cheerchat/widgets/cards/host_card.dart';
// // import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

// // class HostsGridViewScreen extends StatefulWidget {
// //   const HostsGridViewScreen({super.key});

// //   @override
// //   State<HostsGridViewScreen> createState() {
// //     return _HostsGridViewScreenState();
// //   }
// // }

// // class _HostsGridViewScreenState
// //     extends State<HostsGridViewScreen>
// //     with SingleTickerProviderStateMixin {
// //   late AnimationController _animationController;
// //   DateTime? lastBackPress;

// //   void _openFilterOverlay() {
// //     pushScreenWithoutNavBar(context, FiltersScreen());
// //   }

// //   @override
// //   void initState() {
// //     super.initState();
// //     _animationController = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 300),
// //       lowerBound: 0,
// //       upperBound: 1,
// //     );
// //     _animationController.forward();
// //   }

// //   @override
// //   void dispose() {
// //     _animationController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text(
// //           "Connect",
// //           // EmojiConverter.fromAlpha2CountryCode('IN'),
// //           style: GoogleFonts.lato(
// //             fontSize: 30,
// //             color: Colors.black,
// //           ),
// //         ),
// //         actions: [
// //           IconButton(
// //             icon: const FaIcon(FontAwesomeIcons.sliders),
// //             onPressed: () {
// //               _openFilterOverlay();
// //             },
// //           ),
// //           const SizedBox(width: 10),
// //         ],
// //       ),
// //       body: AnimatedBuilder(
// //         animation: _animationController,
// //         child: SafeArea(
// //           child: Padding(
// //             padding: const EdgeInsets.only(
// //               top: 5,
// //               left: 16,
// //               right: 16,
// //             ),
// //             child: GridView.builder(
// //               itemCount: hostData.length,
// //               // cacheExtent: 800,
// //               gridDelegate:
// //                   const SliverGridDelegateWithFixedCrossAxisCount(
// //                     crossAxisCount: 2,
// //                     mainAxisSpacing: 14.0,
// //                     crossAxisSpacing: 14.0,
// //                     childAspectRatio: 6 / 8,
// //                   ),
// //               itemBuilder: (context, index) {
// //                 final host = hostData[index];
// //                 return HostCard(
// //                   key: ValueKey(hostData[index]),
// //                   host: host,
// //                 );
// //               },
// //             ),
// //           ),
// //         ),
// //         builder: (context, child) => Padding(
// //           padding: EdgeInsetsGeometry.only(
// //             top: 100 - _animationController.value * 100,
// //           ),
// //           child: child,
// //         ),
// //       ),
// //     );
// //   }
// // }

// lib/screens/hosts_grid_view.dart

import 'package:cheerchat/data/hosts_data.dart';
import 'package:cheerchat/models/host_model.dart';
import 'package:cheerchat/providers/filters_provider.dart';
import 'package:cheerchat/screens/filters_screen.dart';
import 'package:cheerchat/widgets/cards/host_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

// Display name → ISO code — resolves the country name stored by FiltersScreen
// back to the ISO code that HostModel.countryCode uses.
const Map<String, String> _countryNameToCode = {
  'India': 'IN', 'Bangladesh': 'BD', 'Pakistan': 'PK',
  'Argentina': 'AR', 'Australia': 'AU', 'Brazil': 'BR',
  'Bahrain': 'BH', 'Canada': 'CA', 'Colombia': 'CO',
  'Egypt': 'EG', 'Germany': 'DE', 'Indonesia': 'ID',
  'Morocco': 'MA', 'Nepal': 'NP', 'Philippines': 'PH',
  'Saudi Arabia': 'SA', 'Turkey': 'TR', 'United States': 'US',
  'United Kingdom': 'GB', 'United Arab Emirates': 'AE',
  'Ukraine': 'UA', 'Venezuela': 'VE', 'Vietnam': 'VN',
};


class HostsGridViewScreen extends ConsumerStatefulWidget {
  const HostsGridViewScreen({super.key});

  @override
  ConsumerState<HostsGridViewScreen> createState() =>
      _HostsGridViewScreenState();
}

class _HostsGridViewScreenState extends ConsumerState<HostsGridViewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      lowerBound: 0,
      upperBound: 1,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Filter logic — runs on the client against dummyHosts (or the real API
  // list once wired up).  Online hosts always sort to the top.
  // -------------------------------------------------------------------------
  List<HostModel> _applyFilters(
    List<HostModel> all,
    FiltersState filters,
  ) {
    List<HostModel> result = List.of(all);

    // ID search — exact match on publicId, ignores other filters
    if (filters.searchId != null && filters.searchId!.isNotEmpty) {
      final id = int.tryParse(filters.searchId!);
      if (id != null) {
        result = result.where((h) => h.publicId == id).toList();
      } else {
        result = [];
      }
      return result; // no further filtering needed
    }

    // Country filter
    if (filters.selectedCountry != null) {
      result = result
          .where((h) => h.countryCode == (_countryNameToCode[filters.selectedCountry] ?? filters.selectedCountry))
          .toList();
    }

    // Language filter
    if (filters.selectedLanguage != null) {
      result = result
          .where((h) => h.language == filters.selectedLanguage)
          .toList();
    }

    // Sort: online → busy → offline
    result.sort((a, b) {
      int rank(HostStatus s) {
        switch (s) {
          case HostStatus.online:
            return 0;
          case HostStatus.busy:
            return 1;
          case HostStatus.offline:
            return 2;
        }
      }
      return rank(a.status).compareTo(rank(b.status));
    });

    return result;
  }

  void _openFilters() {
    pushScreenWithoutNavBar(context, const FiltersScreen());
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(filtersProvider);
    final filteredHosts = _applyFilters(dummyHosts, filters);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Connect',
          style: GoogleFonts.lato(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          // Active filter badge — shows a pink dot when filters are on
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.sliders),
                onPressed: _openFilters,
              ),
              if (filters.hasActiveFilter)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Colors.pink,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => Opacity(
          opacity: _animationController.value,
          child: Transform.translate(
            offset: Offset(0, 40 * (1 - _animationController.value)),
            child: child,
          ),
        ),
        child: filteredHosts.isEmpty
            ? _buildEmptyState(filters)
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: GridView.builder(
                    itemCount: filteredHosts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 6 / 8,
                    ),
                    itemBuilder: (context, index) {
                      return HostCard(
                        key: ValueKey(filteredHosts[index].userId),
                        host: filteredHosts[index],
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState(FiltersState filters) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(
              FontAwesomeIcons.magnifyingGlass,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              filters.searchId != null
                  ? 'No host found with ID "${filters.searchId}"'
                  : 'No hosts match your filters',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () => ref.read(filtersProvider.notifier).clearAll(),
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Clear filters'),
            ),
          ],
        ),
      ),
    );
  }
}