import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final tapFunc;
  const PrimaryButton({required this.label, required this.tapFunc, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 250,
        child: ElevatedButton(
          onPressed: tapFunc,
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0),
              ),
              backgroundColor: Color(0xffd4dc57),
              // onPrimary: Colors.white,
              elevation: 0,
              textStyle: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
          child: Text(label),
        ));
  }
}

class ColorButton extends StatelessWidget {
  final String label;
  final color;
  final fcolor;
  final tapFunc;
  const ColorButton(
      {required this.label,
      required this.tapFunc,
      this.color,
      this.fcolor,
      super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: tapFunc,
      style: ElevatedButton.styleFrom(
          // padding: EdgeInsets.symmetric(vertical: 12),
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(32.0),
          // ),
          backgroundColor: color ?? Color(0xffefefef),
          foregroundColor: fcolor ?? Colors.grey,
          textStyle: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
      child: Text(label),
    );
  }
}

class CancelButton extends StatelessWidget {
  final String label;
  final tapFunc;
  const CancelButton({required this.label, required this.tapFunc, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: tapFunc,
      style: ElevatedButton.styleFrom(
          // padding: EdgeInsets.symmetric(vertical: 12),
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(32.0),
          // ),
          backgroundColor: Colors.grey,
          // foregroundColor: Colors.white,
          textStyle: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
      child: Text(label),
    );
  }
}

class Flat1Button extends StatelessWidget {
  final String label;
  final tapFunc;
  const Flat1Button({required this.label, required this.tapFunc, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tapFunc,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(border: Border.all(color: Color(0xffb3c3a4))),
        child: Text(
          label,
          style: TextStyle(
              letterSpacing: 2,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xff28460c)),
        ),
      ),
      // style: ElevatedButton.styleFrom(
      //     // padding: EdgeInsets.symmetric(vertical: 12),
      //     // shape: RoundedRectangleBorder(
      //     //   borderRadius: BorderRadius.circular(32.0),
      //     // ),
      //     primary: Colors.grey,
      //     // onPrimary: Colors.white,
      //     textStyle: TextStyle(
      //         fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
    );
  }
}
