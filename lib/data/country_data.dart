import 'package:flag/flag.dart';

enum Country {
  india,
  bangladesh,
  pakistan,
  argentina,
  australia,
  brazil,
  bahrain,
  canada,
  colombia,
  egypt,
  germany,
  indonesia,
  morocco,
  nepal,
  philippines,
  saudiaArabia,
  turkey,
  unitedStates,
  unitedKingdom,
  unitedArabEmirates,
  ukraine,
  venezuala,
  vietnam,
}

extension CountryExtension on Country {
  FlagsCode get flagCode {
    switch (this) {
      case Country.india:
        return FlagsCode.IN;
      case Country.bangladesh:
        return FlagsCode.BD;
      case Country.pakistan:
        return FlagsCode.PK;
      case Country.argentina:
        return FlagsCode.AR;
      case Country.australia:
        return FlagsCode.AU;
      case Country.brazil:
        return FlagsCode.BR;
      case Country.bahrain:
        return FlagsCode.BH;
      case Country.canada:
        return FlagsCode.CA;
      case Country.colombia:
        return FlagsCode.CO;
      case Country.egypt:
        return FlagsCode.EG;
      case Country.germany:
        return FlagsCode.DE;
      case Country.indonesia:
        return FlagsCode.ID;
      case Country.morocco:
        return FlagsCode.MA;
      case Country.nepal:
        return FlagsCode.NP;
      case Country.philippines:
        return FlagsCode.PH;
      case Country.saudiaArabia:
        return FlagsCode.SA;
      case Country.turkey:
        return FlagsCode.TR;
      case Country.unitedStates:
        return FlagsCode.US;
      case Country.unitedKingdom:
        return FlagsCode.GB;
      case Country.unitedArabEmirates:
        return FlagsCode.AE;
      case Country.ukraine:
        return FlagsCode.UA;
      case Country.venezuala:
        return FlagsCode.VE;
      case Country.vietnam:
        return FlagsCode.VN;
    }
  }
}



const Map<Country, String> countryNames = {
  Country.india: "India",
  Country.bangladesh: "Bangladesh",
  Country.pakistan: "Pakistan",
  Country.argentina: "Argentina",
  Country.australia: "Australia",
  Country.brazil: "Brazil",
  Country.bahrain: "Bahrain",
  Country.canada: "Canada",
  Country.colombia: "Colombia",
  Country.egypt: "Egypt",
  Country.germany: "Germany",
  Country.indonesia: "Indonesia",
  Country.morocco: "Morocco",
  Country.nepal: "Nepal",
  Country.philippines: "Philippines",
  Country.saudiaArabia: "Saudi Arabia",
  Country.turkey: "Turkey",
  Country.unitedStates: "United States",
  Country.unitedKingdom: "United Kingdom",
  Country.unitedArabEmirates: "United Arab Emirates",
  Country.ukraine: "Ukraine",
  Country.venezuala: "Venezuela",
  Country.vietnam: "Vietnam",
};
