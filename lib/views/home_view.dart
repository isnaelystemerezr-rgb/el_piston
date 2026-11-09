import 'package:flutter/material.dart';
import '../app/injector.dart';
import '../widgets/ajustes_sheet.dart';
import '../widgets/cliente_forms.dart';
import '../widgets/nueva_orden_sheet.dart';
import '../widgets/repuesto_form.dart';
import 'clientes_view.dart';
import 'inventario_view.dart';
import 'ordenes_view.dart';
import 'resumen_view.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int i = 0;
  @override
  Widget build(BuildContext c) => ListenableBuilder(
      listenable: taller,
      builder: (c, _) => Scaffold(
            appBar: AppBar(
                leading: Padding(
                    padding: const EdgeInsets.all(8), child: Image.asset('assets/images/logo.png')),
                title: Text(['Órdenes de servicio', 'Clientes', 'Inventario', 'Resumen'][i]),
                actions: [
                  IconButton(icon: const Icon(Icons.settings), tooltip: 'Ajustes', onPressed: () => abrirAjustes(c))
                ]),
            body: [OrdenesPage(onVerInventario: () => setState(() => i = 2)), const ClientesPage(), const InventarioPage(), const ResumenPage()][i],
            floatingActionButton: i == 3
                ? null
                : FloatingActionButton.extended(
                    icon: const Icon(Icons.add),
                    label: Text(['Orden', 'Cliente', 'Repuesto'][i]),
                    onPressed: () {
                      if (i == 0) nuevaOrden(c);
                      if (i == 1) nuevoCliente(c);
                      if (i == 2) editarRepuesto(c);
                    }),
            bottomNavigationBar: NavigationBar(
                selectedIndex: i,
                onDestinationSelected: (x) => setState(() => i = x),
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.assignment), label: 'Órdenes'),
                  NavigationDestination(icon: Icon(Icons.people), label: 'Clientes'),
                  NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Repuestos'),
                  NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Resumen'),
                ]),
          ));
}
