import 'package:flutter/material.dart';

class TopologyView extends StatelessWidget {
  final String? selectedNodeId;

  const TopologyView({super.key, this.selectedNodeId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surfaceContainerLowest,
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.hub,
                  size: 64,
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 8),
                Text(
                  'Topology View',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                if (selectedNodeId != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Selected: $selectedNodeId',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Row(
              children: [
                _zoomButton(context, Icons.zoom_in, '+'),
                const SizedBox(width: 4),
                _zoomButton(context, Icons.zoom_out, '-'),
                const SizedBox(width: 4),
                _zoomButton(context, Icons.fit_screen, 'F'),
              ],
            ),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: _miniIcon(Icons.play_arrow, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _zoomButton(BuildContext context, IconData icon, String label) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Center(
        child: Text(label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _miniIcon(IconData icon, ColorScheme cs) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
      ),
      child: Icon(icon, size: 14),
    );
  }
}
