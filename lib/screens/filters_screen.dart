// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/services.dart';
// // // // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // // // import 'package:cheerchat/data/country_data.dart';
// // // // import 'package:cheerchat/data/language_data.dart';
// // // // import 'package:cheerchat/widgets/search_filters.dart';

// // // // enum FilterType { country, id, language }

// // // // class FiltersScreen extends StatefulWidget {
// // // //   const FiltersScreen({super.key});
// // // //   @override
// // // //   State<FiltersScreen> createState() {
// // // //     return _FiltersScreenState();
// // // //   }
// // // // }

// // // // class _FiltersScreenState extends State<FiltersScreen> {
// // // //   FilterType selectedFilter = FilterType.country;
// // // //   bool get hasSelection =>
// // // //       _idController.text.isNotEmpty ||
// // // //       selectedCountry != "All" ||
// // // //       selectedLanguage != "All";

// // // //   // FilterType? activeFilterType;

// // // //   String selectedCountry = "All";
// // // //   String selectedLanguage = "All";

// // // //   final TextEditingController _idController =
// // // //       TextEditingController();

// // // //   @override
// // // //   void dispose() {
// // // //     _idController.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   void _search() {
// // // //     final id = _idController.text.trim();
// // // //     if (id.isEmpty) return;

// // // //     HapticFeedback.lightImpact();
// // // //     FocusScope.of(context).unfocus();

// // // //     Navigator.pop(context, {'type': FilterType.id, 'value': id});
// // // //   }

// // // //   @override
// // // //   Widget build(context) {
// // // //     return Scaffold(
// // // //       resizeToAvoidBottomInset: true,
// // // //       appBar: AppBar(title: Text("Filters")),
// // // //       body: PopScope(
// // // //         canPop: false,
// // // //         onPopInvokedWithResult: (didPop, result) {
// // // //           if (didPop) return;
// // // //           print("PopInvoked but didnt");
// // // //           Navigator.pop(context);
// // // //         },
// // // //         child: GestureDetector(
// // // //           behavior: HitTestBehavior.translucent,
// // // //           onTap: () {
// // // //             FocusScope.of(context).unfocus();
// // // //           },
// // // //           child: Padding(
// // // //             padding: EdgeInsets.symmetric(
// // // //               vertical: 20,
// // // //               horizontal: 30,
// // // //             ),
// // // //             // top: 30,
// // // //             // left: 30,
// // // //             // right: 30,
// // // //             // bottom: MediaQuery.of(context).viewInsets.bottom,
// // // //             child: Column(
// // // //               children: [
// // // //                 const SizedBox(height: 10),

// // // //                 /// 🔹 Search field (fixed)
// // // //                 TextField(
// // // //                   controller: _idController,
// // // //                   textInputAction: TextInputAction.search,
// // // //                   keyboardType: TextInputType.number,
// // // //                   inputFormatters: [
// // // //                     FilteringTextInputFormatter.digitsOnly,
// // // //                   ],

// // // //                   onSubmitted: (value) {
// // // //                     print('Search id: $value');
// // // //                     print(_idController.text);
// // // //                     FocusScope.of(context).unfocus();
// // // //                   },

// // // //                   // autofocus: true,
// // // //                   decoration: InputDecoration(
// // // //                     focusColor: Colors.white,
// // // //                     labelText: "Search with Id",
// // // //                     hintText: "Enter the ID",
// // // //                     prefixIcon: Icon(FontAwesomeIcons.idBadge),
// // // //                     suffix: Material(
// // // //                       color: Colors.transparent,
// // // //                       child: InkWell(
// // // //                         onTap: _search,
// // // //                         borderRadius: BorderRadius.circular(100),
// // // //                         child: Padding(
// // // //                           padding: const EdgeInsets.all(4),
// // // //                           child: AnimatedSwitcher(
// // // //                             duration: const Duration(
// // // //                               milliseconds: 200,
// // // //                             ),
// // // //                             transitionBuilder:
// // // //                                 (child, animation) {
// // // //                                   return ScaleTransition(
// // // //                                     scale: animation,
// // // //                                     child: child,
// // // //                                   );
// // // //                                 },
// // // //                             child: FaIcon(
// // // //                               FontAwesomeIcons.magnifyingGlass,
// // // //                               // key: ValueKey(isFollowed),
// // // //                               // color: isFollowed
// // // //                               //     ? Colors.red
// // // //                               //     : Colors.white,
// // // //                               color: Colors.black,
// // // //                               size: 23,
// // // //                             ),
// // // //                           ),
// // // //                         ),
// // // //                       ),
// // // //                     ),

