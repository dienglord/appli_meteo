import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/theme_appli.dart';
import 'providers/gestionnaire_theme.dart';
import 'ecrans/ecran_accueil.dart';
import 'ecrans/ecran_chargement_meteo.dart';
import 'ecrans/ecran_meteo_ville.dart';
import 'ecrans/ecran_tout_senegal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Paramétrage de la barre de statut pour un affichage optimal
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MonAppliMeteo());
}

class MonAppliMeteo extends StatelessWidget {
  const MonAppliMeteo({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GestionnaireTheme()),
      ],
      child: Consumer<GestionnaireTheme>(
        builder: (context, gestionnaireTheme, child) {
          return MaterialApp(
            title: 'Météo Sénégal',
            debugShowCheckedModeBanner: false,

            // Paramétrage des thèmes clair et sombre
            theme: ThemeAppli.themeClair,
            darkTheme: ThemeAppli.themeSombre,
            themeMode: gestionnaireTheme.modeTheme,

            // Paramétrage des routes de navigation
            initialRoute: '/',
            routes: {
              '/': (context) => const EcranAccueilAvecBasculeurTheme(),
              '/chargement': (context) => const EcranChargementMeteo(),
              '/tout_senegal': (context) => const EcranToutSenegal(),
            },
            onGenerateRoute: (settings) {
              // Route dynamique pour afficher une ville spécifique
              if (settings.name == '/meteo_ville') {
                final nomVille = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) => EcranMeteoVille(nomVille: nomVille),
                );
              }
              return null;
            },

            // Paramétrage général de l'application
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

class EcranAccueilAvecBasculeurTheme extends StatelessWidget {
  const EcranAccueilAvecBasculeurTheme({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Écran d'accueil principal de l'application
          const EcranAccueil(),

          // Bouton de basculement entre thème clair et sombre
          Positioned(
            top: 50,
            right: 16,
            child: SafeArea(
              child: Consumer<GestionnaireTheme>(
                builder: (context, gestionnaireTheme, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.2 * 255).toInt()),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withAlpha((0.3 * 255).toInt()),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      onPressed: gestionnaireTheme.basculerTheme,
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          gestionnaireTheme.estModeSombre
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          key: ValueKey(gestionnaireTheme.estModeSombre),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      tooltip: gestionnaireTheme.estModeSombre
                          ? 'Passer en mode clair'
                          : 'Passer en mode sombre',
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
