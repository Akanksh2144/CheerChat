import 'package:flutter/material.dart';
import 'package:judotalk/data/country_data.dart';

enum HostStatus { online, offline, busy }

Color getStatusColor(HostStatus status) {
  switch (status) {
    case HostStatus.online:
      return Colors.green;
    case HostStatus.busy:
      return Colors.red;
    case HostStatus.offline:
      return Colors.white;
  }
}

Widget statusCircle(HostStatus status) {
  return Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      color: getStatusColor(status),
      shape: BoxShape.circle,
      border: Border.all(color: Colors.black26, width: 1),
    ),
  );
}

class HostData {
  const HostData(
    this.name,
    this.country,
    this.status,
    this.level,
  );
  final HostStatus status;
  final String name;
  final Country country;
  final String level;
}

const List<HostData> hostData = [
  HostData(
    "Saly dsfkhvbsubvuybvusb",
    Country.india,
    HostStatus.offline,
    "level 2",
  ),
  HostData(
    "Maya",
    Country.bangladesh,
    HostStatus.offline,
    "level 3",
  ),
  HostData(
    "GOGO",
    Country.pakistan,
    HostStatus.offline,
    "level 4",
  ),
  HostData(
    "D",
    Country.argentina,
    HostStatus.offline,
    "level 5",
  ),
  HostData(
    "E",
    Country.australia,
    HostStatus.offline,
    "level 2",
  ),
  HostData("F", Country.brazil, HostStatus.offline, "level 1"),
  HostData("G", Country.bahrain, HostStatus.offline, "level 2"),
  HostData("H", Country.canada, HostStatus.offline, "level 3"),
  HostData("I", Country.colombia, HostStatus.offline, "level 4"),
  HostData("J", Country.egypt, HostStatus.offline, "level 1"),
  HostData("K", Country.germany, HostStatus.offline, "level 3"),
  HostData(
    "L",
    Country.indonesia,
    HostStatus.offline,
    "level 1",
  ),
  HostData("M", Country.morocco, HostStatus.offline, "level 5"),
  HostData("N", Country.nepal, HostStatus.offline, "level 3"),
  HostData(
    "O",
    Country.philippines,
    HostStatus.offline,
    "level 2",
  ),
  HostData(
    "P",
    Country.saudiaArabia,
    HostStatus.offline,
    "level 1",
  ),
  HostData("Q", Country.turkey, HostStatus.offline, "level 1"),
  HostData(
    "R",
    Country.unitedStates,
    HostStatus.offline,
    "level 1",
  ),
  HostData(
    "S",
    Country.unitedKingdom,
    HostStatus.offline,
    "level 1",
  ),
  HostData(
    "T",
    Country.unitedArabEmirates,
    HostStatus.offline,
    "level 1",
  ),
  HostData("U", Country.ukraine, HostStatus.offline, "level 1"),
  HostData(
    "V",
    Country.venezuala,
    HostStatus.offline,
    "level 1",
  ),
  HostData("W", Country.vietnam, HostStatus.offline, "level 2"),
  HostData("X", Country.india, HostStatus.offline, "level 4"),
  HostData("Y", Country.bahrain, HostStatus.offline, "level 3"),
  HostData(
    "Z",
    Country.unitedArabEmirates,
    HostStatus.offline,
    "level 5",
  ),
  HostData("A", Country.pakistan, HostStatus.offline, "level 2"),
  HostData(
    "B",
    Country.bangladesh,
    HostStatus.offline,
    "level 1",
  ),
  HostData("C", Country.egypt, HostStatus.offline, "level 1"),
  HostData("D", Country.colombia, HostStatus.offline, "level 1"),
  HostData(
    "E",
    Country.australia,
    HostStatus.offline,
    "level 1",
  ),
  HostData("F", Country.ukraine, HostStatus.offline, "level 1"),
  HostData("G", Country.india, HostStatus.offline, "level 1"),
  HostData("H", Country.canada, HostStatus.offline, "level 1"),
  HostData(
    "I",
    Country.bangladesh,
    HostStatus.offline,
    "level 1",
  ),
  HostData("J", Country.bahrain, HostStatus.offline, "level 1"),
  HostData("K", Country.nepal, HostStatus.offline, "level 1"),
  HostData(
    "L",
    Country.venezuala,
    HostStatus.offline,
    "level 1",
  ),
  HostData(
    "M",
    Country.unitedArabEmirates,
    HostStatus.offline,
    "level 2",
  ),
  HostData(
    "N",
    Country.unitedKingdom,
    HostStatus.offline,
    "level 3",
  ),
  HostData(
    "O",
    Country.unitedStates,
    HostStatus.offline,
    "level 1",
  ),
  HostData("P", Country.india, HostStatus.offline, "level 4"),
  HostData("Q", Country.india, HostStatus.offline, "level 2"),
  HostData("R", Country.india, HostStatus.offline, "level 3"),
];
