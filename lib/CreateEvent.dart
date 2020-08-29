import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'Event.dart';
import 'Login.dart';

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
  TextEditingController _tagCtrl = TextEditingController();
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
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ),
                  Expanded(
                    child: ListView(
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
                                  decoration: InputDecoration(
                                      hintText: 'PowerPoint Palooza Spectacular'),
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
                                if (_isVirtual)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                        'Optional, leave blank to generate Google Meet URL'),
                                  ),
                                TextFormField(
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (_isVirtual && value.isEmpty) {
                                      return 'Please enter a location.';
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
                                  decoration: InputDecoration(
                                      hintText: _type == Event.appOptions[0]
                                          ? 'example.com'
                                          : 'Arts Quad'),
                                ),
                                SizedBox(height: 12),
                                Text("Description",
                                    style: Theme.of(context).textTheme.headline3),
                                TextFormField(
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                        hintText:
                                        'Come hang out with me! I\'m very cool and fun.'),
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
                                DateTimeSelections(DateTime.now(), setStart),
                                SizedBox(height: 12),
                                Text('Event End Time',
                                    style: Theme.of(context).textTheme.headline3),
                                DateTimeSelections(
                                    DateTime.now().add(Duration(hours: 1)), setEnd),
                                SizedBox(height: 12),
                                Text('Max Attendees',
                                    style: Theme.of(context).textTheme.headline3),
                                ListTile(
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
                                  title: Row(children: [
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
                                        onChanged: (value) {
                                          setState(() {
                                            _maxAttendees = int.parse(value);
                                          });
                                        },
                                      ),
                                    )
                                  ]),
                                  leading: Radio(
                                    value: false,
                                    groupValue: noMax,
                                    onChanged: (value) {
                                      setState(() {
                                        noMax = false;
                                        _maxAttendees = null;
                                      });
                                    },
                                  ),
                                ),
                                Text('Tags',
                                    style: Theme.of(context).textTheme.headline3),
                                SizedBox(height: 4),
                                Text(
                                    'Hit enter after each tag, tap on a tag to delete it'),
                                TextFormField(
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(hintText: 'video games'),
                                  controller: _tagCtrl,
                                  onFieldSubmitted: (input) {
                                    setState(() {
                                      _tags.add(input);
                                      _tagCtrl.clear();
                                    });
                                  },
                                ),
                                SizedBox(height: 12),
                                Wrap(
                                    children: _tags
                                        .map((tag) => InputChip(
                                        label: Text(tag),
                                        onPressed: () {
                                          setState(() {
                                            _tags.remove(tag);
                                          });
                                        }))
                                        .toList(),
                                    spacing: 8)
                              ],
                            )),
                        SizedBox(height: 12),
                        SizedBox(
                          height: 48,
                          width: double.infinity,
                          child: Builder(builder: (context) {
                            return FlatButton(
                                color: Theme.of(context).accentColor,
                                textColor: Colors.white,
                                child: Text("Create Event",
                                    style: TextStyle(fontSize: 18)),
                                onPressed: () {
                                  if (_startTime.isAfter(_endTime)) {
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                        content: Text(
                                            'Start time must be before end time!')));
                                  } else if (_formKey.currentState.validate()) {
                                    FirebaseFirestore.instance
                                        .collection('events')
                                        .add({
                                      'title': _title,
                                      'isVirtual': _isVirtual,
                                      'location': _location,
                                      'attendees': [_organizerID],
                                      'description': _description,
                                      'endTime': Timestamp.fromDate(_endTime),
                                      'maxAttendees': _maxAttendees,
                                      'organizerID': _organizerID,
                                      'startTime': Timestamp.fromDate(_startTime),
                                      'tags': _tags,
                                    });
                                    Navigator.pop(context);
                                  }
                                });
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ));
  }
}

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class DateTimeSelections extends StatefulWidget {
  DateTimeSelections(this.init, this.setterCallback);
  final DateTime init;
  final Function setterCallback;

  @override
  _DateTimeSelectionsState createState() => _DateTimeSelectionsState();
}

class _DateTimeSelectionsState extends State<DateTimeSelections> {
  DateTime date;
  TimeOfDay time;

  @override
  void initState() {
    super.initState();
    date = widget.init;
    time = TimeOfDay(hour: widget.init.hour, minute: widget.init.minute);
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
              final DateTime selection = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: today,
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
