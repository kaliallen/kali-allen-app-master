import 'package:intl/intl.dart';
import 'package:kaliallendatingapp/screens/Home.dart';

class DateManager {

  DateTime now = DateTime.now();



  List<String> identifyDateTimes(DateTime now) {

    DateFormat dateFormat = DateFormat('yyyyMMdd');
    List<String> datesSlots = [];

    datesSlots.add(
        dateFormat.format(now) + '-46'
    );
    datesSlots.add(
      dateFormat.format(now) + '-68',
    );
    datesSlots.add(
      dateFormat.format(now) + '-810',
    );
    datesSlots.add(
        dateFormat
        .format(now.add(Duration(days: 1))) + '-46');
    datesSlots.add(
        dateFormat
        .format(now.add(Duration(days: 1))) +
        '-68');
    datesSlots.add(
        dateFormat
        .format(now.add(Duration(days: 1))) +
        '-810');
    datesSlots.add(
        dateFormat
        .format(now.add(Duration(days: 2))) +
        '-46');
    datesSlots.add(
        dateFormat
        .format(now.add(Duration(days: 2))) +
        '-68');
    datesSlots.add(
        dateFormat
        .format(now.add(Duration(days: 2))) +
        '-810');
    datesSlots.add(
        dateFormat
        .format(now.add(Duration(days: 3))) +
        '-46');
    datesSlots.add(
        dateFormat
        .format(now.add(Duration(days: 3))) +
        '-68');
    datesSlots.add(
        dateFormat
        .format(now.add(Duration(days: 3))) +
        '-810');

    return datesSlots;
  }

  List<String> identifyActiveDateTimes(DateTime now){

    List<String> availableDates = identifyDateTimes(now);
    int hourNow = int.parse('${DateFormat.H().format(now)}');
    print('The hour is $hourNow');


    if (hourNow >= 16 && hourNow < 18){
      availableDates[0] = null;
    }

    if (hourNow >= 18 && hourNow < 20){
      availableDates[0] = null;
      availableDates[1] = null;
    }

    if (hourNow >= 20){
      availableDates[0] = null;
      availableDates[1] = null;
      availableDates[2] = null;
    }

    print(availableDates);

    return availableDates;
  }

  findActiveDatesFromList(){
    List<String> availableDates = identifyActiveDateTimes(now);
    print(availableDates);
  }

  ///Takes in userAvailableDates and usersAvailability to return only the users Availability that matches available dates
  List<String> userAvailabilityDateCodes(List<String> userAvailableDates, List<bool> usersAvailability){

    List<String> userAvailabilityDateCodes = [];

    for (int i=0; i<12; i++){
      if (usersAvailability[i] == true){
        userAvailabilityDateCodes.add(userAvailableDates[i]);
      }

    }

    return userAvailabilityDateCodes;

  }

  String dateIdToName(List listOfDateIds)
  {

    String dateIdToNames = '';

    for (String id in listOfDateIds){
      var newid = id.split('-');
      String date = newid[0];
      String time = newid[1];

      //Date
     DateTime dateDay = DateTime.parse(date);
      String dateDayFormatted = '${DateFormat.MEd().format(dateDay)}';

      //Time
      if (time == '46') {
        time = '4-6 PM';

      }
      if (time == '68') {
        time = '6-8 PM';
      }
      if (time == '810') {
        time = '8-10 PM';
      }

      dateIdToNames = dateIdToNames + dateDayFormatted + ' from ' + time + '; ';

    }

    print(dateIdToNames);
    return dateIdToNames;

  }


  // VVVVVVV Might Delete VVVVVV


  Map<String, bool> createTimesMap(){
    List dateTimes = identifyDateTimes(now);

    for (String timeSlot in dateTimes){

    }
  }

