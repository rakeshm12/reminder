import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:reminder_pro/widgets/text_input.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({Key? key,}) : super(key: key);

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final _auth = FirebaseAuth.instance;
  String email = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(25.0),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(30.0),
                topLeft: Radius.circular(30.0)),
            color: Colors.blueGrey),
        child: Column(
          children: [
            TextInputWidget(
              hint: 'email',
              length: 50,
              keyboard: TextInputType.emailAddress,
              icon: Icons.email,
              onChanged: (value) {
                email = value;
              },
              validate: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                if (!RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value)) {
                  return 'enter a valid email';
                }
                return null;
              },
              hideText: false,
              tailIcon: const SizedBox(),
            ),
            const SizedBox(height: 10.00),
            ElevatedButton(
                child: const Text('RESET PASSWORD'),
                style: ButtonStyle(
                  padding:
                      MaterialStateProperty.all(const EdgeInsets.all(15.0)),
                  backgroundColor:
                      MaterialStateProperty.all(Colors.lightBlueAccent),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  shape: MaterialStateProperty.all(
                    const StadiumBorder(side: BorderSide()),
                  ),
                ),
                onPressed: () async {
                  try {
                    if(email == null || email.isNotEmpty){
                      await _auth.sendPasswordResetEmail(email: email);
                      Fluttertoast.showToast(
                          msg: 'Reset link sent! Check email',
                          toastLength: Toast.LENGTH_SHORT);
                      Navigator.pop(context);
                    }

                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'user-not-found') {
                      Fluttertoast.showToast(
                          msg: 'email not registered..!',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          fontSize: 16.0);
                    }
                  } catch (e) {
                    Fluttertoast.showToast(
                        msg: 'something went wrong! Try again',
                        toastLength: Toast.LENGTH_SHORT);
                  }
                }),
          ],
        ),
      ),
    );
  }
}
