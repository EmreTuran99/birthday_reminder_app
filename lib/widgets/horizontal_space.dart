
import 'package:flutter/material.dart';

class HorizontalSpace extends StatelessWidget {

  double width;
  HorizontalSpace(this.width, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width);
  }
}