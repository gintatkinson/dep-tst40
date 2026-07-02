import 'package:flutter/material.dart';

class ResizableSplitter extends StatefulWidget {
  final Widget primary;
  final Widget secondary;
  final Axis axis;
  final double initialRatio;
  final double minPrimarySize;
  final double minSecondarySize;

  const ResizableSplitter({
    super.key,
    required this.primary,
    required this.secondary,
    this.axis = Axis.vertical,
    this.initialRatio = 0.6,
    this.minPrimarySize = 150,
    this.minSecondarySize = 150,
  });

  @override
  State<ResizableSplitter> createState() => _ResizableSplitterState();
}

class _ResizableSplitterState extends State<ResizableSplitter> {
  late double _ratio;

  @override
  void initState() {
    super.initState();
    _ratio = widget.initialRatio;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final total = widget.axis == Axis.vertical
            ? constraints.maxHeight
            : constraints.maxWidth;
        final primarySize = (total * _ratio).clamp(
          widget.minPrimarySize,
          total - widget.minSecondarySize,
        );
        final secondarySize = total - primarySize - 4;

        return Flex(
          direction: widget.axis,
          children: [
            SizedBox(
              width: widget.axis == Axis.horizontal ? primarySize : double.infinity,
              height: widget.axis == Axis.vertical ? primarySize : double.infinity,
              child: widget.primary,
            ),
            _buildDivider(constraints),
            SizedBox(
              width: widget.axis == Axis.horizontal ? secondarySize : double.infinity,
              height: widget.axis == Axis.vertical ? secondarySize : double.infinity,
              child: widget.secondary,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDivider(BoxConstraints constraints) {
    return MouseRegion(
      cursor: widget.axis == Axis.vertical
          ? SystemMouseCursors.resizeRow
          : SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final total = widget.axis == Axis.vertical
                ? constraints.maxHeight
                : constraints.maxWidth;
            final delta = widget.axis == Axis.vertical
                ? details.delta.dy
                : details.delta.dx;
            _ratio = (_ratio + delta / total).clamp(0.15, 0.85);
          });
        },
        child: Container(
          width: widget.axis == Axis.horizontal ? 4 : double.infinity,
          height: widget.axis == Axis.vertical ? 4 : double.infinity,
          color: Theme.of(context).dividerColor,
          child: Center(
            child: Container(
              width: widget.axis == Axis.horizontal ? 2 : 24,
              height: widget.axis == Axis.vertical ? 2 : 24,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
