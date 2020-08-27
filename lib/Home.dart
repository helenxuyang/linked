import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'Event.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Text('Discover Events',
                style: Theme.of(context).textTheme.headline1),
            Spacer(),
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () {
                //TODO: add filter options
              },
            )
          ]),
        ),
        Expanded(
          child: ListView(children: [EventGroup('water')]),
        ),
        FloatingActionButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return CreateEvent();
                  });
            },
            child: Icon(Icons.add))
      ]),
    );
  }
}

class EventGroup extends StatelessWidget {
  EventGroup(this.tag);
  final String tag;
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        Text(tag, style: TextStyle(fontSize: 22)),
        Spacer(),
        Text('view more', style: TextStyle(fontSize: 14))
      ]),
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('events')
                .where('tags', arrayContains: tag)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              return Row(children:
                  List<EventCard>.from(snapshot.data.documents.map((doc) {
                return EventCard.fromDoc(doc);
              })));
            },
          ))
    ]);
  }
}

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
