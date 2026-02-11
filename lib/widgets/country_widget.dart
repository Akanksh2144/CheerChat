import 'package:flag/flag.dart';
import 'package:flutter/material.dart';

Widget countryDetails() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.amberAccent,
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      children: [
        Flag.fromCode(FlagsCode.IN, height: 20, width: 30),
        Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            // borderRadius: BorderRadius.circular(5),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('India'),
        ),
      ],
    ),
  );
}
