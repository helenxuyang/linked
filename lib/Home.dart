import 'dart:math';

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
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                  children: [
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
                    EventGroup(
                        'Happening Now',
                        FirebaseFirestore.instance
                            .collection('events')
                            .where('startTime', isLessThan: Timestamp.now())
                            .orderBy('startTime')
                            .snapshots()),
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
                              children: tags
                                  .map((tag) => EventGroup(
                                  'Tag: $tag',
                                  FirebaseFirestore.instance
                                      .collection('events')
                                      .where('tags', arrayContains: tag)
                                      .snapshots()))
                                  .toList());
                        })
                  ]),
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
                        return CreateEventPage();
                      });
                },
                child: Icon(Icons.add)
            )
        ),
      ],
    );
  }
}

class EventGroup extends StatelessWidget {
  EventGroup(this.title, this.stream);

  final String title;
  final Stream stream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        List<DocumentSnapshot> docs =
        List<DocumentSnapshot>.from(snapshot.data.documents).where((doc) {
          return doc.get('endTime').seconds > Timestamp.now().seconds;
        }).toList();
        docs = docs.sublist(0, min(3, docs.length));
        if (docs.isEmpty) {
          return Container();
        }
        return Column(children: [
          Row(children: [
            Text(title, style: TextStyle(fontSize: 22)),
            Spacer(),
            FlatButton(
                child: Text('view all',
                    style: TextStyle(
                        fontSize: 14, color: Theme.of(context).accentColor)),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EventGroupPage(title, stream)));
                })
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

class EventGroupPage extends StatelessWidget {
  EventGroupPage(this.title, this.stream);
  final String title;
  final Stream stream;

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('events')
              .where('startTime', isGreaterThanOrEqualTo: Timestamp.now())
              .orderBy('startTime')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            List<DocumentSnapshot> docs =
            List<DocumentSnapshot>.from(snapshot.data.documents)
                .where((doc) {
              return doc.get('endTime').toDate().isAfter(DateTime.now());
            }).toList();
            if (docs.isEmpty) {
              return Container();
            }
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FlatButton(
                      padding: EdgeInsets.only(left: 0),
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: Align(
                          alignment: Alignment.centerLeft, child: Text('Back')),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(title, style: Theme.of(context).textTheme.headline1),
                    SizedBox(height: 16),
                    Expanded(
                      child: Scrollbar(
                        child: ListView(
                            children: List<EventCard>.from(docs.map((doc) {
                              return EventCard(Event.fromDoc(doc));
                            }))),
                      ),
                    )
                  ]),
            );
          },
        ),
      ),
    );
  }
}
