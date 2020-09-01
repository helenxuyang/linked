import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Login.dart';
import 'main.dart';
import 'Utils.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  List<int> years = [for (int i = 2020; i < 2027; i++) i];
  int gradYear;
  List<String> statuses = [
    'Living on-campus',
    'Living off-campus in Ithaca',
    'Living outside of Ithaca'
  ];

  String f20Status;
  List<String> tags;
  List<String> classes;

  int pageIndex = 0;
  Widget smallSpacer = SizedBox(height: 8);
  Widget bigSpacer = SizedBox(height: 24);

  FocusNode _focusNodeBuildName;
  FocusNode _focusNodeSocial;

  TextEditingController _firstNameCtrl;
  TextEditingController _lastNameCtrl;
  TextEditingController _majorCtrl;
  TextEditingController _bioCtrl;
  TextEditingController _instagramUserCtrl;
  TextEditingController _facebookUserCtrl;
  TextEditingController _linkedinUserCtrl;
  TextEditingController _classCtrl;

  @override
  initState() {
    super.initState();
    gradYear = years[0];
    f20Status = statuses[0];
    tags = [];
    classes = [];
    _focusNodeBuildName = FocusNode();
    _focusNodeSocial = FocusNode();
    _firstNameCtrl = TextEditingController();
    _lastNameCtrl = TextEditingController();
    _majorCtrl = TextEditingController();
    _bioCtrl = TextEditingController();
    _instagramUserCtrl = TextEditingController();
    _facebookUserCtrl = TextEditingController();
    _linkedinUserCtrl = TextEditingController();
    _classCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _focusNodeBuildName.dispose();
    _focusNodeSocial.dispose();
    super.dispose();
  }

  Widget _buildNamePage(BuildContext context, GlobalKey<FormState> key) {
    return Form(
      key: key,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello!', style: Theme.of(context).textTheme.headline1),
            smallSpacer,
            Text('What should we call you?',
                style: Theme.of(context).textTheme.headline2),
            bigSpacer,
            Text('First name', style: Theme.of(context).textTheme.headline3),
            smallSpacer,
            TextFormField(
                controller: _firstNameCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: Utils.textFieldDecoration(),
                focusNode: _focusNodeBuildName,
                textInputAction: TextInputAction.next,
                validator: (input) {
                  if (input.isEmpty) {
                    return 'Please enter your first name!';
                  }
                  return null;
                },
                onFieldSubmitted: (value) => FocusScope.of(context).nextFocus()
            ),
            bigSpacer,
            Text('Last name', style: Theme.of(context).textTheme.headline3),
            TextFormField(
              controller: _lastNameCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: Utils.textFieldDecoration(),
              textInputAction: TextInputAction.done,
              validator: (input) {
                if (input.isEmpty) {
                  return 'Please enter your last name!';
                }
                return null;
              },
            ),
          ]),
    );
  }

  Widget _buildInfoPage(BuildContext context, GlobalKey<FormState> key) {
    return Form(
      key: key,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A bit about you', style: Theme.of(context).textTheme.headline1),
            smallSpacer,
            Text(
                'These will be shown on your profile for others to get to know you!',
                style: Theme.of(context).textTheme.subtitle2),
            bigSpacer,
            Text('Intended major', style: Theme.of(context).textTheme.headline3),
            smallSpacer,
            TextFormField(
              controller: _majorCtrl,
              decoration: Utils.textFieldDecoration(hint: "Information Science"),
              // textInputAction: TextInputAction.next,
              validator: (input) {
                if (input.isEmpty) {
                  return 'Please enter your major!';
                }
                return null;
              },
            ),
            bigSpacer,
            Text('Graduation year', style: Theme.of(context).textTheme.headline3),
            DropdownButton(
              value: gradYear,
              items: years
                  .map((year) =>
                  DropdownMenuItem(child: Text(year.toString()), value: year))
                  .toList(),
              onChanged: (selection) {
                setState(() {
                  gradYear = selection;
                });
              },
            ),
            bigSpacer,
            Text('Fall 2020 status',
                style: Theme.of(context).textTheme.headline3),
            DropdownButton(
              value: f20Status,
              items: statuses
                  .map((str) => DropdownMenuItem(
                child: Text(str),
                value: str,
              ))
                  .toList(),
              onChanged: (selection) {
                setState(() {
                  f20Status = selection;
                });
              },
            ),
            bigSpacer,
            Text('Introduce yourself!',
                style: Theme.of(context).textTheme.headline3),
            smallSpacer,
            TextFormField(
              controller: _bioCtrl,
              maxLength: 200,
              textInputAction: TextInputAction.done,
              maxLines: null,
              decoration: Utils.textFieldDecoration(
                  hint: "Tell us a bit about yourself!"),
              validator: (input) {
                if (input.isEmpty) {
                  return 'Please enter a short bio!';
                }
                return null;
              },
            ),
          ]
      ),
    );
  }

  Widget _buildSocialMediaRow(String platform) {
    double imageSize = 30;
    return Row(children: [
      Image.asset('assets/${platform.toLowerCase()}_logo.png',
          width: imageSize),
      SizedBox(width: 16),
      Flexible(
        child: TextFormField(
          decoration:
          Utils.textFieldDecoration(hint: 'Enter $platform username'),
          onFieldSubmitted: (value) => FocusScope.of(context).nextFocus(),
          textInputAction: TextInputAction.next,
        ),
      )
    ]);
  }

  Widget _buildSocialMediaPage(BuildContext context, GlobalKey<FormState> key) {
    return Form(
      key: key,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bigSpacer,
            Text("Let's get connected!",
                style: Theme.of(context).textTheme.headline1),
            smallSpacer,
            Text(
              "Enter your social platform usernames so that people you meet can connect with you after events!",
              style: Theme.of(context).textTheme.headline3,
            ),
            bigSpacer,
            _buildSocialMediaRow(
                'Instagram'),
            smallSpacer,
            _buildSocialMediaRow(
              'Facebook',
            ),
            smallSpacer,
            _buildSocialMediaRow(
              'LinkedIn',
            ),
          ]),
    );
  } // end of fun

  Widget _buildEventPage(BuildContext context, GlobalKey<FormState> key) {
    String inPersonTag = 'in-person';
    String virtualTag = 'virtual';

    return Form(
      key: key,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What events are you interested in?',
                style: Theme.of(context).textTheme.headline1),
            smallSpacer,
            Text('We\'ll recommend events for you based on your preferences!',
                style: Theme.of(context).textTheme.subtitle2),
            bigSpacer,
            Text('Type', style: Theme.of(context).textTheme.headline3),
            smallSpacer,
            CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.all(0),
              title: Text('In-person (with social distancing)',
                  style: TextStyle(fontSize: 16)),
              value: tags.contains(inPersonTag),
              onChanged: (value) {
                setState(() {
                  if (value)
                    tags.add(inPersonTag);
                  else
                    tags.remove(inPersonTag);
                });
              },
            ),
            CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.all(0),
              title: Text('Virtual', style: TextStyle(fontSize: 16)),
              value: tags.contains(virtualTag),
              onChanged: (value) {
                setState(() {
                  if (value)
                    tags.add(virtualTag);
                  else
                    tags.remove(virtualTag);
                });
              },
            ),
            bigSpacer,
            Text('Activities', style: Theme.of(context).textTheme.headline3),
            Wrap(
              children: Utils.allTags.map((tag) {
                return ChoiceChip(
                  label: Text(tag, style: TextStyle(fontSize: 14)),
                  selected: tags.contains(tag),
                  onSelected: (selected) {
                    setState(() {
                      if (selected)
                        tags.add(tag);
                      else
                        tags.remove(tag);
                    });
                  },
                );
              }).toList(),
              spacing: 4,
            )
          ]),
    );
  }

  Widget _buildClassPage(BuildContext context, GlobalKey<FormState> key) {
    return Form(
      key: key,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What classes are you taking?',
                style: Theme.of(context).textTheme.headline1),
            smallSpacer,
            Text('We\'ll show you study groups for the classes you\'re taking!',
                style: Theme.of(context).textTheme.subtitle2),
            bigSpacer,
            Text('Enter Classes', style: Theme.of(context).textTheme.headline3),
            smallSpacer,
            TextFormField(
              controller: _classCtrl,
              decoration: Utils.textFieldDecoration(hint: 'Add a class'),
              onFieldSubmitted: (input) {
                setState(() {
                  classes.add(input);
                  _classCtrl.clear();
                });
              },
            ),
            Wrap(
              children: classes.map((name) {
                return ChoiceChip(
                  label: Text(name, style: TextStyle(fontSize: 14)),
                  selected: classes.contains(name),
                  onSelected: (selected) {
                    setState(() {
                      if (selected)
                        classes.add(name);
                      else
                        classes.remove(name);
                    });
                  },
                );
              }).toList(),
              spacing: 4,
            )
          ]),
    );
  }

  Widget _buildProgress(int currentIndex, int total) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List<Widget>.generate(total, (index) {
          return Padding(
            padding: EdgeInsets.only(left: 3, right: 3),
            child: Container(
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentIndex == index
                      ? Colors.black
                      : Color.fromRGBO(0xC4, 0xC4, 0xC4, 1.0),
                )),
          );
        })
    );
  }

  Widget _buildBackButton() {
    return FlatButton(
        child: Text('Back', style: TextStyle(fontSize: 16)),
        onPressed: () {
          setState(() {
            pageIndex--;
          });
        }
    );
  }

  Widget _buildSkipButton() {
    return FlatButton(
        child: Text('Skip', style: TextStyle(fontSize: 16)),
        onPressed: () {
          setState(() {
            pageIndex++;
          });
        }
    );
  }

  Widget _buildNextButton(GlobalKey<FormState> formKey) {
    return Builder(
        builder: (context) {
          return SizedBox(
            width: double.infinity,
            child: FlatButton(
              child: Text('Next', style: TextStyle(fontSize: 16)),
              color: Theme
                  .of(context)
                  .accentColor,
              textColor: Colors.white,
              onPressed: () {
                if (formKey.currentState.validate()) {
                  setState(() {
                    pageIndex++;
                  });
                }
              },
            ),
          );
        });
  }

  Widget _buildFinishButton(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        height: 48,
        child: FlatButton(
          child: Text('Finish', style: TextStyle(fontSize: 16)),
          color: Theme.of(context).accentColor,
          textColor: Colors.white,
          onPressed: () {
            String userID =
                Provider.of<CurrentUserInfo>(context, listen: false).id;
            User user = FirebaseAuth.instance.currentUser;
            FirebaseFirestore.instance.collection('users').doc(userID).set({
              'firstName': _firstNameCtrl.text,
              'lastName': _lastNameCtrl.text,
              'bio': _bioCtrl.text,
              'status': f20Status,
              'photoURL': user.photoURL,
              'major': _majorCtrl.text,
              'classYear': gradYear,
              'classes': classes,
              'interestedTags': tags,
              'events': [],
              'instagramUser': _instagramUserCtrl.text,
              'facebookUser': _facebookUserCtrl.text,
              'linkedinUser': _linkedinUserCtrl.text
            });
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MainPage()));
          },
        )
    );
  }

  ScrollController scrollCtrl = ScrollController();
  bool fitsOnScreen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        fitsOnScreen = (scrollCtrl.position.maxScrollExtent == 0);
      });
    });
  }

  List<GlobalKey<FormState>> keys = List.filled(5, GlobalKey<FormState>());
  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      _buildNamePage(context, keys[0]),
      _buildInfoPage(context, keys[1]),
      _buildSocialMediaPage(context, keys[2]),
      _buildEventPage(context, keys[3]),
      _buildClassPage(context, keys[4])
    ];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              if (pageIndex > 0)
                Row(children: [
                  _buildBackButton(),
                  if (pageIndex == 2) Spacer(),
                  if (pageIndex == 2) _buildSkipButton()
                ]),
              Padding(
                padding: pageIndex == 0
                    ? const EdgeInsets.all(32)
                    : const EdgeInsets.only(left: 32, right: 32),
                child: pages[pageIndex],
              ),
              SizedBox(height: 24),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                      children: [
                        _buildProgress(pageIndex, pages.length),
                        SizedBox(height: 24),
                        SizedBox(
                            height: 48,
                            width: MediaQuery.of(context).size.width,
                            child: pageIndex == pages.length - 1 ? _buildFinishButton(context) : _buildNextButton(keys[pageIndex])
                        )
                      ]
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}
