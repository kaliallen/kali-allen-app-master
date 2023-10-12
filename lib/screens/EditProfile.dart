

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/screens/Home.dart';
import 'package:kaliallendatingapp/widgets/Pill.dart';
import 'package:kaliallendatingapp/widgets/Prompts.dart';
import 'package:kaliallendatingapp/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/screens/Home.dart';
import 'package:kaliallendatingapp/screens/profilesetup/Profile10School.dart';
import 'package:kaliallendatingapp/screens/profilesetup/Profile8AddMorePhotos.dart';
import 'package:kaliallendatingapp/screens/profilesetup/Profile9Job.dart';
import 'package:kaliallendatingapp/widgets/StyledButton.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kaliallendatingapp/widgets/progress.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';


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

  TextEditingController relationshipController = TextEditingController();
  TextEditingController pronounsController = TextEditingController();
  TextEditingController interestedInController = TextEditingController();

  bool relationshipOther = false;
  bool pronounsOther = false;
  bool interestedinOther = false;

  bool openRelationship = false;
  bool openPronouns = false;
  bool openInterestedin = false;

  String? relationshipStatus;
  String pronounds = 'He/Him';
  String interestedin = 'Men';

  //Profile Picture
  bool isUploading = false;
  File? _image;
  final picker = ImagePicker();
  String postId = Uuid().v4();

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

    userData!.relationshipStatus != null && userData!.relationshipStatus != ''
        ? relationshipStatus = userData!.relationshipStatus.toString()
        : relationshipStatus = null;

    userData!.gender != null
        ? pronounds = userData!.gender.toString()
        : pronounds = '';
    userData!.isInterestedIn != null
        ? interestedin = userData!.isInterestedIn.toString()
        : interestedin = '';

    print('relationship status is: ${userData!.relationshipStatus}');

    if (userData!.relationshipStatus != 'Dating' &&
        userData!.relationshipStatus != 'Not Dating' &&
        userData!.relationshipStatus != 'In a Relationship') {
      if (userData!.relationshipStatus == null) {
        relationshipStatus = null;
        relationshipOther = false;
      } else {
        relationshipOther = true;
        relationshipController.text = userData!.relationshipStatus.toString();
      }
    }

    print('relationshipOther is: $relationshipOther');
    print('relationshipStatus is: $relationshipStatus');

    if (userData!.gender != 'He/Him' &&
        userData!.gender != 'She/Her' &&
        userData!.gender != 'They/Them' &&
        userData!.gender != 'Ze/Hir' &&
        userData!.gender != null) {
      pronounsOther = true;
      pronounsController.text = userData!.gender.toString();
    }

    if (userData!.isInterestedIn != 'Men' &&
        userData!.isInterestedIn != 'Women' &&
        userData!.isInterestedIn != 'All genders' &&
        userData!.isInterestedIn != null) {
      interestedinOther = true;
      interestedInController.text = userData!.isInterestedIn.toString();
    }

    //3. Change all the controllers to have existing info inputted
    // userData.education != null? educationController.text = userData.education!: print('education is null');
    setState(() {
      isLoading = false;
    });
  }

  //Upload an Image
  //1) When upload photo button is pressed, a popup dialog will appear to select image
  selectImage(parentContext){
    return showDialog(
        context: parentContext,
        builder: (context){
          return SimpleDialog(
            title: Text('Upload Profile Photo'),
            children: [
              SimpleDialogOption(
                child: Text('Photo with Camera'),
                onPressed: getImageCamera,
              ),
              SimpleDialogOption(
                child: Text('Photo from Gallery'),
                onPressed: getImageGallery,
              ),
              SimpleDialogOption(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        }
    );
  }

  //2) gets a photo from the camera OR...
  Future getImageCamera() async {
    Navigator.pop(context);
    var pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960
    );

    setState(() {
      if (pickedFile != null){
        _image = File(pickedFile.path);
      } else {
        print('No image selected');
      }
    });
  }

// OR image gallery
  Future getImageGallery() async {
    Navigator.pop(context);
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null){
        _image = File(pickedFile.path);
      } else {
        print('No image selected');
      }
    });

  }

  //3) What happens when continue is pressed
  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    print('1. handle submit triggered');
    await compressImage();
    print('2. image successfully compressed');
    String medialUrl = await uploadImage(_image);
    print('3. image uploaded to storage');
    print(medialUrl);
    //6) Add image to UserData
    userData!.picture1 = medialUrl;

    print('4. photo added to userData');
    //7) Set is Uploading back to False
    setState(() {
      isUploading = false;
    });
  }



  //4) takes file stored in state and compresses it
  compressImage() async {
    print('compress Image triggered');
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    //Reading the image file and putting it into imageFile variable
    Im.Image? imageFile = Im.decodeImage(_image!.readAsBytesSync());
      final compressedImageFile = File('$path/img_$postId.jpg')
        ..writeAsBytesSync(Im.encodeJpg(imageFile!, quality: 85));
      setState(() {
        _image = compressedImageFile;
      });

  }

  //5) Uploads image to firebase storage and returns the image's URL
  Future<String> uploadImage(imageFile) async {
      UploadTask uploadTask = storageRef.child('post_$postId.jpg').putFile(
          imageFile);
      String imageUrl = await (await uploadTask).ref.getDownloadURL();
      return imageUrl;

  }


  GestureDetector buildProfilePicture(){
    return GestureDetector(
      onTap: () => selectImage(context),
      child: _image != null ?
      CircleAvatar(
        radius: MediaQuery.of(context).size.width * .4,
        backgroundImage:
        FileImage(_image!),
      )
      : CircleAvatar(
        radius: MediaQuery.of(context).size.width * .4,
        backgroundImage:
        CachedNetworkImageProvider(userData!.picture1!),
      ),
    );
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

  Column buildRelationshipStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Relationship Status', style: TextStyle(color: kLightDark)),
        Wrap(
          children: [
            PillButton(
              isSelected: relationshipStatus == 'Dating' ? true : false,
              text: 'Dating',
              onTap: () {
                setState(() {
                  if (relationshipStatus != 'Dating') {
                    setState(() {
                      relationshipStatus = 'Dating';
                      relationshipOther = false;
                    });
                  } else {
                    setState(() {
                      relationshipStatus = '';
                    });
                  }
                });
              },
            ),
            PillButton(
              isSelected: relationshipStatus == 'Not Dating' ? true : false,
              text: 'Not Dating',
              onTap: () {
                if (relationshipStatus != 'Not Dating') {
                  setState(() {
                    relationshipStatus = 'Not Dating';
                    relationshipOther = false;
                  });
                } else {
                  setState(() {
                    relationshipStatus = '';
                  });
                }
              },
            ),
            PillButton(
              isSelected:
                  relationshipStatus == 'In a Relationship' ? true : false,
              text: 'In a Relationship',
              onTap: () {
                if (relationshipStatus != 'In a Relationship') {
                  setState(() {
                    relationshipStatus = 'In a Relationship';
                    relationshipOther = false;
                  });
                } else {
                  setState(() {
                    relationshipStatus = '';
                  });
                }
              },
            ),
            PillButton(
              isSelected: relationshipOther ? true : false,
              text:
                  relationshipOther && relationshipController.text.trim().isNotEmpty
                      ? relationshipController.text.trim()
                      : 'Other',
              onTap: () {
                if (relationshipStatus ==
                    relationshipController.text.trim().toString()) {
                  setState(() {
                    relationshipStatus = null;
                    relationshipOther = false;
                  });
                } else if (relationshipStatus == 'Other') {
                  setState(() {
                    relationshipStatus = '';
                    relationshipOther = false;
                  });
                } else if (relationshipStatus == null) {
                  setState(() {
                    relationshipStatus = 'Other';
                    relationshipOther = true;
                  });
                } else {
                  setState(() {
                    relationshipStatus = 'Other';
                  });
                }

                // if (relationshipStatus != 'Other'){
                //   setState(() {
                //     relationshipStatus = 'Other';
                //   });
                // } else {
                //   setState(() {
                //     relationshipOther = false;
                //     relationshipStatus = '';
                //   });
                // }
                print('relationshipstatus is $relationshipStatus');
                print('relationshipOther is $relationshipOther');
              },
            ),
          ],
        ),
        relationshipStatus == 'Other' //Always 'Other'
            ? Row(
                children: [
                  Expanded(
                    child: Container(
                      // width: MediaQuery.of(context).size.width * .5,
                      child: TextField(
                        controller: relationshipController,
                        readOnly: false, //Always false
                        decoration: InputDecoration(

                            // border: InputBorder.none,
                            ),
                      ),
                    ),
                  ),
                  PillButton(
                    isSelected: false, //Always False
                    text: 'Done',
                    onTap: () {
                      //If done is pressed, if the text is not blank,
                      //set state: relationshipStatus == controller.text,
                      if (relationshipController.text.trim().isNotEmpty){
                        setState(() {
                          relationshipStatus = relationshipController.text.trim();
                        });
                      }
                    },
                  ),
                ],
              )
            : SizedBox(),
      ],
    );
  }

  Column buildPronounField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pronouns', style: TextStyle(color: kLightDark)),
        Wrap(
          children: [
            PillButton(
              isSelected: pronounds == 'He/Him' ? true : false,
              text: 'He/Him',
              onTap: () {
                if (pronounds != 'He/Him') {
                  setState(() {
                    pronounds = 'He/Him';
                    pronounsOther = false;
                  });
                } else {
                  setState(() {
                    pronounds = '';
                  });
                }
              },
            ),
            PillButton(
              isSelected: pronounds == 'She/Her' ? true : false,
              text: 'She/Her',
              onTap: () {
                if (pronounds != 'She/Her') {
                  setState(() {
                    pronounds = 'She/Her';
                    pronounsOther = false;
                  });
                } else {
                  setState(() {
                    pronounds = '';
                  });
                }
              },
            ),
            PillButton(
              isSelected: pronounds == 'They/Them' ? true : false,
              text: 'They/Them',
              onTap: () {
                if (pronounds != 'They/Them') {
                  setState(() {
                    pronounds = 'They/Them';
                    pronounsOther = false;
                  });
                } else {
                  setState(() {
                    pronounds = '';
                  });
                }
              },
            ),
            PillButton(
              isSelected: pronounds == 'Ze/Hir' ? true : false,
              text: 'Ze/Hir',
              onTap: () {
                if (pronounds != 'Ze/Hir') {
                  setState(() {
                    pronounds = 'Ze/Hir';
                    pronounsOther = false;
                  });
                } else {
                  setState(() {
                    pronounds = '';
                  });
                }
              },
            ),
            PillButton(
              isSelected: pronounds == 'Other' ? true : false,
              text: pronounsOther ? pronounsController.text.trim() : 'Other',
              onTap: () {
                if (pronounds != 'Other') {
                  setState(() {
                    pronounds = 'Other';
                  });
                } else {
                  setState(() {
                    pronounsOther = false;
                    pronounds = '';
                  });
                }
              },
            ),
          ],
        ),
        pronounds == 'Other'
            ? Row(
                children: [
                  pronounsOther
                      ? SizedBox()
                      : Expanded(
                          child: Container(
                            // width: MediaQuery.of(context).size.width * .5,
                            child: TextField(
                              controller: pronounsController,
                              readOnly: pronounsOther ? true : false,
                              textAlign: pronounsOther
                                  ? TextAlign.center
                                  : TextAlign.left,
                              decoration: InputDecoration(

                                  // border: InputBorder.none,
                                  ),
                            ),
                          ),
                        ),
                  pronounsOther
                      ? SizedBox()
                      : PillButton(
                          isSelected: pronounsOther ? true : false,
                          text: pronounsOther
                              ? '${pronounsController.text.trim()}'
                              : 'Done',
                          onTap: () {
                            if (pronounsOther) {
                              setState(() {
                                pronounsOther = false;
                              });
                            } else {
                              if (pronounsController.text.trim().isNotEmpty) {
                                setState(() {
                                  pronounsOther = true;
                                });
                              }
                            }
                          },
                        ),
                ],
              )
            : SizedBox(),
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
              isSelected: interestedin == 'Men' ? true : false,
              text: 'Men',
              onTap: () {
                if (interestedin != 'Men') {
                  setState(() {
                    interestedin = 'Men';
                    interestedinOther = false;
                  });
                } else {
                  setState(() {
                    interestedin = '';
                  });
                }
              },
            ),
            PillButton(
              isSelected: interestedin == 'Women' ? true : false,
              text: 'Women',
              onTap: () {
                if (interestedin != 'Women') {
                  setState(() {
                    interestedin = 'Women';
                    interestedinOther = false;
                  });
                } else {
                  setState(() {
                    interestedin = '';
                  });
                }
              },
            ),
            PillButton(
              isSelected: interestedin == 'All genders' ? true : false,
              text: 'All genders',
              onTap: () {
                if (interestedin != 'All genders') {
                  setState(() {
                    interestedin = 'All genders';
                    interestedinOther = false;
                  });
                } else {
                  setState(() {
                    interestedin = '';
                  });
                }
              },
            ),
            PillButton(
              isSelected: interestedin == 'Other' ? true : false,
              text: interestedinOther
                  ? interestedInController.text.trim()
                  : 'Other',
              onTap: () {
                if (interestedin != 'Other') {
                  setState(() {
                    interestedin = 'Other';
                  });
                } else {
                  setState(() {
                    interestedinOther = false;
                    interestedin = '';
                  });
                }
              },
            ),
          ],
        ),
        interestedin == 'Other'
            ? Row(
                children: [
                  interestedinOther
                      ? SizedBox()
                      : Expanded(
                          child: Container(
                            // width: MediaQuery.of(context).size.width * .5,
                            child: TextField(
                              controller: interestedInController,
                              readOnly: interestedinOther ? true : false,
                              textAlign: interestedinOther
                                  ? TextAlign.center
                                  : TextAlign.left,
                              decoration: InputDecoration(

                                  // border: InputBorder.none,
                                  ),
                            ),
                          ),
                        ),
                  interestedinOther
                      ? SizedBox()
                      : PillButton(
                          isSelected: interestedinOther ? true : false,
                          text: interestedinOther
                              ? '${interestedInController.text.trim()}'
                              : 'Done',
                          onTap: () {
                            if (interestedinOther) {
                              setState(() {
                                interestedinOther = false;
                              });
                            } else {
                              if (interestedInController.text
                                  .trim()
                                  .isNotEmpty) {
                                setState(() {
                                  interestedinOther = true;
                                });
                              }
                            }
                          },
                        ),
                ],
              )
            : SizedBox(),
      ],
    );
  }

  updateProfileData() async {

    if (_image != null){
      print('New image to upload!');
      await handleSubmit();

    } else {
      print('No new image to upload');
    }


    //4) Validate Text before you are allowed to update them
    setState(() {
      // occupationController.text.trim().isEmpty
      //     ? _occupationValid = false
      //     : _occupationValid = true;
      // educationController.text.trim().isEmpty
      //     ? _educationValid = false
      //     : _educationValid = true;
      // locationController.text.trim().isEmpty
      //     ? _locationValid = false
      //     : _locationValid = true;

      // if (_occupationValid && _educationValid) {
      usersRef.doc(widget.currentUserId).update({
        'picture1': userData!.picture1,
        'occupation': occupationController.text.trim(),
        'education': educationController.text.trim(),
        'location': locationController.text.trim(),
        'bio': bioController.text.trim(),
        'gender': pronounds,
        'isInterestedIn': interestedin,
        'relationshipStatus': relationshipStatus
      });
      //6)
      SnackBar snackBar = SnackBar(content: Text('Profile updated!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // _scaffoldKey.currentState.showSnackBar(snackBar);
      ;
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context);
      });
      // }
    });

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
                        SizedBox(
                            height: MediaQuery.of(context).size.height * .01),
                        buildProfilePicture(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildBioField(),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * .01),
                            buildLocationField(),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * .01),
                            buildEducationField(),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * .01),
                            buildOccupationField(),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * .02),
                            buildRelationshipStatusField(),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * .01),
                            buildPronounField(),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * .01),
                            buildInterestedInField(),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * .03),
                          ],
                        ),
                        StyledButton(
                          text: 'Update profile',
                          color: kYesNoButtonColor,
                          onTap: updateProfileData,
                        ),
                      ],
                    )
                  ],
                ),
              ));
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
