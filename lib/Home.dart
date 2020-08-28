import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'Event.dart';
import 'CreateEvent.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
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
        Expanded(
          child: ListView(children: [EventGroup('virtual')]),
        ),
        FloatingActionButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return CreateEvent();
                  });
            },
            child: Icon(Icons.add))
      ]),
    );
  }
}

class EventGroup extends StatelessWidget {
  EventGroup(this.tag);
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        Text(tag, style: TextStyle(fontSize: 22)),
        Spacer(),
        Text('view more', style: TextStyle(fontSize: 14))
      ]),
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('events')
                .where('tags', arrayContains: tag)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              return Row(children:
                  List<EventCard>.from(snapshot.data.documents.map((doc) {
                return EventCard(Event.fromDoc(doc));
              })));
            },
          ))
    ]);
  }
}
