import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                  Expanded(
                    child: ListView(
                        children: [
                          EventCard('Codenames battle',
                              ['virtual', 'games', 'codenames'],
                              'guys I just wanna play codenames. New players welcomed, I\'ll explain the rules!',
                              'Helen Yang',
                              DateTime(2020, 8, 26, 22),
                              'example.com',
                              3,
                              12
                          )
                        ]
                    ),
                  )
                ]
            )
        )
    );
  }
}

class EventCard extends StatelessWidget {
  EventCard(this.title, this.tags, this.description, this.organizer, this.dateTime, this.zoomURL, this.currentAttendees, this.maxAttendees);
  final String title;
  final List<String> tags;
  final String description;
  final String organizer;
  final DateTime dateTime;
  final String zoomURL;
  final int currentAttendees;
  final int maxAttendees;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Tags(tags),
                  SizedBox(height: 8),
                  Text('Organized by $organizer'),
                  SizedBox(height: 8),
                  Text(description),
                  Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time),
                        SizedBox(width: 8),
                        Text(DateFormat('Md').add_jm().format(dateTime)),
                        SizedBox(width: 16),
                        Icon(Icons.person),
                        SizedBox(width: 8),
                        Text(currentAttendees.toString() + '/' + maxAttendees.toString()),
                      ],
                    ),
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