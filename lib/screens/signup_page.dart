import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:reminder_pro/screens/verify.dart';
import 'package:reminder_pro/widgets/text_input.dart';

class SignupPage extends StatefulWidget {
  static const id = 'signup_page';
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlurryModalProgressHUD(
        inAsyncCall: isLoading,
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.app_registration,
                      size: 100,
                      color: Colors.lightBlueAccent,
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    TextInputWidget(
                      hint: 'email',
                      icon: Icons.email,
                      length: 50,
                      keyboard: TextInputType.emailAddress,
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
                        return '';
                      },
                      hideText: false,
                      tailIcon: const SizedBox(),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    TextInputWidget(
                      hint: 'password',
                      icon: Icons.lock,
                      length: 20,
                      keyboard: TextInputType.emailAddress,
                      onChanged: (value) {
                        password = value;
                      },
                      validate: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return '';
                      },
                      hideText: false,
                      tailIcon: const SizedBox(),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    ElevatedButton(
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(10.0),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.all(15.0)),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.lightBlueAccent),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white),
                          shape: MaterialStateProperty.all(
                            const StadiumBorder(side: BorderSide()),
                          ),
                        ),
                        child: const Text('REGISTER'),
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          try {
                            final user =
                                await _auth.createUserWithEmailAndPassword(
                                    email: email, password: password);
                            if (user != null) {
                              User? user = FirebaseAuth.instance.currentUser;

                              final uid = user!.uid;

                              Map<String, dynamic> userDetails = {
                                'email': email,
                                'uid' : uid
                              };
                              FirebaseFirestore.instance.collection('user').doc(uid).set(userDetails);


                              if (user != null && !user.emailVerified) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => VerifyEmail()));
                                Fluttertoast.showToast(
                                    msg:
                                        'Registration successful, Please Verify your email',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    fontSize: 16.0);
                              }
                            }
                            setState(() {
                              isLoading = false;
                            });
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'weak-password') {
                              Fluttertoast.showToast(
                                  msg: 'password length must be at least six',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  fontSize: 16.0);
                            } else if (e.code == 'email-already-in-use') {
                              Fluttertoast.showToast(
                                  msg:
                                      'Account already exists.! reset your password..',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  fontSize: 16.0);
                            }
                          } catch (e) {
                            Fluttertoast.showToast(
                                msg: 'something went wrong ! try again',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                fontSize: 16.0);
                          }
                          setState(() {
                            isLoading = false;
                          });
                        }),
                    const SizedBox(height: 15.0),
                    TextButton(
                      child: const Text(
                        'Already have an account ?',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(height: 15.0),
                    TextButton(
                      child: const Text(
                        'Verify Email',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        User? user = FirebaseAuth.instance.currentUser;
                        if (user != null && !user.emailVerified) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VerifyEmail(),
                            ),
                          );
                        }
                        if (user != null && user.emailVerified) {
                          Fluttertoast.showToast(
                              msg: 'Email already verified',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER);
                        } else {
                          Fluttertoast.showToast(
                              msg: 'Register your email to verify',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
