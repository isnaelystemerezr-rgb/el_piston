import 'package:flutter/material.dart';
import '../app/injector.dart';
import '../models/cliente.dart';
import '../models/vehiculo.dart';
import '../utils/validators.dart';
import 'form_sheet.dart';

void nuevoCliente(BuildContext c) => _formCliente(c, null);
void editarCliente(BuildContext c, Cliente cl) => _formCliente(c, cl);

void _formCliente(BuildContext c, Cliente? cl) =>
    form(c, cl == null ? 'Nuevo cliente' : 'Editar cliente', ['Nombre', 'Teléfono', 'Dirección (opcional)'], (v) {
      if (vacio(v.take(2))) return 'Nombre y teléfono son obligatorios';
      if (cl == null) {
        taller.addCliente(v[0], v[1], v[2]);
      } else {
        taller.editarCliente(cl, v[0], v[1], v[2]);
      }
      return null;
    }, init: cl == null ? null : [cl.nombre, cl.tel, cl.dir]);

void nuevoVehiculo(BuildContext c, String cid) => _formVehiculo(c, cid, null);
void editarVehiculo(BuildContext c, Vehiculo v) => _formVehiculo(c, v.clienteId, v);

void _formVehiculo(BuildContext c, String cid, Vehiculo? veh) => form(
    c, veh == null ? 'Nuevo vehículo' : 'Editar vehículo', ['Matrícula', 'Marca', 'Modelo', 'Año', 'Kilometraje'], (v) {
  final a = int.tryParse(v[3]), k = dn(v[4]);
  if (vacio(v.take(3)) || a == null || a < 1900 || k == null || k < 0) return 'Completa todos los datos correctamente';
  return taller.guardarVehiculo(veh, cid, v[0].toUpperCase(), v[1], v[2], a, k);
}, init: veh == null ? null : [veh.mat, veh.marca, veh.modelo, '${veh.anio}', veh.km.toStringAsFixed(0)], nums: {3, 4});
