// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Notification helper compatible with flutter_local_notifications >= 18 / 19
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);
  }

  /// Schedule a daily notification at a specific [scheduledDate] (tz.TZDateTime).
  /// Uses AndroidScheduleMode.exact so notification fires at that exact time on Android.
  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'med_reminders', // channel id
          'Medication Reminders', // channel name
          channelDescription: 'Reminder notifications for medications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),

      // REQUIRED in new versions: pick an Android schedule mode
      androidScheduleMode: AndroidScheduleMode.exact,

      // payload is optional, but include something useful if you want a tap payload
      payload: body,

      // Keep matchDateTimeComponents to repeat at the same time every day
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Helper to parse "HH:mm" and return the next occurrence as a tz.TZDateTime
  static tz.TZDateTime nextInstanceOfTime(String hhmm) {
    final parts = hhmm.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));
    return scheduled;
  }
}
