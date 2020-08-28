import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'Login.dart';

class _CreateEventPageState extends State<CreateEventPage> {
  // State for form validation / progress
  int pageIndex;

  // Event fields
  String _appName; // Zoom, Meets, in person; should be renamed to medium
  String _appURL; // should be renamed to mediumLocation
  List<String> _attendees;
  DateTime _dateTime = DateTime.now();
  String _description;
  int _maxAttendees;
  String _organizerID; // google ID of event organizer
  List<String> _tags;
  String _title;

  @override
  initState() {
    super.initState();
    pageIndex = 0;
  }

  Widget _eventDetails(BuildContext context) {
    return Column(
      children: <Widget>[
        IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            }),
        Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("New Event",
                style: Theme.of(context).textTheme.headline1)),
        Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Event Name",
                style: Theme.of(context).textTheme.bodyText1)),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: TextField(onChanged: (value) {
            setState(() {
              _title = value;
            });
          }),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Event Description",
              style: Theme.of(context).textTheme.bodyText1),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: TextField(onChanged: (value) {
            setState(() {
              _description = value;
            });
          }),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: FlatButton(
              child: Text("Submit"),
              onPressed: () {
                FirebaseFirestore.instance.collection('events').add({
                  'appName': _appName,
                  'appURL': _appURL,
                  'currentAttendees': _attendees,
                  'dateTime': Timestamp.fromDate(_dateTime),
                  'description': _description,
                  'maxAttendees': _maxAttendees,
                  'organizerID': _organizerID,
                  'tags': _tags,
                  'title': _title,
                });
              }),
        ),
      ],
    );
  }

  Widget _eventConfirm(BuildContext context) {
    return Column(
      children: [Text('Are you sure?')],
    );
  }

  Widget _buildProgress(int currentIndex, int total) {
    Widget back = FlatButton(
        child: Row(children: [
          Icon(Icons.arrow_left),
          SizedBox(width: 4),
          Text('Back')
        ]),
        onPressed: () {
          setState(() {
            pageIndex--;
          });
        });
    Widget next = Builder(builder: (context) {
      return FlatButton(
        child: Row(children: [
          Text('Next'),
          SizedBox(width: 4),
          Icon(Icons.arrow_right)
        ]),
        onPressed: () {
          bool valid = true; // TODO: validate fields for each page
          if (valid) {
            setState(() {
              pageIndex++;
            });
          }
        },
      );
    });

    Widget dots = Row(
        children: List<Widget>.generate(total, (index) {
      return Padding(
        padding: EdgeInsets.only(left: 3, right: 3),
        child: Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentIndex == index ? Colors.black : Colors.grey,
            )),
      );
    }));

    List<Widget> navChildren = [];
    if (currentIndex != 0) {
      navChildren.add(back);
    }
    navChildren.add(Padding(
      padding: const EdgeInsets.only(left: 24, right: 24),
      child: dots,
    ));
    if (currentIndex != total - 1) {
      navChildren.add(next);
    } else {
      navChildren.add(FlatButton(
        child: Text('Finish'),
        onPressed: () {
          String userID =
              Provider.of<CurrentUserInfo>(context, listen: false).id;
          User user = FirebaseAuth.instance.currentUser;
          FirebaseFirestore.instance.collection('events').doc(userID).set({
            // TODO: event fields
          });
          Navigator.pop(context);
        },
      ));
    }
    return Row(
        mainAxisAlignment: MainAxisAlignment.center, children: navChildren);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      _eventDetails(context),
      _eventConfirm(context),
    ];
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(children: [
            pages[pageIndex],
            Spacer(),
            _buildProgress(pageIndex, pages.length)
          ]),
        )));
  }
}

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}
