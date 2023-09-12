
import 'package:birthday_app/screens/screen_birthdays.dart';
import 'package:flutter/material.dart';

class BirthdayReminderApp extends StatelessWidget {
  const BirthdayReminderApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Birthday Reminder App',
      home: BirthdaysScreen()
    );
  }
}