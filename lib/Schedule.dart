import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      padding: EdgeInsets.all(24),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Schedule', style: Theme.of(context).textTheme.headline1),
            SizedBox(height: 16),
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
                          setState(() {
                            upcoming = true;
                          });
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
                        setState(() {
                          upcoming = false;
                        });
                      },
                    ),
                  )
                ]
            ),
            SizedBox(height: 16),
            StreamBuilder(
                stream: upcoming ?
                FirebaseFirestore.instance
                    .collection('events')
                    .where('attendees', arrayContains: userID)
                    .where('dateTime', isGreaterThan: Timestamp.now())
                    .orderBy('dateTime')
                    .snapshots() :
                FirebaseFirestore.instance
                    .collection('events')
                    .where('attendees', arrayContains: userID)
                    .where('dateTime', isLessThan: Timestamp.now())
                    .orderBy('dateTime', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  List<DocumentSnapshot> eventDocs = snapshot.data.docs;
                  if (eventDocs.isEmpty) {
                    return Text('No events yet!');
                  }
                  Map<DateTime, List<DocumentSnapshot>> daysAndEvents = {};
                  for (DocumentSnapshot d in eventDocs) {
                    DateTime dateTime = d.get('dateTime').toDate();
                    DateTime justDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
                    if (daysAndEvents[justDay] == null) {
                      daysAndEvents[justDay] = [d];
                    }
                    else {
                      daysAndEvents[justDay].add(d);
                    }
                  }
                  List<DateTime> daysList = daysAndEvents.keys.toList()..sort((d1, d2) => d1.compareTo(d2));
                  List<List<DocumentSnapshot>> eventDocsList = [for (DateTime d in daysList) daysAndEvents[d]];
                  return Expanded(
                    child: ListView.builder(
                        itemCount: daysAndEvents.length,
                        itemBuilder: (context, index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(DateFormat('EEEE').format(daysList[index]), style: TextStyle(fontSize: 14)),
                              Text(DateFormat('d').format(daysList[index]), style: TextStyle(fontSize: 18)),
                              SizedBox(height: 6),
                              ListView(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  children: eventDocsList[index].map((eventDoc) => EventRow(Event.fromDoc(eventDoc))).toList()
                              ),
                              SizedBox(height: 16)
                            ],
                          );
                        }
                    ),
                  );
                }
            ),
          ]
      ),
    );
  }
}