import 'package:flutter/material.dart';

class IncreaseView extends StatelessWidget {
  final int value;
  const IncreaseView({required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 2),
        alignment: Alignment.center,
        width: 60,
        height: 30,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(6)),
        child: Text(
          value.toString(),
          style: TextStyle(fontSize: 18),
        ));
  }
}
