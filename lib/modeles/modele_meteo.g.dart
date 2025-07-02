// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modele_meteo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReponseMeteo _$ReponseMeteoFromJson(Map<String, dynamic> json) => ReponseMeteo(
      name: json['name'] as String,
      main: DonneesMeteo.fromJson(json['main'] as Map<String, dynamic>),
      weather: (json['weather'] as List<dynamic>)
          .map((e) => DescriptionMeteo.fromJson(e as Map<String, dynamic>))
          .toList(),
      coord: Coordonnees.fromJson(json['coord'] as Map<String, dynamic>),
      sys: InfosPays.fromJson(json['sys'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReponseMeteoToJson(ReponseMeteo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'main': instance.main,
      'weather': instance.weather,
      'coord': instance.coord,
      'sys': instance.sys,
    };

DonneesMeteo _$DonneesMeteoFromJson(Map<String, dynamic> json) => DonneesMeteo(
      temp: (json['temp'] as num).toDouble(),
      tempRessentie: (json['feels_like'] as num).toDouble(),
      tempMin: (json['temp_min'] as num).toDouble(),
      tempMax: (json['temp_max'] as num).toDouble(),
      pressure: (json['pressure'] as num).toInt(),
      humidity: (json['humidity'] as num).toInt(),
    );

Map<String, dynamic> _$DonneesMeteoToJson(DonneesMeteo instance) =>
    <String, dynamic>{
      'temp': instance.temp,
      'feels_like': instance.tempRessentie,
      'temp_min': instance.tempMin,
      'temp_max': instance.tempMax,
      'pressure': instance.pressure,
      'humidity': instance.humidity,
    };

DescriptionMeteo _$DescriptionMeteoFromJson(Map<String, dynamic> json) =>
    DescriptionMeteo(
      id: (json['id'] as num).toInt(),
      main: json['main'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
    );

Map<String, dynamic> _$DescriptionMeteoToJson(DescriptionMeteo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'main': instance.main,
      'description': instance.description,
      'icon': instance.icon,
    };

Coordonnees _$CoordonneesFromJson(Map<String, dynamic> json) => Coordonnees(
      lon: (json['lon'] as num).toDouble(),
      lat: (json['lat'] as num).toDouble(),
    );

Map<String, dynamic> _$CoordonneesToJson(Coordonnees instance) =>
    <String, dynamic>{
      'lon': instance.lon,
      'lat': instance.lat,
    };

InfosPays _$InfosPaysFromJson(Map<String, dynamic> json) => InfosPays(
      country: json['country'] as String,
    );

Map<String, dynamic> _$InfosPaysToJson(InfosPays instance) => <String, dynamic>{
      'country': instance.country,
    };
