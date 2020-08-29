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
  String firstName;
  String lastName;
  String major;
  String bio;
  String f20Status;
  String instagramUser;
  String facebookUser;
  String linkedinUser;
  List<String> tags;
  List<String> classes;

  int pageIndex = 0;
  Widget smallSpacer = SizedBox(height: 8);
  Widget bigSpacer = SizedBox(height: 24);

  FocusNode _focusNodeBuildName;
  FocusNode _focusNodeSocial;

  @override
  initState() {
    super.initState();
    gradYear = years[0];
    f20Status = statuses[0];
    tags = [];
    classes = [];
    _focusNodeBuildName = FocusNode();
    _focusNodeSocial = FocusNode();
  }

  @override
  void dispose() {
    _focusNodeBuildName.dispose();
    _focusNodeSocial.dispose();
    super.dispose();
  }

  Widget _buildNamePage(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Hello!', style: Theme.of(context).textTheme.headline1),
      smallSpacer,
      Text('What should we call you?',
          style: Theme.of(context).textTheme.headline2),
      bigSpacer,
      Text('First name', style: Theme.of(context).textTheme.headline3),
      smallSpacer,
      TextFormField(
        decoration: Utils.textFieldDecoration(),
        focusNode: _focusNodeBuildName,
        textInputAction: TextInputAction.next,
        onChanged: (value) {
          setState(() {
            firstName = value;
          });
        },
        onFieldSubmitted: (value) => FocusScope.of(context).nextFocus(),
      ),
      bigSpacer,
      Text('Last name', style: Theme.of(context).textTheme.headline3),
      TextFormField(
        decoration: Utils.textFieldDecoration(),
        textInputAction: TextInputAction.next,
        onChanged: (value) {
          setState(() {
            lastName = value;
          });
        },
        onFieldSubmitted: (value) => FocusScope.of(context).nextFocus(),
      ),
      smallSpacer,
    ]);
  }

  Widget _buildInfoPage(BuildContext context) {
    return ListView(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
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
            decoration: Utils.textFieldDecoration(hint: "Information Science"),
            // textInputAction: TextInputAction.next,
            onChanged: (value) {
              setState(() {
                major = value;
              });
            },
          ),
          smallSpacer,
          Text('Graduation year', style: Theme.of(context).textTheme.headline3),
          smallSpacer,
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
          smallSpacer,
          Text('Fall 2020 status',
              style: Theme.of(context).textTheme.headline3),
          smallSpacer,
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
          smallSpacer,
          Text('Introduce yourself!',
              style: Theme.of(context).textTheme.headline3),
          smallSpacer,
          TextFormField(
            decoration: Utils.textFieldDecoration(
                hint: "Tell me a bit about yourself!"),
            onChanged: (value) {
              setState(() {
                bio = value;
              });
            },
          ),
        ]);
  }

  Widget _buildSocialMediaRow(String platform, Function callback,
      // ignore: avoid_init_to_null
      {socialFocusNode: null}) {
    double imageSize = 30;
    return Row(children: [
      Image.asset('assets/${platform.toLowerCase()}_logo.png',
          width: imageSize),
      SizedBox(width: 16),
      Flexible(
        child: TextFormField(
          decoration:
              Utils.textFieldDecoration(hint: 'Enter $platform username'),
          onChanged: (input) {
            callback(input);
          },
          onFieldSubmitted: (value) => FocusScope.of(context).nextFocus(),
          textInputAction: TextInputAction.next,
          focusNode: socialFocusNode,
        ),
      )
    ]);
  }

  Widget _buildSocialMediaPage(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          'Instagram',
          (input) => setState(() {
                instagramUser = input;
              }),
          socialFocusNode: _focusNodeSocial),
      smallSpacer,
      _buildSocialMediaRow(
          'Facebook',
          (input) => setState(() {
                facebookUser = input;
              })),
      smallSpacer,
      _buildSocialMediaRow(
          'LinkedIn',
          (input) => setState(() {
                linkedinUser = input;
              })),
    ]);
  } // end of fun

  Widget _buildEventPage(BuildContext context) {
    String inPersonTag = 'in-person';
    String virtualTag = 'virtual';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
    ]);
  }

  Widget _buildClassPage(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('What classes are you taking?',
          style: Theme.of(context).textTheme.headline1),
      smallSpacer,
      Text('We\'ll show you study groups for the classes you\'re taking!',
          style: Theme.of(context).textTheme.subtitle2),
      bigSpacer,
      Text('Enter Classes', style: Theme.of(context).textTheme.headline3),
      smallSpacer,
      TextFormField(
        decoration: Utils.textFieldDecoration(hint: 'Add a class'),
        onFieldSubmitted: (input) {
          setState(() {
            classes.add(input);
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
    ]);
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
        }));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      _buildNamePage(context),
      _buildInfoPage(context),
      _buildSocialMediaPage(context),
      _buildEventPage(context),
      _buildClassPage(context)
    ];

    Widget backButton = FlatButton(
        child: Text('Back', style: TextStyle(fontSize: 16)),
        onPressed: () {
          setState(() {
            pageIndex--;
          });
        });

    Widget skipButton = FlatButton(
        child: Text('Skip', style: TextStyle(fontSize: 16)),
        onPressed: () {
          setState(() {
            facebookUser = "";
            instagramUser = "";
            linkedinUser = "";
            pageIndex++;
          });
        });

    Widget nextButton = Builder(builder: (context) {
      return SizedBox(
        width: double.infinity,
        child: FlatButton(
          child: Text('Next', style: TextStyle(fontSize: 16)),
          color: Theme.of(context).accentColor,
          textColor: Colors.white,
          onPressed: () {
            bool valid = true;
            switch (pageIndex) {
              case 0:
                String snackBarPrompt = "";
                if (firstName == null || firstName.isEmpty) {
                  snackBarPrompt += "Please enter your first name!\n";
                }
                if (lastName == null || lastName.isEmpty) {
                  snackBarPrompt += "Please enter your last name!";
                }
                if (snackBarPrompt.isNotEmpty) {
                  valid = false;
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text(snackBarPrompt)));
                }
                break;
              case 1:
                String snackBarPrompt = "";
                if (major == null || major.isEmpty) {
                  snackBarPrompt +=
                      'Please enter your major, feel free to put \'Undecided\' if you\'re unsure!\n';
                } else if (bio == null || bio.isEmpty) {
                  snackBarPrompt += 'Please enter a short bio!';
                }
                if (snackBarPrompt.isNotEmpty) {
                  valid = false;
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text(snackBarPrompt)));
                }
                break;
              default:
                break;
            }
            if (valid) {
              setState(() {
                pageIndex++;
              });
            }
          },
        ),
      );
    });

    Widget finishButton = SizedBox(
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
              'firstName': firstName,
              'lastName': lastName,
              'bio': bio,
              'status': f20Status,
              'photoURL': user.photoURL,
              'major': major,
              'classYear': gradYear,
              'classes': classes,
              'interestedTags': tags,
              'events': [],
              'instagramUser': instagramUser,
              'facebookUser': facebookUser,
              'linkedinUser': linkedinUser
            });
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MainPage()));
          },
        ));

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pageIndex > 0)
              Row(children: [
                backButton,
                if (pageIndex == 2) Spacer(),
                if (pageIndex == 2) skipButton
              ]),
            Padding(
              padding: pageIndex == 0
                  ? const EdgeInsets.all(32)
                  : const EdgeInsets.only(left: 32, right: 32),
              child: pages[pageIndex],
            ),
            Spacer(),
            _buildProgress(pageIndex, pages.length),
            SizedBox(height: 24),
            SizedBox(
                height: 48,
                width: double.infinity,
                child:
                    pageIndex == pages.length - 1 ? finishButton : nextButton)
          ],
        )));
  }
}
