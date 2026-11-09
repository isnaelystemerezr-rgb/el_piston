import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PistonRepository {
  static const _clave = 'piston';

  Future<Map<String, dynamic>?> leer() async {
    final s = (await SharedPreferences.getInstance()).getString(_clave);
    return s == null ? null : jsonDecode(s) as Map<String, dynamic>;
  }

  Future<String?> leerTema() async => (await SharedPreferences.getInstance()).getString('tema');

  Future<void> guardarTema(String t) async {
    await (await SharedPreferences.getInstance()).setString('tema', t);
  }

  Future<void> guardar(Map<String, dynamic> datos) async {
    await (await SharedPreferences.getInstance()).setString(_clave, jsonEncode(datos));
  }
}
