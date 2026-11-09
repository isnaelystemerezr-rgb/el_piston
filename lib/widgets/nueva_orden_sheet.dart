import 'package:flutter/material.dart';
import '../app/injector.dart';
import '../utils/constants.dart';
import '../utils/ui_helpers.dart';
import '../utils/validators.dart';

void nuevaOrden(BuildContext c, {String? vehiculoId}) {
  if (taller.vehiculos.isEmpty) return msg(c, 'Primero registra un cliente y su vehículo');
  showModalBottomSheet(context: c, isScrollControlled: true, builder: (_) => _NuevaOrden(vehiculoId));
}

class _NuevaOrden extends StatefulWidget {
  final String? vehiculoId;
  const _NuevaOrden(this.vehiculoId);
  @override
  State<_NuevaOrden> createState() => _NuevaOrdenState();
}

class _NuevaOrdenState extends State<_NuevaOrden> {
  late String vid = widget.vehiculoId ?? taller.vehiculos.first.id;
  int mec = 0;
  final km = TextEditingController(), pr = TextEditingController();
  @override
  Widget build(BuildContext c) => Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(c).viewInsets.bottom + 16),
      child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Nueva orden de servicio', style: Theme.of(c).textTheme.titleLarge),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
            value: vid,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Vehículo', border: OutlineInputBorder()),
            items: [
              for (final v in taller.vehiculos)
                DropdownMenuItem(
                    value: v.id,
                    child: Text('${v.mat} · ${v.marca} ${v.modelo} (${taller.cli(v.clienteId).nombre})',
                        overflow: TextOverflow.ellipsis))
            ],
            onChanged: (x) => vid = x!),
        const SizedBox(height: 10),
        TextField(
            controller: km,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Kilometraje actual', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(
            controller: pr,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Problema que reporta el cliente', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(
            value: mec,
            decoration: const InputDecoration(labelText: 'Mecánico asignado', border: OutlineInputBorder()),
            items: [
              for (var i = 0; i < mecanicos.length; i++)
                DropdownMenuItem(
                    value: i,
                    child: Text('${mecanicos[i]} (${taller.ordenes.where((o) => o.mec == i && o.estado < 4).length} abiertas)'))
            ],
            onChanged: (x) => mec = x!),
        const SizedBox(height: 14),
        SizedBox(
            width: double.infinity,
            child: FilledButton(
                onPressed: () {
                  final k = dn(km.text);
                  if (k == null || k < 0 || pr.text.trim().isEmpty) return msg(c, 'Indica kilometraje y problema');
                  taller.addOrden(vid, k, pr.text.trim(), mec);
                  Navigator.pop(c);
                },
                child: const Text('Crear orden')))
      ])));
}
