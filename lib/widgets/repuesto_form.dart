import 'package:flutter/material.dart';
import '../app/injector.dart';
import '../models/repuesto.dart';
import '../utils/validators.dart';
import 'form_sheet.dart';

void editarRepuesto(BuildContext c, [Repuesto? r]) => form(
    c, r == null ? 'Nuevo repuesto' : 'Editar repuesto',
    ['Nombre', 'Código', 'Precio de venta', 'Existencias', 'Avisar cuando queden (o menos)'], (v) {
  final p = dn(v[2]), s = int.tryParse(v[3]), m = int.tryParse(v[4]);
  if (vacio(v.take(2)) || p == null || p < 0 || s == null || s < 0 || m == null || m < 0) return 'Revisa los datos';
  return taller.guardarRepuesto(r, v[0], v[1], p, s, m);
}, init: r == null ? null : [r.nombre, r.codigo, '${r.precio}', '${r.stock}', '${r.minimo}'], nums: {2, 3, 4});

void reponerRepuesto(BuildContext c, Repuesto r) => form(c, 'Reponer ${r.nombre}', ['Cantidad que llegó'], (v) {
      final q = int.tryParse(v[0]);
      if (q == null || q <= 0) return 'Indica una cantidad válida';
      taller.reponer(r, q);
      return null;
    }, nums: {0});
