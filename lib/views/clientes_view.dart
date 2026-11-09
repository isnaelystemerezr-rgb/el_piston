import 'package:flutter/material.dart';
import '../app/injector.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/ui_helpers.dart';
import '../widgets/cliente_forms.dart';
import '../widgets/common_widgets.dart';
import 'cliente_detalle_view.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});
  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  String q = '';
  @override
  Widget build(BuildContext c) => ListenableBuilder(listenable: taller, builder: (c, _) => _contenido(c));

  Widget _contenido(BuildContext c) {
    final s = q.toLowerCase();
    final l = taller.clientes.where((x) =>
        s.isEmpty ||
        '${x.nombre}${x.tel}'.toLowerCase().contains(s) ||
        taller.vehiculos.any((v) => v.clienteId == x.id && v.mat.toLowerCase().contains(s)));
    return ListView(padding: const EdgeInsets.all(12), children: [
      TextField(
          onChanged: (x) => setState(() => q = x),
          decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search), hintText: 'Buscar nombre, teléfono o matrícula', border: OutlineInputBorder())),
      const SizedBox(height: 8),
      if (taller.clientes.isEmpty)
        estadoVacio(Icons.people_outline, 'Aún no hay clientes', boton: 'Nuevo cliente', onBoton: () => nuevoCliente(c))
      else if (l.isEmpty)
        estadoVacio(Icons.search_off, 'Ningún cliente coincide con la búsqueda'),
      for (final x in l)
        Card(
            child: ListTile(
                onTap: () => ir(c, ClientePage(x.id)),
                title: Text(x.nombre),
                isThreeLine: true,
                subtitle: Text('${x.tel}\n${_placas(x.id)}'),
                trailing: taller.deuda(x.id) > 0
                    ? Text('debe ${money(taller.deuda(x.id))}', style: const TextStyle(color: kRojo))
                    : null)),
      const SizedBox(height: 80),
    ]);
  }
}

String _placas(String id) {
  final l = taller.vehiculos.where((v) => v.clienteId == id).map((v) => '${v.mat} ${v.marca} ${v.modelo}');
  return l.isEmpty ? 'Sin vehículos registrados' : l.join(' · ');
}
