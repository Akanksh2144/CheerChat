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
  const HostData(this.name, this.country, this.status);
  final HostStatus status;
  final String name;
  final Country country;
}

const List<HostData> hostData = [
  HostData(
    "Saly dsfkhvbsubvuybvusb",
    Country.india,
    HostStatus.offline,
  ),
  HostData("Maya", Country.bangladesh, HostStatus.offline),
  HostData("GOGO", Country.pakistan, HostStatus.offline),
  HostData("D", Country.argentina, HostStatus.offline),
  HostData("E", Country.australia, HostStatus.offline),
  HostData("F", Country.brazil, HostStatus.offline),
  HostData("G", Country.bahrain, HostStatus.offline),
  HostData("H", Country.canada, HostStatus.offline),
  HostData("I", Country.colombia, HostStatus.offline),
  HostData("J", Country.egypt, HostStatus.offline),
  HostData("K", Country.germany, HostStatus.offline),
  HostData("L", Country.indonesia, HostStatus.offline),
  HostData("M", Country.morocco, HostStatus.offline),
  HostData("N", Country.nepal, HostStatus.offline),
  HostData("O", Country.philippines, HostStatus.offline),
  HostData("P", Country.saudiaArabia, HostStatus.offline),
  HostData("Q", Country.turkey, HostStatus.offline),
  HostData("R", Country.unitedStates, HostStatus.offline),
  HostData("S", Country.unitedKingdom, HostStatus.offline),
  HostData("T", Country.unitedArabEmirates, HostStatus.offline),
  HostData("U", Country.ukraine, HostStatus.offline),
  HostData("V", Country.venezuala, HostStatus.offline),
  HostData("W", Country.vietnam, HostStatus.offline),
  HostData("X", Country.india, HostStatus.offline),
  HostData("Y", Country.bahrain, HostStatus.offline),
  HostData("Z", Country.unitedArabEmirates, HostStatus.offline),
  HostData("A", Country.pakistan, HostStatus.offline),
  HostData("B", Country.bangladesh, HostStatus.offline),
  HostData("C", Country.egypt, HostStatus.offline),
  HostData("D", Country.colombia, HostStatus.offline),
  HostData("E", Country.australia, HostStatus.offline),
  HostData("F", Country.ukraine, HostStatus.offline),
  HostData("G", Country.india, HostStatus.offline),
  HostData("H", Country.canada, HostStatus.offline),
  HostData("I", Country.bangladesh, HostStatus.offline),
  HostData("J", Country.bahrain, HostStatus.offline),
  HostData("K", Country.nepal, HostStatus.offline),
  HostData("L", Country.venezuala, HostStatus.offline),
  HostData("M", Country.unitedArabEmirates, HostStatus.offline),
  HostData("N", Country.unitedKingdom, HostStatus.offline),
  HostData("O", Country.unitedStates, HostStatus.offline),
  HostData("P", Country.india, HostStatus.offline),
  HostData("Q", Country.india, HostStatus.offline),
  HostData("R", Country.india, HostStatus.offline),
];
