import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/reclamation.dart';
import '../providers/reclamation_provider.dart';

class ReclamationDetailDialog extends StatefulWidget {
  final Reclamation reclamation;

  const ReclamationDetailDialog({Key? key, required this.reclamation})
      : super(key: key);

  @override
  State<ReclamationDetailDialog> createState() =>
      _ReclamationDetailDialogState();
}

class _ReclamationDetailDialogState extends State<ReclamationDetailDialog> {
  final _responseController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.reclamation.adminResponse != null) {
      _responseController.text = widget.reclamation.adminResponse!;
    }
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _submitResponse() async {
    if (_responseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a response'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await Provider.of<ReclamationProvider>(
      context,
      listen: false,
    ).addAdminResponse(widget.reclamation.id, _responseController.text);

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() {
      _isSubmitting = true;
    });

    await Provider.of<ReclamationProvider>(
      context,
      listen: false,
    ).updateReclamationStatus(
      widget.reclamation.id,
      newStatus,
      adminResponse: _responseController.text.isNotEmpty
          ? _responseController.text
          : widget.reclamation.adminResponse,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');
    final isSubmitDisabled = _isSubmitting ||
        (widget.reclamation.status == 'resolved' &&
            widget.reclamation.adminResponse == _responseController.text);

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        constraints: BoxConstraints(
          maxWidth: 600,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getColorsForPriority(widget.reclamation.priority),
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 24, 16, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.reclamation.title,
                        style: textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildStatusChip(context, widget.reclamation.status),
                        const SizedBox(width: 12),
                        _buildPriorityChip(
                            context, widget.reclamation.priority),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _buildSectionHeader(
                        context, 'Description', Icons.description_outlined),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        widget.reclamation.description,
                        style: textTheme.bodyMedium,
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildSectionHeader(
                        context, 'User Information', Icons.person_outline),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: colorScheme.primary,
                              child: Text(
                                widget.reclamation.userName.isNotEmpty
                                    ? widget.reclamation.userName[0]
                                        .toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.reclamation.userName.isNotEmpty
                                      ? widget.reclamation.userName
                                      : 'Anonymous',
                                  style: textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceVariant,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'ID: ${widget.reclamation.userId}',
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildSectionHeader(
                        context, 'Timeline', Icons.timeline_outlined),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildTimelineItem(
                            context,
                            icon: Icons.create_outlined,
                            title: 'Reclamation Created',
                            date: widget.reclamation.createdAt,
                            isFirst: true,
                            isLast: widget.reclamation.status == 'pending' &&
                                widget.reclamation.resolvedAt == null,
                          ),
                          if (widget.reclamation.status == 'in_progress')
                            _buildTimelineItem(
                              context,
                              icon: Icons.pending_actions_outlined,
                              title: 'In Progress',
                              date: DateTime.now(),
                              isFirst: false,
                              isLast: widget.reclamation.resolvedAt == null,
                            ),
                          if (widget.reclamation.resolvedAt != null)
                            _buildTimelineItem(
                              context,
                              icon: Icons.check_circle_outline,
                              title: 'Resolved',
                              date: widget.reclamation.resolvedAt!,
                              isFirst: false,
                              isLast: true,
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    _buildSectionHeader(
                        context, 'Admin Response', Icons.comment_outlined),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withOpacity(0.5),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _responseController,
                        decoration: InputDecoration(
                          hintText: 'Enter your response...',
                          hintStyle: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.6)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: widget.reclamation.status == 'resolved'
                              ? colorScheme.surfaceVariant.withOpacity(0.3)
                              : colorScheme.surface,
                          filled: true,
                          contentPadding: const EdgeInsets.all(16),
                          enabled: widget.reclamation.status != 'resolved',
                        ),
                        maxLines: 5,
                        style: textTheme.bodyMedium,
                      ),
                    ),

                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                isSubmitDisabled ? null : _submitResponse,
                            icon: const Icon(Icons.send),
                            label: const Text('Send Response'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              disabledBackgroundColor:
                                  colorScheme.surfaceVariant,
                              disabledForegroundColor:
                                  colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        if (widget.reclamation.status != 'resolved') ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isSubmitting
                                  ? null
                                  : () => _updateStatus('resolved'),
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Mark as Resolved'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                disabledBackgroundColor:
                                    colorScheme.surfaceVariant,
                                disabledForegroundColor:
                                    colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  List<Color> _getColorsForPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return [Colors.red.shade700, Colors.red.shade400];
      case 'medium':
        return [Colors.orange.shade800, Colors.orange.shade400];
      case 'low':
        return [Colors.green.shade700, Colors.green.shade400];
      default:
        return [Colors.blue.shade700, Colors.blue.shade400];
    }
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    late IconData icon;
    late Color color;
    late String label;

    switch (status) {
      case 'pending':
        icon = Icons.pending_actions;
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'in_progress':
        icon = Icons.hourglass_top;
        color = Colors.blue;
        label = 'In Progress';
        break;
      case 'resolved':
        icon = Icons.task_alt;
        color = Colors.green;
        label = 'Resolved';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(BuildContext context, String priority) {
    late Color color;
    late IconData icon;

    switch (priority.toLowerCase()) {
      case 'high':
        color = Colors.red;
        icon = Icons.priority_high;
        break;
      case 'medium':
        color = Colors.orange;
        icon = Icons.remove_circle_outline;
        break;
      case 'low':
        color = Colors.green;
        icon = Icons.arrow_downward;
        break;
      default:
        color = Colors.blue;
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '${priority.toUpperCase()} Priority',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required DateTime date,
    required bool isFirst,
    required bool isLast,
  }) {
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.primary,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 16,
                color: colorScheme.primary,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: colorScheme.primary.withOpacity(0.5),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    dateFormat.format(date),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
