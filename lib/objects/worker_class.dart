import 'package:apod_lockscreen_app/objects/wallpaper_setter.dart';
import 'package:apod_lockscreen_app/services/get_apod.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/space_media.dart';
import '../utils.dart';

class WorkerClass {
  static const String backgroundTask = "wallpaper";

  bool mounted = true;

  static Future<void> activateService(BuildContext context, bool mounted) async {
    // TODO: 15 for tests, change to 120 later

    var prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    if (prefs.getDouble("screenAspectRatio") == null) {
      prefs.setDouble("screenAspectRatio", MediaQuery.of(context).size.aspectRatio);
    }

    if (prefs.getInt("lastSet") == null) {
      prefs.setInt("lastSet", 1);
    }

    // WallpaperSetter.screenAspectRatio = MediaQuery.of(context).size.aspectRatio;

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

    Utils.sendNotification(0, true, 'changeLockScreenWallpaper',
        'Lockscreen wallpaper change is happening right now', null);

    SpaceMedia? media = await getAPOD(date: DateTime.now());

    var prefs = await SharedPreferences.getInstance();
    var lastSet = prefs.getInt('lastSet')!;

    if (media != null && media.hdImageUrl != "") {
      // Retrieved today's SpaceMedia

      Utils.sendNotification(
          200,
          true,
          'changeLockScreenWallpaper',
          'Today ${DateTime.now().day}. ToSet ${media.date.day}. LastSet $lastSet',
          null);

      if (media.date.day != lastSet) {
        // Last SpaceMedia set as wallpaper is not today
        await WallpaperSetter.setWallpaper(media.hdImageUrl);

        prefs.setInt("lastSet", media.date.day);

        Utils.sendNotification(55, false, 'changeLockScreenWallpaper',
            'New wallpaper set!!!', media.hdImageUrl);
      } else {
        Utils.sendNotification(56, true, 'changeLockScreenWallpaper',
            'Today\'s wallpaper already set ${media.date.day}', null);
      }
    } else {
      Utils.sendNotification(57, true, 'changeLockScreenWallpaper',
          'Could not retrieve today\'s image OR it\'s a YouTube video', null);
    }
  }

  static Future<void> receiveState(
      bool active, BuildContext context, bool mounted) async {
    late String messaggio;

    if (active) {
      await activateService(context, true);
      messaggio = 'Servizio attivato';
    } else {
      await deactivateService();
      messaggio = 'Servizio disattivato';
    }

    if (!mounted) return;
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(messaggio),
        action: SnackBarAction(
            label: 'OK', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
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
      Utils.sendNotification(
          2, true, "_onBackgroundFetch", "BackgroundFetch fired", null);
    }

    // this prints by TSBackgroundFetch
    BackgroundFetch.finish(taskId);
  }

  static void _onBackgroundFetchTimeout(String taskId) {
    if (kDebugMode) {
      print("[BackgroundFetch] TIMEOUT: $taskId");
    }
    Utils.sendNotification(
        4, true, "_onBackgroundFetchTimeout", "TIMEOUT Received", null);
    BackgroundFetch.finish(taskId);
  }
}
