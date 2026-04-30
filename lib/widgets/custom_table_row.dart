import 'package:flutter/material.dart';

class CustomTableRow extends StatelessWidget {
  final String parameter;
  final String normalRange;
  final String units;
  final ValueChanged<String> onChanged;

  const CustomTableRow({
    required this.parameter,
    required this.normalRange,
    required this.units,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              parameter,
              style: TextStyle(
                color: Color(0xFF3B6FF0),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              normalRange,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              units,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextField(
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
                onChanged: onChanged,
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
