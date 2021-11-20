import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextInputWidget extends StatefulWidget {
  TextInputWidget({
    Key? key,
    required this.hint,
    required this.keyboard,
    required this.icon,
    required this.onChanged,
    required this.validate,
    required this.hideText,
    required this.length,
    required this.tailIcon,
  }) : super(key: key);

  final String hint;
  final TextInputType keyboard;
  final IconData icon;
  final void Function(String) onChanged;
  final String? Function(String?)? validate;
  final bool hideText;
  final int length;
  final Widget tailIcon;


  @override
  State<TextInputWidget> createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  String myText = '';



  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(
          color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.w500),
      maxLength: widget.length,
      keyboardType: widget.keyboard,
      initialValue: myText,
      textAlign: TextAlign.justify,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(15.0),
        hintText: widget.hint,
        suffixIcon: widget.tailIcon,
        hintStyle: const TextStyle(
            color: Colors.grey, fontSize: 18.0, fontWeight: FontWeight.w400),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(
          widget.icon,
          color: Colors.lightBlueAccent,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      onChanged: widget.onChanged,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: widget.validate,
      obscureText: widget.hideText,
    );
  }
}
