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

  TextEditingController firstNameCtrl = TextEditingController();
  TextEditingController lastNameCtrl = TextEditingController();
  TextEditingController majorCtrl = TextEditingController();
  TextEditingController bioCtrl = TextEditingController();
  TextEditingController classCtrl = TextEditingController();

  @override
  initState() {
    super.initState();
    gradYear = years[0];
    f20Status = statuses[0];
    tags = [];
    classes = [];
  }

  Widget _buildNamePage(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Hello!', style: Theme.of(context).textTheme.headline1),
      smallSpacer,
      Text('What should we call you?',
          style: Theme.of(context).textTheme.headline2),
      bigSpacer,
      Text('Hello!', style: Utils.proximaNova),
      smallSpacer,
      TextField(
        decoration: Utils.textFieldDecoration,
        controller: firstNameCtrl,
        onSubmitted: (value) {
          setState(() {
            firstNameCtrl.text = value;
          });
        },
      ),
      bigSpacer,
      Text('Last name'),
      smallSpacer,
      TextField(
        decoration: Utils.textFieldDecoration,
        controller: lastNameCtrl,
        onSubmitted: (value) {
          setState(() {
            lastNameCtrl.text = value;
          });
        },
      ),
    ]);
  }

  Widget _buildInfoPage(BuildContext context) {
    return ListView(shrinkWrap: true, children: [
      Text('A bit about you', style: Theme.of(context).textTheme.headline1),
      smallSpacer,
      Text('These will be shown on your profile for others to get to know you!',
          style: Theme.of(context).textTheme.headline2),
      bigSpacer,
      Text('Intended major'),
      smallSpacer,
      TextField(
        decoration: Utils.textFieldDecoration,
        controller: majorCtrl,
        onSubmitted: (value) {
          setState(() {
            majorCtrl.text = value;
          });
        },
      ),
      bigSpacer,
      Text('Graduation year'),
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
      bigSpacer,
      Text('Fall 2020 status'),
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
      bigSpacer,
      Text('A short bio'),
      smallSpacer,
      TextField(
        decoration: Utils.textFieldDecoration,
        controller: bioCtrl,
        onSubmitted: (value) {
          setState(() {
            bioCtrl.text = value;
          });
        },
      ),
    ]);
  }

  Widget _buildSocialMediaPage(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        Row(children: [
          Text("Back"),
          Spacer(),
          Text("Skip"),
        ],)
        Text("Let's get connected!",
            style: Theme.of(context).textTheme.headline2)
      ],
    );
  }

  Widget _buildEventPage(BuildContext context) {
    String inPersonTag = 'in-person';
    String virtualTag = 'virtual';
    List<String> allTags = [
      'video games',
      'board games',
      'music',
      'tv show',
      'movies',
      'study group',
      'making friends'
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('What kinds of events are you interested in?',
          style: Theme.of(context).textTheme.headline1),
      smallSpacer,
      Text('We\'ll recommend events for you based on your preferences!',
          style: Theme.of(context).textTheme.headline2),
      bigSpacer,
      Text('Type'),
      smallSpacer,
      CheckboxListTile(
        title: Text('In-person (with social distancing)'),
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
        title: Text('Virtual'),
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
      Text('Activities'),
      Wrap(
        children: allTags.map((tag) {
          return ChoiceChip(
            label: Text(tag),
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
          style: Theme.of(context).textTheme.headline2),
      bigSpacer,
      Text('Classes'),
      ListView.builder(
          shrinkWrap: true,
          itemCount: classes.length,
          itemBuilder: (context, index) {
            return Row(children: [
              Text(classes[index]),
              Spacer(),
              IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      classes.removeAt(index);
                    });
                  })
            ]);
          }),
      TextField(
        controller: classCtrl,
        decoration: InputDecoration(hintText: 'Add a class'),
        onSubmitted: (input) {
          setState(() {
            classes.add(input);
            classCtrl.clear();
          });
        },
      )
    ]);
  }

  Widget _buildProgress(int currentIndex, int total) {
    Widget back = FlatButton(
        child: Row(children: [
          Icon(Icons.arrow_left),
          SizedBox(width: 4),
          Text('Back')
        ]),
        onPressed: () {
          setState(() {
            pageIndex--;
          });
        });

    Widget next = Builder(builder: (context) {
      return FlatButton(
        child: Row(children: [
          Text('Next'),
          SizedBox(width: 4),
          Icon(Icons.arrow_right)
        ]),
        onPressed: () {
          bool valid = true;
          switch (currentIndex) {
            case 0:
              if (firstNameCtrl.text == null ||
                  firstNameCtrl.text.isEmpty ||
                  lastNameCtrl.text == null ||
                  lastNameCtrl.text.isEmpty) {
                valid = false;
                Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('Please enter your first and last name!')));
              }
              break;
            case 1:
              if (majorCtrl.text == null || majorCtrl.text.isEmpty) {
                valid = false;
                Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'Please enter your major, feel free to put \'Undecided\' if you\'re unsure!')));
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
      );
    });

    Widget dots = Row(
        children: List<Widget>.generate(total, (index) {
      return Padding(
        padding: EdgeInsets.only(left: 3, right: 3),
        child: Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentIndex == index ? Colors.black : Colors.grey,
            )),
      );
    }));

    List<Widget> children = [];
    if (currentIndex != 0) {
      children.add(back);
    }
    children.add(Padding(
      padding: const EdgeInsets.only(left: 24, right: 24),
      child: dots,
    ));
    if (currentIndex != total - 1) {
      children.add(next);
    } else {
      children.add(FlatButton(
        child: Text('Finish'),
        onPressed: () {
          String userID =
              Provider.of<CurrentUserInfo>(context, listen: false).id;
          User user = FirebaseAuth.instance.currentUser;
          FirebaseFirestore.instance.collection('users').doc(userID).set({
            'firstName': firstNameCtrl.text,
            'lastName': lastNameCtrl.text,
            'bio': bioCtrl.text,
            'status': f20Status,
            'photoURL': user.photoURL,
            'major': majorCtrl.text,
            'classYear': gradYear,
            'classes': classes,
            'interestedTags': tags,
            'events': []
          });
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => MainPage()));
        },
      ));
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: children);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      _buildNamePage(context),
      _buildInfoPage(context),
      _buildEventPage(context),
      _buildClassPage(context)
    ];

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(children: [
            pages[pageIndex],
            Spacer(),
            _buildProgress(pageIndex, pages.length)
          ]),
        )));
  }
}
