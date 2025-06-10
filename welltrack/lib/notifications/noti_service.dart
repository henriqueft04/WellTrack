import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotiService {
  final notificationPlugin = FlutterLocalNotificationsPlugin();

  final bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // INITIALIZE
  Future<void> initNotification() async {
    if (_isInitialized) return; // prevent re-initialization

    // prepare android init settings
    const initSettingsAndroid = 
      AndroidInitializationSettings('@mipmap/ic_launcher');

    // prepare ios init settings
    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // init settings
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    // finally, initialize the plugin!
    await notificationPlugin.initialize(initSettings);
  }


  // NOTIFICATIONS DETAIL SETUP
NotificationDetails notificationDetails() {
  return const NotificationDetails(
    android: AndroidNotificationDetails(
      'daily_channel_id',
      'Daily Notifications',
      channelDescription: 'Daily Notification Channel',
      importance: Importance.max,
      priority: Priority.high,
    ), // AndroidNotificationDetails
    iOS: DarwinNotificationDetails(),
  ); // NotificationDetails
}



    // SHOW NOTIFICATION
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    return notificationPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(),
    );
  }


}