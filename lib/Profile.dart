import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)
                      ),
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
              return Expanded(
                child: Scrollbar(
                  child: ListView(children: [
                    Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(doc.get('firstName') + ' ' + doc.get('lastName'),
                                      style: Theme.of(context).textTheme.headline1),
                                  Text(
                                      doc.get('major') +
                                          ' ' +
                                          doc.get('classYear').toString(),
                                      style: TextStyle(fontSize: 18)),
                                  Text(doc.get('status'),
                                      style: TextStyle(fontSize: 18, color: Theme.of(context).accentColor)),
                                ]
                            ),
                          ),
                          Spacer(),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: ClipOval(
                                  child: Image.network(
                                      doc.get('photoURL'),
                                      width: 75
                                  )
                              )
                          ),
                        ]
                    ),
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
                          .map((str) =>
                          InputChip(
                            labelStyle: TextStyle(color: Colors.grey[700]),
                            label: Text(str),
                            backgroundColor: Colors.blue,
                          ))
                          .toList(),
                      spacing: 4,
                      runSpacing: -8,
                    ),
                    SizedBox(height: 16),
                    Text('Upcoming Events', style: subtitleStyle),
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('events')
                            .where('attendees', arrayContains: id)
                            .where('startTime', isGreaterThan: Timestamp.now())
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container();
                          }
                          List<DocumentSnapshot> docs = snapshot.data.docs;
                          if (docs.isEmpty) {
                            return Text('No events yet');
                          }
                          return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(children: List<EventCard>.from(
                                  snapshot.data.documents.map((doc) {
                                    return EventCard(Event.fromDoc(doc));
                                  }))
                              )
                          );
                        }),
                    SizedBox(height: 24),
                    StreamBuilder<Object>(
                        stream: FirebaseFirestore.instance.collection('users').doc(userID).snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container();
                          }
                          DocumentSnapshot doc = snapshot.data;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (doc.get('linkedinUser') != null && !doc.get('linkedinUser').isEmpty)
                                  MaterialButton(
                                    shape: CircleBorder(side: BorderSide(width: 2, color: Colors.transparent)),
                                    child: Image.asset('assets/linkedin_logo.png', width: 30),
                                    onPressed: () async {
                                      String url = 'https://linkedin.com/in/' + doc.get('linkedinUser');
                                      if (await canLaunch(url)) {
                                        await launch(
                                          url,
                                          forceSafariVC: false,
                                          forceWebView: false,
                                          headers: <String, String>{'my_header_key': 'my_header_value'},
                                        );
                                      } else {
                                        throw 'Could not launch $url';
                                      }
                                    },
                                  ),
                                if (doc.get('facebookUser') != null && !doc.get('facebookUser').isEmpty)
                                  MaterialButton(
                                    shape: CircleBorder(side: BorderSide(width: 2, color: Colors.transparent)),
                                    child: Image.asset('assets/facebook_logo.png', width: 30),
                                    onPressed: () async {
                                      String url = 'https://facebook.com/' + doc.get('facebookUser');
                                      if (await canLaunch(url)) {
                                        await launch(
                                          url,
                                          forceSafariVC: false,
                                          forceWebView: false,
                                          headers: <String, String>{'my_header_key': 'my_header_value'},
                                        );
                                      } else {
                                        throw 'Could not launch $url';
                                      }
                                    },
                                  ),
                                if (doc.get('instagramUser') != null && !doc.get('instagramUser').isEmpty)
                                  MaterialButton(
                                    shape: CircleBorder(side: BorderSide(width: 2, color: Colors.transparent)),
                                    child: Image.asset('assets/instagram_logo.png', width: 30),
                                    onPressed: () async {
                                      String url = 'https://instagram.com/' + doc.get('instagramUser');
                                      if (await canLaunch(url)) {
                                        await launch(
                                          url,
                                          forceSafariVC: false,
                                          forceWebView: false,
                                          headers: <String, String>{'my_header_key': 'my_header_value'},
                                        );
                                      } else {
                                        throw 'Could not launch $url';
                                      }
                                    },
                                  ),
                              ]
                          );
                        }
                    )
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
