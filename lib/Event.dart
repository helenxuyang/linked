import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'Login.dart';
import 'Profile.dart';
import 'EditEvent.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'dart:developer';
import "package:http/http.dart" as http;
import "package:googleapis_auth/auth_io.dart";

class Event {
  static final List<String> appOptions = ['Virtual', 'In Person'];

  Event(
      this.eventID,
      this.calEventID,
      this.title,
      this.isVirtual,
      this.location,
      this.description,
      this.organizer,
      this.startTime,
      this.endTime,
      this.attendeeIDs,
      this.maxAttendees,
      this.tags);

  Event.fromDoc(DocumentSnapshot doc)
      : eventID = doc.id,
        calEventID = doc.get('calEventID'),
        title = doc.get('title'),
        isVirtual = doc.get('isVirtual'),
        location = doc.get('location'),
        description = doc.get('description'),
        organizer = doc.get('organizerID'),
        startTime = doc.get('startTime').toDate(),
        endTime = doc.get('endTime').toDate(),
        attendeeIDs = List<String>.from(doc.get('attendees')),
        maxAttendees = doc.get('maxAttendees'),
        tags = List<String>.from(doc.get('tags'));

  final String eventID;
  final String calEventID;
  final String title;
  final bool isVirtual;
  final String location;
  final List<String> tags;
  final String description;
  final String organizer;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> attendeeIDs;
  final int maxAttendees;

  bool isLive() {
    DateTime now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }
}

class EventCard extends StatelessWidget {
  EventCard(this.event);
  final Event event;

  Future<DocumentSnapshot> retrieveUserDoc(String userID) {
    return FirebaseFirestore.instance.collection('users').doc(userID).get();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
    TextStyle logisticsStyle = TextStyle(fontSize: 16);
    TextStyle secondaryStyle = TextStyle(
        fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey);

    double iconSize = 14;

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => EventPage(event)));
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                child: Text(event.title, style: titleStyle),
                width: MediaQuery.of(context).size.width * 0.6),
            Row(
              children: [
                Icon(Icons.access_time, size: iconSize),
                SizedBox(width: 4),
                event.isLive()
                    ? Text('Now',
                    style: logisticsStyle.apply(
                        color: Color.fromRGBO(0xeb, 0x8a, 0x90, 1.0)))
                    : Text(
                    DateFormat('E').format(event.startTime) +
                        '. ' +
                        DateFormat('MMMMd').format(event.startTime) +
                        ' at ' +
                        DateFormat('jm').format(event.startTime),
                    style: logisticsStyle),
              ],
            ),
            Row(
              children: [
                Icon(Icons.location_on, size: iconSize),
                SizedBox(width: 4),
                Text(event.isVirtual ? 'Online' : event.location,
                    style: logisticsStyle),
              ],
            ),
            Row(
              children: [
                Icon(Icons.people, size: iconSize),
                SizedBox(width: 4),
                Text(
                    event.attendeeIDs.length.toString() +
                        (event.maxAttendees == null
                            ? ''
                            : '/' + event.maxAttendees.toString()),
                    style: logisticsStyle),
              ],
            ),
            Row(children: [
              Text('Organizer:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(width: 4),
              OrganizerChip(event.organizer)
            ]),
            Container(
                child: Text(event.description, style: logisticsStyle),
                width: MediaQuery.of(context).size.width * 0.6),
            SizedBox(height: 8),
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Text(event.tags.map((tag) => '#' + tag).join('  '),
                  style: secondaryStyle),
            ),
            SizedBox(height: 8),
            Row(children: [
              event.isVirtual && event.isLive()
                  ? JoinButton(event.location)
                  : RSVPButton(event),
              SizedBox(width: 16),
              ShareButton(event)
            ])
          ]),
        ),
      ),
    );
  }
}

