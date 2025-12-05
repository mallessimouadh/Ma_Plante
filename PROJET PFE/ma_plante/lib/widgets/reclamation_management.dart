import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reclamation_provider.dart';
import '../providers/auth_provider.dart';
import '../models/reclamation.dart';
import 'reclamation_detail_dialog.dart';

class ReclamationManagement extends StatefulWidget {
  const ReclamationManagement({Key? key}) : super(key: key);

  @override
  State<ReclamationManagement> createState() => _ReclamationManagementState();
}

class _ReclamationManagementState extends State<ReclamationManagement>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showReclamationDetail(BuildContext context, Reclamation reclamation) {
    showDialog(
      context: context,
      builder: (context) => ReclamationDetailDialog(reclamation: reclamation),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(
    BuildContext context,
    String title,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous vraiment supprimer la réclamation "$title" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.role != 'Super Admin') {
          return const Center(child: Text('Accès réservé aux administrateurs'));
        }

        final reclamationProvider = Provider.of<ReclamationProvider>(context);
        print(
          'Current user: ${authProvider.adminName}, role: ${authProvider.role}',
        );

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reclamation Management',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage user complaints, feedback, and feature requests',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              TabBar(
                controller: _tabController,
                labelPadding: EdgeInsets.symmetric(horizontal: 8),
                tabs: [
                  Tab(
                    icon: Stack(
                      children: [
                        const Icon(Icons.pending_actions),
                        if (reclamationProvider.pendingReclamations.isNotEmpty)
                          Positioned(
                            right: -5,
                            top: -5,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                              ),
                              child: Text(
                                reclamationProvider.pendingReclamations.length
                                    .toString(),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onError,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    text: 'Pending',
                  ),
                  const Tab(
                    icon: Icon(Icons.hourglass_top),
                    text: 'In Prog.',
                  ),
                  const Tab(
                    icon: Icon(Icons.task_alt),
                    text: 'Resolved',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: reclamationProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildReclamationList(
                            context,
                            reclamationProvider.pendingReclamations,
                            emptyMessage: 'No pending reclamations',
                          ),
                          _buildReclamationList(
                            context,
                            reclamationProvider.inProgressReclamations,
                            emptyMessage: 'No reclamations in progress',
                          ),
                          _buildReclamationList(
                            context,
                            reclamationProvider.resolvedReclamations,
                            emptyMessage: 'No resolved reclamations',
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReclamationList(
    BuildContext context,
    List<Reclamation> reclamations, {
    required String emptyMessage,
  }) {
    if (reclamations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: reclamations.length,
      itemBuilder: (context, index) {
        final reclamation = reclamations[index];
        final priorityColor = _getPriorityColor(reclamation.priority);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showReclamationDetail(context, reclamation),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reclamation.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          reclamation.priority.toUpperCase(),
                          style: TextStyle(
                            color: priorityColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirmed = await _showDeleteConfirmationDialog(
                            context,
                            reclamation.title,
                          );
                          if (confirmed == true) {
                            try {
                              await Provider.of<ReclamationProvider>(
                                context,
                                listen: false,
                              ).deleteReclamation(reclamation.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Réclamation supprimée avec succès',
                                  ),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Erreur lors de la suppression: $e',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reclamation.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.2),
                        child: Text(
                          reclamation.userName.isNotEmpty
                              ? reclamation.userName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reclamation.userName.isNotEmpty
                                  ? reclamation.userName
                                  : 'Anonymous',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'ID: ${reclamation.userId}',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (reclamation.adminResponse != null)
                        const Icon(
                          Icons.comment_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(reclamation.createdAt),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
