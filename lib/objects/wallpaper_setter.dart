import 'dart:io';

import 'package:apod_lockscreen_app/objects/worker_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class WallpaperSetter {
  static MediaQueryData? mediaQuery;

  static Future<void> setWallpaper(String url) async {
    WorkerClass.sendNotification(1000, 'Entered setWallpaper', 'setWallpaper');

    final DefaultCacheManager cacheManager = DefaultCacheManager();
    WorkerClass.sendNotification(
        1001, 'Got reference to DefaultCacheManager', 'setWallpaper');

    final FileInfo downloadedFile = await cacheManager.downloadFile(url);
    final File rawWallpaperFile = downloadedFile.file;
    WorkerClass.sendNotification(1002, 'Downloaded Image File', 'setWallpaper');

    final File croppedWallpaperImage = await cropWallpaper(rawWallpaperFile);
    WorkerClass.sendNotification(
        1003, 'Cropped wallpaper image', 'setWallpaper');

    try {
      await WallpaperManager.setWallpaperFromFile(
          croppedWallpaperImage.path, WallpaperManager.LOCK_SCREEN);
      WorkerClass.sendNotification(1004, 'Wallpaper set', 'setWallpaper');
    } on PlatformException {
      return;
    }
  }

  static Future<File> cropWallpaper(File file) async {
    final Directory cacheDirectory = await getTemporaryDirectory();
    final String imagePath = '${cacheDirectory.path}/wallpaper.png';

    final img.Image? rawWallpaper = img.decodeImage(file.readAsBytesSync());
    final int imageHeight = rawWallpaper!.height;
    final int imageWidth = rawWallpaper.width;
    // final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenAspectRatio = mediaQuery!.size.aspectRatio;
    final double imageAspectRatio = imageWidth / imageHeight;

    // se tutto funziona provare a pulire il blocco seguente mantenendo
    //  solamente il contenuto del primo if per ogni ramo

    if (imageAspectRatio > screenAspectRatio) {
      final int newWidth = (screenAspectRatio * imageHeight).toInt();
      final int newHeight = imageHeight;
      final int x = (imageWidth - newWidth) ~/ 2;
      const int y = 0;
      return File(imagePath)
        ..writeAsBytesSync(
          img.encodePng(
            img.copyCrop(
              rawWallpaper,
              x,
              y,
              newWidth,
              newHeight,
            ),
          ),
        );
    } else if (imageAspectRatio < screenAspectRatio) {
      final int newWidth = imageWidth;
      final int newHeight = imageWidth ~/ screenAspectRatio;
      const int x = 0;
      final int y = (imageHeight - newHeight) ~/ 2;
      return File(imagePath)
        ..writeAsBytesSync(
          img.encodePng(
            img.copyCrop(
              rawWallpaper,
              x,
              y,
              newWidth,
              newHeight,
            ),
          ),
        );
    }
    return file;
  }
}
