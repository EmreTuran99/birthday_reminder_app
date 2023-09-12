
import 'package:flutter/material.dart';

class VerticalSpace extends StatelessWidget {

  double height;
  VerticalSpace(this.height, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}