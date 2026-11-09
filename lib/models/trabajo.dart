import '../utils/helpers.dart';

class Trabajo {
  final String d;
  final double p;
  Trabajo(this.d, this.p);
  Map<String, dynamic> toJson() => {'d': d, 'p': p};
  factory Trabajo.fromJson(Map j) => Trabajo(j['d'], toD(j['p']));
}
