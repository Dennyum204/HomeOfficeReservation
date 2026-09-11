import 'package:flutter/material.dart';

import 'theme_tokens.dart';

enum BadgeTone { neutral, pending, danger, information }

/// Place inside the section's scroll view, never in a persistent app bar.
class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key});
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Semantics(
      header: true,
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    ),
  );
}

class StateBadge extends StatelessWidget {
  const StateBadge(
    this.label,
    this.icon, {
    super.key,
    this.tone = BadgeTone.neutral,
    this.color,
  });
  final String label;
  final IconData icon;
  final BadgeTone tone;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final t = ThemeTokens(Theme.of(context).brightness == Brightness.dark);
    final (foreground, background) = switch (tone) {
      BadgeTone.pending => (t.pending, t.pendingSurface),
      BadgeTone.danger => (t.danger, t.dangerSurface),
      BadgeTone.information => (t.info, t.infoSurface),
      BadgeTone.neutral => (t.foreground, t.secondary),
    };
    return MergeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color ?? foreground),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: color ?? foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.title,
    required this.child,
    this.description,
  });
  final String title;
  final String? description;
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 6),
              Text(description!),
            ],
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    ),
  );
}
