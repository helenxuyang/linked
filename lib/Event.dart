import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'Login.dart';

class EventCard extends StatelessWidget {
  EventCard.fromDoc(DocumentSnapshot doc) :
        eventID = doc.id,
        title = doc.get('title'),
        tags = List<String>.from(doc.get('tags')),
        description = doc.get('description'),
        organizer = doc.get('organizerID'),
        dateTime = doc.get('dateTime').toDate(),
        app = doc.get('appName'),
        url = doc.get('appURL'),
        currentAttendees = doc.get('currentAttendees'),
        maxAttendees = doc.get('maxAttendees');

  EventCard(this.eventID, this.title, this.tags, this.description, this.organizer, this.dateTime, this.app, this.url, this.currentAttendees, this.maxAttendees);
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

  Future<bool> retrieveSignedUp(String userID, String eventID) {
    return FirebaseFirestore.instance.collection('users').doc(userID).get().then((doc) => List<String>.from(doc.get('events')).contains(eventID));
  }

  Future<DocumentSnapshot> retrieveUserDoc(String userID) {
    return FirebaseFirestore.instance.collection('users').doc(userID).get();
  }

  void addSignUp(String userID, String eventID) {
    DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(userID);
    userDoc.get().then((snapshot) {
      userDoc.update({'events': List<String>.from(snapshot.get('events'))..add(eventID)});
    });
    DocumentReference eventDoc = FirebaseFirestore.instance.collection('events').doc(eventID);
    eventDoc.get().then((snapshot) {
      eventDoc.update({'currentAttendees': snapshot.get('currentAttendees') + 1});
    });
  }

  void removeSignUp(String userID, String eventID) {
    DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(userID);
    userDoc.get().then((snapshot) {
      userDoc.update({'events': List<String>.from(snapshot.get('events'))..remove(eventID)});
    });
    DocumentReference eventDoc = FirebaseFirestore.instance.collection('events').doc(eventID);
    eventDoc.get().then((snapshot) {
      eventDoc.update({'currentAttendees': snapshot.get('currentAttendees') - 1});
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle logisticsStyle = TextStyle(
        fontSize: 14
    );
    TextStyle titleStyle = TextStyle(
        fontSize: 24,
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

    Color blue = Color.fromRGBO(0x2d, 0x82, 0xB7, 1.0);
    String userID = Provider.of<CurrentUserInfo>(context).id;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: titleStyle),
                  SizedBox(height: 8),
                  Row(
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 4),
                        Text(DateFormat('E').add_MMMd().format(dateTime), style: logisticsStyle),
                        SizedBox(width: 16),
                        Icon(Icons.access_time),
                        SizedBox(width: 4),
                        Text(DateFormat('jm').format(dateTime), style: logisticsStyle),
                        SizedBox(width: 16),
                        Icon(Icons.person),
                        SizedBox(width: 4),
                        Text(currentAttendees.toString() + '/' + maxAttendees.toString(), style: logisticsStyle),
                      ]
                  ),
                  SizedBox(height: 8),
                  FutureBuilder(
                    future: retrieveUserDoc(organizer),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        print(snapshot.error);
                        throw(Exception('error when retrieving user doc'));
                      }
                      if (!snapshot.hasData) {
                        return Text('Organized by...');
                      }
                      DocumentSnapshot userDoc = snapshot.data;
                      return Text('Organized by: ' + userDoc.get('firstName') + ' ' + userDoc.get('lastName'), style: subtitleStyle);
                    },
                  ),
                  SizedBox(height: 8),
                  Text(description),
                  SizedBox(height: 8),
                  Text(tags.map((tag) => '#' + tag).join('  '), style: secondaryStyle),
                  Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FutureBuilder(
                          future: retrieveSignedUp(userID, eventID),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            }
                            bool signedUp = snapshot.data;
                            return signedUp ?
                            FlatButton(
                                color: blue,
                                textColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text('SIGNED UP'),
                                onPressed: () {
                                  removeSignUp(userID, eventID);
                                }
                            ) :
                            OutlineButton(
                                borderSide: BorderSide(color: blue),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                                child: Text('RSVP', style: TextStyle(color: blue)),
                                onPressed: () {
                                  addSignUp(userID, eventID);
                                  //TODO: create email screen
                                }
                            );

                          },
                        ),
                        SizedBox(width: 16),
                        OutlineButton(
                            borderSide: BorderSide(color: Colors.blue),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                            child: Text('SHARE', style: TextStyle(color: Colors.blue)),
                            onPressed: () {
                              //TODO: add share
                            }
                        )
                      ]
                  )
                ]
            ),
          )
      ),
    );
  }
}

class Tags extends StatelessWidget {
  Tags(this.tags);

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
        spacing: 8,
        runSpacing: 4,
        children: tags.map((name) {
          return Container(
              color: Colors.blue[100],
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text(name),
              )
          );
        }).toList()
    );
  }
}

class EventMethods {
  static Future<List<String>> retrieveEventIDs(String userID) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .get()
        .then((doc) => List<String>.from(doc.get('events')));
  }
}