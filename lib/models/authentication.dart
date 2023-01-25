import 'package:flutter/material.dart';
import 'package:kaliallendatingapp/models/userRepository.dart';

class Authentication extends ChangeNotifier {
  final UserRepository _userRepository;

  Authentication({@required UserRepository userRepository}) : assert(userRepository != null),
  _userRepository = userRepository;



}