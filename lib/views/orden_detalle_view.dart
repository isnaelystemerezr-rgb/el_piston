import 'package:flutter/material.dart';
import '../app/injector.dart';
import '../models/orden.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/ui_helpers.dart';
import '../utils/validators.dart';
import '../widgets/common_widgets.dart';
import '../widgets/form_sheet.dart';
import 'cliente_detalle_view.dart';

class OrdenPage extends StatelessWidget {
  final String id;
  const OrdenPage(this.id, {super.key});

  static Widget _item(String t, String precio, List<Widget> acc) =>
      Row(children: [Expanded(child: Text(t)), Text(precio), ...acc]);
  static Widget _ic(IconData i, String tip, VoidCallback f) =>
      IconButton(icon: Icon(i, size: 20), tooltip: tip, visualDensity: VisualDensity.compact, onPressed: f);

  @override
  Widget build(BuildContext c) => ListenableBuilder(
      listenable: taller,
      builder: (c, _) {
        final o = taller.ordenOrNull(id);
        if (o == null) return const Scaffold(body: Center(child: Text('La orden ya no existe')));
        final v = taller.veh(o.vehiculoId), cl = taller.cli(v.clienteId);
        final ed = o.estado < 4, s = taller.saldo(o);
        return Scaffold(
            appBar: AppBar(title: Text('Orden #${o.n}'), actions: [
              PopupMenuButton<String>(
                  onSelected: (x) async {
                    if (x == 'p') {
                      form(c, 'Editar problema reportado', ['Problema'], (t) {
                        if (t[0].isEmpty) return 'Describe el problema';
                        taller.editarProblema(o, t[0]);
                        return null;
                      }, init: [o.problema]);
                    } else if (await confirmar(c, '¿Eliminar la orden #${o.n}? Los repuestos usados volverán al inventario.')) {
                      taller.eliminarOrden(o);
                      if (c.mounted) Navigator.pop(c);
                    }
                  },
                  itemBuilder: (_) => const [
                        PopupMenuItem(value: 'p', child: Text('Editar problema')),
                        PopupMenuItem(value: 'x', child: Text('Eliminar orden')),
                      ])
            ]),
            body: ListView(padding: const EdgeInsets.all(14), children: [
              Align(alignment: Alignment.centerLeft, child: estadoChip(o.estado)),
              Text('${v.mat} · ${v.marca} ${v.modelo} ${v.anio} · ${v.km.toStringAsFixed(0)} km'),
              Text('${cl.nombre} · ${cl.tel}'),
              Text('Entrada ${o.fecha}${o.fechaEntrega != null ? ' · Entrega ${o.fechaEntrega}' : ''}',
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Text('“${o.problema}”', style: const TextStyle(fontStyle: FontStyle.italic)),
              Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                      icon: const Icon(Icons.person),
                      label: const Text('Ver ficha del cliente'),
                      onPressed: () => ir(c, ClientePage(cl.id)))),
              if (ed) ...[
                DropdownButtonFormField<int>(
                    value: o.mec,
                    decoration: const InputDecoration(labelText: 'Mecánico', border: OutlineInputBorder()),
                    items: [for (var i = 0; i < mecanicos.length; i++) DropdownMenuItem(value: i, child: Text(mecanicos[i]))],
                    onChanged: (x) => taller.setMec(o, x!)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: FilledButton(
                          onPressed: () => taller.setEstado(o, o.estado + 1),
                          child: Text('Pasar a: ${estados[o.estado + 1]}'))),
                  const SizedBox(width: 8),
                  OutlinedButton(
                      onPressed: () async {
                        if (await confirmar(c, '¿Cancelar la orden? Los repuestos volverán al inventario.')) {
                          taller.setEstado(o, 5);
                        }
                      },
                      child: const Text('Cancelar')),
                ]),
              ] else
                Text('${o.estado == 5 ? 'Orden cancelada · ' : ''}Mecánico: ${mecanicos[o.mec]}'),
              if (o.estado >= 1 && o.estado <= 4)
                Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                        icon: const Icon(Icons.undo),
                        label: Text('Volver a: ${estados[o.estado - 1]}'),
                        onPressed: () => taller.setEstado(o, o.estado - 1))),
              const SizedBox(height: 8),
              seccion('Trabajos (mano de obra)', [
                if (o.trabajos.isEmpty) vacioLinea('Sin trabajos registrados en esta orden'),
                for (var i = 0; i < o.trabajos.length; i++)
                  _item(o.trabajos[i].d, money(o.trabajos[i].p), ed
                      ? [
                          _ic(Icons.edit, 'Editar', () => _trabajo(c, o, i)),
                          _ic(Icons.delete_outline, 'Quitar', () async {
                            if (await confirmar(c, '¿Quitar este trabajo?')) taller.quitarTrabajo(o, i);
                          }),
                        ]
                      : []),
                if (ed)
                  TextButton.icon(
                      icon: const Icon(Icons.add), label: const Text('Añadir trabajo'), onPressed: () => _trabajo(c, o)),
              ]),
              seccion('Repuestos usados', [
                if (o.usos.isEmpty) vacioLinea('No se han usado repuestos en esta orden'),
                for (var i = 0; i < o.usos.length; i++)
                  _item('${o.usos[i].q} × ${taller.rep(o.usos[i].repId).nombre}', money(o.usos[i].q * o.usos[i].p), ed
                      ? [
                          _ic(Icons.edit, 'Cambiar cantidad', () => _cantidad(c, o, i)),
                          _ic(Icons.delete_outline, 'Quitar', () async {
                            if (await confirmar(c, '¿Quitar este repuesto? Volverá al inventario.')) taller.quitarUso(o, i);
                          }),
                        ]
                      : []),
                if (ed)
                  TextButton.icon(
                      icon: const Icon(Icons.add), label: const Text('Usar repuesto'), onPressed: () => _elegirRepuesto(c, o)),
              ]),
              seccion('Cuenta', [
                fila('Mano de obra', money(taller.mano(o))),
                fila('Repuestos', money(taller.total(o) - taller.mano(o))),
                fila('Total', money(taller.total(o)), st: const TextStyle(fontWeight: FontWeight.bold)),
                fila('Pagado', money(taller.pagado(o))),
                for (var i = 0; i < o.pagos.length; i++)
                  _item('  · Pago ${o.pagos[i].f}', money(o.pagos[i].m), o.estado < 5
                      ? [
                          _ic(Icons.delete_outline, 'Anular pago', () async {
                            if (await confirmar(c, '¿Anular este pago?')) taller.quitarPago(o, i);
                          })
                        ]
                      : []),
                fila('Falta por pagar', money(s),
                    st: TextStyle(fontWeight: FontWeight.bold, color: s > 0 ? kRojo : kVerde)),
                if (o.estado < 5 && s > 0)
                  TextButton.icon(
                      icon: const Icon(Icons.payments),
                      label: const Text('Registrar pago'),
                      onPressed: () => form(c, 'Registrar pago (falta ${money(s)})', ['Monto'], (x) {
                            final m = dn(x[0]);
                            return m == null ? 'Monto inválido' : taller.pagar(o, m);
                          }, init: [s.toStringAsFixed(2)], nums: {0})),
              ]),
              const SizedBox(height: 24),
            ]));
      });

  void _trabajo(BuildContext c, Orden o, [int? i]) {
    final t = i == null ? null : o.trabajos[i];
    form(c, t == null ? 'Nuevo trabajo' : 'Editar trabajo', ['Descripción (ej. Cambio de aceite)', 'Precio de mano de obra'], (x) {
      final p = dn(x[1]);
      if (x[0].isEmpty || p == null || p < 0) return 'Indica descripción y precio';
      if (i == null) {
        taller.addTrabajo(o, x[0], p);
      } else {
        taller.editarTrabajo(o, i, x[0], p);
      }
      return null;
    }, init: t == null ? null : [t.d, t.p.toStringAsFixed(2)], nums: {1});
  }

  void _cantidad(BuildContext c, Orden o, int i) {
    final u = o.usos[i], r = taller.rep(u.repId);
    form(c, 'Cantidad de ${r.nombre}', ['Cantidad'], (x) {
      final q = int.tryParse(x[0]);
      if (q == null || q <= 0) return 'Cantidad inválida';
      final e = taller.cambiarCantidadUso(o, i, q);
      if (e == null && r.bajo) msg(c, 'Quedan ${r.stock} de "${r.nombre}": hay que comprar');
      return e;
    }, init: ['${u.q}'], nums: {0});
  }

  void _elegirRepuesto(BuildContext c, Orden o) {
    final l = taller.repuestos.where((r) => r.stock > 0).toList();
    if (l.isEmpty) return msg(c, 'No hay repuestos con existencias');
    showModalBottomSheet(
        context: c,
        builder: (_) => ListView(children: [
              for (final r in l)
                ListTile(
                    title: Text(r.nombre),
                    subtitle: Text('${r.stock} disponibles'),
                    trailing: Text(money(r.precio)),
                    onTap: () {
                      Navigator.pop(c);
                      form(c, 'Cantidad de ${r.nombre}', ['Cantidad'], (x) {
                        final q = int.tryParse(x[0]);
                        if (q == null) return 'Cantidad inválida';
                        final e = taller.usar(o, r, q);
                        if (e == null && r.bajo) msg(c, 'Quedan ${r.stock} de "${r.nombre}": hay que comprar');
                        return e;
                      }, init: ['1'], nums: {0});
                    })
            ]));
  }
}
