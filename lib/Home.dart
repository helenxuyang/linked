import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Event.dart';
import 'Login.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String userID = Provider.of<CurrentUserInfo>(context).id;
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                        children: [
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
                  LiveEventGroup(),
                  SizedBox(height: 24),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance.collection('users').doc(userID).snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container();
                        }
                        List<String> tags = List<String>.from(snapshot.data.get('interestedTags'));
                        return Column(
                          //TODO: use tags from backend
                            children: tags.map((tag) => TagEventGroup(tag)).toList()
                        );
                      }
                  )
                ]
            ),
          ),
        ),
        Positioned(
            bottom: 16,
            right: 8,
            child: FloatingActionButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return CreateEvent();
                      }
                  );
                },
                child: Icon(Icons.add)
            )
        ),
      ],
    );
  }
}

class LiveEventGroup extends StatelessWidget {
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('events')
          .where('startTime', isLessThan: Timestamp.now())
          .orderBy('startTime')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        List<DocumentSnapshot> docs = List<DocumentSnapshot>.from(snapshot.data.documents).where((doc) {
          return doc.get('endTime').toDate().isAfter(DateTime.now());
        }).toList();
        if (docs.isEmpty) {
          return Container();
        }
        return Column(
            children: [
              Row(
                  children: [
                    Text('Happening Now', style: TextStyle(fontSize: 22)),
                    Spacer(),
                    Text('view more', style: TextStyle(fontSize: 14))
                  ]
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                    children: List<EventCard>.from(
                        docs.map((doc) {
                          return EventCard(Event.fromDoc(doc));
                        }))
                ),
              )
            ]
        );
      },
    );
  }
}

class TagEventGroup extends StatelessWidget {
  TagEventGroup(this.tag);
  final String tag;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('events')
          .where('tags', arrayContains: tag)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        List<DocumentSnapshot> docs = List<DocumentSnapshot>.from(snapshot.data.documents).where((doc) {
          return doc.get('endTime').toDate().isAfter(DateTime.now());
        }).toList();
        if (docs.isEmpty) {
          return Container();
        }
        return Column(
            children: [
              Row(
                  children: [
                    Text(tag, style: TextStyle(fontSize: 22)),
                    Spacer(),
                    Text('view more', style: TextStyle(fontSize: 14))
                  ]
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                    children: List<EventCard>.from(
                        docs.map((doc) {
                          return EventCard(Event.fromDoc(doc));
                        }))
                ),
              )
            ]
        );
      },
    );
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
