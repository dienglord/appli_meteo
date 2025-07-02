import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../modeles/modele_meteo.dart';
import '../services/service_meteo.dart';
import 'ecran_resultats_meteo.dart';

class EcranChargementMeteo extends StatefulWidget {
  const EcranChargementMeteo({super.key});

  @override
  State<EcranChargementMeteo> createState() => EtatEcranChargementMeteo();
}

class EtatEcranChargementMeteo extends State<EcranChargementMeteo>
    with TickerProviderStateMixin {
  late AnimationController _controleurProgression;
  late AnimationController _controleurMessage;
  late AnimationController _controleurPulsation;

  double _progression = 0.0;
  int _indexMessageActuel = 0;
  bool _enChargement = true;
  bool _aUneErreur = false;
  String _messageErreur = '';

  List<ReponseMeteo> _donneesMeteo = [];

  // Messages d'attente dynamiques qui tournent en boucle comme requis
  final List<String> _messagesChargement = [
    'Nous téléchargeons les données... 🌐',
    'C\'est presque fini... ⏳',
    'Plus que quelques secondes avant d\'avoir le résultat... 🎯',
    'Préparation des données météo... 📊',
    'Finalisation... ✨',
  ];

  final DepotMeteo _depotMeteo = DepotMeteo();

  @override
  void initState() {
    super.initState();
    _controleurProgression = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _controleurMessage = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _controleurPulsation = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _demarrerProcessusChargement();
  }

  @override
  void dispose() {
    _controleurProgression.dispose();
    _controleurMessage.dispose();
    _controleurPulsation.dispose();
    super.dispose();
  }

  void _demarrerProcessusChargement() {
    _controleurPulsation.repeat(reverse: true);
    _chargerDonneesMeteo();

    _controleurProgression.addListener(() {
      setState(() {
        _progression = _controleurProgression.value;
      });
    });

    _alternerMessages();
    _controleurProgression.forward();
  }

  void _alternerMessages() {
    Timer.periodic(const Duration(milliseconds: 1600), (timer) {
      if (!_enChargement) {
        timer.cancel();
        return;
      }

      _controleurMessage.forward().then((_) {
        setState(() {
          _indexMessageActuel =
              (_indexMessageActuel + 1) % _messagesChargement.length;
        });
        _controleurMessage.reverse();
      });
    });
  }

  Future<void> _chargerDonneesMeteo() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      final donneesMeteo = await _depotMeteo.recupererToutesLesDonneesMeteo();

      if (!mounted) return;

      setState(() {
        _donneesMeteo = donneesMeteo;
        _enChargement = false;
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => EcranResultatsMeteo(donneesMeteo: _donneesMeteo),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _aUneErreur = true;
        _messageErreur =
            'Échec du chargement des données météo.\nVeuillez réessayer.';
        _enChargement = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_aUneErreur) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 60, color: Colors.redAccent),
                const SizedBox(height: 20),
                Text(
                  _messageErreur,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _aUneErreur = false;
                      _enChargement = true;
                      _progression = 0.0;
                      _indexMessageActuel = 0;
                      _donneesMeteo.clear();
                      _controleurProgression.reset();
                      _demarrerProcessusChargement();
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Jauge de progression animée qui se remplit toute seule
            ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.1).animate(_controleurPulsation),
              child: CircularPercentIndicator(
                radius: 120.0,
                lineWidth: 12.0,
                percent: _progression,
                animation: true,
                center: Text(
                  '${(_progression * 100).toInt()}%',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                progressColor: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 30),
            // Messages d'attente dynamiques qui alternent
            FadeTransition(
              opacity: ReverseAnimation(_controleurMessage),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(0, 0.1),
                ).animate(_controleurMessage),
                child: Text(
                  _messagesChargement[_indexMessageActuel],
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
