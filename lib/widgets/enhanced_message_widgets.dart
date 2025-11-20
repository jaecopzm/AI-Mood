import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/message_model.dart';
import '../config/premium_theme.dart';
import '../services/share_service.dart';
import '../core/services/logger_service.dart';

/// Enhanced message card with swipe actions and improved UI
class EnhancedMessageCard extends StatefulWidget {
  final MessageModel message;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onFavoriteToggle;
  final bool showActions;
  final bool isExpanded;

  const EnhancedMessageCard({
    super.key,
    required this.message,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onFavoriteToggle,
    this.showActions = true,
    this.isExpanded = false,
  });

  @override
  State<EnhancedMessageCard> createState() => _EnhancedMessageCardState();
}

class _EnhancedMessageCardState extends State<EnhancedMessageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dismissible(
        key: Key(widget.message.id),
        background: _buildSwipeBackground(isLeft: true),
        secondaryBackground: _buildSwipeBackground(isLeft: false),
        confirmDismiss: _handleSwipeAction,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: PremiumTheme.spaceMd,
            vertical: PremiumTheme.spaceSm,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                PremiumTheme.surface,
                PremiumTheme.surface.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
            border: Border.all(
              color: widget.message.isSaved
                  ? PremiumTheme.gold.withValues(alpha: 0.3)
                  : PremiumTheme.border.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.message.isSaved
                    ? PremiumTheme.gold.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              onTapDown: (_) => _handleTapDown(),
              onTapUp: (_) => _handleTapUp(),
              onTapCancel: () => _handleTapUp(),
              borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
              child: Padding(
                padding: const EdgeInsets.all(PremiumTheme.spaceMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: PremiumTheme.spaceSm),
                    _buildMessageContent(),
                    if (widget.showActions) ...[
                      const SizedBox(height: PremiumTheme.spaceMd),
                      _buildActionButtons(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildToneChip(),
        const SizedBox(width: PremiumTheme.spaceSm),
        _buildRecipientChip(),
        const Spacer(),
        if (widget.message.isSaved)
          Icon(Icons.star, color: PremiumTheme.gold, size: 18),
        const SizedBox(width: PremiumTheme.spaceSm),
        Text(
          _formatDate(widget.message.createdAt),
          style: PremiumTheme.bodySmall.copyWith(
            color: PremiumTheme.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildToneChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumTheme.spaceSm,
        vertical: PremiumTheme.spaceXs,
      ),
      decoration: BoxDecoration(
        gradient: _getToneGradient(widget.message.tone),
        borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
      ),
      child: Text(
        widget.message.tone,
        style: PremiumTheme.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRecipientChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumTheme.spaceSm,
        vertical: PremiumTheme.spaceXs,
      ),
      decoration: BoxDecoration(
        color: PremiumTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
        border: Border.all(color: PremiumTheme.border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRecipientIcon(widget.message.recipientType),
            size: 14,
            color: PremiumTheme.textSecondary,
          ),
          const SizedBox(width: PremiumTheme.spaceXs),
          Text(
            widget.message.recipientType,
            style: PremiumTheme.labelSmall.copyWith(
              color: PremiumTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.message.context.isNotEmpty) ...[
          Text(
            'Context: ${widget.message.context}',
            style: PremiumTheme.bodySmall.copyWith(
              color: PremiumTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            maxLines: widget.isExpanded ? null : 2,
            overflow: widget.isExpanded ? null : TextOverflow.ellipsis,
          ),
          const SizedBox(height: PremiumTheme.spaceSm),
        ],
        Text(
          widget.message.generatedText,
          style: PremiumTheme.bodyLarge.copyWith(
            height: 1.5,
            color: PremiumTheme.textPrimary,
          ),
          maxLines: widget.isExpanded ? null : 4,
          overflow: widget.isExpanded ? null : TextOverflow.ellipsis,
        ),
        if (!widget.isExpanded && _isTextTruncated()) ...[
          const SizedBox(height: PremiumTheme.spaceXs),
          GestureDetector(
            onTap: widget.onTap,
            child: Text(
              'Read more...',
              style: PremiumTheme.labelMedium.copyWith(
                color: PremiumTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildActionButton(
          icon: Icons.copy,
          label: 'Copy',
          onPressed: _copyToClipboard,
        ),
        const SizedBox(width: PremiumTheme.spaceSm),
        _buildActionButton(
          icon: Icons.share,
          label: 'Share',
          onPressed: _shareMessage,
        ),
        const Spacer(),
        _buildActionButton(
          icon: widget.message.isSaved ? Icons.star : Icons.star_outline,
          label: widget.message.isSaved ? 'Saved' : 'Save',
          onPressed: widget.onFavoriteToggle,
          isHighlighted: widget.message.isSaved,
        ),
        if (widget.onEdit != null) ...[
          const SizedBox(width: PremiumTheme.spaceSm),
          _buildActionButton(
            icon: Icons.edit,
            label: 'Edit',
            onPressed: widget.onEdit,
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isHighlighted = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: PremiumTheme.spaceSm,
            vertical: PremiumTheme.spaceXs,
          ),
          decoration: BoxDecoration(
            color: isHighlighted
                ? PremiumTheme.gold.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isHighlighted
                    ? PremiumTheme.gold
                    : PremiumTheme.textSecondary,
              ),
              const SizedBox(width: PremiumTheme.spaceXs),
              Text(
                label,
                style: PremiumTheme.labelSmall.copyWith(
                  color: isHighlighted
                      ? PremiumTheme.gold
                      : PremiumTheme.textSecondary,
                  fontWeight: isHighlighted
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({required bool isLeft}) {
    final color = isLeft ? PremiumTheme.gold : Colors.red;
    final icon = isLeft ? Icons.star : Icons.delete;
    final label = isLeft ? 'Favorite' : 'Delete';

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: PremiumTheme.spaceMd,
        vertical: PremiumTheme.spaceSm,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
      ),
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: PremiumTheme.spaceLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: PremiumTheme.spaceXs),
          Text(
            label,
            style: PremiumTheme.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _handleSwipeAction(DismissDirection direction) async {
    if (direction == DismissDirection.startToEnd) {
      // Swipe right - toggle favorite
      widget.onFavoriteToggle?.call();
      return false; // Don't dismiss
    } else if (direction == DismissDirection.endToStart) {
      // Swipe left - delete
      final confirmed = await _showDeleteConfirmation();
      if (confirmed == true) {
        widget.onDelete?.call();
        return true; // Dismiss
      }
      return false; // Don't dismiss
    }
    return false;
  }

  Future<bool?> _showDeleteConfirmation() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text(
          'Are you sure you want to delete this message? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleTapDown() {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.message.generatedText));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Message copied to clipboard'),
          backgroundColor: PremiumTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
          ),
        ),
      );
    }
  }

  void _shareMessage() async {
    try {
      await ShareService.shareText(widget.message.generatedText);
    } catch (e) {
      LoggerService.error('Failed to share message', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to share message'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  bool _isTextTruncated() {
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.message.generatedText,
        style: PremiumTheme.bodyLarge,
      ),
      maxLines: 4,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 64);
    return textPainter.didExceedMaxLines;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  LinearGradient _getToneGradient(String tone) {
    switch (tone.toLowerCase()) {
      case 'romantic':
        return PremiumTheme.secondaryGradient;
      case 'funny':
        return PremiumTheme.accentGradient;
      case 'professional':
        return PremiumTheme.oceanGradient;
      case 'apologetic':
        return LinearGradient(
          colors: [Colors.orange.shade400, Colors.red.shade400],
        );
      case 'grateful':
        return PremiumTheme.goldGradient;
      default:
        return PremiumTheme.primaryGradient;
    }
  }

  IconData _getRecipientIcon(String recipientType) {
    switch (recipientType.toLowerCase()) {
      case 'crush':
        return Icons.favorite_outline;
      case 'girlfriend':
      case 'boyfriend':
        return Icons.favorite;
      case 'best friend':
        return Icons.person;
      case 'family':
        return Icons.family_restroom;
      case 'boss':
        return Icons.business;
      case 'colleague':
        return Icons.work;
      case 'parent':
        return Icons.family_restroom;
      case 'sibling':
        return Icons.people;
      default:
        return Icons.person_outline;
    }
  }
}

/// Search and filter widget for message management
class MessageSearchAndFilter extends StatefulWidget {
  final Function(String query) onSearch;
  final Function(String? recipient, String? tone, DateTimeRange? dateRange)
  onFilter;
  final List<String> availableRecipients;
  final List<String> availableTones;

  const MessageSearchAndFilter({
    super.key,
    required this.onSearch,
    required this.onFilter,
    required this.availableRecipients,
    required this.availableTones,
  });

  @override
  State<MessageSearchAndFilter> createState() => _MessageSearchAndFilterState();
}

class _MessageSearchAndFilterState extends State<MessageSearchAndFilter> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedRecipient;
  String? _selectedTone;
  DateTimeRange? _selectedDateRange;
  bool _isFilterExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(PremiumTheme.spaceMd),
      decoration: BoxDecoration(
        color: PremiumTheme.surface,
        borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
        boxShadow: [PremiumTheme.shadowLg],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(PremiumTheme.spaceMd),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search messages...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          PremiumTheme.radiusMd,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: PremiumTheme.surfaceVariant,
                    ),
                    onChanged: widget.onSearch,
                  ),
                ),
                const SizedBox(width: PremiumTheme.spaceSm),
                IconButton(
                  onPressed: () {
                    setState(() => _isFilterExpanded = !_isFilterExpanded);
                  },
                  icon: Icon(
                    _isFilterExpanded ? Icons.filter_list : Icons.tune,
                    color: _hasActiveFilters() ? PremiumTheme.primary : null,
                  ),
                ),
              ],
            ),
          ),
          if (_isFilterExpanded) _buildFilters(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(PremiumTheme.spaceMd),
      decoration: BoxDecoration(
        color: PremiumTheme.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(PremiumTheme.radiusLg),
          bottomRight: Radius.circular(PremiumTheme.radiusLg),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Recipient',
                  value: _selectedRecipient,
                  items: widget.availableRecipients,
                  onChanged: (value) {
                    setState(() => _selectedRecipient = value);
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: PremiumTheme.spaceSm),
              Expanded(
                child: _buildDropdown(
                  label: 'Tone',
                  value: _selectedTone,
                  items: widget.availableTones,
                  onChanged: (value) {
                    setState(() => _selectedTone = value);
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: PremiumTheme.spaceMd),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectDateRange,
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _selectedDateRange != null
                        ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
                        : 'Date Range',
                  ),
                ),
              ),
              const SizedBox(width: PremiumTheme.spaceSm),
              OutlinedButton(
                onPressed: _clearFilters,
                child: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
        ),
      ),
      items: [
        DropdownMenuItem<String>(value: null, child: Text('All ${label}s')),
        ...items.map(
          (item) => DropdownMenuItem<String>(value: item, child: Text(item)),
        ),
      ],
      onChanged: onChanged,
    );
  }

  void _selectDateRange() async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );

    if (dateRange != null) {
      setState(() => _selectedDateRange = dateRange);
      _applyFilters();
    }
  }

  void _applyFilters() {
    widget.onFilter(_selectedRecipient, _selectedTone, _selectedDateRange);
  }

  void _clearFilters() {
    setState(() {
      _selectedRecipient = null;
      _selectedTone = null;
      _selectedDateRange = null;
    });
    _applyFilters();
  }

  bool _hasActiveFilters() {
    return _selectedRecipient != null ||
        _selectedTone != null ||
        _selectedDateRange != null;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
