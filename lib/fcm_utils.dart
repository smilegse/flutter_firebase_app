import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';

class FcmUtils{
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future initialize() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // FirebaseMessaging.onMessage.listen((message) {
    //   log(message.notification?.title ?? 'null title');
    //   log(message.notification?.body ?? 'null body');
    // });

    RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
    if(message != null){
      log('Got a message whilst in the Initial message!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
        log(message.notification?.title ?? 'null title');
        log(message.notification?.body ?? 'null body');
      }
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
        log(message.notification?.title ?? 'null title');
        log(message.notification?.body ?? 'null body');
      }
    });


    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
      log('Got a message whilst in the background!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log(message.notification?.title ?? 'null title');
        log(message.notification?.body ?? 'null body');
      }
    });

    getToken();
    listenToTopic();

  }

  Future<void> messageHandler(RemoteMessage message) async {
    log(message.notification?.title ?? 'null title');
    log(message.notification?.body ?? 'null body');
  }

  Future<void> getToken() async {
    final String? token = await _firebaseMessaging.getToken();
    log(token ?? '');
  }

  Future<void> listenToTopic() async {
    await _firebaseMessaging.subscribeToTopic('siddique');
    //await _firebaseMessaging.unsubscribeFromTopic('siddique');
  }
}