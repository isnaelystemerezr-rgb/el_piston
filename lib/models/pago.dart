import '../utils/helpers.dart';

class Pago {
  final double m;
  final String f;
  Pago(this.m, this.f);
  Map<String, dynamic> toJson() => {'m': m, 'f': f};
  factory Pago.fromJson(Map j) => Pago(toD(j['m']), j['f']);
}
