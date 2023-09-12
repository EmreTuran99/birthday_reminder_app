
import 'package:flutter/material.dart';

class SaveUserController extends InheritedWidget {

  SaveUserController({
    required super.child,
    super.key,
  });

  final TextEditingController ctrlFullname = TextEditingController();
  final TextEditingController ctrlBirthdate = TextEditingController();
  final TextEditingController ctrlNotes = TextEditingController();

  DateTime? selectedBirthDate;
  bool isAvatarMale = true;
  
  final GlobalKey<FormState> saveUserFormKey = GlobalKey<FormState>();

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }

  bool validateFields() {
    return saveUserFormKey.currentState?.validate() ?? false;
  }

  static SaveUserController of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<SaveUserController>();
    assert(result != null, 'No SaveUserController found in context');
    return result!;
  }
}