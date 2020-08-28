import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'Login.dart';

class _CreateEventPageState extends State<CreateEventPage> {
  // State for form validation / progress
  int pageIndex;

  // Event fields
  String _appName; // Zoom, Meets, in person; should be renamed to medium
  String _appURL; // should be renamed to mediumLocation
  DateTime _dateTime = DateTime.now();
  String _description;
  int _maxAttendees;
  String _organizerID; // google ID of event organizer
  List<String> _tags = [];
  String _title;

  TextEditingController tagCtrl = TextEditingController();

  @override
  initState() {
    super.initState();
    pageIndex = 0;
  }

  void setDateAndTime(DateTime date, TimeOfDay time) {
    setState(() {
      _dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SafeArea(
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              Navigator.pop(context);
                            }
                        ),
                        Text("New Event",
                            style: Theme.of(context).textTheme.headline1),
                        SizedBox(height: 30),
                        Text("Event Name",
                            style: Theme.of(context).textTheme.headline3),
                        TextField(
                            onChanged: (value) {
                              setState(() {
                                _title = value;
                              });
                            },
                        ),
                        SizedBox(height: 18),
                        Text("Event Description",
                            style: Theme.of(context).textTheme.headline3),
                        Text("Max 20 characters"),
                        TextField(
                            onChanged: (value) {
                              setState(() {
                                _description = value;
                              });
                            }
                        ),
                        SizedBox(height: 18),
                        Text('Date and Time',
                            style: Theme.of(context).textTheme.headline3),
                        DateTimeSelections(setDateAndTime),
                        SizedBox(height: 18),
                        Text('Tags',
                            style: Theme.of(context).textTheme.headline3),
                        TextField(
                          controller: tagCtrl,
                          onSubmitted: (input) {
                            _tags.add(input);
                            tagCtrl.clear();
                          },
                        ),
                        Wrap(
                          children: _tags.map((tag) => InputChip(label: Text(tag))).toList(),
                          spacing: 8
                        )
                      ],
                    )
                ),
                Spacer(),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: FlatButton(
                      color: Theme.of(context).accentColor,
                      textColor: Colors.white,
                      child: Text("Create Event", style: TextStyle(fontSize: 18)),
                      onPressed: () {
                        FirebaseFirestore.instance.collection('events').add({
                          'appName': _appName,
                          'appURL': _appURL,
                          'attendees': [_organizerID],
                          'dateTime': Timestamp.fromDate(_dateTime),
                          'description': _description,
                          'maxAttendees': _maxAttendees,
                          'organizerID': _organizerID,
                          'tags': _tags,
                          'title': _title,
                        });
                      }
                  ),
                ),
              ],
            )
        )
    );
  }
}

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class DateTimeSelections extends StatefulWidget {
  DateTimeSelections(this.setterCallback);

  final Function setterCallback;

  @override
  _DateTimeSelectionsState createState() => _DateTimeSelectionsState();
}

class _DateTimeSelectionsState extends State<DateTimeSelections> {
  DateTime date;
  TimeOfDay time;

  @override
  void initState() {
    super.initState();
    date = DateTime.now();
    time = TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FlatButton(
                    padding: EdgeInsets.only(left: 0),
                    child: Row(
                        children: [
                          Icon(Icons.calendar_today),
                          SizedBox(width: 8),
                          Text(
                              DateFormat('E').format(date) + '. ' + DateFormat('MMMMd').format(date),
                              style: Theme.of(context).textTheme.bodyText1
                          ),
                          Icon(Icons.arrow_drop_down),
                        ]
                    ),
                    onPressed: () async {
                      DateTime today = DateTime.now();
                      final DateTime selection = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: today,
                          lastDate: today.add(new Duration(days: 50))
                      );
                      if (selection != null) {
                        date = selection;
                        widget.setterCallback(selection, time);
                      }
                    }
                ),
                FlatButton(
                  padding: EdgeInsets.only(left: 0),
                  child: Row(
                      children: [
                        Icon(Icons.access_time),
                        SizedBox(width: 8),
                        Text(
                            DateFormat('jm').format(DateTime(1, 1, 1, time.hour, time.minute)),
                            style: Theme.of(context).textTheme.bodyText1
                        ),
                        Icon(Icons.arrow_drop_down)
                      ]
                  ),
                  onPressed: () async {
                    final TimeOfDay selection = await showTimePicker(
                        context: context,
                        initialTime: time
                    );
                    if (selection != null) {
                      time = selection;
                      widget.setterCallback(date, selection);
                    }
                  },
                )
              ]
          ),
        ]
    );
  }
}
