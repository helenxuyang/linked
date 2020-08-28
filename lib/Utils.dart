import 'package:flutter/material.dart';

class Utils {
  static final TextStyle proximaNova = TextStyle(fontFamily: 'Proxima-Nova');
  static InputDecoration textFieldDecoration({String hint = ""}) {
    return InputDecoration(
        filled: true,
        fillColor: Color.fromRGBO(0xee, 0xee, 0xee, 1.0),
        hintText: hint);
  }
}
