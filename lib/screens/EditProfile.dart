import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/screens/Home.dart';
import 'package:kaliallendatingapp/widgets/Prompts.dart';
import 'package:kaliallendatingapp/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  TextEditingController occupationController = TextEditingController();
  TextEditingController educationController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  bool _occupationValid = true;
  bool _educationValid = true;
  bool _bioValid = true;
  String chosen_prompt = "Chosen Prompt";

  getUser() async {
    setState(() {
      isLoading = true;
    });
    print('widget.currentUserId is ${widget.currentUserId}');
    //2) Begin by getting doc from uid and saving it into userData
    DocumentSnapshot doc = await usersRef.doc(widget.currentUserId).get();
UserData userData = UserData.fromDocument(doc);
occupationController.text = userData.occupation!;
print(userData.picture1);
    //3. Change all the controllers to have existing info inputted
   userData.education != null? educationController.text = userData.education!: print('education is null');
    setState(() {
      userData.education != null? educationController.text = userData.education!: print('education is null');
      isLoading = false;
    });
  }

  Column buildOccupationField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text('Job',
          style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: occupationController,
          decoration: InputDecoration(
            hintText: 'Update Job',
            errorText: _occupationValid ? null : 'Job field empty'
          )
        )
      ],
    );
  }

  Column? buildLocationField(){
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text('Current Location',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        // TextField(
        //
        //   controller: locationController,
        //   decoration: InputDecoration(
        //     hintText: 'Update Location',
        //     errorText: _educationValid ? null : 'Education field empty',
        //   ),
        // ),
      ],
    );
  }

  Column buildEducationField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text('School',
            style: TextStyle(color: Colors.grey),
          ),
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

  updateProfileData(){
    //4) Validate Text before you are allowed to update them
    setState(() {
      occupationController.text
          .trim()
          .isEmpty ? _occupationValid = false : _occupationValid = true;
      educationController.text
          .trim()
          .isEmpty ? _educationValid = false : _educationValid = true;
      //bioController.text.trim().length > 100 ? _bioValid = false : _bioValid = true;

      if (_occupationValid && _bioValid && _educationValid) {
        usersRef.doc(widget.currentUserId).update({
          'occupation': occupationController.text,
          'education': educationController.text,
        });
        //6)
       SnackBar snackBar = SnackBar(content: Text('Profile updated!'));
       ScaffoldMessenger.of(context).showSnackBar(snackBar);
       // _scaffoldKey.currentState.showSnackBar(snackBar);
;
       Future.delayed(Duration(seconds: 1),(){
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
            icon: Icon(Icons.close,
            color: Colors.black,),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: isLoading ? circularProgress() : ListView(
        children: [
          Container(
            child: Column(
              children: [
                Padding(padding: EdgeInsets.only(top: 16, bottom: 8.0),
                child: CircleAvatar(
                  radius: 50.0,
                  backgroundImage: CachedNetworkImageProvider('https://firebasestorage.googleapis.com/v0/b/datingapp-1e76d.appspot.com/o/post_23b52b9c-d315-4f26-a099-4e37ecf25632.jpg?alt=media&token=2f27c093-dc5f-47a6-8973-a4c96bee9543'),
                )),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      buildEducationField(),
                      buildOccupationField(),
                      // buildLocationField(),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: updateProfileData,
                  child: Text('Update Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),),
                ),
                Text(chosen_prompt),
                ElevatedButton(
                  onPressed: toPromptsPage,
                  child: Text('Prompts Page',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),),
                ),
              ],
            )
          )
        ],
      )
    );
  }

  void toPromptsPage() async {
    setState(() async {
      chosen_prompt = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Prompts()));
    });
    print(chosen_prompt);
  }

  @override
  void dispose() {
  occupationController.dispose();
  educationController.dispose();
  locationController.dispose();
    super.dispose();
  }
}
