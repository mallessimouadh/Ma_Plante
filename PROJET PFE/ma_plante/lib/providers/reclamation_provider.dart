import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reclamation.dart';

class ReclamationProvider with ChangeNotifier {
  List<Reclamation> _pendingReclamations = [];
  List<Reclamation> _inProgressReclamations = [];
  List<Reclamation> _resolvedReclamations = [];
  bool _isLoading = true;

  List<Reclamation> get pendingReclamations => _pendingReclamations;
  List<Reclamation> get inProgressReclamations => _inProgressReclamations;
  List<Reclamation> get resolvedReclamations => _resolvedReclamations;
  bool get isLoading => _isLoading;

  ReclamationProvider() {
    _fetchReclamations();
  }

  void _fetchReclamations() {
    _isLoading = true;
    notifyListeners();

    FirebaseFirestore.instance
        .collection('reclamations')
        .snapshots()
        .listen(
          (snapshot) {
            print(
              'Fetched ${snapshot.docs.length} reclamations: ${snapshot.docs.map((d) => d.data()).toList()}',
            );
            final pending = <Reclamation>[];
            final inProgress = <Reclamation>[];
            final resolved = <Reclamation>[];

            for (var doc in snapshot.docs) {
              try {
                final reclamation = Reclamation.fromFirestore(
                  doc.data(),
                  doc.id,
                );
                switch (reclamation.status) {
                  case 'pending':
                    pending.add(reclamation);
                    break;
                  case 'in_progress':
                    inProgress.add(reclamation);
                    break;
                  case 'resolved':
                    resolved.add(reclamation);
                    break;
                }
              } catch (e) {
                print('Error parsing reclamation ${doc.id}: $e');
              }
            }

            _pendingReclamations = pending;
            _inProgressReclamations = inProgress;
            _resolvedReclamations = resolved;
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            print('Error fetching reclamations: $e');
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<void> updateReclamationStatus(
    String id,
    String newStatus, {
    String? adminResponse,
  }) async {
    final updateData = {
      'status': newStatus,
      if (newStatus == 'resolved') 'resolvedAt': FieldValue.serverTimestamp(),
      if (adminResponse != null) 'adminResponse': adminResponse,
    };
    await FirebaseFirestore.instance
        .collection('reclamations')
        .doc(id)
        .update(updateData);
  }

  Future<void> addAdminResponse(String id, String response) async {
    await FirebaseFirestore.instance.collection('reclamations').doc(id).update({
      'adminResponse': response,
    });
  }

  
  Future<void> deleteReclamation(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('reclamations')
          .doc(id)
          .delete();
      print('Reclamation $id deleted successfully');
    } catch (e) {
      print('Error deleting reclamation $id: $e');
      rethrow; 
    }
  }
}
