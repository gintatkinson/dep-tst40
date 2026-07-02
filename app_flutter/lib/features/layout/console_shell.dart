import 'package:flutter/material.dart';
import '../../data/reference_frame_repository.dart';
import '../../domain/feature_flags.dart';
import '../../domain/reference_frame_validator.dart';
import '../reference_frame/reference_frame_form.dart';
import '../reference_frame/reference_frame_viewmodel.dart';
import '../../core/app_theme.dart';

class ConsoleViewModel extends ChangeNotifier {
  String? _selectedNodeId;
  final ReferenceFrameRepository repository;
  final ReferenceFrameViewModel referenceFrameVm;

  ConsoleViewModel({required this.repository})
      : referenceFrameVm = ReferenceFrameViewModel(
          repository: repository,
          validator: const ReferenceFrameValidator(),
          featureFlags: const FeatureFlags(),
        );

  String? get selectedNodeId => _selectedNodeId;

  void selectNode(String nodeId) {
    _selectedNodeId = nodeId;
    if (nodeId == 'ref-frame') {
      referenceFrameVm.load();
    }
    notifyListeners();
  }
}

class ConsoleShell extends StatelessWidget {
  final ConsoleViewModel viewModel;
  final AppTheme themeController;

  const ConsoleShell({
    super.key,
    required this.viewModel,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return Column(
            children: [
              _buildTopBar(context),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              Expanded(child: _buildBody(context)),
              _buildStatusBar(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(Icons.hub, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          const Text('Systems Console',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(width: 24),
          _breadcrumb(context),
          const Spacer(),
          _themeToggle(context),
          IconButton(
            icon: const Icon(Icons.settings, size: 14),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _breadcrumb(BuildContext context) {
    final segments = <String>['Dashboard'];
    if (viewModel.selectedNodeId != null) {
      segments.add(viewModel.selectedNodeId!);
    }
    return Row(
      children: [
        for (var i = 0; i < segments.length; i++) ...[
          if (i > 0)
            Icon(Icons.chevron_right, size: 12, color: Colors.grey.shade500),
          Text(
            segments[i],
            style: TextStyle(
              fontSize: 11,
              fontWeight: i == segments.length - 1 ? FontWeight.w600 : FontWeight.normal,
              color: i == segments.length - 1
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ],
    );
  }

  Widget _themeToggle(BuildContext context) {
    return IconButton(
      icon: Icon(
        themeController.mode == ThemeMode.dark
            ? Icons.light_mode
            : Icons.dark_mode,
        size: 14,
      ),
      onPressed: () {
        themeController.setMode(
          themeController.mode == ThemeMode.dark
              ? ThemeMode.light
              : ThemeMode.dark,
        );
      },
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      tooltip: 'Toggle theme',
    );
  }

  Widget _buildBody(BuildContext context) {
    return Row(
      children: [
        _buildSidebar(context),
        Container(width: 1, color: Theme.of(context).dividerColor),
        Expanded(child: _buildMainWorkspace(context)),
      ],
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final nodes = [
      _treeNode(context, 'Type-A', children: [
        _treeNode(context, 'Subtype-01'),
        _treeNode(context, 'Subtype-02'),
        _treeNode(context, 'geo-location', children: [
          _treeNode(context, 'ref-frame', isRefFrame: true),
        ]),
      ]),
      _treeNode(context, 'Type-B', children: [
        _treeNode(context, 'Subtype-04'),
        _treeNode(context, 'Subtype-05'),
      ]),
      _treeNode(context, 'Type-C'),
    ];

    return SizedBox(
      width: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            child: SizedBox(
              height: 24,
              child: TextField(
                style: const TextStyle(fontSize: 11),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  hintText: 'Filter tree...',
                  hintStyle:
                      TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  prefixIcon:
                      Icon(Icons.search, size: 14, color: Colors.grey.shade500),
                ),
              ),
            ),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          Expanded(
            child: ListView(padding: EdgeInsets.zero, children: nodes),
          ),
        ],
      ),
    );
  }

  Widget _treeNode(BuildContext context, String label, {List<Widget>? children, bool isRefFrame = false}) {
    final nodeId = isRefFrame ? 'ref-frame' : label;
    final isSelected = viewModel.selectedNodeId == nodeId;

    return Material(
      color: isSelected
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
          : Colors.transparent,
      child: ListTileTheme(
        data: ListTileThemeData(
          minLeadingWidth: 0,
          horizontalTitleGap: 4,
          dense: true,
          visualDensity: VisualDensity.compact,
          contentPadding: EdgeInsets.only(left: 16.0 + (label == label ? 0 : 0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => viewModel.selectNode(nodeId),
              child: Container(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      isRefFrame ? Icons.public : Icons.folder_outlined,
                      size: 14,
                      color: isRefFrame
                          ? Colors.teal
                          : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isRefFrame ? 'Reference Frame' : label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (children != null)
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(children: children),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainWorkspace(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: _buildTopologyPane(context),
        ),
        Container(height: 1, color: Theme.of(context).dividerColor),
        Expanded(
          flex: 2,
          child: _buildTablePane(context),
        ),
      ],
    );
  }

  Widget _buildTopologyPane(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.hub, size: 48,
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.25)),
                const SizedBox(height: 8),
                Text('Topology Viewport',
                    style: TextStyle(fontSize: 11,
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5))),
                if (viewModel.selectedNodeId != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text('Node: ${viewModel.selectedNodeId}',
                        style: TextStyle(fontSize: 10,
                            color: Theme.of(context).colorScheme.primary)),
                  ),
                ],
              ],
            ),
          ),
          Positioned(right: 8, top: 8, child: _zoomControls(context)),
          Positioned(left: 8, bottom: 8, child: Row(children: [
            _miniButton(Icons.play_arrow, context),
            const SizedBox(width: 4),
            _miniButton(Icons.pause, context),
            const SizedBox(width: 4),
            _miniButton(Icons.stop, context),
          ])),
        ],
      ),
    );
  }

  Widget _zoomControls(BuildContext context) {
    return Row(
      children: [
        _miniButton(Icons.add, context),
        const SizedBox(width: 4),
        _miniButton(Icons.remove, context),
        const SizedBox(width: 4),
        _miniButton(Icons.fit_screen, context),
      ],
    );
  }

  Widget _miniButton(IconData icon, BuildContext context) {
    return Container(
      width: 24, height: 24,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Icon(icon, size: 14),
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.5),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _buildTablePane(BuildContext context) {
    final isRefFrameSelected = viewModel.selectedNodeId == 'ref-frame';

    return Column(
      children: [
        _tableTabBar(context),
        Divider(height: 1, color: Theme.of(context).dividerColor),
        Expanded(
          child: isRefFrameSelected
              ? _buildPropertyPane(context)
              : Center(
                  child: Text('Select a node to view data',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ),
        ),
      ],
    );
  }

  Widget _buildPropertyPane(BuildContext context) {
    final rfVm = viewModel.referenceFrameVm;
    return ListenableBuilder(
      listenable: rfVm,
      builder: (context, _) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.public, size: 14, color: Colors.teal),
                  const SizedBox(width: 6),
                  Text('Reference Frame Configuration',
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyMedium?.color)),
                  const Spacer(),
                  if (rfVm.isValid)
                    _statusBadge('VALID', Colors.green),
                  if (!rfVm.isValid)
                    _statusBadge('INVALID', Colors.red),
                ],
              ),
            ),
            Expanded(child: ReferenceFrameForm(viewModel: rfVm)),
          ],
        );
      },
    );
  }

  Widget _tableTabBar(BuildContext context) {
    final tabs = ['Elements (0)', 'Alarms (0)', 'Events (0)', 'Relations (0)'];
    return SizedBox(
      height: 26,
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            _tabChip(context, tabs[i], i == 0),
          const Spacer(),
          _actionIcon(Icons.filter_list, context),
          _actionIcon(Icons.sort, context),
        ],
      ),
    );
  }

  Widget _tabChip(BuildContext context, String label, bool active) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: InkWell(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
          child: Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  color: active ? Theme.of(context).colorScheme.primary : null)),
        ),
      ),
    );
  }

  Widget _actionIcon(IconData icon, BuildContext context) {
    return SizedBox(
      width: 24, height: 24,
      child: IconButton(
        icon: Icon(icon, size: 13),
        onPressed: () {},
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Text('Ready',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          const Spacer(),
          Text('v1.0.0',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
