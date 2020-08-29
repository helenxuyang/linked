import 'package:flutter/material.dart';

class Utils {
  static List<String> allTags = [
    'video games',
    'board games',
    'music',
    'tv show',
    'movies',
    'study group',
    'making friends'
  ];
  static final TextStyle proximaNova = TextStyle(fontFamily: 'Proxima-Nova');
  static InputDecoration textFieldDecoration({String hint = ""}) {
    return InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none
        ),
        contentPadding: EdgeInsets.all(16),
        filled: true,
        fillColor: Color.fromRGBO(0xee, 0xee, 0xee, 1.0),
        hintText: hint
    );
  }
}
