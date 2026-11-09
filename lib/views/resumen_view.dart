import 'package:flutter/material.dart';
import '../app/injector.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/ui_helpers.dart';
import '../widgets/common_widgets.dart';
import 'cliente_detalle_view.dart';
import 'orden_detalle_view.dart';

class ResumenPage extends StatefulWidget {
  const ResumenPage({super.key});
  @override
  State<ResumenPage> createState() => _ResumenPageState();
}

class _ResumenPageState extends State<ResumenPage> {
  DateTime d1 = DateTime.now().subtract(const Duration(days: 30)), d2 = DateTime.now();
  String f(DateTime d) => d.toIso8601String().substring(0, 10);
  Future<void> pick(bool a) async {
    final r = await showDatePicker(
        context: context, initialDate: a ? d1 : d2, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (r != null) setState(() => a ? d1 = r : d2 = r);
  }

  @override
  Widget build(BuildContext c) => ListenableBuilder(listenable: taller, builder: (c, _) => _contenido(c));

  Widget _contenido(BuildContext c) {
    final ab = taller.ordenes.where((o) => o.estado < 4).toList();
    final deb = [for (final x in taller.clientes) if (taller.deuda(x.id) > 0) x];
    final ent = taller.ordenes.where((o) =>
        o.estado == 4 && o.fechaEntrega != null && o.fechaEntrega!.compareTo(f(d1)) >= 0 && o.fechaEntrega!.compareTo(f(d2)) <= 0);
    final cobrado = taller.ordenes
        .expand((o) => o.pagos)
        .where((p) => p.f.compareTo(f(d1)) >= 0 && p.f.compareTo(f(d2)) <= 0)
        .fold(0.0, (a, p) => a + p.m);
    return ListView(padding: const EdgeInsets.all(12), children: [
      seccion('Órdenes abiertas por estado',
          [for (var i = 0; i < 4; i++) fila(estados[i], '${ab.where((o) => o.estado == i).length}')]),
      seccion('Trabajo por mecánico', [
        for (var i = 0; i < mecanicos.length; i++) fila(mecanicos[i], '${ab.where((o) => o.mec == i).length} abierta(s)')
      ]),
      seccion('Clientes con saldo pendiente', [
        if (deb.isEmpty) vacioLinea('Ningún cliente tiene saldo pendiente'),
        for (final x in deb)
          ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              onTap: () => ir(c, ClientePage(x.id)),
              title: Text(x.nombre),
              trailing: Text(money(taller.deuda(x.id)), style: const TextStyle(color: kRojo, fontWeight: FontWeight.bold))),
      ]),
      seccion('Repuestos por agotarse', [
        if (taller.bajos.isEmpty) vacioLinea('No hay repuestos por agotarse'),
        for (final r in taller.bajos) fila(r.nombre, '${r.stock} u. (mín. ${r.minimo})', st: const TextStyle(color: kNaranja)),
      ]),
      seccion('Facturación por período', [
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => pick(true), child: Text('Desde ${f(d1)}'))),
          const SizedBox(width: 8),
          Expanded(child: OutlinedButton(onPressed: () => pick(false), child: Text('Hasta ${f(d2)}'))),
        ]),
        const SizedBox(height: 8),
        fila('Facturado (${ent.length} orden(es) entregadas)', money(ent.fold(0.0, (a, o) => a + taller.total(o))),
            st: const TextStyle(fontWeight: FontWeight.bold)),
        fila('Cobrado en el período', money(cobrado)),
        if (ent.isEmpty) vacioLinea('No hay órdenes entregadas en este período'),
        for (final o in ent)
          ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              onTap: () => ir(c, OrdenPage(o.id)),
              title: Text('#${o.n} · ${taller.veh(o.vehiculoId).mat} · ${o.fechaEntrega}'),
              trailing: Text(money(taller.total(o)))),
      ]),
    ]);
  }
}
