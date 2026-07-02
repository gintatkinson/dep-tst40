import 'package:flutter/material.dart';
import 'package:pipeline_app/domain/validation_result.dart';
import 'reference_frame_viewmodel.dart';

class ReferenceFrameForm extends StatefulWidget {
  final ReferenceFrameViewModel viewModel;

  const ReferenceFrameForm({super.key, required this.viewModel});

  @override
  State<ReferenceFrameForm> createState() => _ReferenceFrameFormState();
}

class _ReferenceFrameFormState extends State<ReferenceFrameForm> {
  final _astronomicalBodyController = TextEditingController();
  final _alternateSystemController = TextEditingController();
  bool _showDeleteConfirm = false;

  ReferenceFrameViewModel get vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _astronomicalBodyController.text = vm.astronomicalBody;
    _alternateSystemController.text = vm.alternateSystem ?? '';
    vm.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    vm.removeListener(_onViewModelChanged);
    _astronomicalBodyController.dispose();
    _alternateSystemController.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final alternateSystemError = vm.errors
        .where((e) => e.field == 'alternateSystem' && e.type == ValidationErrorType.alternateSystemDisabled)
        .firstOrNull;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Reference Frame',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _astronomicalBodyController,
            decoration: InputDecoration(
              labelText: 'Astronomical Body',
              hintText: 'earth',
              errorText: vm.errors
                  .where((e) => e.field == 'astronomicalBody')
                  .map((e) => e.message)
                  .join('\n'),
              errorMaxLines: 3,
            ),
            onChanged: (value) {
              vm.updateAstronomicalBody(value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _alternateSystemController,
            decoration: InputDecoration(
              labelText: 'Alternate System',
              hintText: 'Optional',
              errorText: alternateSystemError?.message,
            ),
            onChanged: (value) {
              if (value.isEmpty) {
                vm.clearAlternateSystem();
              } else {
                vm.updateAlternateSystem(value);
              }
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: vm.isValid ? () => vm.save() : null,
                  icon: const Icon(Icons.save, size: 16),
                  label: const Text('Save'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _showDeleteConfirm = true),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                ),
              ),
            ],
          ),
          if (_showDeleteConfirm)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  const Text('Confirm delete?',
                      style: TextStyle(color: Colors.red)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _showDeleteConfirm = false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      vm.delete();
                      setState(() => _showDeleteConfirm = false);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