class EventRow extends StatelessWidget {
  EventRow(this.event);
  final Event event;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => EventPage(event)));
      },
      child: Card(
          child: Padding(
            padding:
            const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                    child: Text(event.title,
                        style: TextStyle(fontSize: 16), softWrap: true),
                    width: MediaQuery.of(context).size.width * 0.6),
                Text(
                    DateFormat('E').format(event.startTime) +
                        '. ' +
                        DateFormat('MMMMd').format(event.startTime) +
                        ' at ' +
                        DateFormat('jm').format(event.startTime),
                    style: TextStyle(
                        fontSize: 12, color: Theme.of(context).accentColor)),
                Text(event.isVirtual ? 'Virtual Event' : event.location,
                    style: TextStyle(
                        fontSize: 12, color: Color.fromRGBO(0x84, 0x84, 0x84, 1.0)))
              ]),
              Spacer(),
              Icon(Icons.people),
              SizedBox(width: 2),
              Text(event.attendeeIDs.length.toString())
            ]),
          )),
    );
  }
}

class EventPage extends StatelessWidget {
  EventPage(this.event);
  final Event event;

  Widget backButton(context) {
    return Container(
      width: 50,
      child: FlatButton(
          splashColor: Colors.white,
          highlightColor: Colors.white,
          padding: EdgeInsets.only(left: 0, right: 4),
          child: Align(
              child: Text('Back',
                  style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
              alignment: Alignment.centerLeft),
          onPressed: () {
            Navigator.pop(context);
          }),
    );
  }

  Widget deleteButton(context, Event event, String userID) {
    /** Not finished, fails to pop to the desired page, do not use until fixed */
    return event.organizer == userID
        ? Container(
        width: 70,
        child: FlatButton(
            splashColor: Colors.white,
            highlightColor: Colors.white,
            padding: EdgeInsets.only(left: 4, right: 8),
            child: Text('Delete',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.normal)),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                          "Are you sure you want to delete ${event.title}"),
                      content: Row(children: [
                        FlatButton(
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('events')
                                  .doc(event.eventID)
                                  .delete();
                              log("event ${event.eventID} deleted");
                              Navigator.popUntil(
                                  context, ModalRoute.withName('/home'));
                            },
                            child: Text("Yes")),
                        FlatButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text("No"))
                      ]),
                    );
                  });
            }))
        : Container();
  }

  Widget editButton(context, Event event, String userID) {
    return event.organizer == userID
        ? Container(
      width: 50,
      child: FlatButton(
          splashColor: Colors.white,
          highlightColor: Colors.white,
          padding: EdgeInsets.only(left: 0, right: 4),
          child: Align(
              child: Text('Edit',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.normal)),
              alignment: Alignment.centerLeft),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditEventPage(event)));
          }),
    )
        : Container();
  }

  Widget eventPageScaffold(
      BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    String userID = Provider.of<CurrentUserInfo>(context).id;
    TextStyle subtitleStyle =
    TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
    if (!snapshot.hasData) {
      return Container();
    }
    Event event = Event.fromDoc(snapshot.data);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(children: [
            Row(
              children: [
                backButton(context),
                Spacer(),
                editButton(context, event, userID)
              ],
            ),
            Text(event.title,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text(
                DateFormat('EEEE').format(event.startTime) +
                    ', ' +
                    DateFormat('MMMMd').format(event.startTime) +
                    ' at ' +
                    DateFormat('jm').format(event.startTime),
                style: TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(0xEB, 0x8a, 0x90, 1.0))),
            Text(event.isVirtual ? 'Virtual Event' : event.location,
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Row(children: [
              Expanded(child: RSVPButton(event)),
              SizedBox(width: 16),
              Expanded(child: ShareButton(event))
            ]),
            SizedBox(height: 8),
            Text('Description', style: subtitleStyle),
            SizedBox(height: 4),
            Text(event.description),
            SizedBox(height: 4),
            Text(event.tags.map((tag) => '#' + tag).join('  '),
                style: TextStyle(
                    color: Color.fromRGBO(0x8F, 0x8F, 0x8F, 1.0),
                    fontStyle: FontStyle.italic)),
            SizedBox(height: 8),
            Text('Organizer', style: subtitleStyle),
            Align(
              alignment: Alignment.centerLeft,
              child: OrganizerChip(event.organizer),
            ),
            SizedBox(height: 8),
            Text(
                event.attendeeIDs.length.toString() +
                    (event.maxAttendees == null
                        ? ''
                        : '/' + event.maxAttendees.toString()) +
                    ' attendees:',
                style: subtitleStyle),
            AttendeeChips(event.attendeeIDs)
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('events')
            .doc(event.eventID)
            .snapshots(),
        builder: eventPageScaffold);
  }
}

class PersonChip extends StatelessWidget {
  PersonChip(this.doc);
  final DocumentSnapshot doc;
  @override
  Widget build(BuildContext context) {
    return InputChip(
      backgroundColor: Colors.transparent,
      shape: StadiumBorder(
          side: BorderSide(color: Theme.of(context).accentColor, width: 1)),
      avatar: CircleAvatar(
          child: ClipOval(
              child: Image.network(
                doc.get('photoURL'),
              ))),
      label: Text(doc.get('firstName') + ' ' + doc.get('lastName'),
          style: TextStyle(color: Theme.of(context).accentColor)),
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Scaffold(
                    body: SafeArea(child: ProfilePage(doc.id, true)))));
      },
    );
  }
}

