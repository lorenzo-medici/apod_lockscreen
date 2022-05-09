import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ignore: avoid_classes_with_only_static_members
class Utils {
  static void initializeNotifications() {
    AwesomeNotifications().initialize(
        // set the icon to null if you want to use the default app icon
        'resource://drawable/app_icon',
        [
          NotificationChannel(
              channelGroupKey: 'wallpaper_change_channels',
              channelKey: 'debug_channel',
              channelName: 'Debug notifications',
              channelDescription: 'Notification channel for debug',
              defaultColor: Colors.black26,
              ledColor: Colors.white),
          NotificationChannel(
              channelGroupKey: 'wallpaper_change_channels',
              channelKey: 'prod_channel',
              channelName: 'Production notifications',
              channelDescription: 'Notification channel for production',
              defaultColor: const Color(0xFF405771),
              ledColor: Colors.white)
        ],
        // Channel groups are only visual and are not required
        channelGroups: [
          NotificationChannelGroup(
              channelGroupkey: 'wallpaper_change_channels',
              channelGroupName: 'Wallpaper notifications')
        ],
        debug: true);

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  static Future<void> sendNotification(int id, bool isDebug, String title,
      String body, String? imagePath) async {
    if (!kDebugMode && isDebug) {
      return;
    }

    if (imagePath != null) {
      // SHOW IMAGE
      AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: id,
            channelKey: (isDebug) ? 'debug_channel' : 'prod_channel',
            title: ((isDebug)?"DEBUG: ": "") + title,
            body: body,
            bigPicture: imagePath,
            notificationLayout: NotificationLayout.BigPicture),
      );
    } else {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: (isDebug) ? 'debug_channel' : 'prod_channel',
          title: ((isDebug)?"DEBUG: ": "") + title,
          body: body,
        ),
      );
    }
  }
}
