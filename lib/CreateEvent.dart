import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'Event.dart';
import 'Login.dart';
import 'Utils.dart';

class _CreateEventPageState extends State<CreateEventPage> {
  // Event fields
  String _title;
  String _type;
  bool _isVirtual;
  String _location;
  String _description;
  DateTime _startTime;
  DateTime _endTime;
  int _maxAttendees;
  String _organizerID; // google ID of event organizer
  List<String> _tags = [];

  final _formKey = GlobalKey<FormState>();
  FocusNode _focusNode;
  bool noMax = true;

  @override
  void initState() {
    super.initState();
    _title = '';
    _type = Event.appOptions[0];
    _isVirtual = true;
    _description = '';
    _startTime = DateTime.now();
    _endTime = _startTime.add(new Duration(hours: 1));
    _maxAttendees = 10;
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void setStart(DateTime date, TimeOfDay time) {
    setState(() {
      _startTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void setEnd(DateTime date, TimeOfDay time) {
    setState(() {
      _endTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    _organizerID = Provider.of<CurrentUserInfo>(context).id;
    return Scaffold(
        body: SafeArea(
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ),
              SizedBox(height: 24),
              Expanded(
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 24, right: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("New Event", style: Theme.of(context).textTheme.headline1),
                            SizedBox(height: 30),
                            Form(
                                key: _formKey,
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Event Name",
                                          style: Theme.of(context).textTheme.headline3),
                                      TextFormField(
                                        focusNode: _focusNode,
                                        textInputAction: TextInputAction.next,
                                        decoration: Utils.textFieldDecoration(
                                            hint: 'PowerPoint Palooza Spectacular'),
                                        maxLength: 20,
                                        validator: (input) {
                                          if (input.isEmpty) {
                                            return 'Please enter an event name.';
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            _title = value;
                                          });
                                        },
                                        onFieldSubmitted: (value) {
                                          FocusScope.of(context).nextFocus();
                                        },
                                      ),
                                      SizedBox(height: 12),
                                      Text('Event Type',
                                          style: Theme.of(context).textTheme.headline3),
                                      DropdownButton<String>(
                                          items: Event.appOptions
                                              .map((medium) => DropdownMenuItem(
                                              child: Text(medium), value: medium))
                                              .toList(),
                                          value: _type,
                                          icon: Icon(Icons.keyboard_arrow_down),
                                          onChanged: (newValue) {
                                            setState(() {
                                              _type = newValue;
                                              if (newValue == "In Person") {
                                                _isVirtual = false;
                                              } else {
                                                _isVirtual = true;
                                              }
                                            });
                                          }),
                                      SizedBox(height: 12),
                                      Text('Location',
                                          style: Theme.of(context).textTheme.headline3),
                                      TextFormField(
                                        textInputAction: TextInputAction.next,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return _isVirtual
                                                ? 'Please enter a URL.'
                                                : 'Please enter a location.';
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            _location = value;
                                          });
                                        },
                                        onFieldSubmitted: (value) {
                                          FocusScope.of(context).nextFocus();
                                        },
                                        decoration: Utils.textFieldDecoration(
                                            hint: _isVirtual
                                                ? 'Paste Zoom/Google Meet link'
                                                : 'Arts Quad'),
                                      ),
                                      SizedBox(height: 12),
                                      Text("Description",
                                          style: Theme.of(context).textTheme.headline3),
                                      TextFormField(
                                          keyboardType: TextInputType.multiline,
                                          maxLines: null,
                                          textInputAction: TextInputAction.next,
                                          decoration: Utils.textFieldDecoration(
                                              hint:
                                              'Come hang out with me! I\'m very cool and fun.')
                                              .copyWith(hintMaxLines: null),
                                          maxLength: 200,
                                          validator: (input) {
                                            if (input.isEmpty) {
                                              return 'Please enter a description.';
                                            }
                                            return null;
                                          },
                                          onChanged: (value) {
                                            setState(() {
                                              _description = value;
                                            });
                                          },
                                          onFieldSubmitted: (value) {
                                            FocusScope.of(context).nextFocus();
                                          }),
                                      SizedBox(height: 12),
                                      Text('Event Start Time',
                                          style: Theme.of(context).textTheme.headline3),
                                      DateTimeSelections(
                                          DateTime.now(), setStart, DateTimeModes.CREATE),
                                      SizedBox(height: 12),
                                      Text('Event End Time',
                                          style: Theme.of(context).textTheme.headline3),
                                      DateTimeSelections(
                                          DateTime.now().add(Duration(hours: 1)),
                                          setEnd,
                                          DateTimeModes.CREATE),
                                      SizedBox(height: 12),
                                      Text('Max Attendees',
                                          style: Theme.of(context).textTheme.headline3),
                                      ListTile(
                                        contentPadding: EdgeInsets.all(0),
                                        title: Text('Unlimited'),
                                        leading: Radio(
                                          value: true,
                                          groupValue: noMax,
                                          onChanged: (value) {
                                            setState(() {
                                              noMax = true;
                                              _maxAttendees = null;
                                            });
                                          },
                                        ),
                                      ),
                                      ListTile(
                                          contentPadding: EdgeInsets.all(0),
                                          title: Row(
                                            children: [
                                              Text('Max: '),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: TextFormField(
                                                  initialValue: '10',
                                                  keyboardType: TextInputType.number,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter.digitsOnly
                                                  ],
                                                  validator: (value) {
                                                    if (noMax) return null;
                                                    if (value.isEmpty) {
                                                      return 'Please enter a number.';
                                                    }
                                                    int num = int.parse(value);
                                                    if (num < 2) {
                                                      return 'Must have more than 1 attendee (you count as one).';
                                                    }
                                                    return null;
                                                  },
                                                  decoration: Utils.textFieldDecoration(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _maxAttendees = int.parse(value);
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        leading: Radio(
                                          value: true,
                                          groupValue: !noMax,
                                          onChanged: (value) {
                                            setState(() {
                                              noMax = false;
                                            });
                                          },
                                        ),
                                      ),
                                      Text('Tags',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline3),
                                      SizedBox(height: 4),
                                      Wrap(
                                        children: Utils.allTags.map((tag) {
                                          return ChoiceChip(
                                            label: Text(tag,
                                                style: TextStyle(fontSize: 14)),
                                            selected: _tags.contains(tag),
                                            onSelected: (selected) {
                                              setState(() {
                                                if (selected)
                                                  _tags.add(tag);
                                                else
                                                  _tags.remove(tag);
                                              });
                                            },
                                          );
                                        }).toList(),
                                        spacing: 4,
                                      ),
                                    ])),
                            SizedBox(height: 24),
                          ],
                        ),
                      ),
                      SizedBox(
                          height: 48,
                          width: double.infinity,
                          child: Builder(builder: (context) {
                            return FlatButton(
                                color: Theme.of(context).accentColor,
                                textColor: Colors.white,
                                child: Text("Create Event",
                                    style: TextStyle(fontSize: 18)),
                                onPressed: () async {
                                  DateTime _startTimePlusOneMinute =
                                  _startTime.add(new Duration(minutes: 1));
                                  if (_startTime.isAfter(_endTime)) {
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                        content: Text(
                                            'Start time must be before end time!')));
                                  } else if (!_formKey.currentState.validate()) {
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                        content:
                                        Text('Please fill out all fields!')));
                                  } else if (_startTimePlusOneMinute
                                      .isBefore(DateTime.now())) {
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                        content: Text(
                                            'Start time must be after current time!')));
                                  } else {
                                    DocumentReference doc = await FirebaseFirestore
                                        .instance
                                        .collection('events')
                                        .add({
                                      'title': _title,
                                      'isVirtual': _isVirtual,
                                      'location': _location,
                                      'description': _description,
                                      'organizerID': _organizerID,
                                      'attendees': [_organizerID],
                                      'maxAttendees': _maxAttendees,
                                      'startTime': Timestamp.fromDate(_startTime),
                                      'endTime': Timestamp.fromDate(_endTime),
                                      'tags': _tags,
                                    });
                                    DocumentSnapshot snapshot = await doc.get();
                                    EventUtils.addToCalendar(context, Event.fromDoc(snapshot), _isVirtual);
                                    Navigator.pop(context);
                                  }
                                });
                          })),
                    ],
                  )),
            ])));
  }
}

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

