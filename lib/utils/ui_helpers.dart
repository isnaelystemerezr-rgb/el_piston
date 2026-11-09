import 'package:flutter/material.dart';

void msg(BuildContext c, String t) => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(t)));
void ir(BuildContext c, Widget w) => Navigator.push(c, MaterialPageRoute(builder: (_) => w));
Future<bool> confirmar(BuildContext c, String t) async =>
    await showDialog<bool>(
        context: c,
        builder: (_) => AlertDialog(title: Text(t), actions: [
              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('No')),
              FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Sí')),
            ])) ??
    false;
