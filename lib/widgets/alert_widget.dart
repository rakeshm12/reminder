import 'package:flutter/material.dart';

class AppAlert extends StatelessWidget {
  const AppAlert({
    Key? key,
    required this.title,
    required this.content,
    required this.cancel,
    required this.exit,
    required this.onTap,
  }) : super(key: key);
  final Widget title;
  final String content, cancel, exit;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.blueGrey,
      title: title,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            cancel,
            style: TextStyle(fontSize: 17.0, color: Colors.white),
          ),
        ),
        TextButton(
          onPressed: onTap!,
          child: Text(
            exit,
            style: TextStyle(fontSize: 17.0, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
