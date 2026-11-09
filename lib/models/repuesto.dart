import '../utils/helpers.dart';

class Repuesto {
  final String id;
  String nombre, codigo;
  double precio;
  int stock, minimo;
  Repuesto(this.id, this.nombre, this.codigo, this.precio, this.stock, this.minimo);
  bool get bajo => stock <= minimo;
  Map<String, dynamic> toJson() =>
      {'id': id, 'n': nombre, 'cod': codigo, 'p': precio, 's': stock, 'm': minimo};
  factory Repuesto.fromJson(Map j) =>
      Repuesto(j['id'], j['n'], j['cod'], toD(j['p']), j['s'], j['m']);
}
