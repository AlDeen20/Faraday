import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../resources/app_constant.dart';

abstract class FirebaseData {
  Future<String> getToken();
}

class FirebaseDataImpl implements FirebaseData {
  @override
  Future<String> getToken() async {
    final notificationSettings =
        await FirebaseMessaging.instance.requestPermission(provisional: true);

    final apnToken = await FirebaseMessaging.instance.getAPNSToken();
    if (apnToken != null) {
      return await FirebaseMessaging.instance.getToken() ?? "no Token";
    }
    return "no Token";
  }
}
