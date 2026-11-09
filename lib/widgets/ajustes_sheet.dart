import 'package:flutter/material.dart';
import '../app/injector.dart';
import '../utils/constants.dart';
import '../utils/ui_helpers.dart';

void abrirAjustes(BuildContext c) =>
    showModalBottomSheet(context: c, isScrollControlled: true, builder: (_) => const _Ajustes());

class _Ajustes extends StatelessWidget {
  const _Ajustes();

  Future<void> _accion(BuildContext c, String pregunta, Future<void> Function() hacer, String ok) async {
    final m = ScaffoldMessenger.of(c), nav = Navigator.of(c);
    if (!await confirmar(c, pregunta)) return;
    await hacer();
    nav.pop();
    m.showSnackBar(SnackBar(content: Text(ok)));
  }

  @override
  Widget build(BuildContext c) => ListenableBuilder(
      listenable: ajustes,
      builder: (c, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Ajustes', style: Theme.of(c).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Text('Tema de la aplicación'),
            const SizedBox(height: 8),
            SizedBox(
                width: double.infinity,
                child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto), label: Text('Sistema')),
                      ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode), label: Text('Claro')),
                      ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode), label: Text('Oscuro')),
                    ],
                    selected: {ajustes.tema},
                    onSelectionChanged: (s) => ajustes.setTema(s.first))),
            const Divider(height: 32),
            ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.restore),
                title: const Text('Restaurar datos de ejemplo'),
                subtitle: const Text('Reemplaza todo por datos de demostración'),
                onTap: () => _accion(c, '¿Reemplazar todos los datos por los de ejemplo?', taller.restaurarDemo,
                    'Datos de ejemplo restaurados')),
            ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.delete_forever, color: kRojo),
                title: const Text('Borrar todos los datos'),
                subtitle: const Text('Deja la app vacía para empezar de cero'),
                onTap: () => _accion(c, '¿Borrar TODOS los datos? No se puede deshacer.', taller.borrarTodo,
                    'Datos borrados')),
            const SizedBox(height: 8),
            const Center(child: Text('El Pistón · v1.0.0', style: TextStyle(color: Colors.grey))),
          ]))));
}
