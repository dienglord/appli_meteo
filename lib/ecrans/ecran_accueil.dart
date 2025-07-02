import 'package:flutter/material.dart';
import '../services/service_meteo.dart';

// Liste complète des villes principales du Sénégal
final List<String> villesSenegal = [
  'Dakar',
  'Thiès',
  'Kaolack',
  'Saint-Louis',
  'Mbour',
  'Ziguinchor',
  'Tambacounda',
  'Diourbel',
  'Touba',
  'Rufisque',
  'Kolda',
  'Matam',
  'Kédougou',
  'Louga',
  'Fatick',
  'Kaffrine',
  'Sédhiou',
  'Podor',
  'Richard-Toll',
  'Linguère',
  'Bakel',
  'Goudiry',
  'Vélingara',
  'Goudomp',
  'Bignona',
];

// Les six villes principales du Sénégal avec leurs icônes représentatives
final List<Map<String, dynamic>> villesPrincipalesSenegal = [
  {'nom': 'Dakar', 'icone': '🏛️'},
  {'nom': 'Thiès', 'icone': '🏭'},
  {'nom': 'Saint-Louis', 'icone': '🏰'},
  {'nom': 'Tambacounda', 'icone': '🌴'},
  {'nom': 'Ziguinchor', 'icone': '🌊'},
  {'nom': 'Kaolack', 'icone': '🌾'},
];

// Les six plus grandes villes du monde avec leurs icônes représentatives
final List<Map<String, dynamic>> villesPrincipalesMonde = [
  {'nom': 'Tokyo', 'icone': '🏙️'},
  {'nom': 'New York', 'icone': '🗽'},
  {'nom': 'London', 'icone': '🏛️'},
  {'nom': 'Paris', 'icone': '🗼'},
  {'nom': 'Sydney', 'icone': '🦘'},
  {'nom': 'Dubai', 'icone': '🏗️'},
];

class EcranAccueil extends StatefulWidget {
  const EcranAccueil({super.key});

  @override
  State<EcranAccueil> createState() => EcranAccueilState();
}