  Future<List> createActiveDateIDs() async {
    int hourNow = int.parse('${DateFormat.H().format(now)}');
    print('The hour now is $hourNow');

    print(
        'Todays date is: ${DateFormat.yMd().format(now).replaceAll(
            RegExp('[^A-Za-z0-9]'), '')}');
    print('${DateFormat.MEd().format(now.add(Duration(days: 1)))}');
    List<String> activeDates = [];

    //If time is earlier than 3pm
    if (hourNow < 15) {
      //Add all 3 times
      activeDates.add(
        DateFormat.yMd().format(now).replaceAll(RegExp('[^A-Za-z0-9]'), '') +
            '46',
      );
      activeDates.add(
        DateFormat.yMd().format(now).replaceAll(RegExp('[^A-Za-z0-9]'), '') +
            '68',
      );
      activeDates.add(
        DateFormat.yMd().format(now).replaceAll(RegExp('[^A-Za-z0-9]'), '') +
            '810',
      );
      //if time is earlier than 5pm,
    } else if (hourNow < 17) {
      //Add 6-8 and 8-10 only
      activeDates.add(
          DateFormat.yMd().format(now).replaceAll(RegExp('[^A-Za-z0-9]'), '') +
              '68');
      activeDates.add(
        DateFormat.yMd().format(now).replaceAll(RegExp('[^A-Za-z0-9]'), '') +
            '810',
      );

      //if time is earlier than 7pm,
    } else if (hourNow < 19) {
      //Add 8-10 only
      activeDates.add(
        DateFormat.yMd().format(now).replaceAll(RegExp('[^A-Za-z0-9]'), '') +
            '810',
      );
    } else if (hourNow < 20) {
      //TODO: hide all times and show tonight as "unavailable".
    }

    activeDates.add(DateFormat.yMd()
        .format(now.add(Duration(days: 1)))
        .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
        '46');
    activeDates.add(DateFormat.yMd()
        .format(now.add(Duration(days: 1)))
        .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
        '68');
    activeDates.add(DateFormat.yMd()
        .format(now.add(Duration(days: 1)))
        .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
        '810');
    activeDates.add(DateFormat.yMd()
        .format(now.add(Duration(days: 2)))
        .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
        '46');
    activeDates.add(DateFormat.yMd()
        .format(now.add(Duration(days: 2)))
        .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
        '68');
    activeDates.add(DateFormat.yMd()
        .format(now.add(Duration(days: 2)))
        .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
        '810');
    activeDates.add(DateFormat.yMd()
        .format(now.add(Duration(days: 3)))
        .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
        '46');
    activeDates.add(DateFormat.yMd()
        .format(now.add(Duration(days: 3)))
        .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
        '68');
    activeDates.add(DateFormat.yMd()
        .format(now.add(Duration(days: 3)))
        .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
        '810');

    print(activeDates);
    return activeDates;
  }

  String convertDatesToReadable(List<String> codedList){

    String readableDates = '';

    for (String date in codedList){

      String dateDay = date.substring(0, 8);
      DateTime dateTime = DateTime.parse(dateDay);

      String dater = '${DateFormat.MEd().format(dateTime)}';

      if (dateDay == '46') {
        dateDay = '4-6 PM';
        // print('4-6 PM');
      }
      if (dateDay == '68') {
        // print('6-8 PM');
        dateDay = '6-8 PM';
      }
      if (dateDay == '810') {
        // print('8-10 PM');
        dateDay = '8-10 PM';
      }

      readableDates = readableDates + '$dater' + ' $dateTime';
    }

    return readableDates;

  }

 Future<List> anyCurrentActiveDates(List userAvailableDates) async {
    List currentActiveDatesIDs = await createActiveDateIDs();

    //Create a new list of userActiveDates
    List userActiveDatesIDs = [];

    for (String date in currentActiveDatesIDs) {
      if ((userAvailableDates).contains(date) == true) {
        userActiveDatesIDs.add(date);
      }
    }

    print(userActiveDatesIDs);

    return userActiveDatesIDs;
  }



}