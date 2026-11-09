import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/injector.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([taller.load(), ajustes.load()]);
  runApp(const PistonApp());
}
