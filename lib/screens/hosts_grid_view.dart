
// lib/screens/hosts_grid_view.dart

import 'package:cheerchat/data/hosts_data.dart';
import 'package:cheerchat/models/host_model.dart';
import 'package:cheerchat/providers/filters_provider.dart';
import 'package:cheerchat/screens/filters_screen.dart';
import 'package:cheerchat/theme/app_colors.dart';
import 'package:cheerchat/utils/app_transitions.dart';
import 'package:cheerchat/providers/connectivity_provider.dart';
import 'package:cheerchat/widgets/cards/host_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

// Display name → ISO code — resolves the country name stored by FiltersScreen
// back to the ISO code that HostModel.countryCode uses.
const Map<String, String> _countryNameToCode = {
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

class HostsGridViewScreen extends ConsumerStatefulWidget {
  const HostsGridViewScreen({super.key});

  @override
  ConsumerState<HostsGridViewScreen> createState() =>
      _HostsGridViewScreenState();
}

class _HostsGridViewScreenState
    extends ConsumerState<HostsGridViewScreen>
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

  List<HostModel> _applyFilters(
    List<HostModel> all,
    FiltersState filters,
  ) {
    List<HostModel> result = List.of(all);

    if (filters.searchId != null &&
        filters.searchId!.isNotEmpty) {
      final id = int.tryParse(filters.searchId!);
      result = id != null
          ? result.where((h) => h.publicId == id).toList()
          : [];
      return result;
    }

    if (filters.selectedCountry != null) {
      result = result
          .where(
            (h) =>
                h.countryCode ==
                (_countryNameToCode[filters.selectedCountry] ??
                    filters.selectedCountry),
          )
          .toList();
    }

    if (filters.selectedLanguage != null) {
      result = result
          .where((h) => h.language == filters.selectedLanguage)
          .toList();
    }

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

  void _openFilters() => Navigator.of(
    context,
    rootNavigator: true,
  ).push(AppTransitions.slideUp(const FiltersScreen()));

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final filters = ref.watch(filtersProvider);
    final filteredHosts = _applyFilters(dummyHosts, filters);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        elevation: 0,
        title: Text(
          'Connect',
          style: GoogleFonts.lato(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: c.textPrimary,
          ),
        ),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.sliders,
                  color: c.textPrimary,
                ),
                onPressed: _openFilters,
              ),
              if (filters.hasActiveFilter)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: c.pink,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ref
          .watch(connectivityProvider)
          .when(
            loading: () => _buildGrid(filteredHosts, filters),
            error: (_, __) => _buildGrid(filteredHosts, filters),
            data: (isOnline) => isOnline
                ? _buildGrid(filteredHosts, filters)
                : _buildOfflineState(),
          ),
    );
  }

  Widget _buildGrid(
    List<HostModel> filteredHosts,
    FiltersState filters,
  ) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) => Opacity(
        opacity: _animationController.value,
        child: Transform.translate(
          offset: Offset(
            0,
            40 * (1 - _animationController.value),
          ),
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
                  itemBuilder: (context, index) => HostCard(
                    key: ValueKey(filteredHosts[index].userId),
                    host: filteredHosts[index],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildOfflineState() {
    final c = AppColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.card,
                border: Border.all(color: c.border, width: 1),
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 38,
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No internet connection',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: c.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your Wi-Fi or mobile data\nand try again.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: c.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 160,
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      c.pink,
                      Color.lerp(
                        c.pink,
                        const Color(0xFF7B0050),
                        0.45,
                      )!,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: c.pink.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Re-trigger connectivity check + user reload
                    ref.invalidate(connectivityProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: Text(
                    'Try again',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(FiltersState filters) {
    final c = AppColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.magnifyingGlass,
              size: 48,
              color: c.textSecondary,
            ),
            const SizedBox(height: 20),
            Text(
              filters.searchId != null
                  ? 'No host found with ID "${filters.searchId}"'
                  : 'No hosts match your filters',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () =>
                  ref.read(filtersProvider.notifier).clearAll(),
              icon: Icon(Icons.close, size: 16, color: c.pink),
              label: Text(
                'Clear filters',
                style: TextStyle(color: c.pink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
