import 'package:flutter/material.dart';

class BlackRadiusButton extends StatelessWidget {
  final String label;
  final tapFunc;
  const BlackRadiusButton(
      {required this.label, required this.tapFunc, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: tapFunc,
      style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32.0),
          ),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          textStyle: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
      child: Text(label),
    );
  }
}
