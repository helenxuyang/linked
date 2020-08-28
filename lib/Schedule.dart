import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Login.dart';
import 'Event.dart';

class SchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String userID = Provider.of<CurrentUserInfo>(context).id;
    return Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
            child: Row(
                children: [
                  Text('Your Events', style: Theme.of(context).textTheme.headline1),
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
                          return EventCard(Event.fromDoc(eventDoc));
                        }
                    );
                  },
                ),
              );
            },
          )
        ]
    );
  }
}