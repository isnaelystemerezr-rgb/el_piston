import 'pago.dart';
import 'trabajo.dart';
import 'uso.dart';

class Orden {
  final String id, vehiculoId, fecha;
  String problema;
  final int n;
  int mec, estado;
  String? fechaEntrega;
  final List<Trabajo> trabajos;
  final List<Uso> usos;
  final List<Pago> pagos;
  Orden(this.id, this.n, this.vehiculoId, this.fecha, this.problema, this.mec,
      {this.estado = 0, this.fechaEntrega, List<Trabajo>? trabajos, List<Uso>? usos, List<Pago>? pagos})
      : trabajos = trabajos ?? [],
        usos = usos ?? [],
        pagos = pagos ?? [];
  Map<String, dynamic> toJson() => {
        'id': id, 'n': n, 'v': vehiculoId, 'f': fecha, 'pr': problema, 'mec': mec, 'e': estado,
        'fe': fechaEntrega, 't': trabajos, 'u': usos, 'g': pagos
      };
  factory Orden.fromJson(Map j) => Orden(j['id'], j['n'], j['v'], j['f'], j['pr'], j['mec'],
      estado: j['e'],
      fechaEntrega: j['fe'],
      trabajos: [for (final x in j['t']) Trabajo.fromJson(x)],
      usos: [for (final x in j['u']) Uso.fromJson(x)],
      pagos: [for (final x in j['g']) Pago.fromJson(x)]);
}
