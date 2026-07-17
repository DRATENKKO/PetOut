import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  Timer? _repeatTimer;
  bool _isRepeating = false;
  bool _permissionsRequested = false;

  Future<void> init() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Santiago'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);

    // Create Android notification channel
    const androidChannel = AndroidNotificationChannel(
      'petout_timer',
      'Temporizadores',
      description: 'Notificaciones cuando termina una actividad',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  Future<bool> requestPermissions() async {
    if (_permissionsRequested) return true;
    _permissionsRequested = true;

    try {
      final iosGranted =
          await _notifications
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;

      final androidGranted =
          await _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          false;

      return iosGranted || androidGranted;
    } catch (e) {
      return false;
    }
  }

  Future<void> showTimerCompleteNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'petout_timer',
      'Temporizadores',
      channelDescription: 'Notificaciones cuando termina una actividad',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      ongoing: false,
      autoCancel: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(999, title, body, details);
  }

  Future<void> showTimerRunningNotification({
    required String title,
    required String body,
    bool isOngoing = true,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'petout_timer',
      'Temporizadores',
      channelDescription: 'Contadores activos y avisos de PetOut',
      importance: Importance.high,
      priority: Priority.high,
      playSound: false,
      enableVibration: false,
      icon: '@mipmap/ic_launcher',
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    await _notifications.show(
      998,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  Future<void> scheduleTimerEndNotification({
    required int id,
    required DateTime scheduledDate,
    required String title,
    required String body,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'petout_timer',
      'Temporizadores',
      channelDescription: 'Notificaciones cuando termina una actividad',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      autoCancel: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void startRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required Duration interval,
  }) {
    if (_isRepeating) return;
    _isRepeating = true;

    _showNotification(id, title, body);

    _repeatTimer = Timer.periodic(interval, (_) {
      _showNotification(id, title, body);
    });
  }

  void _showNotification(int id, String title, String body) {
    _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'petout_timer',
          'Temporizadores',
          channelDescription: 'Notificaciones cuando termina una actividad',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  void stopRepeatingNotification() {
    _isRepeating = false;
    _repeatTimer?.cancel();
    _repeatTimer = null;
    cancelNotification(999);
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
