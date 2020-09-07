import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'Event.dart';
import 'Login.dart';
import 'Utils.dart';
import 'CreateEvent.dart';
import 'dart:developer';

class _EditEventPageState extends State<EditEventPage> {
  // misc
  // TextEditingController _titleController;
  // TextEditingController _locationController;
  TextEditingController _maxAttendeeNumController;

  _EditEventPageState(this._origEvent);
  // Event fields
  final Event _origEvent;
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
    log("origEvent: ${_origEvent.maxAttendees}");
    // _titleController = TextEditingController(text: _origEvent.title);
    // _locationController = TextEditingController(text: _origEvent.location);
    _maxAttendeeNumController = TextEditingController(
        text: _origEvent.maxAttendees == null
            ? "10"
            : "${_origEvent.maxAttendees}");
    _title = _origEvent.title;
    _location = _origEvent.location;
    _type = _origEvent.isVirtual ? Event.appOptions[0] : Event.appOptions[1];
    _isVirtual = _origEvent.isVirtual;
    _description = _origEvent.description;
    _startTime = _origEvent.startTime;
    _endTime = _origEvent.endTime;
    _maxAttendees = _origEvent.maxAttendees;
    _tags = _origEvent.tags;
    noMax = _origEvent.maxAttendees == null;
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
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                children: [
                  Text("Edit Event",
                      style: Theme.of(context).textTheme.headline1),
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
                            initialValue: _title,
                            // controller: _titleController,
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
                              initialValue: _location,
                              // controller: _locationController,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value.isEmpty) {
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
                              decoration: Utils.textFieldDecoration()),
                          SizedBox(height: 12),
                          Text("Description",
                              style: Theme.of(context).textTheme.headline3),
                          TextFormField(
                              initialValue: _description,
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
                              _startTime, setStart, DateTimeModes.EDIT),
                          SizedBox(height: 12),
                          Text('Event End Time',
                              style: Theme.of(context).textTheme.headline3),
                          DateTimeSelections(
                              _endTime, setEnd, DateTimeModes.EDIT),
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
                                  log("max Attendees = $_maxAttendees");
                                });
                              },
                            ),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.all(0),
                            title: Row(children: [
                              Text('Max: '),
                              SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: _maxAttendeeNumController,
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
                                      noMax = false;
                                      _maxAttendees = int.tryParse(
                                          _maxAttendeeNumController.text);
                                      log("${_maxAttendeeNumController.text}");
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
                                  log("$value ; ${_maxAttendeeNumController.text}");
                                  _maxAttendees = int.tryParse(
                                      _maxAttendeeNumController.text);
                                });
                              },
                            ),
                          ),
                          Text('Tags',
                              style: Theme.of(context).textTheme.headline3),
                          SizedBox(height: 4),
                          Wrap(
                            children: Utils.allTags.map((tag) {
                              return ChoiceChip(
                                label:
                                    Text(tag, style: TextStyle(fontSize: 14)),
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
                          )
                        ],
                      )),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: Builder(builder: (context) {
              return FlatButton(
                  color: Theme.of(context).accentColor,
                  textColor: Colors.white,
                  child: Text("Edit Event", style: TextStyle(fontSize: 18)),
                  onPressed: () {
                    if (_startTime.isAfter(_endTime)) {
                      Scaffold.of(context).showSnackBar(SnackBar(
                          content:
                              Text('Start time must be before end time!')));
                    } else if (!_formKey.currentState.validate()) {
                      Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text('Please fill out all fields!')));
                    } else {
                      FirebaseFirestore.instance
                          .collection('events')
                          .doc(_origEvent.eventID)
                          .set({
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
                      Event modifiedEvent = new Event(_origEvent.eventID, _title, _isVirtual, _location, _description, _organizerID, _startTime, _endTime, _origEvent.attendeeIDs, _maxAttendees, _tags);
                      log("max Attendees = $_maxAttendees");
                      EventUtils.addToCalendar(_organizerID, context, modifiedEvent, _isVirtual);
                      Navigator.pop(context);
                    }
                  });
            }),
          ),
        ],
      )),
    );
  }
}

class EditEventPage extends StatefulWidget {
  EditEventPage(this._origEvent);
  final Event _origEvent;
  @override
  _EditEventPageState createState() => _EditEventPageState(_origEvent);
}
