import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Login.dart';
import 'Event.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  bool upcoming = true;
  @override
  Widget build(BuildContext context) {
    String userID = Provider.of<CurrentUserInfo>(context).id;
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 16, bottom: 16),
              child: Text('My Schedule', style: Theme.of(context).textTheme.headline1),
            ),
            Row(
              children: [
                Expanded(
                  child: FlatButton(
                    child: Text('Upcoming', style: TextStyle(color: upcoming ? Colors.white : Theme.of(context).accentColor)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                      side: BorderSide(color: Theme.of(context).accentColor),
                    ),
                      color: upcoming ? Theme.of(context).accentColor : Colors.white,
                    onPressed: () {
                      upcoming = true;
                    }
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    child: Text('Past', style: TextStyle(color: upcoming ? Theme.of(context).accentColor : Colors.white)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
                      side: BorderSide(color: Theme.of(context).accentColor),
                    ),
                    color: upcoming ? Colors.white : Theme.of(context).accentColor,
                    onPressed: () {
                      upcoming = false;
                    },
                  ),
                )
              ]
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').doc(userID).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  throw Exception('error when retrieving user\'s event IDs');
                }
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                DocumentSnapshot userDoc = snapshot.data;
                List<String> eventIDs = List<String>.from(userDoc.get('events'));

                if (eventIDs.isEmpty) {
                  return Text('No events yet!');
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: eventIDs.length,
                    itemBuilder: (context, index) {
                      return StreamBuilder(
                          stream: FirebaseFirestore.instance.collection('events').doc(eventIDs[index]).snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            }
                            DocumentSnapshot eventDoc = snapshot.data;
                            return EventRow(Event.fromDoc(eventDoc));
                          }
                      );
                    },
                  ),
                );
              },
            )
          ]
      ),
    );
  }
}