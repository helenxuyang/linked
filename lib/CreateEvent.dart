import 'package:flutter/material.dart';

class _CreateEventState extends State<CreateEvent> {
  String _appName; // Zoom, Meets, in person; should be renamed to medium
  String _appURL; // should be renamed to mediumLocation
  int _currentAttendees;
  DateTime _dateTime = DateTime.now();
  String _description;
  int _maxAttendees;
  String _organizerID; // google ID of event organizer
  List<String> _tags;
  String _title;

  AlertDialog alertBuilder(BuildContext context) {
    return AlertDialog(
      content: Column(
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
                    'currentAttendees': _currentAttendees,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return alertBuilder(context);
  }
}

class CreateEvent extends StatefulWidget {
  @override
  _CreateEventState createState() => _CreateEventState();
}