class OrganizerChip extends StatelessWidget {
  OrganizerChip(this.id);
  final String id;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: FirebaseFirestore.instance.collection('users').doc(id).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          DocumentSnapshot organizerDoc = snapshot.data;
          return PersonChip(organizerDoc);
        });
  }
}

class AttendeeChips extends StatelessWidget {
  AttendeeChips(this.attendeeIDs);
  final List<String> attendeeIDs;
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: attendeeIDs.map((id) {
        return FutureBuilder(
            future:
            FirebaseFirestore.instance.collection('users').doc(id).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              DocumentSnapshot attendeeDoc = snapshot.data;
              return PersonChip(attendeeDoc);
            });
      }).toList(),
      spacing: 8,
    );
  }
}

class ShareButton extends StatelessWidget {
  ShareButton(this.event);
  final Event event;
  @override
  Widget build(BuildContext context) {
    return OutlineButton(
        borderSide: BorderSide(color: Colors.blue),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        child: Text('SHARE', style: TextStyle(color: Colors.blue)),
        onPressed: () async {
          log("Share button pressed");
          String organizerId = event.organizer;
          await FirebaseFirestore.instance
              .collection('users')
              .doc(organizerId)
              .get()
              .then<void>((snapshot) async {
            log("organizer doc fetched");
            String mediumLine = event.isVirtual
                ? "URL: ${event.location}\n"
                : "Location: ${event.location}\n";
            String startDateStr =
                DateFormat('EEE M/d/y ').format(event.startTime) +
                    DateFormat('jm').format(event.startTime);
            String endDateStr = event.startTime.day == event.endTime.day
                ? DateFormat('jm').format(event.endTime)
                : DateFormat('M/d/y ').format(event.endTime) +
                DateFormat('jm').format(event.endTime);
            String dateTimeLine =
                "Date & Time: " + startDateStr + " to " + endDateStr + "\n";
            String shareString = "Event: ${event.title} \n" +
                "Description: ${event.description} \n" +
                "$mediumLine" +
                "$dateTimeLine";
            String organizer =
                snapshot.get('firstName') + ' ' + snapshot.get('lastName');
            shareString += "Organizer: $organizer";
            await Share.share(shareString);
          });
        });
  }
}

class JoinButton extends StatelessWidget {
  JoinButton(this.url);
  final String url;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
        color: Theme.of(context).accentColor,
        disabledColor: Colors.transparent,
        textColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text('JOIN'),
        onPressed: () async {
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
        });
  }
}

class RSVPButton extends StatefulWidget {
  RSVPButton(this.event);
  final Event event;

  @override
  _RSVPButtonState createState() => _RSVPButtonState();
}

class _RSVPButtonState extends State<RSVPButton> {
  bool disabled = false;

  void addSignUp(String userID, String eventID) async {
    DocumentReference userDoc =
    FirebaseFirestore.instance.collection('users').doc(userID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot userSnap = await transaction.get(userDoc);
      transaction.update(
          userSnap.reference, {'events': userSnap.get('events')..add(eventID)});
    });

