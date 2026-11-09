import 'package:flutter/material.dart';
import '../app/injector.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/ui_helpers.dart';
import '../widgets/common_widgets.dart';
import '../widgets/repuesto_form.dart';

class InventarioPage extends StatefulWidget {
  const InventarioPage({super.key});
  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  String q = '';
  @override
  Widget build(BuildContext c) => ListenableBuilder(listenable: taller, builder: (c, _) => _contenido(c));

  Widget _contenido(BuildContext c) {
    final s = q.toLowerCase();
    final l = taller.repuestos.where((r) => s.isEmpty || '${r.nombre}${r.codigo}'.toLowerCase().contains(s)).toList()
      ..sort((a, b) => a.bajo == b.bajo ? a.nombre.compareTo(b.nombre) : (a.bajo ? -1 : 1));
    return ListView(padding: const EdgeInsets.all(12), children: [
      TextField(
          onChanged: (x) => setState(() => q = x),
          decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search), hintText: 'Buscar por nombre o código', border: OutlineInputBorder())),
      const SizedBox(height: 8),
      if (l.isEmpty)
        estadoVacio(Icons.inventory_2_outlined, q.isEmpty ? 'El inventario está vacío' : 'Ningún repuesto coincide con la búsqueda',
            boton: q.isEmpty ? 'Nuevo repuesto' : null, onBoton: () => editarRepuesto(c)),
      for (final r in l)
        Card(
            child: ListTile(
                onTap: () => editarRepuesto(c, r),
                leading: Icon(r.bajo ? Icons.warning_amber : Icons.build, color: r.bajo ? kNaranja : null),
                title: Text(r.nombre),
                subtitle: Text('${r.codigo} · ${money(r.precio)}${r.bajo ? '\nPor agotarse: comprar' : ''}'),
                isThreeLine: r.bajo,
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('${r.stock} u.', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  PopupMenuButton<String>(
                      onSelected: (x) async {
                        if (x == 'e') editarRepuesto(c, r);
                        if (x == 'r') reponerRepuesto(c, r);
                        if (x == 'x' && await confirmar(c, '¿Eliminar "${r.nombre}"?')) {
                          final e = taller.eliminarRepuesto(r);
                          if (e != null && c.mounted) msg(c, e);
                        }
                      },
                      itemBuilder: (_) => const [
                            PopupMenuItem(value: 'e', child: Text('Editar')),
                            PopupMenuItem(value: 'r', child: Text('Reponer existencias')),
                            PopupMenuItem(value: 'x', child: Text('Eliminar')),
                          ]),
                ]))),
      const SizedBox(height: 80),
    ]);
  }
}
