// lib/widgets/category_grid.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 8,
          childAspectRatio: 0.8,
        ),
        itemCount: AppConstants.categories.length,
        itemBuilder: (_, i) {
          final cat = AppConstants.categories[i];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cat.color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(cat.emoji,
                      style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                cat.name,
                style: const TextStyle(
                    fontSize: 9,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      ),
    );
  }
}