// // // //                     border: OutlineInputBorder(
// // // //                       borderRadius: BorderRadius.circular(12),
// // // //                     ),
// // // //                   ),
// // // //                 ),

// // // //                 const SizedBox(height: 20),

// // // //                 Column(
// // // //                   children: [
// // // //                     const Text(
// // // //                       "Filter by",
// // // //                       style: TextStyle(
// // // //                         fontSize: 18,
// // // //                         fontWeight: FontWeight.bold,
// // // //                       ),
// // // //                     ),
// // // //                     const SizedBox(height: 16),

// // // //                     Row(
// // // //                       mainAxisAlignment:
// // // //                           MainAxisAlignment.spaceEvenly,
// // // //                       children: [
// // // //                         FilterButton(
// // // //                           label: "Country",
// // // //                           icon: FontAwesomeIcons.flag,
// // // //                           isSelected:
// // // //                               selectedFilter ==
// // // //                               FilterType.country,
// // // //                           onTap: () {
// // // //                             setState(() {
// // // //                               selectedFilter =
// // // //                                   FilterType.country;
// // // //                             });
// // // //                           },
// // // //                         ),
// // // //                         FilterButton(
// // // //                           label: "Language",
// // // //                           icon: FontAwesomeIcons.language,
// // // //                           isSelected:
// // // //                               selectedFilter ==
// // // //                               FilterType.language,
// // // //                           onTap: () {
// // // //                             setState(() {
// // // //                               selectedFilter =
// // // //                                   FilterType.language;
// // // //                             });
// // // //                           },
// // // //                         ),
// // // //                       ],
// // // //                     ),
// // // //                   ],
// // // //                 ),

// // // //                 const SizedBox(height: 16),

// // // //                 /// 🔹 SCROLLABLE FILTER CONTENT (ONLY THIS)
// // // //                 Expanded(
// // // //                   child: AnimatedSwitcher(
// // // //                     duration: const Duration(milliseconds: 200),
// // // //                     child: Align(
// // // //                       alignment: Alignment.topCenter,
// // // //                       child: selectedFilter == FilterType.country
// // // //                           ? SingleChildScrollView(
// // // //                               child: CountryFilter(
// // // //                                 key: const ValueKey('country'),
// // // //                                 countries: [
// // // //                                   'All',
// // // //                                   ...countryNames.values,
// // // //                                 ],
// // // //                                 selectedCountry: selectedCountry,
// // // //                                 onSelected: (country) {
// // // //                                   setState(() {
// // // //                                     // activeFilterType =
// // // //                                     //     FilterType.country;
// // // //                                     selectedCountry = country;
// // // //                                     selectedLanguage = "All";
// // // //                                     _idController.clear();
// // // //                                   });
// // // //                                 },
// // // //                               ),
// // // //                             )
// // // //                           : SingleChildScrollView(
// // // //                               child: LanguageFilter(
// // // //                                 key: const ValueKey('language'),
// // // //                                 languages: [
// // // //                                   'All',
// // // //                                   ...languageNames.values,
// // // //                                 ],
// // // //                                 selectedLanguage:
// // // //                                     selectedLanguage,
// // // //                                 onSelected: (lang) {
// // // //                                   setState(() {
// // // //                                     // activeFilterType =
// // // //                                     //     FilterType.language;
// // // //                                     selectedLanguage = lang;
// // // //                                     selectedCountry = "All";
// // // //                                     _idController.clear();
// // // //                                   });
// // // //                                 },
// // // //                               ),
// // // //                             ),
// // // //                     ),
// // // //                   ),
// // // //                 ),

