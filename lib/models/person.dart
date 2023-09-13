
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:birthday_app/utils/enums.dart';

@immutable
class Person {
  
  final int? personID;
  final String fullname;
  final DateTime birthDate;
  final String avatarPath;
  final ZodiacSign zodiacSign;
  final String? notes;

  // will not saved to db
  final DateTime? nextBirthDate;

  const Person({
    this.personID,
    required this.fullname,
    required this.birthDate,
    required this.avatarPath,
    required this.zodiacSign,
    this.notes,
    this.nextBirthDate,
  });

  Person copyWith({
    int? personID,
    String? fullname,
    DateTime? birthDate,
    String? avatarPath,
    ZodiacSign? zodiacSign,
    String? notes,
    DateTime? nextBirthDate,
    bool? notifSaved,
  }) {
    return Person(
      personID: personID ?? this.personID,
      fullname: fullname ?? this.fullname,
      birthDate: birthDate ?? this.birthDate,
      avatarPath: avatarPath ?? this.avatarPath,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      notes: notes ?? this.notes,
      nextBirthDate: nextBirthDate ?? this.nextBirthDate,
    );
  }

  @override
  bool operator ==(covariant Person other) {
    if (identical(this, other)) return true;
  
    return 
      other.personID == personID &&
      other.fullname == fullname &&
      other.birthDate == birthDate &&
      other.avatarPath == avatarPath &&
      other.zodiacSign == zodiacSign &&
      other.notes == notes &&
      other.nextBirthDate == nextBirthDate;
  }

  @override
  int get hashCode {
    return personID.hashCode ^
      fullname.hashCode ^
      birthDate.hashCode ^
      avatarPath.hashCode ^
      zodiacSign.hashCode ^
      notes.hashCode ^
      nextBirthDate.hashCode;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'person_id': personID,
      'fullname': fullname,
      'birthdate': birthDate.toIso8601String(),
      'avatar_path': avatarPath,
      'zodiac_sign': zodiacSign.engName,
      'notes': notes
    };
  }

  factory Person.fromMap(Map<String, dynamic> map) {

    DateTime birthDate = DateTime.parse(map['birthdate'] as String);

    return Person(
      personID: map['person_id'] as int,
      fullname: map['fullname'] as String,
      birthDate: birthDate,
      avatarPath: map['avatar_path'] as String,
      zodiacSign: ZodiacSignExtension.getZodiacSignFromEngName(map['zodiac_sign'] as String),
      notes: map['notes'],
      nextBirthDate: findNextBirthate(birthDate)
    );
  }

  static DateTime findNextBirthate(DateTime birthDate){

    DateTime now = DateTime.now();
    DateTime nextBirthDate = DateTime(now.year, birthDate.month, birthDate.day);

    if(now.month == nextBirthDate.month && now.day == nextBirthDate.day){
      return nextBirthDate;
    }

    if(now.isAfter(nextBirthDate)){
      return nextBirthDate.copyWith(year: now.year + 1);
    }
    else{
      return nextBirthDate;
    }
  }

  static bool isTodayBirthday(Person person){

    return (DateTime.now().month == person.birthDate.month) && 
      (DateTime.now().day == person.birthDate.day);
  }
}

class PersonNotifier extends StateNotifier<List<Person>> {
  PersonNotifier(): super([]);
  
  void setPersonList(List<Person> personList){
    state = personList;
  }

  Person getPersonWithID(int personID){
    return state.firstWhere((person) => person.personID == personID);
  }

  void addPersonToList(Person person){
    state = [...state, person];
  }

  void removePersonFromList(int personID){
    state = [
      for(var person in state)
        if(person.personID != personID) person
    ];
  }

  void updatePersonInList(Person updatedPerson){
    state = [
      for(var person in state)
        if(person.personID == updatedPerson.personID)
          updatedPerson
        else
          person
    ];
  }
}
