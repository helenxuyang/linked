import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'Login.dart';

class Event {
  Event(this.eventID, this.title, this.tags, this.description, this.organizer, this.dateTime, this.app, this.url, this.attendeeIDs, this.maxAttendees);
  Event.fromDoc(DocumentSnapshot doc) :
        eventID = doc.id,
        title = doc.get('title'),
        tags = List<String>.from(doc.get('tags')),
        description = doc.get('description'),
        organizer = doc.get('organizerID'),
        dateTime = doc.get('dateTime').toDate(),
        app = doc.get('appName'),
        url = doc.get('appURL'),
        attendeeIDs = List<String>.from(doc.get('attendees')),
        maxAttendees = doc.get('maxAttendees');

  final String eventID;
  final String title;
  final List<String> tags;
  final String description;
  final String organizer;
  final DateTime dateTime;
  final String app;
  final String url;
  final List<String> attendeeIDs;
  final int maxAttendees;
}
class EventCard extends StatelessWidget {
  EventCard(this.event);
  final Event event;

  Future<DocumentSnapshot> retrieveUserDoc(String userID) {
    return FirebaseFirestore.instance.collection('users').doc(userID).get();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle logisticsStyle = TextStyle(
        fontSize: 14
    );
    TextStyle titleStyle = TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold
    );
    TextStyle subtitleStyle = TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold
    );
    TextStyle secondaryStyle = TextStyle(
        fontSize: 14,
        fontStyle: FontStyle.italic,
        color: Colors.grey
    );

    String userID = Provider.of<CurrentUserInfo>(context).id;
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => EventPage(event)));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: titleStyle),
                    SizedBox(height: 8),
                    Row(
                        children: [
                          Icon(Icons.calendar_today),
                          SizedBox(width: 4),
                          Text(DateFormat('E').add_MMMd().format(event.dateTime), style: logisticsStyle),
                          SizedBox(width: 16),
                          Icon(Icons.access_time),
                          SizedBox(width: 4),
                          Text(DateFormat('jm').format(event.dateTime), style: logisticsStyle),
                          SizedBox(width: 16),
                          Icon(Icons.person),
                          SizedBox(width: 4),
                          Text(event.attendeeIDs.length.toString() + '/' + event.maxAttendees.toString(), style: logisticsStyle),
                        ]
                    ),
                    SizedBox(height: 8),
                    FutureBuilder(
                      future: retrieveUserDoc(event.organizer),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          print(snapshot.error);
                          throw(Exception('error when retrieving user doc'));
                        }
                        if (!snapshot.hasData) {
                          return Text('Organized by...', style: subtitleStyle);
                        }
                        DocumentSnapshot userDoc = snapshot.data;
                        return Text('Organized by: ' + userDoc.get('firstName') + ' ' + userDoc.get('lastName'), style: subtitleStyle);
                      },
                    ),
                    SizedBox(height: 8),
                    Text(event.description),
                    SizedBox(height: 8),
                    Text(event.tags.map((tag) => '#' + tag).join('  '), style: secondaryStyle),
                    Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 8),
                    ),
                    Row(
                        children: [
                          RSVPButton(event.eventID),
                          SizedBox(width: 16),
                          ShareButton()
                        ]
                    )
                  ]
              ),
            )
        ),
      ),
    );
  }
}

class EventRow extends StatelessWidget {
  EventRow(this.event);
  final Event event;
  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
          child: Row(
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.title, style: TextStyle(fontSize: 16)),
                      Text(DateFormat('E').format(event.dateTime) + '. ' + DateFormat('MMMMd').format(event.dateTime) + ' at ' + DateFormat('jm').format(event.dateTime),
                          style: TextStyle(fontSize: 12, color: Color.fromRGBO(0x84, 0x84, 0x84, 1.0)))
                    ]
                ),
                Spacer(),
                Icon(Icons.people),
                SizedBox(width: 2),
                Text(event.attendeeIDs.length.toString())
              ]
          ),
        )
    );
  }
}

class EventPage extends StatelessWidget {
  EventPage(this.event);
  final Event event;