// // // //                 const SizedBox(height: 12),

// // // //                 /// 🔹 Bottom buttons (fixed)
// // // //                 AnimatedPadding(
// // // //                   duration: const Duration(milliseconds: 200),
// // // //                   curve: Curves.easeOut,
// // // //                   padding: EdgeInsets.only(
// // // //                     bottom:
// // // //                         MediaQuery.of(
// // // //                               context,
// // // //                             ).viewInsets.bottom >
// // // //                             0
// // // //                         ? 0
// // // //                         : 25,
// // // //                     top:
// // // //                         MediaQuery.of(
// // // //                               context,
// // // //                             ).viewInsets.bottom >
// // // //                             0
// // // //                         ? 0
// // // //                         : 16,
// // // //                   ),
// // // //                   child: Row(
// // // //                     mainAxisAlignment: MainAxisAlignment.end,
// // // //                     children: [
// // // //                       TextButton(
// // // //                         onPressed: () {
// // // //                           FocusScope.of(context).unfocus();
// // // //                           _idController.clear();
// // // //                           Navigator.pop(context);
// // // //                         },
// // // //                         child: const Text("Close"),
// // // //                       ),
// // // //                       const SizedBox(width: 8),
// // // //                       ElevatedButton(
// // // //                         onPressed: hasSelection
// // // //                             ? () {
// // // //                                 FocusScope.of(context).unfocus();

// // // //                                 if (_idController
// // // //                                     .text
// // // //                                     .isNotEmpty) {
// // // //                                   Navigator.pop(context, {
// // // //                                     'type': FilterType.id,
// // // //                                     'value': _idController.text
// // // //                                         .trim(),
// // // //                                   });
// // // //                                   return;
// // // //                                 }

// // // //                                 if (selectedCountry != "All") {
// // // //                                   Navigator.pop(context, {
// // // //                                     'type': FilterType.country,
// // // //                                     'value': selectedCountry,
// // // //                                   });
// // // //                                   return;
// // // //                                 }

// // // //                                 if (selectedLanguage != "All") {
// // // //                                   Navigator.pop(context, {
// // // //                                     'type': FilterType.language,
// // // //                                     'value': selectedLanguage,
// // // //                                   });
// // // //                                   return;
// // // //                                 }

// // // //                                 Navigator.pop(context);
// // // //                               }
// // // //                             : null,
// // // //                         child: const Text("Apply Filters"),
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // import 'package:cheerchat/data/country_data.dart';
// // import 'package:cheerchat/data/language_data.dart';
// // import 'package:cheerchat/providers/filters_provider.dart';
// // import 'package:cheerchat/widgets/search_filters.dart';

// // enum FilterType { country, id, language }

// // class FiltersScreen extends ConsumerStatefulWidget {
// //   const FiltersScreen({super.key});

// //   @override
// //   ConsumerState<FiltersScreen> createState() =>
// //       _FiltersScreenState();
// // }

// // class _FiltersScreenState extends ConsumerState<FiltersScreen> {
// //   FilterType selectedFilter = FilterType.country;

// //   bool get hasSelection =>
// //       _idController.text.isNotEmpty ||
// //       selectedCountry != "All" ||
// //       selectedLanguage != "All";

// //   String selectedCountry = "All";
// //   String selectedLanguage = "All";

// //   final TextEditingController _idController =
// //       TextEditingController();

// //   @override
// //   void initState() {
// //     super.initState();
// //     // Pre-populate from active filters
// //     final current = ref.read(filtersProvider);
// //     if (current.searchId != null) {
// //       _idController.text = current.searchId!;
// //     } else if (current.selectedCountry != null) {
// //       // Convert code back to display name
// //       selectedCountry =
// //           countryNames[current.selectedCountry] ?? "All";
// //     } else if (current.selectedLanguage != null) {
// //       selectedLanguage = current.selectedLanguage!;
// //       selectedFilter = FilterType.language;
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _idController.dispose();
// //     super.dispose();
// //   }

