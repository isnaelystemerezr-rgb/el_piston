import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:el_piston/app/app.dart';
import 'package:el_piston/app/injector.dart';

Future<void> abrir(WidgetTester t) async {
  SharedPreferences.setMockInitialValues({});
  await taller.load();
  await ajustes.load();
  t.view.physicalSize = const Size(800, 4000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(const PistonApp());
}

void main() {
  testWidgets('arranca con datos, navega y cambia el tema', (t) async {
    await abrir(t);
    expect(find.text('Órdenes de servicio'), findsOneWidget);
    await t.tap(find.text('Repuestos'));
    await t.pumpAndSettle();
    expect(find.text('Inventario'), findsOneWidget);
    await t.tap(find.byTooltip('Ajustes'));
    await t.pumpAndSettle();
    expect(find.text('Tema de la aplicación'), findsOneWidget);
    await t.tap(find.text('Oscuro'));
    await t.pumpAndSettle();
    expect(ajustes.tema, ThemeMode.dark);
  });

  testWidgets('los cambios se ven al instante en cada pestaña', (t) async {
    await abrir(t);
    await t.tap(find.text('Clientes'));
    await t.pumpAndSettle();
    taller.addCliente('Zeta Prueba', '5 000 0000', '');
    await t.pump();
    expect(find.text('Zeta Prueba'), findsOneWidget);

    await t.tap(find.text('Repuestos'));
    await t.pumpAndSettle();
    taller.guardarRepuesto(null, 'Pieza Nueva', 'PN-1', 5, 9, 2);
    await t.pump();
    expect(find.text('Pieza Nueva'), findsOneWidget);
  });
}
