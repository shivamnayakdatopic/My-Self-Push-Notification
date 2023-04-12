import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:notification/services/notification_service.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // You have to import notification services file.
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    // For Notification permission
    notificationServices.requestNotificationPermission();
    // This is for initialize firebase message
    notificationServices.firebaseInit(context);
    // For geting user device token.
    notificationServices.getDeviceToken().then((value) {
      if (kDebugMode) {
        print('device token--- $value');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {
            // send notification from one device to another
            notificationServices.getDeviceToken().then((value) async {
              var data = {
                'to': value
                    .toString(), // just pass token of that device. In which device you want to send message.
                'notification': {
                  'title': 'Shivam Kumar Nayak',
                  'body': 'Hello, How are you?',
                },
                'android': {
                  'notification': {
                    'notification_count': 23,
                  },
                },
                'data': {
                  // This is define for redirect to another screen.
                  'type': 'msj',
                  'id': 'shivam123'
                }
              };

              await http
                  .post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
                      body: jsonEncode(data),
                      headers: {
                        'Content-Type': 'application/json; charset=UTF-8',
                        'Authorization':
                            'key=AAAAJf-L0gg:APA91bGvLCl_jFM_rdaAQLy8AYhaiIPwGMPZAbqYgFBacWFXIVAgTjlr3aCb0hZIFJJWPR1OOTNvF9xILq8GSP6F8hZYS84Di3MfFUh-lAlnR1pfyMiCEGle5UMZtStqbMJZXtbGoxCb'
                      })
                  .then((value) {})
                  .onError((error, stackTrace) {
                    print(error);
                  });
            });
          },
          child: Text("Send Message"),
        ),
      ),
    );
  }
}
