import 'package:flutter/material.dart';

import '../../services/notification_service.dart';

/// Screen to view medicine details and configure reminder schedules.
class MedicineDetailScreen extends StatefulWidget {
  final Map<String, dynamic> medicineItem;

  const MedicineDetailScreen({
    super.key,
    required this.medicineItem,
  });

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  String _mode = 'Once daily';
  final List<TimeOfDay> _times = [];

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selected == null) return;
    setState(() => _times.add(selected));
  }

  Future<void> _scheduleReminder() async {
    if (_times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one reminder time.')),
      );
      return;
    }

    final medicineName =
        widget.medicineItem['medicineName']?.toString() ?? 'Medicine';
    final baseId = widget.medicineItem['id']?.hashCode ??
        DateTime.now().millisecondsSinceEpoch;

    await NotificationService.scheduleDailyReminder(
      baseId: baseId,
      title: 'Medicine Reminder',
      body: 'Time to take $medicineName',
      times: _times,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reminder set ($_mode).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.medicineItem;

    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['medicineName']?.toString() ?? 'Medicine',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text('Dose: ${item['dose'] ?? ''}'),
                    Text('Frequency: ${item['frequency'] ?? ''}'),
                    Text('Duration: ${item['durationDays'] ?? 0} days'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reminder Type',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _mode,
                      items: const [
                        DropdownMenuItem(
                            value: 'Once daily', child: Text('Once daily')),
                        DropdownMenuItem(
                            value: 'Twice daily', child: Text('Twice daily')),
                        DropdownMenuItem(
                            value: 'Custom time', child: Text('Custom time')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _mode = value;
                          _times.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: _times
                          .map((t) => Chip(label: Text(t.format(context))))
                          .toList(growable: false),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (_mode == 'Once daily' && _times.isNotEmpty) return;
                        if (_mode == 'Twice daily' && _times.length >= 2) {
                          return;
                        }
                        await _pickTime();
                      },
                      icon: const Icon(Icons.access_time_rounded),
                      label: const Text('Pick Time'),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _scheduleReminder,
                        child: const Text('Schedule Reminder'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final baseId = item['id']?.hashCode ?? 0;
                          await NotificationService.cancelReminder(
                              baseId: baseId);
                          if (!mounted) return;
                          messenger.showSnackBar(
                            const SnackBar(
                                content: Text('Reminder cancelled.')),
                          );
                        },
                        child: const Text('Cancel Reminder'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
