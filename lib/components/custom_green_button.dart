import 'package:flutter/material.dart';

class CustomGreenButton extends StatelessWidget {
  final VoidCallback handleClick;
  final String label;

  const CustomGreenButton({
    super.key,
    required this.handleClick,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: handleClick,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Color(0xff00A63E),
        iconColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
