import '../models/cliente.dart';
import '../models/orden.dart';
import '../models/pago.dart';
import '../models/repuesto.dart';
import '../models/trabajo.dart';
import '../models/uso.dart';
import '../models/vehiculo.dart';
import '../utils/helpers.dart';

class DatosTaller {
  final List<Cliente> clientes;
  final List<Vehiculo> vehiculos;
  final List<Repuesto> repuestos;
  final List<Orden> ordenes;
  final int seq;
  DatosTaller(this.clientes, this.vehiculos, this.repuestos, this.ordenes, this.seq);
}

Orden _orden(int n, String v, int atras, String pr, int mec, int e,
        {int? ent, List<Trabajo> t = const [], List<Uso> u = const [], List<Pago> g = const []}) =>
    Orden('o$n', n, v, haceDias(atras), pr, mec,
        estado: e,
        fechaEntrega: ent == null ? null : haceDias(ent),
        trabajos: [...t],
        usos: [...u],
        pagos: [...g]);

DatosTaller datosDemo() {
  final clientes = [
    Cliente('c1', 'Ana María Pérez', '5 234 5678', 'Calle Martí #112, Pinar del Río'),
    Cliente('c2', 'Luis Alberto Gómez', '5 345 6789', 'Reparto Hermanos Cruz'),
    Cliente('c3', 'Yadira Fernández', '5 456 7890', 'Calle Gerardo Medina #78'),
    Cliente('c4', 'Roberto Suárez', '5 567 8901', 'Calle Rafael Morales #45'),
    Cliente('c5', 'Maylin Castro', '5 678 9012', 'Carretera Central km 3'),
    Cliente('c6', 'Osvaldo Hernández', '5 789 0123', 'Reparto Hermanos Barcón'),
    Cliente('c7', 'Idania Morales', '5 890 1234', 'Reparto Camilo Cienfuegos'),
    Cliente('c8', 'Dayron Álvarez', '5 901 2345', 'Calle Isabel Rubio #230'),
  ];
  final vehiculos = [
    Vehiculo('v1', 'c1', 'B123456', 'Lada', '2107', 1998, 184500),
    Vehiculo('v2', 'c1', 'P234567', 'Geely', 'CK', 2012, 96200),
    Vehiculo('v3', 'c2', 'B345678', 'Peugeot', '206', 2006, 142000),
    Vehiculo('v4', 'c3', 'P456789', 'Hyundai', 'Accent', 2010, 118300),
    Vehiculo('v5', 'c4', 'B567890', 'Chevrolet', 'Bel Air', 1955, 61000),
    Vehiculo('v6', 'c4', 'P678901', 'Moskvich', '412', 1985, 203400),
    Vehiculo('v7', 'c5', 'B789012', 'Kia', 'Rio', 2015, 74800),
    Vehiculo('v8', 'c6', 'P890123', 'Toyota', 'Corolla', 2004, 221000),
    Vehiculo('v9', 'c7', 'B901234', 'Chery', 'QQ', 2013, 88700),
    Vehiculo('v10', 'c8', 'P012345', 'Suzuki', 'Swift', 2009, 130000),
  ];
  final repuestos = [
    Repuesto('r1', 'Filtro de aceite', 'FA-100', 8, 14, 4),
    Repuesto('r2', 'Pastillas de freno', 'PF-220', 35, 3, 3),
    Repuesto('r3', 'Bujía', 'BJ-310', 6, 18, 8),
    Repuesto('r4', 'Aceite 10W-40 (litro)', 'AC-104', 7.5, 26, 10),
    Repuesto('r5', 'Filtro de aire', 'FAI-120', 12, 2, 4),
    Repuesto('r6', 'Correa de distribución', 'CD-450', 48, 5, 2),
    Repuesto('r7', 'Batería 12V 60Ah', 'BT-60', 95, 4, 2),
    Repuesto('r8', 'Amortiguador delantero', 'AM-210', 62, 6, 2),
    Repuesto('r9', 'Líquido de frenos', 'LF-500', 9, 1, 3),
    Repuesto('r10', 'Filtro de combustible', 'FC-130', 10, 9, 3),
    Repuesto('r11', 'Lámpara de faro', 'LM-55', 4, 25, 10),
    Repuesto('r12', 'Disco de freno', 'DF-330', 42, 4, 2),
    Repuesto('r13', 'Refrigerante (litro)', 'RF-700', 6, 12, 4),
    Repuesto('r14', 'Contrapesa de balanceo', 'CB-15', 3, 30, 10),
    Repuesto('r15', 'Aceite de transmisión (litro)', 'AT-80', 9, 8, 3),
  ];
  final ordenes = [
    _orden(1, 'v1', 25, 'Cambio de aceite y revisión general', 0, 4, ent: 24,
        t: [Trabajo('Cambio de aceite y filtro', 15)], u: [Uso('r4', 4, 7.5), Uso('r1', 1, 8)], g: [Pago(53, haceDias(24))]),
    _orden(2, 'v3', 20, 'Se va hacia un lado al frenar', 1, 4, ent: 18,
        t: [Trabajo('Alineación', 25), Trabajo('Balanceo', 20)], u: [Uso('r14', 4, 3)], g: [Pago(25, haceDias(18))]),
    _orden(3, 'v4', 15, 'Pastillas de freno gastadas, chirrían', 0, 4, ent: 14,
        t: [Trabajo('Cambio de pastillas delanteras', 30)], u: [Uso('r2', 1, 35)], g: [Pago(65, haceDias(14))]),
    _orden(4, 'v6', 12, 'Correa de distribución rota, no arranca', 1, 4, ent: 10,
        t: [Trabajo('Cambio de correa de distribución', 60)], u: [Uso('r6', 1, 48)],
        g: [Pago(50, haceDias(11)), Pago(40, haceDias(10))]),
    _orden(5, 'v7', 9, 'No enciende por las mañanas', 0, 4, ent: 8,
        t: [Trabajo('Cambio de batería', 10)], u: [Uso('r7', 1, 95)], g: [Pago(105, haceDias(8))]),
    _orden(6, 'v8', 6, 'Fallos al acelerar', 1, 4, ent: 5,
        t: [Trabajo('Cambio de bujías', 18)], u: [Uso('r3', 4, 6)], g: [Pago(42, haceDias(5))]),
    _orden(7, 'v5', 4, 'Amortiguadores vencidos, rebota mucho', 0, 4, ent: 2,
        t: [Trabajo('Cambio de amortiguadores delanteros', 70)], u: [Uso('r8', 2, 62)], g: [Pago(100, haceDias(2))]),
    _orden(8, 'v2', 3, 'Mantenimiento de los 5000 km', 1, 3,
        t: [Trabajo('Cambio de aceite', 15)], u: [Uso('r4', 4, 7.5), Uso('r1', 1, 8)], g: [Pago(20, haceDias(3))]),
    _orden(9, 'v1', 2, 'Frena mal y vibra el pedal', 0, 2,
        t: [Trabajo('Cambio de discos de freno', 40)], u: [Uso('r12', 2, 42), Uso('r9', 1, 9)]),
    _orden(10, 'v9', 1, 'Los faros delanteros no encienden', 1, 2,
        t: [Trabajo('Revisión del sistema eléctrico', 35)], u: [Uso('r11', 2, 4)]),
    _orden(11, 'v3', 1, 'El motor se calienta y sale vapor', 0, 1, t: [Trabajo('Diagnóstico del sistema de enfriamiento', 12)], u: [Uso('r13', 2, 6)]),
    _orden(12, 'v6', 0, 'Ruido metálico en la caja de cambios', 1, 0,
        t: [Trabajo('Revisión inicial de la caja', 8)], u: [Uso('r15', 2, 9)]),
    _orden(13, 'v4', 10, 'El aire acondicionado no enfría', 0, 5,
        t: [Trabajo('Diagnóstico del aire acondicionado', 10)], g: [Pago(10, haceDias(10))]),
    _orden(14, 'v10', 5, 'Cambio de filtros de aire y combustible', 1, 4, ent: 4,
        t: [Trabajo('Cambio de filtros', 12)], u: [Uso('r5', 1, 12), Uso('r10', 1, 10)], g: [Pago(34, haceDias(4))]),
  ];
  return DatosTaller(clientes, vehiculos, repuestos, ordenes, 15);
}
