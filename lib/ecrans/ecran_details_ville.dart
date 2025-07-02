import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../modeles/modele_meteo.dart';

class EcranDetailsVille extends StatelessWidget {
  final ReponseMeteo reponseMeteo;

  const EcranDetailsVille({super.key, required this.reponseMeteo});

  @override
  Widget build(BuildContext context) {
    final latitude = reponseMeteo.coord.lat;
    final longitude = reponseMeteo.coord.lon;
    final main = reponseMeteo.main;

    return Scaffold(
      appBar: AppBar(
        title: Text('${reponseMeteo.name} (${reponseMeteo.sys.country})'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Météo détaillée',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Text('Température : ${main.temp.round()}°C',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text('Température ressentie : ${main.tempRessentie.round()}°C'),
            const SizedBox(height: 8),
            Text(
                'Minimum : ${main.tempMin.round()}°C / Maximum : ${main.tempMax.round()}°C'),
            const SizedBox(height: 8),
            Text('Taux d\'humidité : ${main.humidity}%'),
            const SizedBox(height: 8),
            Text('Pression atmosphérique : ${main.pressure} hPa'),
            const SizedBox(height: 20),
            Text('Coordonnées géographiques : $latitude, $longitude'),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final url = Uri.parse(
                      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
                  try {
                    await launchUrl(url, mode: LaunchMode.platformDefault);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Impossible d\'ouvrir Google Maps ou le navigateur')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.map),
                label: const Text('Voir sur Google Maps'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
