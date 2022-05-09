import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils.dart';

class WallpaperSetter {
  static Future<void> setWallpaper(String url) async {
    Utils.sendNotification(1000, true, 'setWallpaper', 'Entered method', null);

    final DefaultCacheManager cacheManager = DefaultCacheManager();
    Utils.sendNotification(1001, true, 'setWallpaper',
        'Got reference to DefaultCacheManager', null);

    Utils.sendNotification(
        5555, true, 'setWallpaper', 'Downloading image at $url', null);

    final FileInfo downloadedFile = await cacheManager.downloadFile(url);
    final File rawWallpaperFile = downloadedFile.file;

    Utils.sendNotification(1002, true, 'setWallpaper', 'Downloaded Image File',
        'file:/${rawWallpaperFile.absolute.path}');

    final File croppedWallpaperImage = await cropWallpaper(rawWallpaperFile);

    Utils.sendNotification(
        1003,
        true,
        'setWallpaper',
        'Cropped wallpaper image',
        'file:/${croppedWallpaperImage.absolute.path}');

    try {
      await WallpaperManager.setWallpaperFromFile(
          croppedWallpaperImage.path, WallpaperManager.LOCK_SCREEN);
      Utils.sendNotification(1004, true, 'setWallpaper', 'Wallpaper set', null);
    } on PlatformException {
      return;
    }
  }

  static Future<File> cropWallpaper(File file) async {
    var prefs = await SharedPreferences.getInstance();
    double screenAspectRatio = prefs.getDouble('screenAspectRatio')!;

    final Directory cacheDirectory = await getTemporaryDirectory();
    final String imagePath = '${cacheDirectory.path}/wallpaper.png';

    final img.Image? rawWallpaper = img.decodeImage(file.readAsBytesSync());
    final int imageHeight = rawWallpaper!.height;
    final int imageWidth = rawWallpaper.width;
    final double imageAspectRatio = imageWidth / imageHeight;

    if (imageAspectRatio >= screenAspectRatio) {
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
