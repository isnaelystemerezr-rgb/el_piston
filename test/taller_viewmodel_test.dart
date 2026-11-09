import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:el_piston/data/piston_repository.dart';
import 'package:el_piston/viewmodels/ajustes_viewmodel.dart';
import 'package:el_piston/viewmodels/taller_viewmodel.dart';

void main() {
  late TallerViewModel s;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    s = TallerViewModel(PistonRepository());
    await s.load();
    await s.borrarTodo();
    s.guardarRepuesto(null, 'Filtro de aceite', 'FA-100', 8, 12, 4);
    s.addCliente('Ana', '555-1234', '');
    s.addVehiculo(s.clientes.first.id, 'P123456', 'Lada', '2107', 1990, 1000);
    s.addOrden(s.vehiculos.first.id, 1200, 'Ruido en el motor', 0);
  });

  test('la primera vez la app trae datos de ejemplo en todas las secciones', () async {
    SharedPreferences.setMockInitialValues({});
    final d = TallerViewModel(PistonRepository());
    await d.load();
    expect(d.clientes.length, greaterThanOrEqualTo(6));
    expect(d.vehiculos.length, greaterThanOrEqualTo(8));
    expect(d.ordenes.where((o) => o.estado < 4), isNotEmpty);
    expect(d.ordenes.map((o) => o.estado).toSet().length, 6);
    expect(d.bajos, isNotEmpty);
    expect(d.vehiculos.every((v) => d.ordenes.any((o) => o.vehiculoId == v.id)), isTrue);
    expect(d.ordenes.every((o) => o.trabajos.isNotEmpty), isTrue);
    expect(d.clientes.any((c) => d.deuda(c.id) > 0), isTrue);
  });

  test('los cambios se guardan y se recuperan al reabrir', () async {
    await s.borrarTodo();
    final otro = TallerViewModel(PistonRepository());
    await otro.load();
    expect(otro.clientes, isEmpty);
  });

  test('matrícula duplicada es rechazada, también al editar', () {
    final c = s.clientes.first;
    expect(s.addVehiculo(c.id, 'P123456', 'X', 'Y', 2000, 1), isNotNull);
    s.addVehiculo(c.id, 'B999999', 'Kia', 'Rio', 2015, 5);
    expect(s.guardarVehiculo(s.vehiculos.last, c.id, 'P123456', 'Kia', 'Rio', 2015, 5), isNotNull);
  });

  test('usar repuesto baja existencias y suma al total', () {
    final o = s.ordenes.first, r = s.repuestos.first;
    s.addTrabajo(o, 'Cambio de aceite', 20);
    expect(s.usar(o, r, 2), isNull);
    expect(r.stock, 10);
    expect(s.total(o), 36);
    expect(s.usar(o, r, 99), isNotNull);
  });

  test('editar cantidad y quitar repuesto ajustan el inventario', () {
    final o = s.ordenes.first, r = s.repuestos.first;
    s.usar(o, r, 2);
    expect(s.cambiarCantidadUso(o, 0, 5), isNull);
    expect(r.stock, 7);
    expect(s.cambiarCantidadUso(o, 0, 50), isNotNull);
    s.quitarUso(o, 0);
    expect(r.stock, 12);
    expect(o.usos, isEmpty);
  });

  test('pago en dos partes, saldo y anulación de pago', () {
    final o = s.ordenes.first;
    s.addTrabajo(o, 'Alineación', 40);
    expect(s.pagar(o, 25), isNull);
    expect(s.saldo(o), 15);
    expect(s.pagar(o, 20), isNotNull);
    expect(s.deuda(s.clientes.first.id), 15);
    s.quitarPago(o, 0);
    expect(s.saldo(o), 40);
  });

  test('cancelar devuelve repuestos y elimina la deuda; eliminar orden también', () {
    final o = s.ordenes.first, r = s.repuestos.first;
    s.usar(o, r, 3);
    s.setEstado(o, 5);
    expect(r.stock, 12);
    expect(s.deuda(s.clientes.first.id), 0);
    s.eliminarOrden(o);
    expect(s.ordenes, isEmpty);
  });

  test('no se elimina un cliente, vehículo o repuesto con historial', () {
    final o = s.ordenes.first, r = s.repuestos.first;
    s.usar(o, r, 1);
    expect(s.eliminarVehiculo(s.vehiculos.first), isNotNull);
    expect(s.eliminarCliente(s.clientes.first), isNotNull);
    expect(s.eliminarRepuesto(r), isNotNull);
    s.eliminarOrden(o);
    expect(s.eliminarVehiculo(s.vehiculos.first), isNull);
    expect(s.eliminarCliente(s.clientes.first), isNull);
  });

  test('reponer y volver a un estado anterior', () {
    final r = s.repuestos.first, o = s.ordenes.first;
    s.reponer(r, 5);
    expect(r.stock, 17);
    s.setEstado(o, 4);
    expect(o.fechaEntrega, isNotNull);
    s.setEstado(o, 3);
    expect(o.fechaEntrega, isNull);
  });

  test('el tema elegido se guarda', () async {
    SharedPreferences.setMockInitialValues({});
    final a = AjustesViewModel(PistonRepository());
    await a.setTema(ThemeMode.dark);
    final b = AjustesViewModel(PistonRepository());
    await b.load();
    expect(b.tema, ThemeMode.dark);
  });
}
