// // import 'package:flutter/material.dart';
// // import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// // /// ================= FILTER BUTTON =================

// // class FilterButton extends StatelessWidget {
// //   const FilterButton({
// //     super.key,
// //     required this.label,
// //     required this.icon,
// //     required this.isSelected,
// //     required this.onTap,
// //   });

// //   final String label;
// //   final IconData icon;
// //   final bool isSelected;
// //   final VoidCallback onTap;

// //   @override
// //   Widget build(BuildContext context) {
// //     return InkWell(
// //       onTap: onTap,
// //       borderRadius: BorderRadius.circular(12),
// //       child: Container(
// //         padding: const EdgeInsets.symmetric(
// //           horizontal: 14,
// //           vertical: 10,
// //         ),
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(12),
// //           color: isSelected ? Colors.pink : Colors.grey.shade200,
// //         ),
// //         child: Column(
// //           children: [
// //             FaIcon(
// //               icon,
// //               size: 20,
// //               color: isSelected ? Colors.white : Colors.black,
// //             ),
// //             const SizedBox(height: 4),
// //             Text(
// //               label,
// //               style: TextStyle(
// //                 fontSize: 12,
// //                 color: isSelected ? Colors.white : Colors.black,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class CountryFilter extends StatelessWidget {
// //   const CountryFilter({
// //     super.key,
// //     required this.countries,
// //     required this.selectedCountry,
// //     required this.onSelected,
// //   });

// //   final List<String> countries;
// //   final String selectedCountry;
// //   final ValueChanged<String> onSelected;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Wrap(
// //       spacing: 8,
// //       runSpacing: 8,
// //       children: countries.map((country) {
// //         return ChoiceChip(
// //           label: Text(country),
// //           selected: selectedCountry == country,
// //           selectedColor: Colors.pink.shade200,
// //           // labelPadding: const EdgeInsets.symmetric(
// //           //   horizontal: 14,
// //           //   vertical: 8,
// //           // ),
// //           // padding: EdgeInsets.zero,
// //           onSelected: (_) => onSelected(country),
// //         );
// //       }).toList(),
// //     );
// //   }
// // }

// // class LanguageFilter extends StatelessWidget {
// //   const LanguageFilter({
// //     super.key,
// //     required this.languages,
// //     required this.selectedLanguage,
// //     required this.onSelected,
// //   });

// //   final List<String> languages;
// //   final String selectedLanguage;
// //   final ValueChanged<String> onSelected;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Wrap(
// //       spacing: 8,
// //       runSpacing: 8,
// //       children: languages.map((lang) {
// //         return FilterChip(
// //           label: Text(lang),
// //           selected: selectedLanguage == lang,
// //           selectedColor: Colors.pink.shade200,
// //           onSelected: (_) => onSelected(lang),
// //         );
// //       }).toList(),
// //     );
// //   }
// // }
// // lib/widgets/search_filters.dart
// //
// // Reusable filter chip widgets used by FiltersScreen.
// // CountryFilter now accepts a Map<code, name> so the grid
// // can filter by ISO code while showing readable names.

// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// // ---------------------------------------------------------------------------
// // FilterButton — kept for any other use but FiltersScreen now uses _TabButton
// // ---------------------------------------------------------------------------
// class FilterButton extends StatelessWidget {
//   const FilterButton({
//     super.key,
//     required this.label,
//     required this.icon,
//     required this.isSelected,
//     required this.onTap,
//   });

//   final String label;
//   final IconData icon;
//   final bool isSelected;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         padding: const EdgeInsets.symmetric(
//           horizontal: 14,
//           vertical: 10,
//         ),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           color: isSelected ? Colors.pink : Colors.grey.shade200,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             FaIcon(
//               icon,
//               size: 20,
//               color: isSelected ? Colors.white : Colors.black,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: isSelected ? Colors.white : Colors.black,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ---------------------------------------------------------------------------
// // CountryFilter
// // Accepts Map<String?, String> — null key = "All".
// // selectedCode is the ISO code (e.g. "IN") or null for "All".
// // ---------------------------------------------------------------------------
// class CountryFilter extends StatelessWidget {
//   const CountryFilter({
//     super.key,
//     required this.countries, // { null: 'All', 'IN': 'India', ... }
//     required this.selectedCode, // null = All selected
//     required this.onSelected, // returns null for "All", code otherwise
//   });

//   final Map<String?, String> countries;
//   final String? selectedCode;
//   final ValueChanged<String?> onSelected;

//   @override
//   Widget build(BuildContext context) {
//     return Wrap(
//       spacing: 8,
//       runSpacing: 8,
//       children: countries.entries.map((entry) {
//         final code = entry.key;
//         final name = entry.value;
//         final isSelected =
//             code == selectedCode ||
//             (code == null && selectedCode == null);

//         return ChoiceChip(
//           label: Text(name),
//           selected: isSelected,
//           selectedColor: Colors.pink.shade200,
//           onSelected: (_) => onSelected(code),
//         );
//       }).toList(),
//     );
//   }
// }

// // ---------------------------------------------------------------------------
// // LanguageFilter — unchanged API
// // ---------------------------------------------------------------------------
// class LanguageFilter extends StatelessWidget {
//   const LanguageFilter({
//     super.key,
//     required this.languages,
//     required this.selectedLanguage, // null = All
//     required this.onSelected,
//   });

//   final List<String> languages;
//   final String? selectedLanguage;
//   final ValueChanged<String> onSelected;

//   @override
//   Widget build(BuildContext context) {
//     return Wrap(
//       spacing: 8,
//       runSpacing: 8,
//       children: languages.map((lang) {
//         final isSelected = lang == 'All'
//             ? selectedLanguage == null
//             : selectedLanguage == lang;

//         return FilterChip(
//           label: Text(lang),
//           selected: isSelected,
//           selectedColor: Colors.pink.shade200,
//           onSelected: (_) => onSelected(lang),
//         );
//       }).toList(),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FilterButton extends StatelessWidget {
  const FilterButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.pink : Colors.grey.shade200,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.black,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// List<String> of display names — "All" + country names
class CountryFilter extends StatelessWidget {
  const CountryFilter({
    super.key,
    required this.countries,
    required this.selectedCountry,
    required this.onSelected,
  });

  final List<String> countries;
  final String selectedCountry;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: countries.map((name) {
        return ChoiceChip(
          label: Text(name),
          selected: name == selectedCountry,
          selectedColor: Colors.pink.shade200,
          onSelected: (_) => onSelected(name),
        );
      }).toList(),
    );
  }
}

class LanguageFilter extends StatelessWidget {
  const LanguageFilter({
    super.key,
    required this.languages,
    required this.selectedLanguage,
    required this.onSelected,
  });

  final List<String> languages;
  final String selectedLanguage;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: languages.map((lang) {
        return FilterChip(
          label: Text(lang),
          selected: lang == selectedLanguage,
          selectedColor: Colors.pink.shade200,
          onSelected: (_) => onSelected(lang),
        );
      }).toList(),
    );
  }
}
