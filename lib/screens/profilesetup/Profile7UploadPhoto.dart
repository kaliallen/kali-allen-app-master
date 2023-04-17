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
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';


class ProfileUploadPhoto extends StatefulWidget {
  final UserData _userData;

  ProfileUploadPhoto({@required UserData userData})
      : assert(userData !=null),
        _userData = userData;

  @override
  _ProfileUploadPhotoState createState() => _ProfileUploadPhotoState();
}

class _ProfileUploadPhotoState extends State<ProfileUploadPhoto> {
  bool isUploading = false;
  File _image;
  final picker = ImagePicker();
  String postId = Uuid().v4();

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
    var pickedFile = await picker.getImage(
        source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
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
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
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
    await uploadImage(_image);
    print('2. image successfully compressed');
    String medialUrl = await uploadImage(_image);
    print('3. image uploaded to storage');
    //6) Add image to UserData
    widget._userData.picture1 = medialUrl;
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
    Im.Image imageFile = Im.decodeImage(_image.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      _image = compressedImageFile;
    });
  }

  //5) Uploads image to firebase storage and returns the image's URL
  Future<String> uploadImage(imageFile) async {
    UploadTask uploadTask = storageRef.child('post_$postId.jpg').putFile(imageFile);
    String imageUrl = await (await uploadTask).ref.getDownloadURL();
    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isUploading,
      dismissible: true,
      progressIndicator: circularProgress(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 8),
                child:  IconButton(icon: Icon(Icons.arrow_back_ios_sharp,
                  color: kLightDark,
                ), onPressed: () async {
                  Navigator.pop(context);
                }),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: Text(
                  'Upload Profile Picture',
                  style: kQuestionText,
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () => selectImage(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xffe6e7ea),
                      borderRadius: BorderRadius.circular(10.0),
                     // border: Border.all(
                     //   width: 1.0,
                     //   color: Colors.black,
                     // )
                    ),
                    height: MediaQuery.of(context).size.width * .8,
                    width: MediaQuery.of(context).size.width * .8,
                    child: _image == null ? Icon(
                        Icons.add_a_photo_outlined,
                  //  color: Colors.grey,
                    )
                    : ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.file(_image,
                      fit: BoxFit.cover,
                        ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0, right: 25.0, left: 25.0),
                child: StyledButton(
                  text: 'Continue',
                  color: kButtonColor,
                  onTap: () async {
                    print('button pressed');
                    if (_image != null) {
                     await handleSubmit();
                      Navigator.push(context, PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: ProfileAddMorePhotos(
                            userData: widget._userData,
                          )));
                    } else {
                      print('No photo attached...');
                    }
                    }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


