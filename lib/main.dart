import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Login.dart';
import 'Home.dart';
import 'Schedule.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
              primarySwatch: Colors.blue,
              accentColor: Color.fromRGBO(0x2d, 0x82, 0xB7, 1.0),
              visualDensity: VisualDensity.adaptivePlatformDensity,
              textTheme: TextTheme(
                  headline1: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      color: Colors.black),
                  headline2: TextStyle(fontSize: 20, color: Colors.black))),
          home: LoginPage(),
        ),
        create: (context) => CurrentUserInfo());
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const int HOME = 0;
  static const int USEREVENTS = 1;
  static const int PROFILE = 2;

  int currentIndex = 0;

  Widget getPage(BuildContext context, int selection) {
    switch (currentIndex) {
      case HOME:
        return HomePage();
      case USEREVENTS:
        return SchedulePage();
      case PROFILE:
        return Column();
      default:
        return Column();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blue,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home), title: Text('Home')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today), title: Text('My Events')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), title: Text('Profile'))
            ],
            currentIndex: currentIndex,
            onTap: (int index) {
              setState(() {
                currentIndex = index;
              });
            }),
        body: SafeArea(child: getPage(context, currentIndex)));
  }
}
