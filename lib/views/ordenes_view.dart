import 'package:flutter/material.dart';
import '../app/injector.dart';
import '../models/orden.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/ui_helpers.dart';
import '../widgets/common_widgets.dart';
import '../widgets/nueva_orden_sheet.dart';
import 'orden_detalle_view.dart';

class OrdenesPage extends StatefulWidget {
  final VoidCallback onVerInventario;
  const OrdenesPage({super.key, required this.onVerInventario});
  @override
  State<OrdenesPage> createState() => _OrdenesPageState();
}

class _OrdenesPageState extends State<OrdenesPage> {
  int f = 0;
  @override
  Widget build(BuildContext c) => ListenableBuilder(listenable: taller, builder: (c, _) => _contenido(c));

  Widget _contenido(BuildContext c) {
    final l = taller.ordenes.where((o) => f == 0 ? o.estado < 4 : f == 1 || (o.mec == f - 2 && o.estado < 4)).toList()
      ..sort((a, b) => b.n.compareTo(a.n));
    final b = taller.bajos.length;
    return ListView(padding: const EdgeInsets.all(12), children: [
      if (b > 0)
        Card(
            color: kNaranja.withAlpha(51),
            child: ListTile(leading: const Icon(Icons.warning_amber), title: Text('$b repuesto(s) por agotarse'),
                trailing: const Icon(Icons.chevron_right),
                onTap: widget.onVerInventario)),
      Wrap(spacing: 8, children: [
        for (final e in ['Abiertas', 'Todas', ...mecanicos].indexed)
          ChoiceChip(label: Text(e.$2), selected: f == e.$1, onSelected: (_) => setState(() => f = e.$1))
      ]),
      const SizedBox(height: 8),
      if (l.isEmpty)
        estadoVacio(Icons.assignment_outlined, 'No hay órdenes en este filtro',
            detalle: f == 0 ? 'No hay trabajos abiertos en el taller.' : null,
            boton: 'Nueva orden',
            onBoton: () => nuevaOrden(c)),
      for (final o in l) _tarjeta(c, o),
      const SizedBox(height: 80),
    ]);
  }

  Widget _tarjeta(BuildContext c, Orden o) {
    final v = taller.veh(o.vehiculoId), s = taller.saldo(o);
    final deb = s > 0 && o.estado < 5 ? ' · debe ${money(s)}' : '';
    return Card(
        child: ListTile(
            onTap: () => ir(c, OrdenPage(o.id)),
            isThreeLine: true,
            title: Text('#${o.n} · ${v.mat}'),
            subtitle: Text('${v.marca} ${v.modelo} · ${taller.cli(v.clienteId).nombre}\nMecánico: ${mecanicos[o.mec]}$deb'),
            trailing: estadoChip(o.estado)));
  }
}
