import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reminder_pro/screens/card_screen.dart';
import 'package:reminder_pro/screens/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('email');
  print(email);
  await Firebase.initializeApp();
  await FirebaseAuth.instance.authStateChanges();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // AwesomeNotifications().initialize('/res/mipmap-xxhdpi/', [
  //   NotificationChannel(
  //       channelKey: 'key',
  //       channelName: 'scheduled_notification',
  //       importance: NotificationImportance.High,
  //       playSound: true,
  //       enableVibration: true,
  //       locked: true)
  // ]);

  runApp(
    MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xff27466e),
      ),
      home: email == null ? LoginPage() : CardScreen(),
    ),
  );
}
