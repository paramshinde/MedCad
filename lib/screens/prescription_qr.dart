import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/firestore_write_service.dart';

/// Displays QR immediately. Firestore save runs in background once.
class PrescriptionQrScreen extends StatefulWidget {
  final String prescriptionId;
  final Future<void>? saveFuture;

  const PrescriptionQrScreen({
    super.key,
    required this.prescriptionId,
    this.saveFuture,
  });

  @override
  State<PrescriptionQrScreen> createState() => _PrescriptionQrScreenState();
}

class _PrescriptionQrScreenState extends State<PrescriptionQrScreen> {
  final FirestoreWriteService _writeService = FirestoreWriteService();
  late final Future<void> _syncFuture;
  bool _hasShownErrorSnack = false;

  @override
  void initState() {
    super.initState();
    _syncFuture = widget.saveFuture ?? Future<void>.value();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prescription QR')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Scan this QR at pharmacy / patient app',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            QrImageView(data: widget.prescriptionId, size: 220),
            const SizedBox(height: 20),
            Text('Prescription ID: ${widget.prescriptionId}'),
            const SizedBox(height: 16),
            FutureBuilder<void>(
              future: _syncFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Syncing prescription...'),
                    ],
                  );
                }
                if (snapshot.hasError) {
                  final quotaExceeded =
                      _writeService.isQuotaExceeded(snapshot.error!);
                  if (!_hasShownErrorSnack) {
                    _hasShownErrorSnack = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            quotaExceeded
                                ? 'Quota exceeded'
                                : 'Failed to save prescription.',
                          ),
                        ),
                      );
                    });
                  }
                  return Text(
                    quotaExceeded
                        ? 'Cloud sync failed: quota exceeded.'
                        : 'Cloud sync failed.',
                    style: const TextStyle(color: Color(0xFFDC2626)),
                  );
                }
                return const Text(
                  'Prescription synced',
                  style: TextStyle(color: Color(0xFF16A34A)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
