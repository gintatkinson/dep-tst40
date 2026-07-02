import 'package:flutter/material.dart';

class TabbedTablePanel extends StatelessWidget {
  final List<TabbedTableData> tabs;

  const TabbedTablePanel({super.key, required this.tabs});

  @override
  Widget build(BuildContext context) {
    if (tabs.isEmpty) {
      return Center(
        child: Text('No data', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 26,
          child: Row(
            children: [
              for (var i = 0; i < tabs.length; i++)
                _tabButton(context, tabs[i], i, i == 0),
              const Spacer(),
              _iconButton(Icons.filter_list, 'Filter'),
              _iconButton(Icons.sort, 'Sort'),
              _iconButton(Icons.more_horiz, 'More'),
            ],
          ),
        ),
        Divider(height: 1, color: Theme.of(context).dividerColor),
        Expanded(
          child: _buildTable(context, tabs[0]),
        ),
      ],
    );
  }

  Widget _tabButton(BuildContext context, TabbedTableData tab, int index, bool active) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tab.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                color: active
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            if (tab.badge != null) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${tab.badge}',
                  style: TextStyle(
                    fontSize: 9,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, String tooltip) {
    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        icon: Icon(icon, size: 14),
        onPressed: () {},
        padding: EdgeInsets.zero,
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildTable(BuildContext context, TabbedTableData tab) {
    if (tab.columns.isEmpty || tab.rows.isEmpty) {
      return Center(
        child: Text(
          'No records',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 12,
          headingRowHeight: 26,
          dataRowMinHeight: 22,
          dataRowMaxHeight: 22,
          horizontalMargin: 8,
          columns: tab.columns
              .map((c) => DataColumn(
                    label: Text(c, style: const TextStyle(fontSize: 10)),
                  ))
              .toList(),
          rows: tab.rows
              .map((row) => DataRow(
                    cells: row
                        .map((cell) => DataCell(
                              Text(
                                cell,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ))
                        .toList(),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class TabbedTableData {
  final String label;
  final int? badge;
  final List<String> columns;
  final List<List<String>> rows;

  const TabbedTableData({
    required this.label,
    this.badge,
    required this.columns,
    required this.rows,
  });
}
