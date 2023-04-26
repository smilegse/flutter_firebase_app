import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'main.dart';

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

    RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
    if(message != null) {
      messageHandler(message);
    }

    FirebaseMessaging.onMessage.listen(messageHandler) ;
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    getToken();
    listenToTopic();

  }

  Future<void> messageHandler(RemoteMessage message) async {
    if (message.notification != null) {
      log('Message also contained a notification: ${message.notification}');
      log(message.notification?.title ?? 'null title');
      log(message.notification?.body ?? 'null body');
    }
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