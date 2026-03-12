
import 'package:cheerchat/data/country_data.dart';
import 'package:cheerchat/data/language_data.dart';
import 'package:cheerchat/providers/filters_provider.dart';
import 'package:cheerchat/theme/app_colors.dart';
import 'package:cheerchat/widgets/search_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// FilterType.id removed — was leftover from old Navigator.pop pattern
enum FilterType { country, language }

class FiltersScreen extends ConsumerStatefulWidget {
  const FiltersScreen({super.key});

  @override
  ConsumerState<FiltersScreen> createState() =>
      _FiltersScreenState();
}

class _FiltersScreenState extends ConsumerState<FiltersScreen> {
  FilterType selectedFilter = FilterType.country;

  bool get hasSelection =>
      _idController.text.trim().isNotEmpty ||
      selectedCountry != "All" ||
      selectedLanguage != "All";

  String selectedCountry = "All";
  String selectedLanguage = "All";

  final TextEditingController _idController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _idController.addListener(_onIdChanged);
    final current = ref.read(filtersProvider);
    if (current.searchId != null) {
      _idController.text = current.searchId!;
    } else if (current.selectedCountry != null) {
      selectedCountry = current.selectedCountry!;
    } else if (current.selectedLanguage != null) {
      selectedLanguage = current.selectedLanguage!;
      selectedFilter = FilterType.language;
    }
  }

  void _onIdChanged() => setState(() {});

  @override
  void dispose() {
    _idController.removeListener(_onIdChanged);
    _idController.dispose();
    super.dispose();
  }

  void _clearAll() {
    ref.read(filtersProvider.notifier).clearAll();
    setState(() {
      selectedCountry = "All";
      selectedLanguage = "All";
      _idController.clear();
      selectedFilter = FilterType.country;
    });
  }

  void _applyFilters() {
    FocusScope.of(context).unfocus();
    final notifier = ref.read(filtersProvider.notifier);
    final id = _idController.text.trim();

    if (id.isNotEmpty) {
      notifier.setSearchId(id);
    } else if (selectedCountry != "All") {
      notifier.setCountry(selectedCountry);
    } else if (selectedLanguage != "All") {
      notifier.setLanguage(selectedLanguage);
    } else {
      notifier.clearAll();
    }

    Navigator.pop(context);
  }

  @override
  Widget build(context) {
    final c = AppColors.of(context);
    final hasActiveFilter = ref
        .watch(filtersProvider)
        .hasActiveFilter;
    final hasIdText = _idController.text.trim().isNotEmpty;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Filters"),
        actions: [
          if (hasActiveFilter)
            TextButton(
              onPressed: _clearAll,
              child: Text(
                "Clear",
                style: TextStyle(color: c.pink),
              ),
            ),
        ],
      ),
      body: Container(
        color: c.bg,
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            Navigator.pop(context);
          },
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 30,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  /// 🔹 Search field
                  TextField(
                    controller: _idController,
                    textInputAction: TextInputAction.search,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onSubmitted: (_) =>
                        hasSelection ? _applyFilters() : null,
                    style: TextStyle(color: c.textPrimary),
                    cursorColor: c.pink,
                    decoration: InputDecoration(
                      labelText: "Search with Id",
                      labelStyle: TextStyle(
                        color: c.textSecondary,
                      ),
                      hintText: "Enter the ID",
                      hintStyle: TextStyle(
                        color: c.textSecondary,
                      ),
                      prefixIcon: Icon(
                        FontAwesomeIcons.idBadge,
                        color: c.textSecondary,
                        size: 18,
                      ),
                      suffix: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: hasIdText
                              ? () => _idController.clear()
                              : null,
                          borderRadius: BorderRadius.circular(
                            100,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: AnimatedSwitcher(
                              duration: const Duration(
                                milliseconds: 200,
                              ),
                              transitionBuilder:
                                  (child, animation) =>
                                      ScaleTransition(
                                        scale: animation,
                                        child: child,
                                      ),
                              child: hasIdText
                                  ? FaIcon(
                                      FontAwesomeIcons.xmark,
                                      key: const ValueKey(
                                        'clear',
                                      ),
                                      color: c.textSecondary,
                                      size: 20,
                                    )
                                  : const SizedBox(),
                            ),
                          ),
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: c.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: c.pink),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Column(
                    children: [
                      Text(
                        "Filter by",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: c.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                        children: [
                          FilterButton(
                            label: "Country",
                            icon: FontAwesomeIcons.flag,
                            isSelected:
                                selectedFilter ==
                                FilterType.country,
                            onTap: () => setState(
                              () => selectedFilter =
                                  FilterType.country,
                            ),
                          ),
                          FilterButton(
                            label: "Language",
                            icon: FontAwesomeIcons.language,
                            isSelected:
                                selectedFilter ==
                                FilterType.language,
                            onTap: () => setState(
                              () => selectedFilter =
                                  FilterType.language,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// 🔹 SCROLLABLE FILTER CONTENT
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(
                        milliseconds: 200,
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child:
                            selectedFilter == FilterType.country
                            ? SingleChildScrollView(
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior
                                        .onDrag,
                                child: CountryFilter(
                                  key: const ValueKey('country'),
                                  countries: [
                                    'All',
                                    ...countryNames.values,
                                  ],
                                  selectedCountry:
                                      selectedCountry,
                                  onSelected: (country) {
                                    setState(() {
                                      selectedCountry = country;
                                      selectedLanguage = "All";
                                      _idController.clear();
                                    });
                                  },
                                ),
                              )
                            : SingleChildScrollView(
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior
                                        .onDrag,
                                child: LanguageFilter(
                                  key: const ValueKey(
                                    'language',
                                  ),
                                  languages: [
                                    'All',
                                    ...languageNames.values,
                                  ],
                                  selectedLanguage:
                                      selectedLanguage,
                                  onSelected: (lang) {
                                    setState(() {
                                      selectedLanguage = lang;
                                      selectedCountry = "All";
                                      _idController.clear();
                                    });
                                  },
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// 🔹 Bottom buttons
                  AnimatedPadding(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.only(
                      bottom:
                          MediaQuery.of(
                                context,
                              ).viewInsets.bottom >
                              0
                          ? 0
                          : 25,
                      top:
                          MediaQuery.of(
                                context,
                              ).viewInsets.bottom >
                              0
                          ? 0
                          : 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Close",
                            style: TextStyle(
                              color: c.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: hasSelection
                              ? _applyFilters
                              : null,
                          child: const Text("Apply Filters"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
