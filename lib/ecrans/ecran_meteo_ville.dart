import 'package:flutter/material.dart';
import '../modeles/modele_meteo.dart';
import '../services/service_meteo.dart';
import 'ecran_details_ville.dart';

class EcranMeteoVille extends StatefulWidget {
  final String nomVille;

  const EcranMeteoVille({super.key, required this.nomVille});

  @override
  State<EcranMeteoVille> createState() => _EcranMeteoVilleState();
}

class _EcranMeteoVilleState extends State<EcranMeteoVille>
    with TickerProviderStateMixin {
  late AnimationController _controleurChargement;
  late AnimationController _controleurResultat;
  late Animation<double> _animationRotation;
  late Animation<double> _animationFondu;

  bool _enChargement = true;
  bool _aErreur = false;
  String _messageErreur = '';
  ReponseMeteo? _meteo;

  final DepotMeteo _depotMeteo = DepotMeteo();

  @override
  void initState() {
    super.initState();
    _controleurChargement = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _controleurResultat = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animationRotation =
        Tween<double>(begin: 0, end: 1).animate(_controleurChargement);
    _animationFondu = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controleurResultat, curve: Curves.easeIn),
    );

    _chargerMeteo();
  }

  @override
  void dispose() {
    _controleurChargement.dispose();
    _controleurResultat.dispose();
    super.dispose();
  }

  Future<void> _chargerMeteo() async {
    setState(() {
      _enChargement = true;
      _aErreur = false;
    });

    _controleurChargement.repeat();

    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      final meteo = await _depotMeteo.recupererMeteoPourVille(widget.nomVille);

      if (!mounted) return;

      setState(() {
        _meteo = meteo;
        _enChargement = false;
      });

      _controleurChargement.stop();
      _controleurResultat.forward();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _aErreur = true;
        _messageErreur =
            'Impossible de récupérer les données météo pour ${widget.nomVille}';
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

  // Calcule l'amplitude thermique entre min et max
  String _calculerAmplitudeThermique() {
    final amplitude = (_meteo!.main.tempMax - _meteo!.main.tempMin).abs();
    return '${amplitude.round()}°C';
  }

  // Détermine le type d'amplitude thermique
  String _obtenirTypeAmplitude() {
    final amplitude = (_meteo!.main.tempMax - _meteo!.main.tempMin).abs();
    if (amplitude < 3) {
      return 'Faible variation';
    } else if (amplitude < 8) {
      return 'Variation modérée';
    } else {
      return 'Forte variation';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Météo - ${widget.nomVille}'),
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
    } else if (_meteo != null) {
      return _construireEcranResultat();
    } else {
      return const Center(child: Text('État inconnu'));
    }
  }

  Widget _construireEcranChargement() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: _animationRotation,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.1 * 255).toInt()),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withAlpha((0.3 * 255).toInt()),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.cloud_download,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Récupération des données météo...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            widget.nomVille,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        ],
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
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red.withAlpha((0.1 * 255).toInt()),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red, width: 2),
              ),
              child:
                  const Icon(Icons.error_outline, size: 50, color: Colors.red),
            ),
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
              onPressed: _chargerMeteo,
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
    if (_meteo == null) return const SizedBox();

    return FadeTransition(
      opacity: _animationFondu,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withAlpha((0.9 * 255).toInt()),
                      Colors.white.withAlpha((0.7 * 255).toInt()),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // En-tête avec nom de ville et pays
                    Text(
                      '${_meteo!.name}',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2d3436),
                              ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      _meteo!.sys.country,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF636e72),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Température principale avec icône météo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _obtenirIconeMeteo(_meteo!.weather.first.icon),
                          style: const TextStyle(fontSize: 60),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_meteo!.main.temp.round()}°C',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2d3436),
                                  ),
                            ),
                            Text(
                              _obtenirDescriptionTraduiteMeteo(
                                  _meteo!.weather.first.description),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: const Color(0xFF636e72),
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Container(
                      height: 1,
                      color: Colors.grey.withAlpha((0.3 * 255).toInt()),
                    ),
                    const SizedBox(height: 20),

                    // Première ligne : Ressentie, Humidité, Pression
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _construireDetailMeteo(
                          '🌡️',
                          'Ressentie',
                          '${_meteo!.main.tempRessentie.round()}°C',
                        ),
                        _construireDetailMeteo(
                          '💧',
                          'Humidité',
                          '${_meteo!.main.humidity}%',
                        ),
                        _construireDetailMeteo(
                          '📊',
                          'Pression',
                          '${_meteo!.main.pressure} hPa',
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Deuxième ligne : Températures Min/Max avec amplitude
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _construireDetailMeteo(
                          '🔽',
                          'Minimum',
                          '${_meteo!.main.tempMin.round()}°C',
                        ),
                        _construireDetailMeteo(
                          '🔼',
                          'Maximum',
                          '${_meteo!.main.tempMax.round()}°C',
                        ),
                        _construireDetailMeteo(
                          '📈',
                          'Amplitude',
                          _calculerAmplitudeThermique(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Note explicative sur l'amplitude thermique
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha((0.1 * 255).toInt()),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.trending_up,
                              size: 16, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${_obtenirTypeAmplitude()} - Températures du jour',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.blue[700],
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Boutons d'action en bas
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              EcranDetailsVille(reponseMeteo: _meteo!),
                        ),
                      );
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Plus de détails'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _chargerMeteo,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualiser'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _construireDetailMeteo(String icone, String label, String valeur) {
    return Expanded(
      child: Column(
        children: [
          Text(
            icone,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF636e72),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            valeur,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2d3436),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
