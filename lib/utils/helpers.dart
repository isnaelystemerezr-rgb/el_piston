

int _c = 0;
String uid() => '${DateTime.now().microsecondsSinceEpoch}${_c++}';
String hoy() => DateTime.now().toIso8601String().substring(0, 10);
String money(num n) => '\$${n.toStringAsFixed(2)}';
String haceDias(int n) => DateTime.now().subtract(Duration(days: n)).toIso8601String().substring(0, 10);
double toD(dynamic x) => (x as num).toDouble();