class EcranAccueilState extends State<EcranAccueil>
    with TickerProviderStateMixin {
  String? villeSelectionnee;
  final TextEditingController _controleurRecherche = TextEditingController();
  final DepotMeteo _depotMeteo = DepotMeteo();
  bool _recherchePersonnalisee = false;
  bool _chargementVille = false;
  String? _erreurVille;

  late AnimationController _controleurAnimation;
  late Animation<double> _animationSlide;

  @override
  void initState() {
    super.initState();
    _controleurAnimation = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationSlide = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controleurAnimation, curve: Curves.easeOut),
    );

    // Démarrer l'animation d'entrée avec un léger délai
    Future.delayed(const Duration(milliseconds: 200), () {
      _controleurAnimation.forward();
    });
  }

  @override
  void dispose() {
    _controleurAnimation.dispose();
    _controleurRecherche.dispose();
    super.dispose();
  }

  void _basculerModeRecherche() {
    setState(() {
      _recherchePersonnalisee = !_recherchePersonnalisee;
      _controleurRecherche.clear();
      _erreurVille = null;
      villeSelectionnee = null;
    });
  }

  Future<void> _verifierVillePersonnalisee() async {
    if (_controleurRecherche.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _chargementVille = true;
      _erreurVille = null;
    });

    try {
      await _depotMeteo
          .recupererMeteoPourVille(_controleurRecherche.text.trim());
      setState(() {
        villeSelectionnee = _controleurRecherche.text.trim();
        _chargementVille = false;
      });
    } catch (e) {
      setState(() {
        _erreurVille = 'Ville introuvable';
        _chargementVille = false;
        villeSelectionnee = null;
      });
    }
  }

  void _voirMeteoVille(String ville) {
    Navigator.pushNamed(
      context,
      '/meteo_ville',
      arguments: ville,
    );
  }

  // Obtient la liste des villes à afficher selon le mode sélectionné
  List<Map<String, dynamic>> _obtenirVillesAffichees() {
    return _recherchePersonnalisee
        ? villesPrincipalesMonde
        : villesPrincipalesSenegal;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.brightness == Brightness.dark
                ? [
                    const Color(0xFF1a1a2e),
                    const Color(0xFF16213e),
                    const Color(0xFF0f3460),
                  ]
                : [
                    const Color(0xFF74b9ff),
                    const Color(0xFF0984e3),
                    const Color(0xFF6c5ce7),
                  ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: FadeTransition(
              opacity: _animationSlide,
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Titre principal avec message d'accueil sympa
                  Text(
                    '🌤️ Météo ${_recherchePersonnalisee ? "Monde" : "Sénégal"}',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Sélecteur entre mode Sénégal et mode Monde
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.15 * 255).toInt()),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (_recherchePersonnalisee) {
                                _basculerModeRecherche();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: !_recherchePersonnalisee
                                    ? Colors.white
                                        .withAlpha((0.25 * 255).toInt())
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                '🇸🇳 Sénégal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: !_recherchePersonnalisee
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (!_recherchePersonnalisee) {
                                _basculerModeRecherche();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _recherchePersonnalisee
                                    ? Colors.white
                                        .withAlpha((0.25 * 255).toInt())
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                '🌍 Monde',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: _recherchePersonnalisee
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Zone de recherche personnalisée (seulement en mode Monde)
                  if (_recherchePersonnalisee) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.15 * 255).toInt()),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: _erreurVille != null
                              ? Colors.red
                              : Colors.white.withAlpha((0.3 * 255).toInt()),
                        ),
                      ),
                      child: TextField(
                        controller: _controleurRecherche,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Rechercher une autre ville...',
                          hintStyle: const TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          suffixIcon: _chargementVille
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.search,
                                      color: Colors.white70),
                                  onPressed: _verifierVillePersonnalisee,
                                ),
                        ),
                        onSubmitted: (_) => _verifierVillePersonnalisee(),
                      ),
                    ),
                    if (_erreurVille != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _erreurVille!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    if (villeSelectionnee != null) ...[
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _voirMeteoVille(villeSelectionnee!),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: theme.primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text('Voir météo de $villeSelectionnee'),
                      ),
                    ],
                    const SizedBox(height: 30),
                  ],

                  // Grille des six villes (change selon le mode sélectionné)
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.3, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: GridView.builder(
                        key: ValueKey(
                            _recherchePersonnalisee), // Pour animer le changement
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: _obtenirVillesAffichees().length,
                        itemBuilder: (context, index) {
                          final ville = _obtenirVillesAffichees()[index];

                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(0, 0.5 + (index * 0.1)),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _controleurAnimation,
                              curve: Interval(
                                0.2 + (index * 0.1),
                                1.0,
                                curve: Curves.easeOut,
                              ),
                            )),
                            child: GestureDetector(
                              onTap: () => _voirMeteoVille(ville['nom']),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withAlpha((0.15 * 255).toInt()),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.white
                                        .withAlpha((0.3 * 255).toInt()),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      ville['icone'],
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      ville['nom'],
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bouton adaptatif selon le mode
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_recherchePersonnalisee) {
                          // En mode Monde : proposer d'autres villes mondiales populaires
                          _afficherDialogVillesMondiales();
                        } else {
                          // En mode Sénégal : voir toutes les villes du Sénégal
                          Navigator.pushNamed(context, '/tout_senegal');
                        }
                      },
                      icon: Icon(
                        _recherchePersonnalisee
                            ? Icons.public
                            : Icons.location_city,
                        size: 20,
                      ),
                      label: Text(
                        _recherchePersonnalisee
                            ? 'Plus de villes mondiales'
                            : 'Voir toutes les villes du Sénégal',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.white.withAlpha((0.2 * 255).toInt()),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                          side: BorderSide(
                            color: Colors.white.withAlpha((0.4 * 255).toInt()),
                            width: 1,
                          ),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Dialog pour afficher plus de villes mondiales
  void _afficherDialogVillesMondiales() {
    final autresVillesMondiales = [
      'Moscow',
      'Beijing',
      'Mumbai',
      'São Paulo',
      'Cairo',
      'Bangkok',
      'Istanbul',
      'Mexico City',
      'Singapore',
      'Toronto',
      'Berlin',
      'Rome'
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🌍 Autres villes mondiales'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: autresVillesMondiales.length,
              itemBuilder: (context, index) {
                final ville = autresVillesMondiales[index];
                return ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _voirMeteoVille(ville);
                  },
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  child: Text(
                    ville,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}
