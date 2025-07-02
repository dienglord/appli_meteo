import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../modeles/modele_meteo.dart';

part 'service_meteo.g.dart';

// Interface Retrofit pour les appels API météo conformément aux exigences
@RestApi(baseUrl: "https://api.openweathermap.org/data/2.5/")
abstract class ApiMeteo {
  factory ApiMeteo(Dio dio, {String baseUrl}) = _ApiMeteo;

  @GET("/weather")
  Future<ReponseMeteo> obtenirMeteoVille(
    @Query("q") String ville,
    @Query("appid") String cleApi,
    @Query("units") String unites,
    @Query("lang") String langue,
  );
}

// Service principal pour la gestion des données météo du Sénégal
class DepotMeteo {
  static const String _cleApi = "f00c38e0279b7bc85480c3fe775d518c";

  // Liste complète des principales villes du Sénégal
  static const List<String> villesSenegal = [
    "Dakar,SN",
    "Thiès,SN",
    "Kaolack,SN",
    "Saint-Louis,SN",
    "Mbour,SN",
    "Ziguinchor,SN",
    "Tambacounda,SN",
    "Diourbel,SN",
    "Touba,SN",
    "Rufisque,SN",
    "Kolda,SN",
    "Matam,SN",
    "Kédougou,SN",
    "Louga,SN",
    "Fatick,SN",
    "Kaffrine,SN",
    "Sédhiou,SN",
    "Podor,SN",
    "Richard-Toll,SN",
    "Linguère,SN",
    "Bakel,SN",
    "Goudiry,SN",
    "Vélingara,SN",
    "Goudomp,SN",
    "Bignona,SN"
  ];

  // Cinq villes principales pour l'écran de progression avec jauge
  static const List<String> villesPrincipales = [
    "Dakar,SN",
    "Thiès,SN",
    "Saint-Louis,SN",
    "Tambacounda,SN",
    "Ziguinchor,SN"
  ];

  final ApiMeteo _apiMeteo;

  DepotMeteo() : _apiMeteo = ApiMeteo(_creerDio()) {
    // Initialisation du service avec l'interface Retrofit
  }

  // Création et paramétrage de l'instance Dio pour Retrofit
  static Dio _creerDio() {
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);

