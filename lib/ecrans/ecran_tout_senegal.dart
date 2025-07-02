import 'package:flutter/material.dart';
import '../modeles/modele_meteo.dart';
import '../services/service_meteo.dart';
import 'ecran_details_ville.dart';

class EcranToutSenegal extends StatefulWidget {
  const EcranToutSenegal({super.key});

  @override
  State<EcranToutSenegal> createState() => _EcranToutSenegalState();
}

class _EcranToutSenegalState extends State<EcranToutSenegal>
    with TickerProviderStateMixin {
  late AnimationController _controleurChargement;
  late AnimationController _controleurResultat;
  late Animation<double> _animationProgression;
  late Animation<double> _animationFondu;

  bool _enChargement = true;
  bool _aErreur = false;
  String _messageErreur = '';
  List<ReponseMeteo> _donneesMeteo = [];
  double _progression = 0.0;
  int _villesChargees = 0;

  final DepotMeteo _depotMeteo = DepotMeteo();

  @override
  void initState() {
    super.initState();
    _controleurChargement = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );
    _controleurResultat = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animationProgression =
        Tween<double>(begin: 0, end: 1).animate(_controleurChargement);
    _animationFondu = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controleurResultat, curve: Curves.easeIn),
    );

    _chargerToutesLesVilles();
  }

  @override
  void dispose() {
    _controleurChargement.dispose();
    _controleurResultat.dispose();
    super.dispose();
  }

  Future<void> _chargerToutesLesVilles() async {
    setState(() {
      _enChargement = true;
      _aErreur = false;
      _donneesMeteo.clear();
      _progression = 0.0;
      _villesChargees = 0;
    });

    _controleurChargement.forward();

    try {
      final totalVilles = DepotMeteo.villesSenegal.length;

      for (int i = 0; i < DepotMeteo.villesSenegal.length; i++) {
        final ville = DepotMeteo.villesSenegal[i];

        try {
          final meteo = await _depotMeteo.recupererMeteoPourVille(
            ville.split(',')[0],
            codePays: 'SN',
          );

          if (!mounted) return;

          setState(() {
            _donneesMeteo.add(meteo);
            _villesChargees = i + 1;
            _progression = _villesChargees / totalVilles;
          });

          await Future.delayed(const Duration(milliseconds: 300));
        } catch (e) {
          debugPrint('Erreur lors de la récupération pour la ville $ville: $e');
        }
      }

      if (!mounted) return;

      setState(() {
        _enChargement = false;
      });

      _controleurChargement.stop();
      _controleurResultat.forward();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _aErreur = true;
        _messageErreur =
            'Erreur lors du chargement des données météo du Sénégal';
        _enChargement = false;
      });
      _controleurChargement.stop();
    }
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
      appBar: AppBar(
        title: const Text('🇸🇳 Météo - Tout le Sénégal'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.brightness == Brightness.dark
                ? [
                    const Color(0xFF1a1a2e),
                    const Color(0xFF16213e),
                  ]
                : [
                    const Color(0xFF74b9ff),
                    const Color(0xFF0984e3),
                  ],
          ),
        ),
        child: SafeArea(
          child: _construireContenu(),
        ),
      ),
    );
  }

  Widget _construireContenu() {
    if (_enChargement) {
      return _construireEcranChargement();
    } else if (_aErreur) {
      return _construireEcranErreur();
    } else {
      return _construireEcranResultat();
    }
  }

  Widget _construireEcranChargement() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.1 * 255).toInt()),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withAlpha((0.3 * 255).toInt()),
                  width: 3,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _progression,
                    strokeWidth: 8,
                    backgroundColor:
                        Colors.white.withAlpha((0.2 * 255).toInt()),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_city,
                        size: 40,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_progression * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Chargement de toutes les villes du Sénégal...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              '$_villesChargees / ${DepotMeteo.villesSenegal.length} villes chargées',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireEcranErreur() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              _messageErreur,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _chargerToutesLesVilles,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireEcranResultat() {
    return FadeTransition(
      opacity: _animationFondu,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'BOOM ! 💥🇸🇳',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_donneesMeteo.length} villes du Sénégal chargées',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _donneesMeteo.length,
              itemBuilder: (context, index) {
                final meteo = _donneesMeteo[index];
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  curve: Curves.easeOutBack,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                EcranDetailsVille(reponseMeteo: meteo),
                          ),
                        );
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withAlpha((0.1 * 255).toInt()),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            _obtenirIconeMeteo(meteo.weather.first.icon),
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      title: Text(
                        meteo.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _obtenirDescriptionTraduiteMeteo(
                              meteo.weather.first.description,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.water_drop,
                                size: 14,
                                color: Colors.blue[300],
                              ),
                              Text(
                                ' ${meteo.main.humidity}%',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.speed,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              Text(
                                ' ${meteo.main.pressure} hPa',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${meteo.main.temp.round()}°C',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '${meteo.main.tempMin.round()}°/${meteo.main.tempMax.round()}°',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              onPressed: _chargerToutesLesVilles,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualiser toutes les données'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
