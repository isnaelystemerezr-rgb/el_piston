import 'package:flutter/material.dart';
import '../data/piston_repository.dart';

class AjustesViewModel extends ChangeNotifier {
  final PistonRepository _repo;
  AjustesViewModel(this._repo);
  ThemeMode tema = ThemeMode.system;

  Future<void> load() async {
    final t = await _repo.leerTema();
    tema = ThemeMode.values.firstWhere((m) => m.name == t, orElse: () => ThemeMode.system);
  }

  Future<void> setTema(ThemeMode m) async {
    tema = m;
    notifyListeners();
    await _repo.guardarTema(m.name);
  }
}
