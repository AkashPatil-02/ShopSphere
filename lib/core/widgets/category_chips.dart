import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class CategoryChipsShimmer extends StatelessWidget {
  const CategoryChipsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: List.generate(6, (index) {
            final widths = [80.0, 100.0, 70.0, 110.0, 90.0, 75.0];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Shimmer(
                duration: const Duration(seconds: 1),
                interval: const Duration(milliseconds: 200),
                color: Colors.white,
                colorOpacity: 0.4,
                child: Container(
                  width: widths[index],
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class CategoryChips extends StatefulWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String> onSelected;
  final VoidCallback onAllSelected;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.onSelected,
    required this.onAllSelected,
    this.selectedCategory,
  });

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedCategory;
  }

  @override
  void didUpdateWidget(covariant CategoryChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCategory != oldWidget.selectedCategory) {
      _selected = widget.selectedCategory;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: const Text('All'),
                selected: _selected == null,
                onSelected: (_) {
                  setState(() => _selected = null);
                  widget.onAllSelected();
                },
              ),
            ),
            ...widget.categories.map((label) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(label),
                  selected: _selected == label,
                  onSelected: (_) {
                    setState(() => _selected = label);
                    widget.onSelected(label);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