// //   void _applyFilters() {
// //     FocusScope.of(context).unfocus();
// //     final notifier = ref.read(filtersProvider.notifier);

// //     final id = _idController.text.trim();

// //     if (id.isNotEmpty) {
// //       notifier.setSearchId(id);
// //     } else if (selectedCountry != "All") {
// //       // Store display name — grid will resolve to ISO code
// //       notifier.setCountry(selectedCountry);
// //     } else if (selectedLanguage != "All") {
// //       notifier.setLanguage(selectedLanguage);
// //     } else {
// //       notifier.clearAll();
// //     }

// //     Navigator.pop(context);
// //   }

// //   void _search() {
// //     final id = _idController.text.trim();
// //     if (id.isEmpty) return;
// //     HapticFeedback.lightImpact();
// //     _applyFilters();
// //   }

// //   @override
// //   Widget build(context) {
// //     return Scaffold(
// //       resizeToAvoidBottomInset: true,
// //       appBar: AppBar(title: Text("Filters")),
// //       body: PopScope(
// //         canPop: false,
// //         onPopInvokedWithResult: (didPop, result) {
// //           if (didPop) return;
// //           Navigator.pop(context);
// //         },
// //         child: GestureDetector(
// //           behavior: HitTestBehavior.translucent,
// //           onTap: () {
// //             FocusScope.of(context).unfocus();
// //           },
// //           child: Padding(
// //             padding: EdgeInsets.symmetric(
// //               vertical: 20,
// //               horizontal: 30,
// //             ),
// //             child: Column(
// //               children: [
// //                 const SizedBox(height: 10),

// //                 /// 🔹 Search field (fixed)
// //                 TextField(
// //                   controller: _idController,
// //                   textInputAction: TextInputAction.search,
// //                   keyboardType: TextInputType.number,
// //                   inputFormatters: [
// //                     FilteringTextInputFormatter.digitsOnly,
// //                   ],
// //                   onSubmitted: (value) {
// //                     FocusScope.of(context).unfocus();
// //                   },
// //                   decoration: InputDecoration(
// //                     focusColor: Colors.white,
// //                     labelText: "Search with Id",
// //                     hintText: "Enter the ID",
// //                     prefixIcon: Icon(FontAwesomeIcons.idBadge),
// //                     suffix: Material(
// //                       color: Colors.transparent,
// //                       child: InkWell(
// //                         onTap: _search,
// //                         borderRadius: BorderRadius.circular(100),
// //                         child: Padding(
// //                           padding: const EdgeInsets.all(4),
// //                           child: AnimatedSwitcher(
// //                             duration: const Duration(
// //                               milliseconds: 200,
// //                             ),
// //                             transitionBuilder:
// //                                 (child, animation) {
// //                                   return ScaleTransition(
// //                                     scale: animation,
// //                                     child: child,
// //                                   );
// //                                 },
// //                             child: FaIcon(
// //                               FontAwesomeIcons.magnifyingGlass,
// //                               color: Colors.black,
// //                               size: 23,
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                     border: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                   ),
// //                 ),

// //                 const SizedBox(height: 20),

// //                 Column(
// //                   children: [
// //                     const Text(
// //                       "Filter by",
// //                       style: TextStyle(
// //                         fontSize: 18,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 16),

// //                     Row(
// //                       mainAxisAlignment:
// //                           MainAxisAlignment.spaceEvenly,
// //                       children: [
// //                         FilterButton(
// //                           label: "Country",
// //                           icon: FontAwesomeIcons.flag,
// //                           isSelected:
// //                               selectedFilter ==
// //                               FilterType.country,
// //                           onTap: () {
// //                             setState(() {
// //                               selectedFilter =
// //                                   FilterType.country;
// //                             });
// //                           },
// //                         ),
// //                         FilterButton(
// //                           label: "Language",
// //                           icon: FontAwesomeIcons.language,
// //                           isSelected:
// //                               selectedFilter ==
// //                               FilterType.language,
// //                           onTap: () {
// //                             setState(() {
// //                               selectedFilter =
// //                                   FilterType.language;
// //                             });
// //                           },
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),

