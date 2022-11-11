# APOD Lockscreen



<img src="https://user-images.githubusercontent.com/67294212/201315937-96593dc3-abb0-484a-8ab2-f9fd89fa789a.jpg" width="250"> <img src="https://user-images.githubusercontent.com/67294212/201316622-7bd476f0-2102-45f4-98a0-ad5544b57939.jpg" width="250" hspace="10">



Simple Flutter project for automatically setting the lockscreen wallpaper with NASA's APOD every day.

The app only has one view, in which you can toggle the service as active or not. You can also force the download of the image of the current day.
Please note that it might take a long time before the OS schedules the automated task for the first time.

The app is tested and working on Android 10 on one phone only, it is not guaranteed that it will work on other devices/Android versions.

The app won't work on:
- iOS devices
- Xiaomi devices or devices running MIUI

## Future development
The main functionality missing in the application is the selection of which screen will be the target of the new picture.
A new widget will be added to the main page to allow users to select which wallpapers they want to be set: home screen, lock screen or both.
