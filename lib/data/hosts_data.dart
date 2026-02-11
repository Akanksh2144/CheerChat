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
    this.level, {
    this.images,
  });
  final HostStatus status;
  final String name;
  final Country country;
  final String level;
  final List<String>? images;
}

const List<HostData> hostData = [
  HostData(
    "Saly",
    Country.india,
    HostStatus.offline,
    "level 2",
    images: [],

    // images: [
    //   "https://media.istockphoto.com/id/1455397163/photo/portrait-of-indian-dark-pretty-girl.jpg?s=2048x2048&w=is&k=20&c=3NUASBYzvRvKn8H8J3OgILfKeAVTrY8-qihYmdjRVFA=",
    //   "https://img.freepik.com/premium-photo/cute-girl-stock-photos-royalty-free-girl-images_152808-937.jpg",
    // ],
  ),
  HostData(
    "Maya",
    Country.bangladesh,
    HostStatus.offline,
    "level 3",
    images: [],
  ),
  HostData(
    "GOGO",
    Country.pakistan,
    HostStatus.offline,
    "level 4",
    images: [],
  ),
  HostData(
    "D",
    Country.argentina,
    HostStatus.offline,
    "level 5",
    images: [],
  ),
  HostData(
    "E",
    Country.australia,
    HostStatus.offline,
    "level 2",
    images: [],
  ),
  HostData(
    "F",
    Country.brazil,
    HostStatus.offline,
    "level 1",
    images: [],
  ),
  HostData(
    "G",
    Country.bahrain,
    HostStatus.offline,
    "level 2",
    images: [],
  ),
  HostData(
    "H",
    Country.canada,
    HostStatus.offline,
    "level 3",
    images: [],
  ),
  HostData(
    "I",
    Country.colombia,
    HostStatus.offline,
    "level 4",
    images: [],
  ),
  HostData(
    "J",
    Country.egypt,
    HostStatus.offline,
    "level 1",
    images: [],
  ),
  HostData(
    "K",
    Country.germany,
    HostStatus.offline,
    "level 3",
    images: [],
  ),
  HostData(
    "L",
    Country.indonesia,
    HostStatus.offline,
    "level 1",
    images: [],
  ),
  HostData(
    "M",
    Country.morocco,
    HostStatus.offline,
    "level 5",
    images: [],
  ),
  HostData(
    "N",
    Country.nepal,
    HostStatus.offline,
    "level 3",
    images: [],
  ),
  HostData(
    "O",
    Country.philippines,
    HostStatus.offline,
    "level 2",
    images: [],
  ),
  HostData(
    "P",
    Country.saudiaArabia,
    HostStatus.offline,
    "level 1",
    images: [],
  ),
  HostData(
    "Q",
    Country.turkey,
    HostStatus.offline,
    "level 1",
    images: [],
  ),
  HostData(
    "R",
    Country.unitedStates,
    HostStatus.offline,
    "level 1",
    images: [],
  ),
  HostData(
    "S",
    Country.unitedKingdom,
    HostStatus.offline,
    "level 1",
    images: [],
  ),
  HostData(
    "T",
    Country.unitedArabEmirates,
    HostStatus.offline,
    "level 1",
    images: [],
  ),
  HostData(
    "U",
    Country.ukraine,
    HostStatus.offline,
    "level 1",
    images: [],
  ),
  HostData(
    "V",
    Country.venezuala,
    HostStatus.offline,
    "level 1",
    images: [],
  ),
  HostData(
    "W",
    Country.vietnam,
    HostStatus.offline,
    "level 2",
    images: [],
  ),
  HostData(
    "X",
    Country.india,
    HostStatus.offline,
    "level 4",
    images: [],
  ),
  HostData(
    "Y",
    Country.bahrain,
    HostStatus.offline,
    "level 3",
    images: [],
  ),
  HostData(
    "Z",
    Country.unitedArabEmirates,
    HostStatus.offline,
    "level 5",
    images: [],
  ),
  HostData(
    "A",
    Country.pakistan,
    HostStatus.offline,
    "level 2",
    images: [],
  ),
  HostData(
    "B",
    Country.bangladesh,
    HostStatus.offline,
    "level 1",
    images: [],
  ),
  HostData(
    "C",
    Country.egypt,
    HostStatus.offline,
    "level 1",
    images: [],
  ),
  HostData(
    "D",
    Country.colombia,
    HostStatus.offline,
    "level 1",
    images: [],
  ),
  HostData(
    "E",
    Country.australia,
    HostStatus.offline,
    "level 1",
    images: [],
  ),
  HostData(
    "F",
    Country.ukraine,
    HostStatus.offline,
    "level 1",
    images: [],
  ),
  HostData(
    "G",
    Country.india,
    HostStatus.offline,
    "level 1",
    images: [],
  ),
  HostData(
    "H",
    Country.canada,
    HostStatus.offline,
    "level 1",
    images: [],
  ),
  HostData(
    "I",
    Country.bangladesh,
    HostStatus.offline,
    "level 1",
    images: [],
  ),
  HostData(
    "J",
    Country.bahrain,
    HostStatus.offline,
    "level 1",
    images: [],
  ),
  HostData(
    "K",
    Country.nepal,
    HostStatus.offline,
    "level 1",
    images: [],
  ),
  HostData(
    "L",
    Country.venezuala,
    HostStatus.offline,
    "level 1",
    images: [],
  ),
  HostData(
    "M",
    Country.unitedArabEmirates,
    HostStatus.offline,
    "level 2",
    images: [],
  ),
  HostData(
    "N",
    Country.unitedKingdom,
    HostStatus.offline,
    "level 3",
    images: [],
  ),
  HostData(
    "O",
    Country.unitedStates,
    HostStatus.offline,
    "level 1",
    images: [],
  ),
  HostData(
    "P",
    Country.india,
    HostStatus.offline,
    "level 4",
    images: [],
  ),
  HostData(
    "Q",
    Country.india,
    HostStatus.offline,
    "level 2",
    images: [],
  ),
  HostData(
    "R",
    Country.india,
    HostStatus.offline,
    "level 3",
    images: [],
  ),
];
