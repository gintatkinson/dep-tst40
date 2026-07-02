import 'package:flutter/material.dart';

class PropertyGrid extends StatelessWidget {
  final List<PropertyField> fields;
  final Map<String, TextEditingController> controllers;
  final VoidCallback onSave;

  const PropertyGrid({
    super.key,
    required this.fields,
    required this.controllers,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sections = <String, List<PropertyField>>{};
    for (final f in fields) {
      sections.putIfAbsent(f.section ?? 'General', () => []).add(f);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final entry in sections.entries) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                entry.key.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  children: entry.value.map((f) => _buildField(context, f)).toList(),
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),
          FilledButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save, size: 14),
            label: const Text('Save'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 28),
              textStyle: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(BuildContext context, PropertyField field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              field.label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 22,
              child: TextField(
                controller: controllers[field.key],
                style: const TextStyle(fontSize: 11),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  errorStyle: const TextStyle(fontSize: 9),
                  errorText: field.error,
                  errorMaxLines: 2,
                ),
                onChanged: field.onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PropertyField {
  final String key;
  final String label;
  final String? section;
  final String? error;
  final ValueChanged<String>? onChanged;

  const PropertyField({
    required this.key,
    required this.label,
    this.section,
    this.error,
    this.onChanged,
  });
}
