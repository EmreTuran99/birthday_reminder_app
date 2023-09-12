
import 'package:intl/intl.dart';

String formattedBirthDate(DateTime dateTime){

  return DateFormat('yMMMMd', 'tr').format(dateTime);
}