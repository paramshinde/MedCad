import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Timeline view for patient prescription history grouped by date.
class PrescriptionHistoryScreen extends StatefulWidget {
  const PrescriptionHistoryScreen({super.key});

  @override
  State<PrescriptionHistoryScreen> createState() =>
      _PrescriptionHistoryScreenState();
}

class _PrescriptionHistoryScreenState extends State<PrescriptionHistoryScreen> {
  String? _patientId;
  String? _patientName;
  bool _isLoadingIdentity = true;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _prescriptionStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _legacyPrescriptionStream;

  @override
  void initState() {
    super.initState();
    _loadIdentityAndStream();
  }

  Future<void> _loadIdentityAndStream() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      setState(() => _isLoadingIdentity = false);
      return;
    }

    _patientId = user.uid;
    String? name;
    try {
      final userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      name = (userSnap.data()?['name'] as String?)?.trim();
      if (name == null || name.isEmpty) {
        final patientSnap = await FirebaseFirestore.instance
            .collection('patients')
            .doc(user.uid)
            .get();
        name = (patientSnap.data()?['name'] as String?)?.trim();
      }
    } catch (_) {
      // Best-effort: fall back to UID-based lookup only.
    }

    _patientName = name;
    _prescriptionStream = FirebaseFirestore.instance
        .collection('prescriptions')
        .where('patientId', isEqualTo: _patientId)
        .snapshots();
    if (name != null && name.isNotEmpty && name != _patientId) {
      _legacyPrescriptionStream = FirebaseFirestore.instance
          .collection('prescriptions')
          .where('patientId', isEqualTo: name)
          .snapshots();
    }

    if (!mounted) return;
    setState(() => _isLoadingIdentity = false);
  }

  String _dayKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildHistoryList(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    if (docs.isEmpty) {
      final hint = _patientName == null || _patientName!.isEmpty
          ? 'No prescriptions found.'
          : 'No prescriptions found for $_patientName.';
      return Center(child: Text(hint));
    }

    final sortedDocs =
        List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(docs)
          ..sort((a, b) {
            final aTs = a.data()['createdAt'] as Timestamp?;
            final bTs = b.data()['createdAt'] as Timestamp?;
            final aDt =
                aTs?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bDt =
                bTs?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bDt.compareTo(aDt);
          });

    final grouped = <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};
    for (final doc in sortedDocs) {
      final ts = doc.data()['createdAt'] as Timestamp?;
      final dt = ts?.toDate() ?? DateTime.now();
      final key = _dayKey(dt);
      grouped.putIfAbsent(key, () => []).add(doc);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final key = sortedKeys[index];
        final items = grouped[key]!;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                key,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ...items.map((doc) {
                final data = doc.data();
                final meds =
                    (data['medicines'] as List<dynamic>? ?? const []);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text('Prescription ${data['id'] ?? doc.id}'),
                    subtitle: Text(
                      'Medicines: ${meds.length}\nNotes: ${data['notes'] ?? ''}',
                    ),
                    isThreeLine: true,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prescription History')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoadingIdentity
            ? const Center(child: CircularProgressIndicator())
            : _patientId == null
            ? const Center(child: Text('Please log in to view history.'))
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _prescriptionStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Unable to load history.'));
                  }

                  final docs = snapshot.data?.docs ?? const [];
                  if (docs.isEmpty && _legacyPrescriptionStream != null) {
                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _legacyPrescriptionStream,
                      builder: (context, legacySnapshot) {
                        if (legacySnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (legacySnapshot.hasError) {
                          return _buildHistoryList(docs);
                        }
                        return _buildHistoryList(
                          legacySnapshot.data?.docs ?? const [],
                        );
                      },
                    );
                  }
                  return _buildHistoryList(docs);
                },
              ),
      ),
    );
  }
}