    DocumentReference eventDoc =
    FirebaseFirestore.instance.collection('events').doc(eventID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot eventSnap = await transaction.get(eventDoc);
      transaction.update(eventSnap.reference,
          {'attendees': eventSnap.get('attendees')..add(userID)});
    }).then((value) => enable());
  }

  void removeSignUp(String userID, String eventID) async {
    DocumentReference userDoc =
    FirebaseFirestore.instance.collection('users').doc(userID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot userSnap = await transaction.get(userDoc);
      transaction.update(userSnap.reference,
          {'events': userSnap.get('events')..remove(eventID)});
    });

    DocumentReference eventDoc =
    FirebaseFirestore.instance.collection('events').doc(eventID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot eventSnap = await transaction.get(eventDoc);
      transaction.update(eventSnap.reference,
          {'attendees': eventSnap.get('attendees')..remove(userID)});
    }).then((value) => enable());
  }

  void disable() {
    setState(() {
      disabled = true;
    });
  }

  void enable() {
    setState(() {
      disabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String userID = Provider.of<CurrentUserInfo>(context).id;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          DocumentSnapshot userDoc = snapshot.data;
          bool signedUp =
          List<String>.from(userDoc.get('events')).contains(widget.event.eventID);
          return signedUp ? FlatButton(
              color: Theme.of(context).accentColor,
              disabledColor: Colors.transparent,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(children: [
                Icon(Icons.check),
                SizedBox(width: 2),
                Text('SIGNED UP'),
              ]),
              onPressed: disabled
                  ? null
                  : () {
                disable();
                removeSignUp(userID, widget.event.eventID);
              })
              : FlatButton(
              color: Theme.of(context).accentColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              child: Text('RSVP', style: TextStyle(color: Colors.white)),
              onPressed: disabled
                  ? null
                  : () async {
                disable();
                addSignUp(userID, widget.event.eventID);
                DocumentSnapshot doc = await FirebaseFirestore
                    .instance
                    .collection('events')
                    .doc(widget.event.eventID)
                    .get();
                EventUtils.addMeToCalEvent(widget.event.calEventID);
              });
        });
  }
}

class EventUtils {
  static Widget noEventsMessage = SizedBox(
      width: double.infinity,
      child: Column(children: [
        Text('No events here 😥'),
        Text('Create or sign up for one to join in the fun!')
      ]));

  static Future<bool> retrieveSignedUp(String userID, String eventID) {
    DocumentReference userDoc =
    FirebaseFirestore.instance.collection('users').doc(userID);
    return userDoc
        .get()
        .then((doc) => List<String>.from(doc.get('events')).contains(eventID));
  }

  // Debug method to help us get accessCredential fields via user consent
  // (intended for no.probllama acct)
  static Future<AccessCredentials> promptBoi() async {
    var scopes = [cal.CalendarApi.CalendarScope];
    var id = new ClientId("44712156267-lakgod0gdas9v68dloqfjs5nrigvbp6u.apps.googleusercontent.com", "");

    void prompt(String url) async {
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
    }

    await clientViaUserConsent(id, scopes, prompt).then((AuthClient client) async {
      AccessCredentials creds = client.credentials;
      String currentAccessToken = creds.accessToken.data;
      String currentRefreshToken = creds.refreshToken;
      DateTime currentExpiry = creds.accessToken.expiry;
      log("accessToken: $currentAccessToken");
      log("refreshToken: $currentRefreshToken");
      log("expiry (utc datetime): ${currentExpiry.toString()}");
      DocumentReference credsDocRef = FirebaseFirestore.instance.collection('credentials').doc('creds');
      credsDocRef.update({'accessToken': currentAccessToken});
      credsDocRef.update({'refreshToken': currentRefreshToken});
      credsDocRef.update({'expiry': Timestamp.fromDate(currentExpiry)});
    });
  }

