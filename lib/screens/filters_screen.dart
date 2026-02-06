import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:judotalk/data/country_data.dart';
import 'package:judotalk/data/language_data.dart';
import 'package:judotalk/widgets/search_filters.dart';

enum FilterType { country, id, language }

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});
  @override
  State<FiltersScreen> createState() {
    return _FiltersScreenState();
  }
}

class _FiltersScreenState extends State<FiltersScreen> {
  FilterType selectedFilter = FilterType.country;
  bool get hasSelection =>
      _idController.text.isNotEmpty ||
      selectedCountry != "All" ||
      selectedLanguage != "All";

  // FilterType? activeFilterType;

  String selectedCountry = "All";
  String selectedLanguage = "All";

  final TextEditingController _idController =
      TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  void _search() {
    final id = _idController.text.trim();
    if (id.isEmpty) return;

    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();

    Navigator.pop(context, {'type': FilterType.id, 'value': id});
  }

  @override
  Widget build(context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text("Filters")),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          print("PopInvoked but didnt");
          Navigator.pop(context);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 30,
            ),
            // top: 30,
            // left: 30,
            // right: 30,
            // bottom: MediaQuery.of(context).viewInsets.bottom,
            child: Column(
              children: [
                const SizedBox(height: 10),

                /// 🔹 Search field (fixed)
                TextField(
                  controller: _idController,
                  textInputAction: TextInputAction.search,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],

                  onSubmitted: (value) {
                    print('Search id: $value');
                    print(_idController.text);
                    FocusScope.of(context).unfocus();
                  },

                  // autofocus: true,
                  decoration: InputDecoration(
                    focusColor: Colors.white,
                    labelText: "Search with Id",
                    hintText: "Enter the ID",
                    prefixIcon: Icon(FontAwesomeIcons.idBadge),
                    suffix: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _search,
                        borderRadius: BorderRadius.circular(100),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: AnimatedSwitcher(
                            duration: const Duration(
                              milliseconds: 200,
                            ),
                            transitionBuilder:
                                (child, animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  );
                                },
                            child: FaIcon(
                              FontAwesomeIcons.magnifyingGlass,
                              // key: ValueKey(isFollowed),
                              // color: isFollowed
                              //     ? Colors.red
                              //     : Colors.white,
                              color: Colors.black,
                              size: 23,
                            ),
                          ),
                        ),
                      ),
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Column(
                  children: [
                    const Text(
                      "Filter by",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                          onTap: () {
                            setState(() {
                              selectedFilter =
                                  FilterType.country;
                            });
                          },
                        ),
                        FilterButton(
                          label: "Language",
                          icon: FontAwesomeIcons.language,
                          isSelected:
                              selectedFilter ==
                              FilterType.language,
                          onTap: () {
                            setState(() {
                              selectedFilter =
                                  FilterType.language;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// 🔹 SCROLLABLE FILTER CONTENT (ONLY THIS)
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: selectedFilter == FilterType.country
                          ? SingleChildScrollView(
                              child: CountryFilter(
                                key: const ValueKey('country'),
                                countries: [
                                  'All',
                                  ...countryNames.values,
                                ],
                                selectedCountry: selectedCountry,
                                onSelected: (country) {
                                  setState(() {
                                    // activeFilterType =
                                    //     FilterType.country;
                                    selectedCountry = country;
                                    selectedLanguage = "All";
                                    _idController.clear();
                                  });
                                },
                              ),
                            )
                          : SingleChildScrollView(
                              child: LanguageFilter(
                                key: const ValueKey('language'),
                                languages: [
                                  'All',
                                  ...languageNames.values,
                                ],
                                selectedLanguage:
                                    selectedLanguage,
                                onSelected: (lang) {
                                  setState(() {
                                    // activeFilterType =
                                    //     FilterType.language;
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

                /// 🔹 Bottom buttons (fixed)
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
                          _idController.clear();
                          Navigator.pop(context);
                        },
                        child: const Text("Close"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: hasSelection
                            ? () {
                                FocusScope.of(context).unfocus();

                                if (_idController
                                    .text
                                    .isNotEmpty) {
                                  Navigator.pop(context, {
                                    'type': FilterType.id,
                                    'value': _idController.text
                                        .trim(),
                                  });
                                  return;
                                }

                                if (selectedCountry != "All") {
                                  Navigator.pop(context, {
                                    'type': FilterType.country,
                                    'value': selectedCountry,
                                  });
                                  return;
                                }

                                if (selectedLanguage != "All") {
                                  Navigator.pop(context, {
                                    'type': FilterType.language,
                                    'value': selectedLanguage,
                                  });
                                  return;
                                }

                                Navigator.pop(context);
                              }
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
    );
  }
}
