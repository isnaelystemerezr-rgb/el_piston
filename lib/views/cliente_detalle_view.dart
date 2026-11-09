import 'package:flutter/material.dart';
import '../app/injector.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/ui_helpers.dart';
import '../widgets/cliente_forms.dart';
import '../widgets/common_widgets.dart';
import '../widgets/nueva_orden_sheet.dart';
import 'orden_detalle_view.dart';

class ClientePage extends StatelessWidget {
  final String id;
  const ClientePage(this.id, {super.key});
  @override
  Widget build(BuildContext c) => ListenableBuilder(
      listenable: taller,
      builder: (c, _) {
        final cl = taller.cliOrNull(id);
        if (cl == null) return const Scaffold(body: Center(child: Text('El cliente ya no existe')));
        final d = taller.deuda(id);
        return Scaffold(
            appBar: AppBar(title: Text(cl.nombre), actions: [
              IconButton(icon: const Icon(Icons.edit), tooltip: 'Editar cliente', onPressed: () => editarCliente(c, cl)),
              IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Eliminar cliente',
                  onPressed: () async {
                    if (!await confirmar(c, '¿Eliminar a ${cl.nombre} y sus vehículos?')) return;
                    final e = taller.eliminarCliente(cl);
                    if (!c.mounted) return;
                    if (e != null) {
                      msg(c, e);
                    } else {
                      Navigator.pop(c);
                    }
                  }),
            ]),
            floatingActionButton: FloatingActionButton.extended(
                icon: const Icon(Icons.directions_car), label: const Text('Vehículo'), onPressed: () => nuevoVehiculo(c, id)),
            body: ListView(padding: const EdgeInsets.all(14), children: [
              Text(cl.tel),
              Text(cl.dir.isNotEmpty ? cl.dir : 'Dirección no registrada', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 6),
              Text('Saldo pendiente: ${money(d)}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: d > 0 ? kRojo : kVerde)),
              const SizedBox(height: 10),
              if (taller.vehiculos.every((v) => v.clienteId != id))
                estadoVacio(Icons.directions_car_outlined, 'Este cliente no tiene vehículos',
                    boton: 'Añadir vehículo', onBoton: () => nuevoVehiculo(c, id)),
              for (final v in taller.vehiculos.where((v) => v.clienteId == id))
                seccion('${v.mat} · ${v.marca} ${v.modelo} ${v.anio}', [
                  Text('${v.km.toStringAsFixed(0)} km', style: const TextStyle(color: Colors.grey)),
                  if (taller.ordenes.every((o) => o.vehiculoId != v.id)) vacioLinea('Este vehículo aún no tiene servicios'),
                  for (final o in (taller.ordenes.where((o) => o.vehiculoId == v.id).toList()..sort((a, b) => b.n.compareTo(a.n))))
                    ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        onTap: () => ir(c, OrdenPage(o.id)),
                        title: Text('#${o.n} · ${o.fecha} · ${estados[o.estado]}'),
                        subtitle: Text(o.problema, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: Text(money(taller.total(o)))),
                  Row(children: [
                    TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Nueva orden'),
                        onPressed: () => nuevaOrden(c, vehiculoId: v.id)),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.edit), tooltip: 'Editar vehículo', onPressed: () => editarVehiculo(c, v)),
                    IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Eliminar vehículo',
                        onPressed: () async {
                          if (!await confirmar(c, '¿Eliminar el vehículo ${v.mat}?')) return;
                          final e = taller.eliminarVehiculo(v);
                          if (e != null && c.mounted) msg(c, e);
                        }),
                  ]),
                ]),
              const SizedBox(height: 80),
            ]));
      });
}
