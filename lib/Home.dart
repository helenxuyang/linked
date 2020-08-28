import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Event.dart';
import 'CreateEvent.dart';
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
              LiveEventGroup(),
              SizedBox(height: 24),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userID)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    List<String> tags =
                        List<String>.from(snapshot.data.get('interestedTags'));
                    return Column(
                        //TODO: use tags from backend
                        children:
                            tags.map((tag) => TagEventGroup(tag)).toList());
                  })
            ]),
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
                        return CreateEventPage();
                      });
                },
                child: Icon(Icons.add))),
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
        List<DocumentSnapshot> docs =
            List<DocumentSnapshot>.from(snapshot.data.documents).where((doc) {
          return doc.get('endTime').toDate().isAfter(DateTime.now());
        }).toList();
        if (docs.isEmpty) {
          return Container();
        }
        return Column(children: [
          Row(children: [
            Text('Happening Now', style: TextStyle(fontSize: 22)),
            Spacer(),
            Text('view more', style: TextStyle(fontSize: 14))
          ]),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: List<EventCard>.from(docs.map((doc) {
              return EventCard(Event.fromDoc(doc));
            }))),
          )
        ]);
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
        List<DocumentSnapshot> docs =
            List<DocumentSnapshot>.from(snapshot.data.documents).where((doc) {
          return doc.get('endTime').toDate().isAfter(DateTime.now());
        }).toList();
        if (docs.isEmpty) {
          return Container();
        }
        return Column(children: [
          Row(children: [
            Text(tag, style: TextStyle(fontSize: 22)),
            Spacer(),
            Text('view more', style: TextStyle(fontSize: 14))
          ]),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: List<EventCard>.from(docs.map((doc) {
              return EventCard(Event.fromDoc(doc));
            }))),
          )
        ]);
      },
    );
  }
}
