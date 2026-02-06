import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// ================= FILTER BUTTON =================

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
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.pink : Colors.grey.shade200,
        ),
        child: Column(
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
      children: countries.map((country) {
        return ChoiceChip(
          label: Text(country),
          selected: selectedCountry == country,
          selectedColor: Colors.pink.shade200,
          // labelPadding: const EdgeInsets.symmetric(
          //   horizontal: 14,
          //   vertical: 8,
          // ),
          // padding: EdgeInsets.zero,
          onSelected: (_) => onSelected(country),
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
          selected: selectedLanguage == lang,
          selectedColor: Colors.pink.shade200,
          onSelected: (_) => onSelected(lang),
        );
      }).toList(),
    );
  }
}
