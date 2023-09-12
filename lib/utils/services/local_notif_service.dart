
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzd;

class LocalNotifService {

  static final LocalNotifService instance = LocalNotifService._init();
  LocalNotifService._init();

  FlutterLocalNotificationsPlugin notifPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {

    tzd.initializeTimeZones();
    
    AndroidInitializationSettings androidInitSettings = const AndroidInitializationSettings('app_icon');
    var iosInitSettings = DarwinInitializationSettings(
      requestAlertPermission: true, 
      requestBadgePermission: true, 
      requestSoundPermission: true, 
      onDidReceiveLocalNotification: (id, title, body, payload) async {}
    );

    var initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings
    );

    await notifPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) async {},
    );
  }

  NotificationDetails notifDetails(){
    return const NotificationDetails(
      android: AndroidNotificationDetails('channelId', 'channelName', importance: Importance.max),
      iOS: DarwinNotificationDetails()
    );
  }

  Future showNotification(int id, String? title, String? body, String? payload) async {
    return notifPlugin.show(id, title, body, notifDetails());
  }

  Future setScheduledNotifs(int id, String? title, String? body, String? payload, {required DateTime scheduledDate}) async {
    print(scheduledDate.toIso8601String());
    return notifPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notifDetails(),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
      matchDateTimeComponents: DateTimeComponents.dateAndTime
    );
  }

  Future<List<PendingNotificationRequest>> getPendingNotifs() async {
    return await notifPlugin.pendingNotificationRequests();
  }

  Future cancelScheduledNotification(int notifId) async {
    await notifPlugin.cancel(notifId);
  }
}