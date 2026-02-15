import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/saved_medicine_service.dart';
import 'medicine_detail.dart';

/// Screen that displays and manages saved medicines for the logged-in patient.
class SavedMedicinesScreen extends StatelessWidget {
  const SavedMedicinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patientId = FirebaseAuth.instance.currentUser?.uid;
    final service = SavedMedicineService();

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Medicines')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: patientId == null
            ? const Center(child: Text('Please login to view saved medicines.'))
            : StreamBuilder<List<Map<String, dynamic>>>(
                stream: service.getSavedMedicines(patientId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Unable to load saved medicines right now.'),
                    );
                  }

                  final items = snapshot.data ?? const [];
                  if (items.isEmpty) {
                    return const Center(
                        child: Text('No saved medicines found.'));
                  }

                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                              item['medicineName']?.toString() ?? 'Medicine'),
                          subtitle: Text(
                            'Dose: ${item['dose'] ?? ''}\n'
                            'Frequency: ${item['frequency'] ?? ''}\n'
                            'Duration: ${item['durationDays'] ?? 0} days',
                          ),
                          isThreeLine: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    MedicineDetailScreen(medicineItem: item),
                              ),
                            );
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_rounded,
                                color: Color(0xFFDC2626)),
                            onPressed: () async {
                              await service.deleteSavedMedicine(
                                patientId: patientId,
                                medicineItemId: item['id'].toString(),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
