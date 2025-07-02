import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Gestionnaire pour le basculement entre thème clair et sombre
class GestionnaireTheme extends ChangeNotifier {
  static const String _cleTheme = 'theme_mode';
  bool _estModeSombre = false;

  bool get estModeSombre => _estModeSombre;

  ThemeMode get modeTheme => _estModeSombre ? ThemeMode.dark : ThemeMode.light;

  GestionnaireTheme() {
    _chargerTheme();
  }

  // Bascule entre le mode clair et le mode sombre
  void basculerTheme() async {
    _estModeSombre = !_estModeSombre;
    notifyListeners();
    await _sauvegarderTheme();
  }

  // Définit explicitement un thème spécifique
  void definirTheme(bool estSombre) async {
    if (_estModeSombre != estSombre) {
      _estModeSombre = estSombre;
      notifyListeners();
      await _sauvegarderTheme();
    }
  }

  // Charge la préférence de thème sauvegardée
  Future<void> _chargerTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _estModeSombre = prefs.getBool(_cleTheme) ?? false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erreur lors du chargement du thème: $e');
      }
    }
  }

  // Sauvegarde la préférence de thème
  Future<void> _sauvegarderTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_cleTheme, _estModeSombre);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erreur lors de la sauvegarde du thème: $e');
      }
    }
  }
}
