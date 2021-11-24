import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'card_screen.dart';

class ModalScreen extends StatefulWidget {
  const ModalScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ModalScreen> createState() => _ModalScreenState();
}

class _ModalScreenState extends State<ModalScreen> {
  final user = FirebaseAuth.instance.currentUser!.uid;
  late String title, subject;
  bool isSelected = false;
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();

  Future<Null> selectDate(BuildContext context) async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
        context: context,
        initialDate: isSelected ? initialDate : date,
        firstDate: DateTime(initialDate.year - 1),
        lastDate: DateTime(initialDate.year + 30));

    if (newDate == null) return;
    setState(() {
      date = newDate;
    });
  }

  Future<Null> selectTime(BuildContext context) async {
    final initialTime = TimeOfDay.now();
    final newTime =
        await showTimePicker(context: context, initialTime: initialTime);
    if (newTime == null) return;
    setState(() {
      time = newTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff142232),
      child: Container(
        padding: const EdgeInsets.all(25.0),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(30.0),
                topLeft: Radius.circular(30.0)),
            color: Colors.blueGrey),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.white,
              elevation: 20.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
              ),
              child: SizedBox(
                height: 200,
                width: 350,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.title,
                        color: Colors.black,
                      ),
                      title: TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                            hintText: 'Title',
                            hintStyle: TextStyle(color: Colors.grey)),
                        onChanged: (value) => title = value,
                        autocorrect: false,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.subject,
                        color: Colors.black,
                      ),
                      title: TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Subject',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        onChanged: (value) => subject = value,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.calendar_today,
                        color: Colors.black,
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              child: Text(
                                  '${date.day}/${date.month}/${date.year}'),
                              onPressed: () {
                                selectDate(context);
                              },
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Icon(
                            Icons.timer,
                            color: Colors.black,
                          ),
                          Expanded(
                            child: TextButton(
                              child: Text('${time.format(context)}'),
                              onPressed: () {
                                selectTime(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            ElevatedButton(
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(10.0),
                padding: MaterialStateProperty.all(EdgeInsets.all(15.0)),
                backgroundColor:
                    MaterialStateProperty.all(Colors.lightBlueAccent),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(
                  StadiumBorder(side: BorderSide()),
                ),
              ),
              child: Text('ADD REMINDER'),
              onPressed: () {

                  Map<String, dynamic> card = {
                  'title': title,
                  'subject': subject,
                  'date': '${date.day}/${date.month}/${date.year}',
                  'time': time.format(context),
                };
                final firestore = FirebaseFirestore.instance;
                 final doc =   firestore.collection('user')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('reminder');
                doc.doc().set(card);
                Fluttertoast.showToast(
                    msg: 'Reminder Added', toastLength: Toast.LENGTH_SHORT);

                doc.doc().collection('reminder').get();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CardScreen(),
                    ),
                    (route) => false).then(
                  (value) => Navigator.pop(context),
                );

              },
            ),
          ],
        ),
      ),
    );
  }
  // int id() {
  //   return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  // }

  // void Notification() async {
  //   await AwesomeNotifications().createNotification(content: NotificationContent(
  //       id: 1,
  //       channelKey: 'key',
  //       title: title,
  //       body: subject
  //   ));
  }



