import 'package:image/image.dart';
import 'package:intl/intl.dart';
import 'package:kaliallendatingapp/screens/Home.dart';

class DateManager {

  DateTime now = DateTime.now();


  ///DONE
  List<String> identifyCurrentTimeSlots(DateTime now) {
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

  ///DONE
  List<String> identifyAvailableTimeSlots(DateTime now) {
    List<String> availableDates = identifyCurrentTimeSlots(now);
    int hourNow = int.parse('${DateFormat.H().format(now)}');
    print('The hour is $hourNow');


    if (hourNow >= 16 && hourNow < 18) {
      availableDates[0] = null;
    }

    if (hourNow >= 18 && hourNow < 20) {
      availableDates[0] = null;
      availableDates[1] = null;
    }

    if (hourNow >= 20) {
      availableDates[0] = null;
      availableDates[1] = null;
      availableDates[2] = null;
    }

    print(availableDates);

    return availableDates;
  }

  ///When "Find A Date" is pressed, this takes the bool usersAvailability list to create a list of the selectedTimeSlot codes ready to be shipped to Firebase
  List<String> createSelectedTimeSlots(List<String> availableTimeSlots, List<bool> usersAvailability){

    //availableTimeSlots: [20230129-46, 20230129-68, 20230129-810, 20230130-46, 20230130-68, 20230130-810, 20230131-46, 20230131-68, 20230131-810, 20230201-46, 20230201-68, 20230201-810]
    //usersAvailability: [false, true, true, false, false, false, false, false, false, false, false, false]

    List<String> selectedTimeSlots = [];

    for (int i = 0; i < 12; i++) {

      if (usersAvailability[i] == true) {
        selectedTimeSlots.add(availableTimeSlots[i]);
      }
    }

    print(selectedTimeSlots);

    return selectedTimeSlots;

    //Example output: [20230129-68, 20230129-810]
  }

  ///Take availableTimeSlots and currentDate.availability to create the bool usersAvailability list
List<bool> createUsersAvailabilityFromDateDoc(List<String> availableTimeSlots, List dateDocAvailability){

    //Example dateDocAvailability: [20230129-68, 20230129-810]
  List<bool> usersAvailability = [];

  for (int i = 0; i < 12; i++) {

    //if availableTimeSlots[i] is in dateDocAvailability, availableTimeSlots[i] is true, else false
    if (dateDocAvailability.contains(availableTimeSlots[i])){
      usersAvailability.add(true);
    } else {
      usersAvailability.add(false);
    }
  }

  print('usersAvailability from dateDoc is: $usersAvailability');
  return usersAvailability;

}








  ///Takes in availableTimeSlots and user's selectedTimeSlots and returns a true/false if the selected time slots are expired
  bool areAvailableTimeSlotsExpired(List<String> availableTimeSlots, List<dynamic> selectedTimeSlots) {
    print('availableTimeSlots: $availableTimeSlots');
    //Output: [20230129-46, 20230129-68, 20230129-810, 20230130-46, 20230130-68, 20230130-810, 20230131-46, 20230131-68, 20230131-810, 20230201-46, 20230201-68, 20230201-810]
    print('selectedTimeSlots: $selectedTimeSlots');
    List availableSelectedTimeSlots = [];



    for (String timeSlot in selectedTimeSlots){

      if (availableTimeSlots.contains(timeSlot) && timeSlot != null){
        return false;
      }
    }

    return true;

  }

//TODO: Clean this up. The output looks like shit
///Takes a date ID (ie. [20230129-68, 20230129-810]) and turns it into one long list of the date and time spelled out like Sun, 1/29 from 6-8 PM.
  String dateIdToName(List listOfDateIds) {
    String dateIdToNames = '';

    for (String id in listOfDateIds) {
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

  ///Takes in userAvailableDates and usersAvailability to return only the users Availability that matches available dates
  List<String> userAvailabilityDateCodes(List<String> userAvailableDates,
      List<bool> usersAvailability) {
    List<String> userAvailabilityDateCodes = [];

    for (int i = 0; i < 12; i++) {
      if (usersAvailability[i] == true) {
        userAvailabilityDateCodes.add(userAvailableDates[i]);
      }
    }

    return userAvailabilityDateCodes;
  }
}

  // Map<String, bool> createTimesMap(){
  //   List dateTimes = identifyCurrentTimeSlots(now);
  //
  //   for (String timeSlot in dateTimes){
  //
  //   }
  // }

  // Future<List> createActiveDateIDs() async {
  //   int hourNow = int.parse('${DateFormat.H().format(now)}');
  //   print('The hour now is $hourNow');
  //
  //   print(
  //       'Todays date is: ${DateFormat.yMd().format(now).replaceAll(
  //           RegExp('[^A-Za-z0-9]'), '')}');
  //   print('${DateFormat.MEd().format(now.add(Duration(days: 1)))}');
  //   List<String> activeDates = [];
  //
  //   //If time is earlier than 3pm
  //   if (hourNow < 15) {
  //     //Add all 3 times
  //     activeDates.add(
  //       DateFormat.yMd().format(now).replaceAll(RegExp('[^A-Za-z0-9]'), '') +
  //           '46',
  //     );
  //     activeDates.add(
  //       DateFormat.yMd().format(now).replaceAll(RegExp('[^A-Za-z0-9]'), '') +
  //           '68',
  //     );
  //     activeDates.add(
  //       DateFormat.yMd().format(now).replaceAll(RegExp('[^A-Za-z0-9]'), '') +
  //           '810',
  //     );
  //     //if time is earlier than 5pm,
  //   } else if (hourNow < 17) {
  //     //Add 6-8 and 8-10 only
  //     activeDates.add(
  //         DateFormat.yMd().format(now).replaceAll(RegExp('[^A-Za-z0-9]'), '') +
  //             '68');
  //     activeDates.add(
  //       DateFormat.yMd().format(now).replaceAll(RegExp('[^A-Za-z0-9]'), '') +
  //           '810',
  //     );
  //
  //     //if time is earlier than 7pm,
  //   } else if (hourNow < 19) {
  //     //Add 8-10 only
  //     activeDates.add(
  //       DateFormat.yMd().format(now).replaceAll(RegExp('[^A-Za-z0-9]'), '') +
  //           '810',
  //     );
  //   } else if (hourNow < 20) {
  //     //TODO: hide all times and show tonight as "unavailable".
  //   }
  //
  //   activeDates.add(DateFormat.yMd()
  //       .format(now.add(Duration(days: 1)))
  //       .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
  //       '46');
  //   activeDates.add(DateFormat.yMd()
  //       .format(now.add(Duration(days: 1)))
  //       .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
  //       '68');
  //   activeDates.add(DateFormat.yMd()
  //       .format(now.add(Duration(days: 1)))
  //       .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
  //       '810');
  //   activeDates.add(DateFormat.yMd()
  //       .format(now.add(Duration(days: 2)))
  //       .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
  //       '46');
  //   activeDates.add(DateFormat.yMd()
  //       .format(now.add(Duration(days: 2)))
  //       .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
  //       '68');
  //   activeDates.add(DateFormat.yMd()
  //       .format(now.add(Duration(days: 2)))
  //       .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
  //       '810');
  //   activeDates.add(DateFormat.yMd()
  //       .format(now.add(Duration(days: 3)))
  //       .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
  //       '46');
  //   activeDates.add(DateFormat.yMd()
  //       .format(now.add(Duration(days: 3)))
  //       .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
  //       '68');
  //   activeDates.add(DateFormat.yMd()
  //       .format(now.add(Duration(days: 3)))
  //       .replaceAll(RegExp('[^A-Za-z0-9]'), '') +
  //       '810');
  //
  //   print(activeDates);
  //   return activeDates;
  // }

 //  String convertDatesToReadable(List<String> codedList){
 //
 //    String readableDates = '';
 //
 //    for (String date in codedList){
 //
 //      String dateDay = date.substring(0, 8);
 //      DateTime dateTime = DateTime.parse(dateDay);
 //
 //      String dater = '${DateFormat.MEd().format(dateTime)}';
 //
 //      if (dateDay == '46') {
 //        dateDay = '4-6 PM';
 //        // print('4-6 PM');
 //      }
 //      if (dateDay == '68') {
 //        // print('6-8 PM');
 //        dateDay = '6-8 PM';
 //      }
 //      if (dateDay == '810') {
 //        // print('8-10 PM');
 //        dateDay = '8-10 PM';
 //      }
 //
 //      readableDates = readableDates + '$dater' + ' $dateTime';
 //    }
 //
 //    return readableDates;
 //
 //  }
 //
 // Future<List> anyCurrentActiveDates(List userAvailableDates) async {
 //    List currentActiveDatesIDs = await createActiveDateIDs();
 //
 //    //Create a new list of userActiveDates
 //    List userActiveDatesIDs = [];
 //
 //    for (String date in currentActiveDatesIDs) {
 //      if ((userAvailableDates).contains(date) == true) {
 //        userActiveDatesIDs.add(date);
 //      }
 //    }
 //
 //    print(userActiveDatesIDs);
 //
 //    return userActiveDatesIDs;
 //  }
 //


