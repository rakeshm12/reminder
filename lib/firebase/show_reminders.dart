import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:reminder_pro/widgets/alert_widget.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_messaging/firebase_messaging.dart';


FirebaseMessaging messaging = FirebaseMessaging.instance;


class ShowReminder extends StatefulWidget {
  const ShowReminder({Key? key}) : super(key: key);

  @override
  _ShowReminderState createState() => _ShowReminderState();
}

class _ShowReminderState extends State<ShowReminder> {



  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('reminders');
    return FutureBuilder<QuerySnapshot>(
        future: firestore.get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<DocumentSnapshot> reminderData = snapshot.data!.docs;
            return ListView(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              children: reminderData.map((data) {
                return InkWell(
                  onTap: () {
                    notifications();
                  },
                  onLongPress: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AppAlert(
                              title: Text('Confirm Delete?'),
                              content: '',
                              cancel: 'Cancel',
                              exit: 'Delete',
                              onTap: () {
                                final id = data.id;
                                setState(() {
                                  delete(id);
                                  Navigator.pop(context);
                                });
                              });
                        });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      color: Colors.blueGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            CardList(
                              leading: Icon(
                                Icons.title,
                                color: Colors.black,
                              ),
                              title: Text(data['title']),
                            ),
                            CardList(
                              leading: Icon(
                                Icons.subject,
                                color: Colors.black,
                              ),
                              title: Text(data['subject']),
                            ),
                            CardList(
                              leading: Icon(
                                Icons.calendar_today,
                                color: Colors.black,
                              ),
                              title: Row(
                                children: [
                                  Text(data['date']),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Icon(
                                    Icons.timer,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    width: 20.0,
                                  ),
                                  Text(data['time']),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          } else
            return Center(
              child: CircularProgressIndicator(),
            );
        });
  }

  void delete(String id) async {
    final firestore = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('reminders');
    firestore.doc(id).delete().then((value) {
      Fluttertoast.showToast(
          msg: 'Reminder Deleted successfully',
          toastLength: Toast.LENGTH_SHORT);
    });
  }
}

class CardList extends StatelessWidget {
  const CardList({
    Key? key,
    required this.leading,
    required this.title,
  }) : super(key: key);

  final Widget leading;
  final Widget title;

  @override
  Widget build(BuildContext context) {
    return ListTile(leading: leading, title: title);
  }
}


void notifications() async {
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  if(settings.authorizationStatus == AuthorizationStatus.authorized) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

}