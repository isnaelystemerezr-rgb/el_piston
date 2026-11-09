import 'package:flutter/foundation.dart';
import '../data/datos_iniciales.dart';
import '../data/piston_repository.dart';
import '../models/cliente.dart';
import '../models/orden.dart';
import '../models/pago.dart';
import '../models/repuesto.dart';
import '../models/trabajo.dart';
import '../models/uso.dart';
import '../models/vehiculo.dart';
import '../utils/helpers.dart';
import '../widgets/cliente_forms.dart';

class TallerViewModel extends ChangeNotifier {
  final PistonRepository _repo;
  TallerViewModel(this._repo);

  List<Cliente> clientes = [];
  List<Vehiculo> vehiculos = [];
  List<Repuesto> repuestos = [];
  List<Orden> ordenes = [];
  int seq = 1;

  Future<void> load() async {
    final j = await _repo.leer();
    if (j == null) {
      _aplicar(datosDemo());
      await _save();
      return;
    }
    clientes = [for (final x in j['c']) Cliente.fromJson(x)];
    vehiculos = [for (final x in j['v']) Vehiculo.fromJson(x)];
    repuestos = [for (final x in j['r']) Repuesto.fromJson(x)];
    ordenes = [for (final x in j['o']) Orden.fromJson(x)];
    seq = j['seq'];
  }

  Future<void> _save() async {
    notifyListeners();
    await _repo.guardar({'c': clientes, 'v': vehiculos, 'r': repuestos, 'o': ordenes, 'seq': seq});
  }

  Cliente cli(String id) => clientes.firstWhere((x) => x.id == id);
  Vehiculo veh(String id) => vehiculos.firstWhere((x) => x.id == id);
  Repuesto rep(String id) => repuestos.firstWhere((x) => x.id == id);
  Orden ord(String id) => ordenes.firstWhere((x) => x.id == id);
  double mano(Orden o) => o.trabajos.fold(0.0, (a, t) => a + t.p);
  double total(Orden o) => mano(o) + o.usos.fold(0.0, (a, u) => a + u.q * u.p);
  double pagado(Orden o) => o.pagos.fold(0.0, (a, p) => a + p.m);
  double saldo(Orden o) => total(o) - pagado(o);
  double deuda(String clienteId) => ordenes
      .where((o) => o.estado < 5 && veh(o.vehiculoId).clienteId == clienteId)
      .fold(0.0, (a, o) => a + saldo(o));
  List<Repuesto> get bajos => repuestos.where((r) => r.bajo).toList();

  void addCliente(String n, String t, String d) {
    clientes.add(Cliente(uid(), n, t, d));
    _save();
  }

  String? addVehiculo(String cid, String mat, String marca, String modelo, int anio, double km) {
    if (vehiculos.any((v) => v.mat == mat)) return 'Esa matrícula ya está registrada';
    vehiculos.add(Vehiculo(uid(), cid, mat, marca, modelo, anio, km));
    _save();
    return null;
  }

  void addOrden(String vid, double km, String problema, int mec) {
    veh(vid).km = km;
    ordenes.add(Orden(uid(), seq++, vid, hoy(), problema, mec));
    _save();
  }

  void setMec(Orden o, int m) {
    o.mec = m;
    _save();
  }

  void setEstado(Orden o, int e) {
    if (e == 5) for (final u in o.usos) rep(u.repId).stock += u.q;
    o.fechaEntrega = e == 4 ? hoy() : null;
    o.estado = e;
    _save();
  }

  void addTrabajo(Orden o, String d, double p) {
    o.trabajos.add(Trabajo(d, p));
    _save();
  }

  String? usar(Orden o, Repuesto r, int q) {
    if (q <= 0) return 'Cantidad inválida';
    if (q > r.stock) return 'Solo hay ${r.stock} en existencias';
    r.stock -= q;
    final i = o.usos.indexWhere((u) => u.repId == r.id && u.p == r.precio);
    if (i >= 0) {
      o.usos[i] = Uso(r.id, o.usos[i].q + q, r.precio);
    } else {
      o.usos.add(Uso(r.id, q, r.precio));
    }
    _save();
    return null;
  }

