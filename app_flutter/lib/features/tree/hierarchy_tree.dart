import 'package:flutter/material.dart';

class HierarchyTreeSelector extends StatefulWidget {
  final List<TreeNode> items;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final double width;

  const HierarchyTreeSelector({
    super.key,
    required this.items,
    this.selectedId,
    required this.onSelect,
    this.width = 280,
  });

  @override
  State<HierarchyTreeSelector> createState() => _HierarchyTreeSelectorState();
}

class _HierarchyTreeSelectorState extends State<HierarchyTreeSelector> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter(widget.items);

    return SizedBox(
      width: widget.width,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 11),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                hintText: 'Filter...',
                hintStyle: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        iconSize: 14,
                        icon: const Icon(Icons.clear, size: 14),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              children: _buildItems(filtered, 0),
            ),
          ),
        ],
      ),
    );
  }

  List<TreeNode> _filter(List<TreeNode> nodes) {
    if (_query.isEmpty) return nodes;
    return nodes
        .where((n) =>
            n.label.toLowerCase().contains(_query) ||
            n.id.toLowerCase().contains(_query) ||
            _filter(n.children).isNotEmpty)
        .toList();
  }

  List<Widget> _buildItems(List<TreeNode> nodes, int depth) {
    final widgets = <Widget>[];
    final colors = [
      Theme.of(context).colorScheme.primary,
      Colors.teal,
      Colors.deepOrange,
      Colors.purple,
    ];

    for (final node in nodes) {
      final isSelected = node.id == widget.selectedId;
      final color = colors[depth % colors.length];

      widgets.add(
        Material(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Colors.transparent,
          child: InkWell(
            onTap: () => widget.onSelect(node.id),
            child: Padding(
              padding: EdgeInsets.only(
                left: 8.0 + depth * 16.0,
                right: 4,
                top: 2,
                bottom: 2,
              ),
              child: SizedBox(
                height: 22,
                child: Row(
                  children: [
                    if (node.children.isNotEmpty)
                      Icon(
                        Icons.chevron_right,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                    if (node.children.isEmpty) const SizedBox(width: 14),
                    const SizedBox(width: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        node.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? color
                              : Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      if (node.children.isNotEmpty) {
        widgets.addAll(_buildItems(node.children, depth + 1));
      }
    }
    return widgets;
  }
}

class TreeNode {
  final String id;
  final String label;
  final List<TreeNode> children;

  const TreeNode({
    required this.id,
    required this.label,
    this.children = const [],
  });
}
