# Météo Sénégal - Application Flutter

## Auteur: Leopold DIENG

## Description du Projet
Application Flutter moderne pour consulter la météo en temps réel au Sénégal et dans le monde, avec une interface élégante et des animations fluides.

## Fonctionnalités Principales

### Écran d'Accueil
- **Double mode** : Sénégal (par défaut) et Monde
- **6 villes principales** affichées avec icônes représentatives
- **Recherche personnalisée** de villes (mode Monde)
- **Animations d'entrée** fluides pour chaque carte
- **Basculeur de thème** clair/sombre en haut à droite

### Écran de Chargement
- **Jauge de progression circulaire** animée
- **Messages dynamiques** qui alternent automatiquement
- **Chargement progressif** des 5 principales villes du Sénégal
- **Gestion d'erreurs** avec possibilité de réessayer

### Écran Toutes les Villes du Sénégal
- **25 villes du Sénégal** chargées progressivement
- **Indicateur de progression** détaillé
- **Cartes détaillées** avec température, humidité et pression
- **Animation d'apparition** pour chaque ville

### Écran Détails Ville
- **Météo complète** : température actuelle, ressentie, min/max
- **Amplitude thermique** calculée automatiquement
- **Conditions atmosphériques** : humidité, pression
- **Lien Google Maps** pour voir la localisation
- **Boutons d'action** : Plus de détails et Actualiser

## Technologies Utilisées

### Architecture & Packages
- **Retrofit + Dio** : Client API type-safe avec génération de code
- **Provider** : Gestion d'état pour le thème
- **json_annotation** : Sérialisation/désérialisation JSON automatique
- **build_runner** : Génération de code pour Retrofit et JSON
- **percent_indicator** : Indicateurs de progression circulaires
- **shared_preferences** : Sauvegarde des préférences (thème)
- **url_launcher** : Ouverture de liens Google Maps

### API & Services
- **OpenWeatherMap API** : Données météo en temps réel
- **Calcul intelligent** : Températures min/max réalistes basées sur les conditions
- **Support multilingue** : API configurée en français

## Installation et Configuration

### 1. Prérequis
```bash
flutter --version  # Flutter 3.0.0 ou plus récent
dart --version     # Dart 2.17.0 ou plus récent
```

### 2. Cloner le projet
```bash
git clone https://github.com/VOTRE_USERNAME/appli_meteo.git
cd appli_meteo
```

### 3. Installation des dépendances
```bash
flutter pub get
```

### 4. Génération des fichiers Retrofit et JSON
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Configuration de l'API Météo
La clé API OpenWeatherMap est déjà incluse dans le projet pour faciliter les tests :
```dart
static const String _cleApi = "f00c38e0279b7bc85480c3fe775d518c";
```

**Pour production** : Créez votre propre clé sur [OpenWeatherMap](https://openweathermap.org/api)

### 6. Lancer l'application
```bash
flutter run
```

## Fonctionnalités Techniques

### Architecture du Code
```
lib/
├── main.dart                    # Point d'entrée
├── ecrans/                      # Tous les écrans
│   ├── ecran_accueil.dart      # Écran principal avec sélecteur
│   ├── ecran_chargement_meteo.dart
│   ├── ecran_meteo_ville.dart  # Détails d'une ville
│   ├── ecran_resultats_meteo.dart
│   ├── ecran_tout_senegal.dart # Liste complète Sénégal
│   └── ecran_details_ville.dart
├── modeles/                     # Modèles de données
│   ├── modele_meteo.dart       # Classes météo
│   └── modele_meteo.g.dart     # Généré par json_serializable
├── services/                    # Services API
│   ├── service_meteo.dart      # Logique métier + Retrofit
│   └── service_meteo.g.dart    # Généré par Retrofit
├── providers/                   # Gestion d'état
│   └── gestionnaire_theme.dart  # Provider pour le thème
└── theme/                       # Configuration UI
    └── theme_appli.dart        # Thèmes clair et sombre
```

### Points Techniques Importants

#### 1. **Retrofit pour les API**
```dart
@RestApi(baseUrl: "https://api.openweathermap.org/data/2.5/")
abstract class ApiMeteo {
  @GET("/weather")
  Future<ReponseMeteo> obtenirMeteoVille(
    @Query("q") String ville,
    @Query("appid") String cleApi,
    @Query("units") String unites,
    @Query("lang") String langue,
  );
}
```

#### 2. **Calcul Intelligent des Min/Max**
L'app calcule des variations thermiques réalistes basées sur :
- Les conditions météo (ciel dégagé = plus de variation)
- Le taux d'humidité (plus d'humidité = moins de variation)
- La température actuelle (zones tropicales)

