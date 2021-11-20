import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'login_page.dart';

User? user = FirebaseAuth.instance.currentUser;

class VerifyEmail extends StatefulWidget {
  static const id = 'verify';

  const VerifyEmail({
    Key? key,
  }) : super(key: key);

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsPadding: EdgeInsets.all(10.0),
      buttonPadding: EdgeInsets.all(10.0),
      backgroundColor: Colors.blueGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Row(
        children: [
          Icon(
            Icons.email,
            color: Colors.red[300],
          ),
          SizedBox(
            width: 20.0,
          ),
          Text('Verify Email !'),
        ],
      ),
      content: Text('verification link will be sent to ${user!.email}'),
      actions: <Widget>[
        TextButton(
          child: Center(
            child: const Text(
              'Verify Email',
              style: TextStyle(color: Colors.lightBlueAccent, fontSize: 18),
            ),
          ),
          onPressed: () async {
            if (user != null && !user!.emailVerified) {
              await user!.sendEmailVerification().then((value) => {
                    Fluttertoast.showToast(
                        msg: 'An email has been sent to ${user!.email}',
                        toastLength: Toast.LENGTH_SHORT),
                  });
            }
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false);
          },
        ),
      ],
    );
  }
}
