import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

import '../../data/models/recurring_bill_model.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 1. Используем ПРАВИЛЬНЫЙ именованный параметр settings (не позиционный)
    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification clicked: ${details.payload}');
      },
    );

    _isInitialized = true;
  }

  Future<void> requestPermissions() async {
    if (!_isInitialized) await init();

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleDailyReminder() async {
    if (!_isInitialized) await init();

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Ежедневные напоминания',
      channelDescription: 'Напоминания о записи расходов в конце дня',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    // 2. Используем ИМЕНОВАННЫЕ параметры + inexact (разрешенный режим Android)
    await _notificationsPlugin.zonedSchedule(
      id: 0,
      title: 'Как прошел ваш день? 🌙',
      body: 'Пара секунд, чтобы записать сегодняшние расходы, спасут ваш бюджет!',
      scheduledDate: _nextInstanceOfTime(20, 0),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleSubscriptionReminder(RecurringBillModel bill) async {
    if (!_isInitialized) await init();
    if (!bill.isActive) return;

    final now = DateTime.now();

    int nextMonth = now.day >= bill.dayOfMonth ? now.month + 1 : now.month;
    int nextYear = now.year;
    if (nextMonth > 12) {
      nextMonth = 1;
      nextYear++;
    }

    int daysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
    int targetDay = bill.dayOfMonth > daysInNextMonth ? daysInNextMonth : bill.dayOfMonth;

    var scheduledDate = DateTime(nextYear, nextMonth, targetDay, 10, 0).subtract(const Duration(days: 1));

    if (scheduledDate.isBefore(now)) return;

    final androidDetails = AndroidNotificationDetails(
      'subs_channel_${bill.id}',
      'Подписки и платежи',
      channelDescription: 'Напоминания о предстоящих списаниях',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final notificationId = bill.id.hashCode;

    // 3. Используем ИМЕНОВАННЫЕ параметры + inexact
    await _notificationsPlugin.zonedSchedule(
      id: notificationId,
      title: 'Завтра списание! 💳',
      body: 'Ожидается платеж: ${bill.title} (${bill.amount} ${bill.currency}). Проверьте баланс!',
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelNotification(int id) async {
    // 4. Именованный параметр id
    await _notificationsPlugin.cancel(id: id);
  }
}