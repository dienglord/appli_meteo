import 'package:json_annotation/json_annotation.dart';

part 'modele_meteo.g.dart';

// Modèle principal pour les réponses de l'API météo
@JsonSerializable()
class ReponseMeteo {
  final String name;
  final DonneesMeteo main;
  final List<DescriptionMeteo> weather;
  final Coordonnees coord;
  final InfosPays sys;

  ReponseMeteo({
    required this.name,
    required this.main,
    required this.weather,
    required this.coord,
    required this.sys,
  });

  factory ReponseMeteo.fromJson(Map<String, dynamic> json) =>
      _$ReponseMeteoFromJson(json);
  Map<String, dynamic> toJson() => _$ReponseMeteoToJson(this);
}

// Modèle pour les données météorologiques principales
@JsonSerializable()
class DonneesMeteo {
  final double temp;
  @JsonKey(name: 'feels_like')
  final double tempRessentie;
  @JsonKey(name: 'temp_min')
  final double tempMin;
  @JsonKey(name: 'temp_max')
  final double tempMax;
  final int pressure;
  final int humidity;

  DonneesMeteo({
    required this.temp,
    required this.tempRessentie,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
  });

  factory DonneesMeteo.fromJson(Map<String, dynamic> json) =>
      _$DonneesMeteoFromJson(json);
  Map<String, dynamic> toJson() => _$DonneesMeteoToJson(this);
}

// Modèle pour la description des conditions météorologiques
@JsonSerializable()
class DescriptionMeteo {
  final int id;
  final String main;
  final String description;
  final String icon;

  DescriptionMeteo({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  factory DescriptionMeteo.fromJson(Map<String, dynamic> json) =>
      _$DescriptionMeteoFromJson(json);
  Map<String, dynamic> toJson() => _$DescriptionMeteoToJson(this);
}

// Modèle pour les coordonnées géographiques
@JsonSerializable()
class Coordonnees {
  final double lon;
  final double lat;

  Coordonnees({required this.lon, required this.lat});

  factory Coordonnees.fromJson(Map<String, dynamic> json) =>
      _$CoordonneesFromJson(json);
  Map<String, dynamic> toJson() => _$CoordonneesToJson(this);
}

// Modèle pour les informations sur le pays
@JsonSerializable()
class InfosPays {
  final String country;

  InfosPays({required this.country});

  factory InfosPays.fromJson(Map<String, dynamic> json) =>
      _$InfosPaysFromJson(json);
  Map<String, dynamic> toJson() => _$InfosPaysToJson(this);
}
