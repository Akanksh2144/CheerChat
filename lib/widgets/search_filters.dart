
// lib/widgets/search_filters.dart
//
// FilterButton — tab pill used in FiltersScreen (Country / Language)
// CountryFilter — wrapping ChoiceChip list
// LanguageFilter — wrapping FilterChip list

import 'package:cheerchat/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────

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
    final c = AppColors.of(context);
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
          color: isSelected ? c.pink : c.card,
          border: Border.all(
            color: isSelected ? c.pink : c.border,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : c.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : c.textPrimary,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Country chip list ─────────────────────────────────────────────────────────

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
    final c = AppColors.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: countries.map((name) {
        final selected = name == selectedCountry;
        return ChoiceChip(
          showCheckmark: false,
          label: Text(name),
          selected: selected,
          selectedColor: c.pink.withOpacity(0.20),
          backgroundColor: c.card,
          side: BorderSide(color: selected ? c.pink : c.border),
          labelStyle: TextStyle(
            color: selected ? c.pink : c.textPrimary,
            fontWeight: selected
                ? FontWeight.w600
                : FontWeight.normal,
          ),
          onSelected: (_) => onSelected(name),
        );
      }).toList(),
    );
  }
}

// ── Language chip list ────────────────────────────────────────────────────────

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
    final c = AppColors.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: languages.map((lang) {
        final selected = lang == selectedLanguage;
        return FilterChip(
          showCheckmark: false,
          label: Text(lang),
          selected: selected,
          selectedColor: c.pink.withOpacity(0.20),
          backgroundColor: c.card,
          side: BorderSide(color: selected ? c.pink : c.border),
          labelStyle: TextStyle(
            color: selected ? c.pink : c.textPrimary,
            fontWeight: selected
                ? FontWeight.w600
                : FontWeight.normal,
          ),
          checkmarkColor: c.pink,
          onSelected: (_) => onSelected(lang),
        );
      }).toList(),
    );
  }
}
