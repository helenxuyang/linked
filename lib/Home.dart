import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Login.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SafeArea(
          child: Text('Your ID is ' + Provider.of<CurrentUserInfo>(context).id)
      )
    );
  }
}