  // Obtain our service account's accessCredentials.
  static Future<AccessCredentials> getCredentials() async {
    var scopes = [cal.CalendarApi.CalendarScope];
    DocumentSnapshot credsDoc = await FirebaseFirestore.instance.collection('credentials').doc('creds').get();
    String accessToken = credsDoc.get('accessToken');
    String refreshToken = credsDoc.get('refreshToken');
    DateTime expiry = credsDoc.get("expiry").toDate();
    print("===========================");
    if(!expiry.isUtc){
      expiry = expiry.add(expiry.timeZoneOffset);
      expiry = DateTime.utc(expiry.year, expiry.month, expiry.day, expiry.hour, expiry.minute, expiry.second);
    }
    print(expiry.toString());
    expiry = expiry.toUtc();
    AccessToken token = new AccessToken("Bearer", accessToken, expiry);
    return AccessCredentials(token,refreshToken, scopes);
  }
  // store updated credentials in Firebase if changed during use
  static void refreshCredentials(AccessCredentials cred) async {
    DocumentReference credsDocRef = FirebaseFirestore.instance.collection('credentials').doc('creds');
    DocumentSnapshot credsDoc = await credsDocRef.get();
    String firebaseAccessToken = credsDoc.get("accessToken");
    String firebaseRefreshToken = credsDoc.get('refreshToken');
    DateTime firebaseExpiry = credsDoc.get("expiry").toDate().toUTC();
    String currentAccessToken = cred.accessToken.data;
    String currentRefreshToken = cred.refreshToken;
    DateTime currentExpiry = cred.accessToken.expiry;
    if( currentAccessToken != firebaseAccessToken){
      credsDocRef.update({'accessToken': currentAccessToken});
    }
    if( currentRefreshToken != firebaseRefreshToken){
      credsDocRef.update({'refreshToken': currentRefreshToken});
    }
    if( currentExpiry != firebaseExpiry){
      credsDocRef.update({'expiry': Timestamp.fromDate(currentExpiry)});
    }

  }

  // returns Google Calendar event
  static Future<cal.Event> createCalEvent(BuildContext context, Event event, bool createLink) async {
    String timeZone = await FlutterNativeTimezone.getLocalTimezone();
    promptBoi();
    http.Client httpClient = http.Client();
    AccessCredentials credentials = await getCredentials();
    AuthClient client = authenticatedClient(httpClient, credentials);

    cal.CalendarApi calAPI = cal.CalendarApi(client);
    String calEmail = "no.probllama.linked@gmail.com";
    cal.Calendar googleCalendar = await calAPI.calendars.get(calEmail);
    String userEmail = FirebaseAuth.instance.currentUser.email;
    cal.Event calEvent = cal.Event.fromJson({
      'summary': event.title,
      'description': event.description,
      'start': {
        'dateTime': event.startTime.toString(),
        'timeZone': timeZone
      },
      'end': {
        'dateTime': event.endTime.toString(),
        'timeZone': timeZone
      },
      'attendees': [
        {
          'email': userEmail
        }
      ]
    });

    if (createLink) {
      calEvent.conferenceData = cal.ConferenceData.fromJson({
        'createRequest': {
          'requestId': 'test'
        }
      });
    }
    else {
      calEvent.location = event.location;
    }
    await calAPI.events.insert(calEvent, calEmail, conferenceDataVersion: 1).then((createdEvent) async {
      if (createdEvent.status == 'confirmed') {
        print('confirmed');

        String calendarURL = createdEvent.htmlLink;
        print('cal URL: ' + calendarURL);
        if (createLink) {
          FirebaseFirestore.instance.collection('events').doc(event.eventID).update({'location': createdEvent.conferenceData.entryPoints[0].uri});
        }
        if (await canLaunch(calendarURL)) {
          await launch(
            calendarURL,
            forceSafariVC: false,
            forceWebView: false,
            headers: <String, String>{'my_header_key': 'my_header_value'},
          );
        } else {
          throw 'Could not launch $calendarURL';
        }
      }
      else {
        print('error inserting event');
      }
      client.close();
      //refreshCredentials(credentials);
    });
      return calEvent;

  }

  static void addMeToCalEvent(String eventID) async {

    http.Client httpClient = http.Client();
    AccessCredentials credentials = await getCredentials();
    AuthClient client = authenticatedClient(httpClient, credentials);

    cal.CalendarApi calAPI = cal.CalendarApi(client);
    String calEmail = "no.probllama.linked@gmail.com";
    cal.Calendar googleCalendar = await calAPI.calendars.get(calEmail);
    String userEmail = FirebaseAuth.instance.currentUser.email;

    cal.Event calEvent = await calAPI.events.get(calEmail, eventID);
    calEvent.attendees.add(cal.EventAttendee.fromJson({
      'email': userEmail
    }));
    refreshCredentials(credentials);
  }
}

