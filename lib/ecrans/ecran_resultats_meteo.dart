import 'package:flutter/material.dart';
import '../modeles/modele_meteo.dart';
import 'ecran_details_ville.dart';
import 'ecran_chargement_meteo.dart';

class EcranResultatsMeteo extends StatefulWidget {
  final List<ReponseMeteo> donneesMeteo;

  const EcranResultatsMeteo({
    super.key,
    required this.donneesMeteo,
  });

  @override
  State<EcranResultatsMeteo> createState() => EtatEcranResultatsMeteo();
}

class EtatEcranResultatsMeteo extends State<EcranResultatsMeteo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controleurAnimation;
  late Animation<double> _animationFondu;

  @override
  void initState() {
    super.initState();
    _controleurAnimation = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationFondu = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controleurAnimation, curve: Curves.easeIn),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      _controleurAnimation.forward();
    });
  }

  @override
  void dispose() {
    _controleurAnimation.dispose();
    super.dispose();
  }

  void _ouvrirDetailsVille(ReponseMeteo meteo) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EcranDetailsVille(reponseMeteo: meteo),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _recommencer() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const EcranChargementMeteo(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  String _obtenirIconeMeteo(String iconeCode) {
    switch (iconeCode.substring(0, 2)) {
      case '01':
        return '☀️';
      case '02':
        return '⛅';
      case '03':
      case '04':
        return '☁️';
      case '09':
      case '10':
        return '🌧️';
      case '11':
        return '⛈️';
      case '13':
        return '🌨️';
      case '50':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  String _obtenirDescriptionTraduiteMeteo(String description) {
    final traductions = {
      'clear sky': 'Ciel dégagé',
      'few clouds': 'Quelques nuages',
      'scattered clouds': 'Nuages épars',
      'broken clouds': 'Nuages fragmentés',
      'shower rain': 'Averses',
      'rain': 'Pluie',
      'thunderstorm': 'Orage',
      'snow': 'Neige',
      'mist': 'Brume',
      'overcast clouds': 'Ciel couvert',
      'light rain': 'Pluie légère',
      'moderate rain': 'Pluie modérée',
      'heavy intensity rain': 'Pluie forte',
    };

    return traductions[description.toLowerCase()] ?? description;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: FadeTransition(
        opacity: _animationFondu,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 36),
              // Message BOOM ! après remplissage de la jauge
              Text(
                'BOOM ! 💥',
                style: theme.textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Données météo pour 5 villes',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 30),
              // Tableau interactif avec les données météo
              Expanded(
                child: ListView.builder(
                  itemCount: widget.donneesMeteo.length,
                  itemBuilder: (context, index) {
                    final meteo = widget.donneesMeteo[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        onTap: () => _ouvrirDetailsVille(meteo),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        leading: Text(
                          _obtenirIconeMeteo(meteo.weather.first.icon),
                          style: const TextStyle(fontSize: 30),
                        ),
                        title: Text(
                          '${meteo.name} (${meteo.sys.country})',
                          style: theme.textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          _obtenirDescriptionTraduiteMeteo(
                              meteo.weather.first.description),
                          style: theme.textTheme.bodyMedium,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${meteo.main.temp.round()}°C',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Bouton Recommencer (la jauge se transforme en bouton)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: ElevatedButton.icon(
                  onPressed: _recommencer,
                  icon: const Icon(Icons.replay),
                  label: const Text("Recommencer"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 16),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
