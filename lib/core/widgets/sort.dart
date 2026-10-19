import 'package:flutter/material.dart';

class SortOptions extends StatefulWidget {
  const SortOptions({super.key, this.onChanged, this.initialValue = 'Price'});

  final ValueChanged<String>? onChanged;
  final String initialValue;

  @override
  State<SortOptions> createState() => _SortOptionsState();
}

class _SortOptionsState extends State<SortOptions> {
  static const List<String> _sortOptions = [
    'None',
    'Price Low to High',
    'Price High to Low',
    'Rating',
    'Title',
  ];

  late String dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = _sortOptions.contains(widget.initialValue)
        ? widget.initialValue
        : _sortOptions.first;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.35 : 0.6,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sort_rounded, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            'Sort:',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 2),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: dropdownValue,
              borderRadius: BorderRadius.circular(12),
              elevation: 4,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
              iconEnabledColor: theme.colorScheme.primary,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              dropdownColor: theme.colorScheme.surface,
              isDense: true,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  dropdownValue = value;
                });

                widget.onChanged?.call(value);
              },
              items: _sortOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
