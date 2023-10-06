import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/screens/Home.dart';
import 'package:kaliallendatingapp/widgets/Prompts.dart';
import 'package:kaliallendatingapp/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../widgets/PillButton.dart';
import '../widgets/StyledButton.dart';

class EditProfile extends StatefulWidget {
  final String? currentUserId;

  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  UserData? userData;

  TextEditingController bioController = TextEditingController();
  TextEditingController occupationController = TextEditingController();
  TextEditingController educationController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  bool _occupationValid = true;
  bool _educationValid = true;
  bool _locationValid = true;
  String chosen_prompt = "Chosen Prompt";

  getUser() async {
    setState(() {
      isLoading = true;
    });
    print('widget.currentUserId is ${widget.currentUserId}');
    //2) Begin by getting doc from uid and saving it into userData
    DocumentSnapshot doc = await usersRef.doc(widget.currentUserId).get();
    userData = UserData.fromDocument(doc);

    userData!.occupation != null
        ? occupationController.text = userData!.occupation!
        : occupationController.text = '';
    userData!.education != null
        ? educationController.text = userData!.education!
        : educationController.text = '';
    userData!.bio != null
        ? bioController.text = userData!.bio!
        : bioController.text = '';
    userData!.location != null
        ? locationController.text = userData!.location!
        : locationController.text = '';
    //3. Change all the controllers to have existing info inputted
    // userData.education != null? educationController.text = userData.education!: print('education is null');
    setState(() {
      isLoading = false;
    });
  }

  Column buildOccupationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job',
          style: TextStyle(color: Colors.grey),
        ),
        TextField(
            controller: occupationController,
            decoration: InputDecoration(
                hintText: 'Update Job',
                errorText: _occupationValid ? null : 'Job field empty'))
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bio',
          style: TextStyle(color: Colors.grey),
        ),
        TextField(
          controller: bioController,
          maxLines: 10,
          minLines: 4,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Update Bio',
              errorText: _occupationValid ? null : 'Bio is empty'),
        )
      ],
    );
  }

  Column buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(color: Colors.grey),
        ),
        TextField(
          controller: locationController,
          decoration: InputDecoration(
            hintText: 'Update Location',
            errorText: _locationValid ? null : 'Location field empty',
          ),
        ),
      ],
    );
  }

  Column buildEducationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'School',
          style: TextStyle(color: Colors.grey),
        ),
        TextField(
          controller: educationController,
          decoration: InputDecoration(
            hintText: 'Update School',
            errorText: _educationValid ? null : 'Education field empty',
          ),
        ),
      ],
    );
  }

  Column buildDatingField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Relationship Status', style: TextStyle(color: kLightDark)),
        Wrap(
          children: [
            PillButton(
              isSelected: true,
              text: 'Dating',
              onTap: () {},
            ),
            PillButton(
              isSelected: false,
              text: 'Not Dating',
              onTap: () {},
            ),
            PillButton(
              isSelected: false,
              text: 'In a Relationship',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Column buildInterestedInField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Interested In', style: TextStyle(color: kLightDark)),
        Wrap(
          children: [
            PillButton(
              isSelected: true,
              text: 'Men',
              onTap: () {},
            ),
            PillButton(
              isSelected: false,
              text: 'Women',
              onTap: () {},
            ),
            PillButton(
              isSelected: false,
              text: 'Both',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  updateProfileData() {
    //4) Validate Text before you are allowed to update them
    setState(() {
      occupationController.text.trim().isEmpty
          ? _occupationValid = false
          : _occupationValid = true;
      educationController.text.trim().isEmpty
          ? _educationValid = false
          : _educationValid = true;
      locationController.text.trim().isEmpty
          ? _locationValid = false
          : _locationValid = true;

      if (_occupationValid && _educationValid) {
        usersRef.doc(widget.currentUserId).update({
          'occupation': occupationController.text.trim(),
          'education': educationController.text.trim(),
          'location' : locationController.text.trim(),
          'bio': bioController.text.trim(),
        });
        //6)
        SnackBar snackBar = SnackBar(content: Text('Profile updated!'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        // _scaffoldKey.currentState.showSnackBar(snackBar);
        ;
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      }
    });

    //5) UPDATE ERROR TEXT!!! Change in each buildField function...
  }

  @override
  void initState() {
    super.initState();
    //1. Need to get the user's info just once using user's ID.

    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Edit Profile',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: isLoading
            ? circularProgress()
            : Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView(
                  children: [
                    Column(
                      children: [
                        Text(
                          '${userData?.firstName}',
                          style: kHeyKaliText,
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * .01),
                        CircleAvatar(
                          radius: MediaQuery.of(context).size.width * .4,
                          backgroundImage:
                              CachedNetworkImageProvider(userData!.picture1!),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildBioField(),
                            SizedBox(height: MediaQuery.of(context).size.height * .01),
                            buildLocationField(),
                            SizedBox(height: MediaQuery.of(context).size.height * .01),
                            buildEducationField(),
                            SizedBox(height: MediaQuery.of(context).size.height * .01),
                            buildOccupationField(),
                            SizedBox(height: MediaQuery.of(context).size.height * .01),
                            buildDatingField(),
                            SizedBox(height: MediaQuery.of(context).size.height * .01),
                            buildInterestedInField(),
                            SizedBox(height: MediaQuery.of(context).size.height * .01),
                          ],
                        ),


                        StyledButton(
                          text: 'Update profile',
                          color: kYesNoButtonColor,
                          onTap: updateProfileData,
                        ),

                        // ElevatedButton(
                        //   onPressed: updateProfileData,
                        //   child: Text(
                        //     'Update Profile',
                        //     style: TextStyle(
                        //       color: Colors.white,
                        //       fontSize: 20.0,
                        //     ),
                        //   ),
                        // ),
                        // Text(chosen_prompt),
                        // ElevatedButton(
                        //   onPressed: toPromptsPage,
                        //   child: Text(
                        //     'Prompts Page',
                        //     style: TextStyle(
                        //       color: Colors.white,
                        //       fontSize: 20.0,
                        //     ),
                        //   ),
                        // ),
                      ],
                    )
                  ],
                ),
              ));
  }

  void toPromptsPage() async {
    setState(() async {
      chosen_prompt = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => Prompts()));
    });
    print(chosen_prompt);
  }

  @override
  void dispose() {
    occupationController.dispose();
    educationController.dispose();
    locationController.dispose();
    bioController.dispose();
    super.dispose();
  }
}
