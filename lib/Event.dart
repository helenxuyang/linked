import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'Login.dart';

class EventCard extends StatelessWidget {
  final String touchdown =
      "https://i2.wp.com/cornellsun.com/wp-content/uploads/2020/03/BYT-Touchdown-1-1.jpg?fit=1170%2C781";
  EventCard.fromDoc(DocumentSnapshot doc)
      : eventID = doc.id,
        title = doc.get('title'),
        tags = List<String>.from(doc.get('tags')),
        description = doc.get('description'),
        organizer = doc.get('organizerID'),
        dateTime = doc.get('dateTime').toDate(),
        app = doc.get('appName'),
        url = doc.get('appURL'),
        currentAttendees = doc.get('currentAttendees'),
        maxAttendees = doc.get('maxAttendees');

  EventCard(
      this.eventID,
      this.title,
      this.tags,
      this.description,
      this.organizer,
      this.dateTime,
      this.app,
      this.url,
      this.currentAttendees,
      this.maxAttendees);
  final String eventID;
  final String title;
  final List<String> tags;
  final String description;
  final String organizer;
  final DateTime dateTime;
  final String app;
  final String url;
  final int currentAttendees;
  final int maxAttendees;

  Future<DocumentSnapshot> retrieveUserDoc(String userID) {
    return FirebaseFirestore.instance.collection('users').doc(userID).get();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle logisticsStyle = TextStyle(fontSize: 14);
    TextStyle titleStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
    TextStyle subtitleStyle =
        TextStyle(fontSize: 14, fontWeight: FontWeight.bold);
    TextStyle secondaryStyle = TextStyle(
        fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey);

    String userID = Provider.of<CurrentUserInfo>(context).id;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
          child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: titleStyle),
          SizedBox(height: 8),
          Row(children: [
            Icon(Icons.calendar_today),
            SizedBox(width: 4),
            Text(DateFormat('E').add_MMMd().format(dateTime),
                style: logisticsStyle),
            SizedBox(width: 16),
            Icon(Icons.access_time),
            SizedBox(width: 4),
            Text(DateFormat('jm').format(dateTime), style: logisticsStyle),
            SizedBox(width: 16),
            Icon(Icons.person),
            SizedBox(width: 4),
            Text(currentAttendees.toString() + '/' + maxAttendees.toString(),
                style: logisticsStyle),
          ]),
          SizedBox(height: 8),
          FutureBuilder(
            future: retrieveUserDoc(organizer),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                throw (Exception('error when retrieving user doc'));
              }
              if (!snapshot.hasData) {
                return Text('Organized by...');
              }

              DocumentSnapshot userDoc = snapshot.data;
              String imgURL;
              String firstName;
              String lastName;
              try {
                imgURL = userDoc.get('photoURL');
                firstName = userDoc.get('firstName');
                lastName = userDoc.get('lastName');
              } on StateError catch (e) {
                print('error caught: $e');
                imgURL = touchdown;
                firstName = "Big";
                lastName = "Red";
              }
              return Chip(
                label: Text('Organized by: $firstName $lastName'),
                avatar: CircleAvatar(
                  child: Image(image: NetworkImage(imgURL)),
                  radius: 8,
                ),
              );
            },
          ),
          SizedBox(height: 8),
          Text(description),
          SizedBox(height: 8),
          Text(tags.map((tag) => '#' + tag).join('  '), style: secondaryStyle),
          Padding(
            padding: EdgeInsets.only(top: 8, bottom: 8),
          ),
          Row(children: [
            RSVPButton(eventID),
            SizedBox(width: 16),
            OutlineButton(
                borderSide: BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                child: Text('SHARE', style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  //TODO: add share
                })
          ])
        ]),
      )),
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
    DocumentReference userDoc =
        FirebaseFirestore.instance.collection('users').doc(userID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot userSnap = await transaction.get(userDoc);
      transaction.update(
          userSnap.reference, {'events': userSnap.get('events')..add(eventID)});
    });

    DocumentReference eventDoc =
        FirebaseFirestore.instance.collection('events').doc(eventID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot eventSnap = await transaction.get(eventDoc);
      transaction.update(eventSnap.reference,
          {'currentAttendees': eventSnap.get('currentAttendees') + 1});
    }).then((value) => enable());
  }

  void removeSignUp(String userID, String eventID) async {
    DocumentReference userDoc =
        FirebaseFirestore.instance.collection('users').doc(userID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot userSnap = await transaction.get(userDoc);
      transaction.update(userSnap.reference,
          {'events': userSnap.get('events')..remove(eventID)});
    });

    DocumentReference eventDoc =
        FirebaseFirestore.instance.collection('events').doc(eventID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot eventSnap = await transaction.get(eventDoc);
      transaction.update(eventSnap.reference,
          {'currentAttendees': eventSnap.get('currentAttendees') - 1});
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
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          DocumentSnapshot userDoc = snapshot.data;
          bool signedUp =
              List<String>.from(userDoc.get('events')).contains(widget.eventID);
          return signedUp
              ? FlatButton(
                  color: Theme.of(context).accentColor,
                  disabledColor: Colors.white,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text('SIGNED UP'),
                  onPressed: disabled
                      ? null
                      : () {
                          disable();
                          removeSignUp(userID, widget.eventID);
                        })
              : OutlineButton(
                  borderSide: BorderSide(color: Theme.of(context).accentColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  child: Text('RSVP',
                      style: TextStyle(color: Theme.of(context).accentColor)),
                  disabledBorderColor: Colors.white,
                  onPressed: disabled
                      ? null
                      : () {
                          //TODO: create email screen
                          disable();
                          addSignUp(userID, widget.eventID);
                        });
        });
  }
}

class EventMethods {
  static Future<bool> retrieveSignedUp(String userID, String eventID) {
    DocumentReference userDoc =
        FirebaseFirestore.instance.collection('users').doc(userID);
    return userDoc
        .get()
        .then((doc) => List<String>.from(doc.get('events')).contains(eventID));
  }
}
