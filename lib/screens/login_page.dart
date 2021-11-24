import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:reminder_pro/screens/signup_page.dart';
import 'package:reminder_pro/widgets/text_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'card_screen.dart';
import 'forgot_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

User? user = FirebaseAuth.instance.currentUser;

class LoginPage extends StatefulWidget {
  const LoginPage({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  bool isView = true;
  bool isLoading = false;
  FirebaseAuth? loggedInUser;

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
                      Icons.login,
                      size: 100,
                      color: Colors.lightBlueAccent,
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    TextInputWidget(
                      hint: 'email',
                      icon: Icons.email,
                      hideText: false,
                      tailIcon: const SizedBox(),
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
                        return;
                      },
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    TextInputWidget(
                      hint: 'password',
                      hideText: isView,
                      length: 20,
                      tailIcon: IconButton(
                          icon: Icon(
                            isView ? Icons.visibility : Icons.visibility_off,
                            color: Colors.lightBlueAccent,
                          ),
                          onPressed: () {
                            setState(() {
                              if (password.isEmpty) {
                                return;
                              }
                              if (password.isNotEmpty) {
                                isView = !isView;
                              }
                            });
                          }),
                      icon: isView ? Icons.lock : Icons.lock_open,
                      keyboard: TextInputType.emailAddress,
                      onChanged: (value) {
                        password = value;
                      },
                      validate: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return '';
                      },
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
                      child: const Text('LOGIN'),
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        try {
                          final user = await _auth.signInWithEmailAndPassword(
                              email: email, password: password);

                          if (user != null) {
                            User? user = FirebaseAuth.instance.currentUser;

                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setString('email', user!.email.toString());

                            if (user != null && !user.emailVerified) {
                              Fluttertoast.showToast(
                                  msg: 'Your email is not verified',
                                  toastLength: Toast.LENGTH_SHORT);
                            }
                            setState(() {
                              isLoading = false;
                            });

                            if (user != null && user.emailVerified) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CardScreen()),
                              );
                            }
                            setState(() {
                              isLoading = false;
                            });
                          }
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                            Fluttertoast.showToast(
                                msg: 'user not found, register to login',
                                toastLength: Toast.LENGTH_SHORT);
                          }
                          if (e.code == 'unknown') {
                            Fluttertoast.showToast(
                                msg: 'enter a valid email and password',
                                toastLength: Toast.LENGTH_SHORT);
                          }
                          if (e.code == 'network-request-failed') {
                            Fluttertoast.showToast(
                                msg: 'Network Error..!',
                                toastLength: Toast.LENGTH_SHORT);
                          } else if (e.code == 'wrong-password') {
                            Fluttertoast.showToast(
                                msg: 'Wrong password !',
                                toastLength: Toast.LENGTH_SHORT);
                          }
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                    ),
                    SizedBox(
                      height: 60.0,
                      child: TextButton(
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(color: Colors.white60),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => SingleChildScrollView(
                              child: Container(
                                padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom),
                                child: const ForgotScreen(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Don\'t have an account?'),
                        TextButton(
                          child: const Text(
                            'Register here',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignupPage()),
                            );
                          },
                        ),
                      ],
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