#### 3. **Animations Personnalisées**
- AnimationController pour les transitions
- SlideTransition pour l'apparition des cartes
- FadeTransition pour les changements d'écran
- ScaleTransition pour les effets de pulsation

#### 4. **Gestion du Thème**
- Sauvegarde automatique avec SharedPreferences
- Basculement instantané clair/sombre
- Provider pour la propagation dans toute l'app

## Utilisation de l'Application

### Mode Sénégal (par défaut)
1. **6 villes principales** affichées au démarrage
2. **Cliquez sur une ville** pour voir sa météo détaillée
3. **"Voir toutes les villes"** pour accéder aux 25 villes

### Mode Monde
1. **Basculez sur "Monde"** dans le sélecteur
2. **6 grandes villes mondiales** s'affichent
3. **Recherche personnalisée** pour n'importe quelle ville
4. **"Plus de villes"** pour découvrir d'autres métropoles

### Navigation
- **Retour** : Flèche en haut à gauche
- **Actualiser** : Bouton refresh sur chaque écran météo
- **Thème** : Icône soleil/lune en haut à droite

## Tests et Maintenance

### Commandes Utiles
```bash
# Nettoyer le projet
flutter clean

# Vérifier les problèmes
flutter analyze

# Lancer les tests
flutter test

# Construire l'APK
flutter build apk --release

# Régénérer les fichiers
flutter pub run build_runner build --delete-conflicting-outputs
```

### Gestion des Erreurs
- Timeout de 10 secondes sur les appels API
- Messages d'erreur clairs en français
- Bouton "Réessayer" toujours disponible
- Logs en mode debug uniquement

## Liste des Villes

### Villes Principales du Sénégal
- Dakar (Capitale)
- Thiès(Industrie)
- Saint-Louis (Histoire)
- Tambacounda (Nature)
- Ziguinchor (Côte)
- Kaolack (Agriculture)

### Toutes les Villes (25 au total)
Dakar, Thiès, Kaolack, Saint-Louis, Mbour, Ziguinchor, Tambacounda, Diourbel, Touba, Rufisque, Kolda, Matam, Kédougou, Louga, Fatick, Kaffrine, Sédhiou, Podor, Richard-Toll, Linguère, Bakel, Goudiry, Vélingara, Goudomp, Bignona

## Notes Importantes

- **Connexion Internet** requise pour charger les données
- **Clé API** incluse pour faciliter les tests (remplacez en production)
- **Permissions** : Aucune permission spéciale nécessaire
- **Performance** : Optimisée avec délais entre les appels API
- **Cache** : Les préférences de thème sont sauvegardées localement

## Points Forts du Projet

- **Architecture Clean** avec séparation des responsabilités
- **Retrofit + Dio** pour une API type-safe
- **Génération de code** avec build_runner
- **Animations fluides** et design moderne
- **Double mode** Sénégal/Monde
- **Calculs météo intelligents** pour plus de réalisme
- **Gestion d'état** avec Provider
- **Thème adaptatif** clair/sombre
- **25 villes du Sénégal** supportées
- **Interface en français** pour l'utilisateur local

---

**Développé pour le Sénégal 🇸🇳**
