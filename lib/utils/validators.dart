

double? dn(String s) => double.tryParse(s.replaceAll(',', '.'));
bool vacio(Iterable<String> l) => l.any((s) => s.isEmpty);