// //                 const SizedBox(height: 16),

// //                 /// 🔹 SCROLLABLE FILTER CONTENT (ONLY THIS)
// //                 Expanded(
// //                   child: AnimatedSwitcher(
// //                     duration: const Duration(milliseconds: 200),
// //                     child: Align(
// //                       alignment: Alignment.topCenter,
// //                       child: selectedFilter == FilterType.country
// //                           ? SingleChildScrollView(
// //                               child: CountryFilter(
// //                                 key: const ValueKey('country'),
// //                                 countries: [
// //                                   'All',
// //                                   ...countryNames.values,
// //                                 ],
// //                                 selectedCountry: selectedCountry,
// //                                 onSelected: (country) {
// //                                   setState(() {
// //                                     selectedCountry = country;
// //                                     selectedLanguage = "All";
// //                                     _idController.clear();
// //                                   });
// //                                 },
// //                               ),
// //                             )
// //                           : SingleChildScrollView(
// //                               child: LanguageFilter(
// //                                 key: const ValueKey('language'),
// //                                 languages: [
// //                                   'All',
// //                                   ...languageNames.values,
// //                                 ],
// //                                 selectedLanguage:
// //                                     selectedLanguage,
// //                                 onSelected: (lang) {
// //                                   setState(() {
// //                                     selectedLanguage = lang;
// //                                     selectedCountry = "All";
// //                                     _idController.clear();
// //                                   });
// //                                 },
// //                               ),
// //                             ),
// //                     ),
// //                   ),
// //                 ),

// //                 const SizedBox(height: 12),

// //                 /// 🔹 Bottom buttons (fixed)
// //                 AnimatedPadding(
// //                   duration: const Duration(milliseconds: 200),
// //                   curve: Curves.easeOut,
// //                   padding: EdgeInsets.only(
// //                     bottom:
// //                         MediaQuery.of(
// //                               context,
// //                             ).viewInsets.bottom >
// //                             0
// //                         ? 0
// //                         : 25,
// //                     top:
// //                         MediaQuery.of(
// //                               context,
// //                             ).viewInsets.bottom >
// //                             0
// //                         ? 0
// //                         : 16,
// //                   ),
// //                   child: Row(
// //                     mainAxisAlignment: MainAxisAlignment.end,
// //                     children: [
// //                       TextButton(
// //                         onPressed: () {
// //                           FocusScope.of(context).unfocus();
// //                           _idController.clear();
// //                           Navigator.pop(context);
// //                         },
// //                         child: const Text("Close"),
// //                       ),
// //                       const SizedBox(width: 8),
// //                       ElevatedButton(
// //                         onPressed: hasSelection
// //                             ? _applyFilters
// //                             : null,
// //                         child: const Text("Apply Filters"),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:cheerchat/data/country_data.dart';
// import 'package:cheerchat/data/language_data.dart';
// import 'package:cheerchat/providers/filters_provider.dart';
// import 'package:cheerchat/widgets/search_filters.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// enum FilterType { country, id, language }

// class FiltersScreen extends ConsumerStatefulWidget {
//   const FiltersScreen({super.key});

//   @override
//   ConsumerState<FiltersScreen> createState() =>
//       _FiltersScreenState();
// }

// class _FiltersScreenState extends ConsumerState<FiltersScreen> {
//   FilterType selectedFilter = FilterType.country;

//   bool get hasSelection =>
//       _idController.text.trim().isNotEmpty ||
//       selectedCountry != "All" ||
//       selectedLanguage != "All";

//   String selectedCountry = "All";
//   String selectedLanguage = "All";

//   final TextEditingController _idController =
//       TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     // Pre-populate local draft from the currently active filter.
//     // Country is stored as a display name ("India"), language as-is.
//     _idController.addListener(_onIdChanged);
//     final current = ref.read(filtersProvider);
//     if (current.searchId != null) {
//       _idController.text = current.searchId!;
//     } else if (current.selectedCountry != null) {
//       selectedCountry =
//           current.selectedCountry!; // already a display name
//     } else if (current.selectedLanguage != null) {
//       selectedLanguage = current.selectedLanguage!;
//       selectedFilter = FilterType.language;
//     }
//   }

