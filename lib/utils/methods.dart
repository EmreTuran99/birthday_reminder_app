
import 'package:birthday_app/models/person.dart';
import 'package:intl/intl.dart';

String formattedBirthDate(DateTime dateTime){

  return DateFormat('yMMMMd', 'tr').format(dateTime);
}

String getBirthDayInfoText(Person person){

  int newAge = person.nextBirthDate!.year - person.birthDate.year;
  if(Person.isTodayBirthday(person)){
    return "Bugün $newAge yaşına girdi";
  }

  String formattedPart = DateFormat('d MMMM, EEEE', 'tr').format(person.nextBirthDate!);
  return "$formattedPart günü $newAge yaşına giriyor";
}

String getDateWithDay(DateTime dateTime){

  return DateFormat('d MMMM yyyy, EEEE', 'tr').format(dateTime);
}