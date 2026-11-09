import 'package:flutter/material.dart';
import '../utils/constants.dart';

Future<void> form(BuildContext c, String t, List<String> campos, String? Function(List<String>) accion,
        {List<String>? init, Set<int> nums = const {}}) =>
    showModalBottomSheet(
        context: c, isScrollControlled: true, builder: (_) => _Form(t, campos, accion, init, nums));

class _Form extends StatefulWidget {
  final String t;
  final List<String> campos;
  final String? Function(List<String>) accion;
  final List<String>? init;
  final Set<int> nums;
  const _Form(this.t, this.campos, this.accion, this.init, this.nums);
  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late final cs = [
    for (var i = 0; i < widget.campos.length; i++) TextEditingController(text: widget.init?[i] ?? '')
  ];
  String? err;
  @override
  Widget build(BuildContext c) => Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(c).viewInsets.bottom + 16),
      child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(widget.t, style: Theme.of(c).textTheme.titleLarge),
        for (var i = 0; i < cs.length; i++)
          Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextField(
                  controller: cs[i],
                  keyboardType: widget.nums.contains(i) ? const TextInputType.numberWithOptions(decimal: true) : null,
                  decoration: InputDecoration(labelText: widget.campos[i], border: const OutlineInputBorder()))),
        if (err != null)
          Padding(padding: const EdgeInsets.only(top: 8), child: Text(err!, style: const TextStyle(color: kRojo))),
        const SizedBox(height: 12),
        SizedBox(
            width: double.infinity,
            child: FilledButton(
                onPressed: () {
                  final e = widget.accion([for (final x in cs) x.text.trim()]);
                  if (e != null) {
                    setState(() => err = e);
                  } else {
                    Navigator.pop(c);
                  }
                },
                child: const Text('Guardar')))
      ])));
}
