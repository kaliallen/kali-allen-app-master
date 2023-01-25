import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/constants.dart';
import 'package:kaliallendatingapp/models/userData.dart';
import 'package:kaliallendatingapp/screens/profilesetup/Profile9Job.dart';
import 'package:kaliallendatingapp/screens/profilesetup/Profile10School.dart';
import 'package:kaliallendatingapp/widgets/StyledButton.dart';
import 'package:page_transition/page_transition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

import '../Home.dart';


class ProfileAddMorePhotos extends StatefulWidget {
  final UserData _userData;

  ProfileAddMorePhotos({@required UserData userData})
      : assert(userData != null),
        _userData = userData;

  @override
  State<ProfileAddMorePhotos> createState() => _ProfileAddMorePhotosState();
}

class _ProfileAddMorePhotosState extends State<ProfileAddMorePhotos> {
  bool isUploading = false;
  File _image;
  File _image2;
  File _image3;
  final picker = ImagePicker();
  String postId = Uuid().v4();
  String postId2 = Uuid().v4();
  String postId3 = Uuid().v4();

  //1) When upload photo button is pressed, a popup dialog will appear to select image
  Future<Function> selectImage(parentContext) async {
    return showDialog(
        context: parentContext,
        builder: (context){
          return SimpleDialog(
            title: Text('Upload Profile Photo'),
            children: [
              SimpleDialogOption(
                child: Text('Photo with Camera'),
                onPressed: (){
                  return getImageCamera;
                }
              ),
              SimpleDialogOption(
                child: Text('Photo from Gallery'),
                onPressed: (){
                  return getImageGallery;
                },
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
    print('pressed');
    // Navigator.pop(context);
    // var pickedFile = await picker.getImage(
    //   source: ImageSource.camera,
    //   maxHeight: 675,
    //   maxWidth: 960,
    // );
    // setState(() {
    //   if (pickedFile != null){
    //     _image = File(pickedFile.path);
    //   } else {
    //     print('No image selected');
    //   }
    // });
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
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_sharp,
                      color: kLightDark,
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Text(
                    'Add More Photos',
                    style: TextStyle(
                      // letterSpacing: 2.0,
                      fontSize: 30.0,
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w600,
                      color: kDarkest,
                    )
                ),
              ),
              Center(
                child: Container(
                  height: MediaQuery.of(context).size.width * .7,
                  width: MediaQuery.of(context).size.width * .7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.width * .3,
                            width: MediaQuery.of(context).size.width * .3,
                            child: Image(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(widget._userData.picture1),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              Function selectedFunction = await selectImage(context);
                              print(selectedFunction);
                            },
                            child: Container(
                              height: 125.0,
                              width: 125.0,
                              child: _image == null ? Icon(
                                Icons.add_a_photo_outlined,
                              ) : Image.file(
                                  _image,
                                  fit: BoxFit.cover,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xffe6e7ea),
                                //borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                          onTap: () => selectImage(context),
                          child: Container(
                            height: 125.0,
                            width: 125.0,
                            child: _image2 == null ? Icon(
                              Icons.add_a_photo_outlined,
                            ) : Image.file(
                              _image2,
                              fit: BoxFit.cover,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xffe6e7ea),
                              //borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                          GestureDetector(
                            onTap: () => selectImage(context),
                            child: Container(
                              height: 125.0,
                              width: 125.0,
                              child: _image3 == null ? Icon(
                                Icons.add_a_photo_outlined,
                              ) : Image.file(
                                _image3,
                                fit: BoxFit.cover,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xffe6e7ea),
                                //borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: 30.0, right: 25.0, left: 25.0),
                child: StyledButton(
                  text: 'Continue',
                  color: kButtonColor,
                  onTap: () async {
                    setState(() {
                      isUploading = true;
                    });
                   //  final images = [_image1, _image2, _image3];
                   // for (File image in images){
                   //   await handleSubmit(image);
                   // }
                    // await handleSubmit();
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: ProfileJob(
                              userData: widget._userData,
                            )));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


