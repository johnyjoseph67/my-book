// ─── Section Title ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppTheme.dark,
        letterSpacing: 0.5,
      ),
    );
  }
}
