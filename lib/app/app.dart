import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../views/home_view.dart';
import 'injector.dart';
import 'theme.dart';

class PistonApp extends StatelessWidget {
  const PistonApp({super.key});
  @override
  Widget build(BuildContext c) => ListenableBuilder(
      listenable: ajustes,
      builder: (c, _) => MaterialApp(
            title: 'El Pistón',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.claro,
            darkTheme: AppTheme.oscuro,
            themeMode: ajustes.tema,
            locale: const Locale('es'),
            supportedLocales: const [Locale('es'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const Home(),
          ));
}