//   void _onIdChanged() {
//     setState(() {
//       // This empty setState forces the build method to run,
//       // which re-evaluates 'hasSelection' and enables the button.
//     });
//   }

//   @override
//   void dispose() {
//     _idController.removeListener(_onIdChanged);
//     _idController.dispose();
//     super.dispose();
//   }

//   void _clearAll() {
//     ref.read(filtersProvider.notifier).clearAll();
//     setState(() {
//       selectedCountry = "All";
//       selectedLanguage = "All";
//       _idController.clear();
//       selectedFilter = FilterType.country;
//     });
//   }

//   void _applyFilters() {
//     FocusScope.of(context).unfocus();
//     final notifier = ref.read(filtersProvider.notifier);
//     final id = _idController.text.trim();

//     if (id.isNotEmpty) {
//       notifier.setSearchId(id);
//     } else if (selectedCountry != "All") {
//       notifier.setCountry(
//         selectedCountry,
//       ); // display name, grid resolves to ISO
//     } else if (selectedLanguage != "All") {
//       notifier.setLanguage(selectedLanguage);
//     } else {
//       notifier.clearAll();
//     }

//     Navigator.pop(context);
//   }

//   // void _search() {
//   //   final id = _idController.text.trim();
//   //   if (id.isEmpty) return;
//   //   HapticFeedback.lightImpact();
//   //   _applyFilters();
//   // }

//   @override
//   Widget build(context) {
//     final hasActiveFilter = ref
//         .watch(filtersProvider)
//         .hasActiveFilter;

//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//         title: const Text("Filters"),
//         actions: [
//           if (hasActiveFilter)
//             TextButton(
//               onPressed: _clearAll,
//               child: const Text(
//                 "Clear",
//                 style: TextStyle(color: Colors.pink),
//               ),
//             ),
//         ],
//       ),
//       body: PopScope(
//         canPop: false,
//         onPopInvokedWithResult: (didPop, result) {
//           if (didPop) return;
//           Navigator.pop(context);
//         },
//         child: GestureDetector(
//           behavior: HitTestBehavior.translucent,
//           onTap: () => FocusScope.of(context).unfocus(),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               vertical: 20,
//               horizontal: 30,
//             ),
//             child: Column(
//               children: [
//                 const SizedBox(height: 10),

//                 /// 🔹 Search field (fixed)
//                 TextField(
//                   controller: _idController,
//                   textInputAction: TextInputAction.search,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [
//                     FilteringTextInputFormatter.digitsOnly,
//                   ],
//                   onSubmitted: (_) =>
//                       FocusScope.of(context).unfocus(),
//                   decoration: InputDecoration(
//                     focusColor: Colors.white,
//                     labelText: "Search with Id",
//                     hintText: "Enter the ID",
//                     prefixIcon: const Icon(
//                       FontAwesomeIcons.idBadge,
//                     ),
//                     suffix: Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         onTap: () {
//                           _idController.clear();
//                         }, //_search,
//                         borderRadius: BorderRadius.circular(100),
//                         child: Padding(
//                           padding: const EdgeInsets.all(4),
//                           child: AnimatedSwitcher(
//                             duration: const Duration(
//                               milliseconds: 200,
//                             ),
//                             transitionBuilder:
//                                 (child, animation) =>
//                                     ScaleTransition(
//                                       scale: animation,
//                                       child: child,
//                                     ),
//                             child: const FaIcon(
//                               FontAwesomeIcons.magnifyingGlass,
//                               color: Colors.black,
//                               size: 23,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 Column(
//                   children: [
//                     const Text(
//                       "Filter by",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       mainAxisAlignment:
//                           MainAxisAlignment.spaceEvenly,
//                       children: [
//                         FilterButton(
//                           label: "Country",
//                           icon: FontAwesomeIcons.flag,
//                           isSelected:
//                               selectedFilter ==
//                               FilterType.country,
//                           onTap: () => setState(
//                             () => selectedFilter =
//                                 FilterType.country,
//                           ),
//                         ),
//                         FilterButton(
//                           label: "Language",
//                           icon: FontAwesomeIcons.language,
//                           isSelected:
//                               selectedFilter ==
//                               FilterType.language,
//                           onTap: () => setState(
//                             () => selectedFilter =
//                                 FilterType.language,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 16),

