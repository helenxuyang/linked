import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Login.dart';
import 'Event.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage(this.id);
  final String id;

  @override
  Widget build(BuildContext context) {
    String userID = Provider.of<CurrentUserInfo>(context).id;
    TextStyle subtitleStyle =
        TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (id != userID)
            Container(
              width: 50,
              child: FlatButton(
                  splashColor: Colors.white,
                  highlightColor: Colors.white,
                  padding: EdgeInsets.only(left: 0, right: 4),
                  child: Align(
                      child: Text('Back',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.normal)),
                      alignment: Alignment.centerLeft),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(id)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              DocumentSnapshot doc = snapshot.data;
              String userID = Provider.of<CurrentUserInfo>(context).id;
              return Expanded(
                child: Scrollbar(
                  child: ListView(children: [
                    Text(doc.get('firstName') + ' ' + doc.get('lastName'),
                        style: Theme.of(context).textTheme.headline1),
                    Text(
                        doc.get('major') +
                            ' ' +
                            doc.get('classYear').toString(),
                        style: TextStyle(fontSize: 18)),
                    Text(doc.get('status'),
                        style: TextStyle(
                            fontSize: 18,
                            color: Color.fromRGBO(0xeb, 0x8a, 0x90, 1.0))),
                    SizedBox(height: 16),
                    Text('Bio', style: subtitleStyle),
                    Text(doc.get('bio'), style: TextStyle(fontSize: 16)),
                    SizedBox(height: 16),
                    Text('Activities', style: subtitleStyle),
                    Wrap(
                      children: List<String>.from(doc.get('interestedTags'))
                          .map((str) => InputChip(label: Text(str)))
                          .toList(),
                      spacing: 4,
                      runSpacing: -8,
                    ),
                    SizedBox(height: 16),
                    Text('Classes', style: subtitleStyle),
                    Wrap(
                      children: List<String>.from(doc.get('classes'))
                          .map((str) => InputChip(label: Text(str)))
                          .toList(),
                      spacing: 4,
                      runSpacing: -8,
                    ),
                    SizedBox(height: 16),
                    Text('Upcoming Events', style: subtitleStyle),
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('events')
                            .where('attendees', arrayContains: userID)
                            .where('dateTime', isGreaterThan: Timestamp.now())
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container();
                          }
                          List<DocumentSnapshot> docs = snapshot.data.docs;
                          if (docs.isEmpty) {
                            return Text('No events yet!');
                          }
                          return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(children: List<EventCard>.from(
                                  snapshot.data.documents.map((doc) {
                                return EventCard(Event.fromDoc(doc));
                              }))));
                        })
                  ]),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
