import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'Event.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
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
          child: ListView(children: [EventGroup('water')]),
        ),
        FloatingActionButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Stack(
                        overflow: Overflow.visible,
                        children: <Widget>[
                          Positioned(
                            right: -40.0,
                            top: -40.0,
                            child: InkResponse(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: CircleAvatar(
                                child: Icon(Icons.close),
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ),
                          Form(
                              key: GlobalKey(debugLabel: 'tempFormKey'),
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: TextFormField(),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Submit"),
                                  )
                                ],
                              ))
                        ],
                      ),
                    );
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
                return EventCard.fromDoc(doc);
              })));
            },
          ))
    ]);
  }
}

class _CreateEventState extends State<CreateEvent> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            initialValue: "Hi Mom",
          )
        ],
      ),
    );
  }
}

class CreateEvent extends StatefulWidget {
  @override
  _CreateEventState createState() => _CreateEventState();
}
