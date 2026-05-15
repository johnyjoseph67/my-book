import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';

class StyledDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final String? prefixEmoji;

  const StyledDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.prefixEmoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppTheme.textSecondary, size: 18),
          style: const TextStyle(
              fontSize: 13, color: AppTheme.dark, fontFamily: 'DMSans'),
          onChanged: onChanged,
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Row(
                      children: [
                        if (prefixEmoji != null && item == value) ...[
                          Text(prefixEmoji!,
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                        ],
                        Text(itemLabel(item)),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
