import 'package:app_settings/app_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:reminder_pro/firebase/show_reminders.dart';
import 'package:reminder_pro/secretScreens/secret_screen.dart';
import 'package:reminder_pro/widgets/alert_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';
import 'modal_screen.dart';

class CardScreen extends StatefulWidget {
  CardScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final user = FirebaseAuth.instance.currentUser!.uid;
  bool checkAuth = false;
  bool isAuth = false;

  void getAuth() async {
    try {
      checkAuth = await auth.canCheckBiometrics;
      if (checkAuth == true)
        isAuth = await auth.authenticate(
            localizedReason: 'Please verify your finger',
            useErrorDialogs: true,
            stickyAuth: true);
      if (isAuth == true) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SecretScreen(userId: user)),
        );
      } else {
        Navigator.pop(context);
      }
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable') {
        showDialog(
            context: (context),
            builder: (context) {
              return AppAlert(
                  title: Text('Password not set!'),
                  content: 'Goto settings?',
                  cancel: 'Cancel',
                  exit: 'Settings',
                  onTap: (ctx) => AppSettings.openDeviceSettings()
                      .then((value) => Navigator.pop(ctx)));
            });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isExit = await showExit(context);

        return isExit ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text('Reminders'),
          ),
          backgroundColor: Color(0xff27466e),
          actions: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: IconButton(
                onPressed: () async {
                  try {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.remove('email');
                    FirebaseAuth.instance.signOut().whenComplete(() {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                      Fluttertoast.showToast(
                          msg: 'Logged out successfully',
                          toastLength: Toast.LENGTH_SHORT);
                    });
                  } catch (e) {
                    print(e);
                  }
                },
                icon: Icon(Icons.logout),
                tooltip: 'Logout',
              ),
            ),
          ],
        ),
        floatingActionButton: InkWell(
          onLongPress: () {
           getAuth();
          },
          child: FloatingActionButton(
            backgroundColor: Colors.lightBlueAccent,
            child: Icon(
              Icons.add,
              size: 35.0,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: const ModalScreen(),
                  ),
                ),
              );
            },
          ),
        ),
        body: SafeArea(
          child: ListView(children: [
            ShowReminder(),
          ]),
        ),
      ),
    );
  }

  Future<bool?> showExit(context) async => showDialog<bool>(
      context: context,
      builder: (context) {
        return AppAlert(
          cancel: 'Stay',
          exit: 'Exit',
          content: 'Exit to Home?',
          title: Text('🏠 🏃‍♂' , style: TextStyle(fontSize: 40),),
          onTap: () => Navigator.pop(context, true),
        );
      });
}