  @override
  Widget build(BuildContext context) {
    TextStyle subtitleStyle = TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold
    );
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  child: FlatButton(
                      splashColor: Colors.white,
                      highlightColor: Colors.white,
                      padding: EdgeInsets.only(left: 0, right: 4),
                      child: Align(
                          child: Text('Back', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
                          alignment: Alignment.centerLeft
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      }
                  ),
                ),
                Text(event.title,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
                ),
                Text(DateFormat('EEEE').format(event.dateTime) + ', ' + DateFormat('MMMMd').format(event.dateTime) + ' at ' + DateFormat('jm').format(event.dateTime),
                    style: TextStyle(fontSize: 14, color: Color.fromRGBO(0xEB, 0x8a, 0x90, 1.0))
                ),
                SizedBox(height: 8),
                Row(
                    children: [
                      Expanded(child: RSVPButton(event.eventID)),
                      SizedBox(width: 16),
                      Expanded(child: ShareButton())
                    ]
                ),
                SizedBox(height: 8),
                Text('Description', style: subtitleStyle),
                SizedBox(height: 4),
                Text(event.description),
                SizedBox(height: 4),
                Text(event.tags.map((tag) => '#' + tag).join('  '), style: TextStyle(color: Color.fromRGBO(0x8F, 0x8F, 0x8F, 1.0), fontStyle: FontStyle.italic)),
                SizedBox(height: 8),
                Text('Organizer', style: subtitleStyle),
                FutureBuilder(
                    future: FirebaseFirestore.instance.collection('users').doc(event.organizer).get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }
                      DocumentSnapshot organizerDoc = snapshot.data;
                      return InputChip(
                          avatar: CircleAvatar(child: Image.network(organizerDoc.get('photoURL'))),
                          label: Text(organizerDoc.get('firstName') + ' ' + organizerDoc.get('lastName'))
                      );
                    }
                ),
                SizedBox(height: 8),
                Text('Attendees (${event.attendeeIDs.length.toString()}/${event.maxAttendees.toString()})', style: subtitleStyle),
                StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('events').doc(event.eventID).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }
                      DocumentSnapshot eventDoc = snapshot.data;
                      List<String> attendeeIDs = List<String>.from(eventDoc.get('attendees'));
                      return Wrap(
                          children: attendeeIDs.map((id) {
                            return FutureBuilder(
                                future: FirebaseFirestore.instance.collection('users').doc(id).get(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Container();
                                  }
                                  DocumentSnapshot attendeeDoc = snapshot.data;
                                  return InputChip(
                                      avatar: CircleAvatar(child: Image.network(attendeeDoc.get('photoURL'))),
                                      label: Text(attendeeDoc.get('firstName') + ' ' + attendeeDoc.get('lastName'))
                                  );
                                }
                            );
                          }).toList()
                      );
                    }
                )
              ]
          ),
        ),
      ),
    );
  }
}

class ShareButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlineButton(
        borderSide: BorderSide(color: Colors.blue),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        child: Text('SHARE', style: TextStyle(color: Colors.blue)),
        onPressed: () {
          //TODO: add share
        }
    );
  }
}

class RSVPButton extends StatefulWidget {
  RSVPButton(this.eventID);
  final String eventID;
  @override
  _RSVPButtonState createState() => _RSVPButtonState();
}

class _RSVPButtonState extends State<RSVPButton> {
  bool disabled = false;

  void addSignUp(String userID, String eventID) async {
    DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(userID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot userSnap = await transaction.get(userDoc);
      transaction.update(userSnap.reference, {'events': userSnap.get('events')..add(eventID)});
    });

    DocumentReference eventDoc = FirebaseFirestore.instance.collection('events').doc(eventID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot eventSnap = await transaction.get(eventDoc);
      transaction.update(eventSnap.reference, {'attendees': eventSnap.get('attendees')..add(userID)});
    }).then((value) => enable());
  }

  void removeSignUp(String userID, String eventID) async {
    DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(userID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot userSnap = await transaction.get(userDoc);
      transaction.update(userSnap.reference, {'events': userSnap.get('events')..remove(eventID)});
    });

    DocumentReference eventDoc = FirebaseFirestore.instance.collection('events').doc(eventID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot eventSnap = await transaction.get(eventDoc);
      transaction.update(eventSnap.reference, {'attendees': eventSnap.get('attendees')..remove(userID)});
    }).then((value) => enable());
  }

  void disable() {
    setState(() {
      disabled = true;
    });
  }

  void enable() {
    setState(() {
      disabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String userID = Provider.of<CurrentUserInfo>(context).id;
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').doc(userID).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          DocumentSnapshot userDoc = snapshot.data;
          bool signedUp = List<String>.from(userDoc.get('events')).contains(widget.eventID);
          return signedUp ?
          FlatButton(
              color: Theme.of(context).accentColor,
              disabledColor: Colors.white,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text('SIGNED UP'),
              onPressed: disabled ? null : () {
                disable();
                removeSignUp(userID, widget.eventID);
              }
          ) :
          OutlineButton(
              borderSide: BorderSide(color: Theme.of(context).accentColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              child: Text('RSVP', style: TextStyle(color: Theme.of(context).accentColor)),
              disabledBorderColor: Colors.white,
              onPressed: disabled ? null : () {
                //TODO: create email screen
                disable();
                addSignUp(userID, widget.eventID);
              }
          );
        }
    );
  }
}

class EventMethods {
  static Future<bool> retrieveSignedUp(String userID, String eventID) {
    DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(userID);
    return userDoc.get().then((doc) => List<String>.from(doc.get('events')).contains(eventID));
  }
}