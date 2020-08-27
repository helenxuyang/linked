import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'Login.dart';

class HomePage extends StatelessWidget {

  Future<List<String>> retrieveEventIDs(String userID) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .get()
        .then((doc) => List<String>.from(doc.get('events')));
  }

  Future<DocumentSnapshot> retrieveEventDoc(String eventID) async {
    return FirebaseFirestore.instance.collection('events').doc(eventID).get();
  }

  @override
  Widget build(BuildContext context) {
    String userID = Provider.of<CurrentUserInfo>(context).id;
    return Scaffold(
        body: SafeArea(
            child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                    child: Row(
                        children: [
                          Text('Scheduled Events', style: TextStyle(fontSize: 24)),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.filter_list),
                            onPressed: () {
                              //TODO: add filter options
                            },
                          )
                        ]
                    ),
                  ),
                  FutureBuilder(
                    future: retrieveEventIDs(userID),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        print(snapshot.error);
                        throw Exception('error when retrieving user\'s event IDs');
                      }
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      return Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              return FutureBuilder(
                                future: retrieveEventDoc(snapshot.data[index]),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Container();
                                  }
                                  DocumentSnapshot eventDoc = snapshot.data;
                                  return EventCard(
                                      eventDoc.get('title'),
                                      List<String>.from(eventDoc.get('tags')),
                                      eventDoc.get('description'),
                                      eventDoc.get('organizerID'),
                                      eventDoc.get('dateTime').toDate(),
                                      eventDoc.get('appName'),
                                      eventDoc.get('appURL'),
                                      eventDoc.get('currentAttendees'),
                                      eventDoc.get('maxAttendees')
                                  );
                                }
                              );
                            },
                        ),
                      );
                    },
                  )
                ]
            )
        )
    );
  }
}

class EventCard extends StatelessWidget {
  EventCard(this.title, this.tags, this.description, this.organizer, this.dateTime, this.app, this.url, this.currentAttendees, this.maxAttendees);
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
                        OutlineButton(
                            borderSide: BorderSide(color: Colors.blue),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                            child: Text('SIGN UP', style: TextStyle(color: Colors.blue)),
                            onPressed: () {
                              //TODO: add sign up
                            }
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