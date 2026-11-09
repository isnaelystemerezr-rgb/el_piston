import '../utils/helpers.dart';

class Uso {
  final String repId;
  final int q;
  final double p;
  Uso(this.repId, this.q, this.p);
  Map<String, dynamic> toJson() => {'r': repId, 'q': q, 'p': p};
  factory Uso.fromJson(Map j) => Uso(j['r'], j['q'], toD(j['p']));
}
