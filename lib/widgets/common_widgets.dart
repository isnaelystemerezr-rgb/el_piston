import 'package:flutter/material.dart';
import '../utils/constants.dart';

Widget estadoVacio(IconData icono, String titulo, {String? detalle, String? boton, VoidCallback? onBoton}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
    child: Column(children: [
      Icon(icono, size: 56, color: Colors.grey),
      const SizedBox(height: 12),
      Text(titulo, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      if (detalle != null)
        Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(detalle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey))),
      if (boton != null && onBoton != null)
        Padding(padding: const EdgeInsets.only(top: 16), child: FilledButton.tonal(onPressed: onBoton, child: Text(boton))),
    ]));

Widget vacioLinea(String t) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      const Icon(Icons.info_outline, size: 18, color: Colors.grey),
      const SizedBox(width: 8),
      Expanded(child: Text(t, style: const TextStyle(color: Colors.grey))),
    ]));

Widget estadoChip(int e) => Chip(
    label: Text(estados[e]),
    backgroundColor: colores[e].withAlpha(64),
    visualDensity: VisualDensity.compact);
Widget fila(String a, String b, {TextStyle? st}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Flexible(child: Text(a, style: st)), Text(b, style: st)]));
Widget seccion(String t, List<Widget> h) => Card(
    child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...h
        ])));
