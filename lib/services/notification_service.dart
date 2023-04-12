import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification/screens/message_screen.dart';

class NotificationServices {
  //initialising firebase message notification.
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  //initialising firebase message plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // function to request notifications permissions from user
  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert:
          true, // It is shown the notification for enable app notification in application.
      announcement:
          true, // Becuase of this, you can not say to shree,airpods etc. device to enable notification.
      badge: true, // It is show indicator on your app icon.
      carPlay: true, //
      criticalAlert: true,
      provisional: true,
      sound: true, // This is use for sound during notification.
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // This function is belong when user give notification permission.
      print('user granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      // This is use when user give permission but when our aap notification come inside user phone. then we show notification disbled option on out notification.
      print('user granted provisional permission');
    } else {
      //  AppSettings.openNotificationSettings();
      print('user denied permission');
    }
  }

  //function to initialise flutter local notification plugin to show notifications for android when app is active
  void initLocalNotifications(
      BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings = const AndroidInitializationSettings(
        '@mipmap/ic_launcher'); // Inside this we are passing our app icon name.

    var initializationSetting =
        InitializationSettings(android: androidInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSetting,
        onDidReceiveNotificationResponse: (payload) {
      // handle interaction when app is active for android
      handleMessage(context, message);
    });
  }

// This is initialize firebase for notification.
  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;

      if (kDebugMode) {
        print("notifications title:" + notification!.title.toString());
        print("notifications body:" + notification.body.toString());
        print('count:' + android!.count.toString());

        print("notifications channel id:" +
            message.notification!.android!.channelId.toString());
        print("notifications click action:" +
            message.notification!.android!.clickAction.toString());
        print("notifications color:" +
            message.notification!.android!.color.toString());
        print("notifications count:" +
            message.notification!.android!.count.toString());
      }

      if (Platform.isAndroid) {
        initLocalNotifications(context, message);
        showNotification(message);
      }
    });
  }

  // function to show visible notification when app is active
  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      message.notification!.android!.channelId.toString(),
      message.notification!.android!.channelId.toString(),
      importance: Importance.max,
      showBadge: true,
    );

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      channelDescription: 'your app description',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      //  icon: largeIconPath
    );

    // DarwinNotificationDetails we are not using for IOS.Because IOS handle self in Firebase package.
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails);
    });
  }

  //function to get device token on which we will send the notifications to that particular user.
  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

// This function define when your token get expired then this function refresh and get new token.
  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      if (kDebugMode) {
        print('refresh');
      }
    });
  }

  //handle tap on notification when app is in background or terminated
  Future<void> setupInteractMessage(BuildContext context) async {
    // when app is terminated
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleMessage(context, initialMessage);
    }

    //when app ins background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  void handleMessage(BuildContext context, RemoteMessage message) {
    if (message.data['type'] == 'msj') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MessageScreen(
                    id: message.data['id'],
                  )));
    }
  }
}
