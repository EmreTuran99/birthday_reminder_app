
import 'package:birthday_app/models/person.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final personNotifierProvider = StateNotifierProvider<PersonNotifier, List<Person>>((ref) {
  return PersonNotifier();
});