enum DateTimeModes { CREATE, EDIT }

class DateTimeSelections extends StatefulWidget {
  DateTimeSelections(this.init, this.setterCallback, this.mode);
  final DateTime init;
  final Function setterCallback;
  final DateTimeModes mode;

  @override
  _DateTimeSelectionsState createState() => _DateTimeSelectionsState();
}

class _DateTimeSelectionsState extends State<DateTimeSelections> {
  DateTime date;
  TimeOfDay time;
  DateTimeModes mode;

  @override
  void initState() {
    super.initState();
    date = widget.init;
    time = TimeOfDay(hour: widget.init.hour, minute: widget.init.minute);
    mode = widget.mode;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        FlatButton(
            padding: EdgeInsets.only(left: 0),
            child: Row(children: [
              Icon(Icons.calendar_today),
              SizedBox(width: 8),
              Text(
                  DateFormat('E').format(date) +
                      '. ' +
                      DateFormat('MMMMd').format(date),
                  style: Theme.of(context).textTheme.bodyText1),
              Icon(Icons.arrow_drop_down),
            ]),
            onPressed: () async {
              DateTime today = DateTime.now();
              DateTime earlierDate = today.isBefore(date) ? today : date;
              final DateTime selection = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: mode == DateTimeModes.EDIT ? earlierDate : today,
                  lastDate: today.add(new Duration(days: 50)));
              if (selection != null) {
                date = selection;
                widget.setterCallback(selection, time);
              }
            }),
        FlatButton(
          padding: EdgeInsets.only(left: 0),
          child: Row(children: [
            Icon(Icons.access_time),
            SizedBox(width: 8),
            Text(
                DateFormat('jm')
                    .format(DateTime(1, 1, 1, time.hour, time.minute)),
                style: Theme.of(context).textTheme.bodyText1),
            Icon(Icons.arrow_drop_down)
          ]),
          onPressed: () async {
            final TimeOfDay selection =
            await showTimePicker(context: context, initialTime: time);
            if (selection != null) {
              time = selection;
              widget.setterCallback(date, selection);
            }
          },
        )
      ]),
    ]);
  }
}