    // Journalisation des requêtes en mode débogage uniquement
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }

    return dio;
  }

  /// Calcule des températures min/max réalistes basées sur des modèles météorologiques
  Map<String, double> _calculerVariationThermique(
      double tempActuelle, String description, int humidity) {
    // Facteurs météorologiques réalistes
    double variationBase = 0;

    // Variation selon les conditions météorologiques
    switch (description.toLowerCase()) {
      case 'clear sky':
      case 'few clouds':
        variationBase = 8.0; // Ciel dégagé = plus de variation thermique
        break;
      case 'scattered clouds':
      case 'broken clouds':
        variationBase = 6.0; // Nuages = variation modérée
        break;
      case 'overcast clouds':
        variationBase = 4.0; // Ciel couvert = moins de variation
        break;
      case 'light rain':
      case 'rain':
        variationBase = 3.0; // Pluie = variation faible
        break;
      case 'thunderstorm':
        variationBase = 5.0; // Orage = variation modérée
        break;
      default:
        variationBase = 5.0; // Valeur par défaut
    }

    // Ajustement selon l'humidité (plus d'humidité = moins de variation)
    double facteurHumidite =
        1.0 - (humidity / 200.0); // Réduction selon humidité
    variationBase *= facteurHumidite;

    // Ajustement selon la température (zones tropicales)
    if (tempActuelle > 30) {
      variationBase *= 1.2; // Plus chaud = plus de variation
    } else if (tempActuelle < 20) {
      variationBase *= 0.8; // Plus frais = moins de variation
    }

    // Garantir une variation minimum et maximum
    variationBase = variationBase.clamp(3.0, 12.0);

    // Calcul de l'heure approximative basée sur la température
    // (température élevée = après-midi, température plus basse = matin/soir)
    double facteurHeure =
        0.6; // Assumer qu'on est à 60% vers le maximum journalier

    double tempMax = tempActuelle + (variationBase * (1 - facteurHeure));
    double tempMin = tempActuelle - (variationBase * facteurHeure);

    // Arrondir à 0.5 près pour plus de réalisme
    tempMax = (tempMax * 2).round() / 2;
    tempMin = (tempMin * 2).round() / 2;

    return {
      'min': tempMin,
      'max': tempMax,
    };
  }

  /// Récupère les données météo pour les cinq villes principales avec progression
  Future<List<ReponseMeteo>> recupererToutesLesDonneesMeteo() async {
    List<ReponseMeteo> donneesMeteo = [];

    for (String ville in villesPrincipales) {
      try {
        final meteo = await _recupererMeteoAvecVariationRealiste(ville);
        donneesMeteo.add(meteo);

        // Simulation d'un délai pour créer l'effet de progression visuelle
        await Future.delayed(const Duration(milliseconds: 800));
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Erreur lors de la récupération pour la ville $ville: $e');
        }
        // Continuer avec les autres villes même en cas d'erreur
      }
    }

    return donneesMeteo;
  }

  /// Récupère la météo pour n'importe quelle ville du monde avec variation réaliste
  Future<ReponseMeteo> recupererMeteoPourVille(String nomVille,
      {String? codePays}) async {
    String requeteVille = codePays != null ? '$nomVille,$codePays' : nomVille;
    return await _recupererMeteoAvecVariationRealiste(requeteVille);
  }

  /// Méthode privée qui récupère la météo et calcule des variations réalistes
  Future<ReponseMeteo> _recupererMeteoAvecVariationRealiste(
      String ville) async {
    try {
      // Récupérer les données météo actuelles
      final meteoActuelle = await _apiMeteo.obtenirMeteoVille(
        ville,
        _cleApi,
        'metric',
        'fr',
      );

      // Calculer des températures min/max réalistes
      final variationRealiste = _calculerVariationThermique(
        meteoActuelle.main.temp,
        meteoActuelle.weather.first.description,
        meteoActuelle.main.humidity,
      );

      // Créer une nouvelle instance avec les valeurs réalistes
      final donneesMeteoCorrigees = DonneesMeteo(
        temp: meteoActuelle.main.temp,
        tempRessentie: meteoActuelle.main.tempRessentie,
        tempMin: variationRealiste['min']!,
        tempMax: variationRealiste['max']!,
        pressure: meteoActuelle.main.pressure,
        humidity: meteoActuelle.main.humidity,
      );

      return ReponseMeteo(
        name: meteoActuelle.name,
        main: donneesMeteoCorrigees,
        weather: meteoActuelle.weather,
        coord: meteoActuelle.coord,
        sys: meteoActuelle.sys,
      );
    } catch (e) {
      throw Exception(
          'Impossible de récupérer les données météo pour $ville: $e');
    }
  }

  /// Récupère la météo pour toutes les villes du Sénégal
  Future<List<ReponseMeteo>> recupererMeteoToutSenegal() async {
    List<ReponseMeteo> donneesMeteo = [];

    for (String ville in villesSenegal) {
      try {
        final meteo = await _recupererMeteoAvecVariationRealiste(ville);
        donneesMeteo.add(meteo);

        // Petit délai pour éviter de surcharger l'API OpenWeatherMap
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Erreur lors de la récupération pour la ville $ville: $e');
        }
        // Continuer avec les autres villes même en cas d'erreur
      }
    }

    return donneesMeteo;
  }

  /// Recherche de villes par nom pour l'autocomplétion
  Future<List<String>> rechercherVilles(String recherche) async {
    if (recherche.isEmpty) return [];

    final rechercheMinuscule = recherche.toLowerCase();

    // Recherche dans les villes du Sénégal en priorité
    final villesSenegalFiltrees = villesSenegal
        .where((ville) => ville.toLowerCase().contains(rechercheMinuscule))
        .map((ville) =>
            ville.split(',')[0]) // Retirer le code pays pour l'affichage
        .toList();

    return villesSenegalFiltrees;
  }
}
