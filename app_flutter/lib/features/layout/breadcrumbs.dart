import 'package:flutter/material.dart';

class NavigationBreadcrumbs extends StatelessWidget {
  final List<BreadcrumbSegment> segments;

  const NavigationBreadcrumbs({super.key, required this.segments});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          for (var i = 0; i < segments.length; i++) ...[
            if (i > 0)
              Icon(Icons.chevron_right, size: 14, color: Colors.grey.shade500),
            _buildSegment(context, segments[i], i == segments.length - 1),
          ],
        ],
      ),
    );
  }

  Widget _buildSegment(
      BuildContext context, BreadcrumbSegment segment, bool isLast) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: segment.onTap,
        borderRadius: BorderRadius.circular(2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(
            segment.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
              color: isLast
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      ),
    );
  }
}

class BreadcrumbSegment {
  final String label;
  final VoidCallback? onTap;

  const BreadcrumbSegment({required this.label, this.onTap});
}
