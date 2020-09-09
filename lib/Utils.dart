import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  static List<String> allTags = [
    'video games',
    'board games',
    'card games',
    'music',
    'tv shows',
    'movies',
    'study group',
    'homework',
    'making friends',
    'discussion'
  ];

  static void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

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
