import 'package:apod_lockscreen_app/objects/wallpaper_setter.dart';
import 'package:apod_lockscreen_app/services/get_apod.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/space_media.dart';

class WorkerClass {
  static const String backgroundTask = "wallpaper";

  static DateTime lastSet = DateTime.fromMillisecondsSinceEpoch(0);

  static Future<void> activateService(BuildContext context) async {
    // TODO: 15 for tests, change to 120 later

    WallpaperSetter.mediaQuery = MediaQuery.of(context);

    await BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 15,
            // change to true se non funziona
            forceAlarmManager: false,
            stopOnTerminate: false,
            startOnBoot: true,
            enableHeadless: true,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.ANY),
        _onBackgroundFetch,
        _onBackgroundFetchTimeout);

    if (kDebugMode) {
      print("Native called background task activate(): $backgroundTask");
    }

    BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  }

  static Future<void> deactivateService() async {
    BackgroundFetch.stop();
    if (kDebugMode) {
      print("Native called background task deactivate(): $backgroundTask");
    }
  }

  static Future<void> changeLockScreenWallpaper() async {
    if (kDebugMode) {
      print("Native called background task change(): $backgroundTask");
    }

    sendNotification(0, 'Lockscreen wallpaper change is happening right now',
        'Lockscreen change');

    SpaceMedia? media = await getAPOD(date: DateTime.now());

    if (media != null) {
      // Retrieved today's SpaceMedia

      sendNotification(
          200,
          'Today ${DateTime.now().day}. ToSet ${media.date.day}. LastSet ${lastSet.day}',
          'changeLockScreenWallpaper');

      if (media.date.day != lastSet.day) {
        // Last SpaceMedia set as wallpaper is not today
        await WallpaperSetter.setWallpaper(media.hdImageUrl);

        lastSet = media.date;

        sendNotification(
            55, 'New wallpaper set!!!', 'changeLockScreenWallpaper');
      } else {
        // TODO: remove after testing
        sendNotification(56, 'Today\'s wallpaper already set ${media.date.day}',
            'changeLockScreenWallpaper');
      }
    } else {
      sendNotification(
          57, 'Could not retrieve image', 'changeLockScreenWallpaper');
    }
  }

  static void receiveState(bool active, BuildContext context) {
    late String messaggio;

    if (active) {
      activateService(context);
      messaggio = 'Servizio attivato';
    } else {
      deactivateService();
      messaggio = 'Servizio disattivato';
    }

    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(messaggio),
        action: SnackBarAction(
            label: 'OK', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  static Future<void> sendNotification(int id, String text, String type) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? id) {
      return;
    });
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(type, type,
            channelDescription: type,
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(id, type, text, platformChannelSpecifics, payload: 'item x');
  }

  static void backgroundFetchHeadlessTask(HeadlessTask task) async {
    var taskId = task.taskId;
    var timeout = task.timeout;

    if (timeout) {
      if (kDebugMode) {
        print("[BackgroundFetch] Headless task timed-out: $taskId");
      }
      BackgroundFetch.finish(taskId);
      return;
    }

    if (kDebugMode) {
      print("[BackgroundFetch] Headless event received: $taskId");
    }

    if (taskId == "flutter_background_fetch") {
      // sendNotification(3, "backgroundFetchHeadlessTask",
      //    "HEADLESS TASK FIRED SUCCESSFULLY!!!");
      changeLockScreenWallpaper();
      BackgroundFetch.finish(taskId);
      return;
    }

    BackgroundFetch.finish(taskId);
  }

  static void _onBackgroundFetch(String taskId) async {
    // something gets printed by TSBackgroundFetch

    // this prints

    if (kDebugMode) {
      print("[BackgroundFetch] Event received: $taskId");
    }

    if (taskId == "flutter_background_fetch") {
      await changeLockScreenWallpaper();
      sendNotification(2, "_onBackgroundFetch", "BackgroundFetch fired");
    }

    // this prints by TSBackgroundFetch
    BackgroundFetch.finish(taskId);
  }

  static void _onBackgroundFetchTimeout(String taskId) {
    if (kDebugMode) {
      print("[BackgroundFetch] TIMEOUT: $taskId");
    }
    sendNotification(4, "_onBackgroundFetchTimeout", "TIMEOUT Received");
    BackgroundFetch.finish(taskId);
  }
}