//                 /// 🔹 SCROLLABLE FILTER CONTENT (ONLY THIS)
//                 Expanded(
//                   child: AnimatedSwitcher(
//                     duration: const Duration(milliseconds: 200),
//                     child: Align(
//                       alignment: Alignment.topCenter,
//                       child: selectedFilter == FilterType.country
//                           ? SingleChildScrollView(
//                               keyboardDismissBehavior:
//                                   ScrollViewKeyboardDismissBehavior
//                                       .onDrag,
//                               child: CountryFilter(
//                                 key: const ValueKey('country'),
//                                 countries: [
//                                   'All',
//                                   ...countryNames.values,
//                                 ],
//                                 selectedCountry: selectedCountry,
//                                 onSelected: (country) {
//                                   setState(() {
//                                     selectedCountry = country;
//                                     selectedLanguage = "All";
//                                     _idController.clear();
//                                   });
//                                 },
//                               ),
//                             )
//                           : SingleChildScrollView(
//                               child: LanguageFilter(
//                                 key: const ValueKey('language'),
//                                 languages: [
//                                   'All',
//                                   ...languageNames.values,
//                                 ],
//                                 selectedLanguage:
//                                     selectedLanguage,
//                                 onSelected: (lang) {
//                                   setState(() {
//                                     selectedLanguage = lang;
//                                     selectedCountry = "All";
//                                     _idController.clear();
//                                   });
//                                 },
//                               ),
//                             ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 12),

//                 /// 🔹 Bottom buttons (fixed)
//                 AnimatedPadding(
//                   duration: const Duration(milliseconds: 200),
//                   curve: Curves.easeOut,
//                   padding: EdgeInsets.only(
//                     bottom:
//                         MediaQuery.of(
//                               context,
//                             ).viewInsets.bottom >
//                             0
//                         ? 0
//                         : 25,
//                     top:
//                         MediaQuery.of(
//                               context,
//                             ).viewInsets.bottom >
//                             0
//                         ? 0
//                         : 16,
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       TextButton(
//                         onPressed: () {
//                           FocusScope.of(context).unfocus();
//                           _idController.clear();
//                           Navigator.pop(context);
//                         },
//                         child: const Text("Close"),
//                       ),
//                       const SizedBox(width: 8),
//                       ElevatedButton(
//                         onPressed: hasSelection
//                             ? _applyFilters
//                             : null,
//                         child: const Text("Apply Filters"),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:cheerchat/data/country_data.dart';
import 'package:cheerchat/data/language_data.dart';
import 'package:cheerchat/providers/filters_provider.dart';
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
              child: const Text(
                "Clear",
                style: TextStyle(color: Colors.pink),
              ),
            ),
        ],
      ),
      body: Container(
        color: Colors.white,
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
                    // Fix #2: keyboard search button now applies filters
                    onSubmitted: (_) =>
                        hasSelection ? _applyFilters() : null,
                    decoration: InputDecoration(
                      focusColor: Colors.white,
                      labelText: "Search with Id",
                      hintText: "Enter the ID",
                      prefixIcon: const Icon(
                        FontAwesomeIcons.idBadge,
                      ),
                      // Fix #1 + #4: icon switches between X and search,
                      // with a ValueKey so AnimatedSwitcher actually animates
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
                                  ? const FaIcon(
                                      FontAwesomeIcons.xmark,
                                      key: ValueKey('clear'),
                                      color: Colors.grey,
                                      size: 20,
                                    )
                                  : SizedBox(),

                              // : const FaIcon(
                              //     FontAwesomeIcons
                              //         .magnifyingGlass,
                              //     key: ValueKey('search'),
                              //     color: Colors.black,
                              //     size: 20,
                              //   ),
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
                          child: const Text("Close"),
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
