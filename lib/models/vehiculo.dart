import '../utils/helpers.dart';

class Vehiculo {
  final String id, clienteId;
  String mat, marca, modelo;
  int anio;
  double km;
  Vehiculo(this.id, this.clienteId, this.mat, this.marca, this.modelo, this.anio, this.km);
  Map<String, dynamic> toJson() =>
      {'id': id, 'c': clienteId, 'mat': mat, 'marca': marca, 'modelo': modelo, 'anio': anio, 'km': km};
  factory Vehiculo.fromJson(Map j) =>
      Vehiculo(j['id'], j['c'], j['mat'], j['marca'], j['modelo'], j['anio'], toD(j['km']));
}
