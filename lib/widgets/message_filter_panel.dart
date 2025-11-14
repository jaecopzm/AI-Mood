import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/app_widgets.dart';

class MessageFilterPanel extends StatefulWidget {
  final ValueChanged<String?> onRecipientFilter;
  final ValueChanged<bool> onSavedOnlyFilter;
  final ValueChanged<String> onSearchChange;
  final VoidCallback onReset;

  const MessageFilterPanel({
    super.key,
    required this.onRecipientFilter,
    required this.onSavedOnlyFilter,
    required this.onSearchChange,
    required this.onReset,
  });

  @override
  State<MessageFilterPanel> createState() => _MessageFilterPanelState();
}

class _MessageFilterPanelState extends State<MessageFilterPanel> {
  late TextEditingController _searchController;
  String? _selectedRecipient;
  bool _savedOnly = false;

  final List<String> _recipients = [
    'crush',
    'friend',
    'family',
    'boss',
    'colleague',
    'best_friend',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      widget.onSearchChange(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters', style: Theme.of(context).textTheme.titleLarge),
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                    _selectedRecipient = null;
                    _savedOnly = false;
                    widget.onReset();
                    setState(() {});
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.lg),

            // Search
            AppTextField(
              label: 'Search Messages',
              hint: 'Type to search...',
              controller: _searchController,
              prefixIcon: Icons.search,
            ),
            const SizedBox(height: AppTheme.lg),

            // Recipient Filter
            Text(
              'Recipient',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppTheme.sm),
            Wrap(
              spacing: AppTheme.sm,
              runSpacing: AppTheme.sm,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedRecipient == null,
                  onSelected: (selected) {
                    setState(() => _selectedRecipient = null);
                    widget.onRecipientFilter(null);
                  },
                ),
                ..._recipients.map((recipient) {
                  return FilterChip(
                    label: Text(_capitalizeFirst(recipient)),
                    selected: _selectedRecipient == recipient,
                    onSelected: (selected) {
                      setState(
                        () => _selectedRecipient = selected ? recipient : null,
                      );
                      widget.onRecipientFilter(_selectedRecipient);
                    },
                  );
                }),
              ],
            ),
            const SizedBox(height: AppTheme.lg),

            // Saved Only Filter
            CheckboxListTile(
              value: _savedOnly,
              onChanged: (value) {
                setState(() => _savedOnly = value ?? false);
                widget.onSavedOnlyFilter(_savedOnly);
              },
              title: const Text('Show Saved Only'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppTheme.primary,
            ),
            const SizedBox(height: AppTheme.lg),

            // Apply Button
            AppButton(
              label: 'Apply Filters',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).replaceAll('_', ' ');
  }
}
