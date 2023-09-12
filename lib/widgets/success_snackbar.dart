
import 'package:birthday_app/utils/enums.dart';
import 'package:flutter/material.dart';

SnackBar SuccessSnackbar(String message){ 

  return SnackBar(
    elevation: 4,
    content: Text(
      message,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontFamily: TextFonts.nunitoSans.fontName
      ),
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.green,
    showCloseIcon: true,
    closeIconColor: Colors.white,
  );
}