  String? pagar(Orden o, double m) {
    if (m <= 0) return 'Monto inválido';
    if (m > saldo(o) + 0.001) return 'El pago supera lo que falta por pagar';
    o.pagos.add(Pago(m, hoy()));
    _save();
    return null;
  }

  String? guardarRepuesto(Repuesto? r, String n, String cod, double p, int s, int m) {
    if (repuestos.any((x) => x.codigo == cod && x != r)) return 'Ese código ya existe';
    if (r == null) {
      repuestos.add(Repuesto(uid(), n, cod, p, s, m));
    } else {
      r..nombre = n..codigo = cod..precio = p..stock = s..minimo = m;
    }
    _save();
    return null;
  }

  Orden? ordenOrNull(String id) {
    for (final o in ordenes) {
      if (o.id == id) return o;
    }
    return null;
  }

  Cliente? cliOrNull(String id) {
    for (final c in clientes) {
      if (c.id == id) return c;
    }
    return null;
  }

  void editarCliente(Cliente c, String n, String t, String d) {
    c
      ..nombre = n
      ..tel = t
      ..dir = d;
    _save();
  }

  String? eliminarCliente(Cliente c) {
    final ids = vehiculos.where((v) => v.clienteId == c.id).map((v) => v.id).toSet();
    if (ordenes.any((o) => ids.contains(o.vehiculoId))) return 'No se puede eliminar: tiene servicios registrados';
    vehiculos.removeWhere((v) => v.clienteId == c.id);
    clientes.remove(c);
    _save();
    return null;
  }

  String? guardarVehiculo(Vehiculo? v, String cid, String mat, String marca, String modelo, int anio, double km) {
    if (v == null) return addVehiculo(cid, mat, marca, modelo, anio, km);
    if (vehiculos.any((x) => x.mat == mat && x != v)) return 'Esa matrícula ya está registrada';
    v
      ..mat = mat
      ..marca = marca
      ..modelo = modelo
      ..anio = anio
      ..km = km;
    _save();
    return null;
  }

  String? eliminarVehiculo(Vehiculo v) {
    if (ordenes.any((o) => o.vehiculoId == v.id)) return 'No se puede eliminar: tiene servicios registrados';
    vehiculos.remove(v);
    _save();
    return null;
  }

  void editarProblema(Orden o, String p) {
    o.problema = p;
    _save();
  }

  void eliminarOrden(Orden o) {
    if (o.estado != 5) {
      for (final u in o.usos) {
        rep(u.repId).stock += u.q;
      }
    }
    ordenes.remove(o);
    _save();
  }

  void editarTrabajo(Orden o, int i, String d, double p) {
    o.trabajos[i] = Trabajo(d, p);
    _save();
  }

  void quitarTrabajo(Orden o, int i) {
    o.trabajos.removeAt(i);
    _save();
  }

  String? cambiarCantidadUso(Orden o, int i, int q) {
    final u = o.usos[i], r = rep(u.repId), dif = q - u.q;
    if (dif > r.stock) return 'Solo hay ${r.stock} más en existencias';
    r.stock -= dif;
    o.usos[i] = Uso(u.repId, q, u.p);
    _save();
    return null;
  }

  void quitarUso(Orden o, int i) {
    final u = o.usos.removeAt(i);
    rep(u.repId).stock += u.q;
    _save();
  }

  void quitarPago(Orden o, int i) {
    o.pagos.removeAt(i);
    _save();
  }

  void reponer(Repuesto r, int q) {
    r.stock += q;
    _save();
  }

  String? eliminarRepuesto(Repuesto r) {
    if (ordenes.any((o) => o.usos.any((u) => u.repId == r.id))) return 'No se puede eliminar: se usó en alguna orden';
    repuestos.remove(r);
    _save();
    return null;
  }

  void _aplicar(DatosTaller d) {
    clientes = d.clientes;
    vehiculos = d.vehiculos;
    repuestos = d.repuestos;
    ordenes = d.ordenes;
    seq = d.seq;
  }

  Future<void> restaurarDemo() async {
    _aplicar(datosDemo());
    await _save();
  }

  Future<void> borrarTodo() async {
    _aplicar(DatosTaller([], [], [], [], 1));
    await _save();
  }
}
