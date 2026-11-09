

class Cliente {
  final String id;
  String nombre, tel, dir;
  Cliente(this.id, this.nombre, this.tel, this.dir);
  Map<String, dynamic> toJson() => {'id': id, 'nombre': nombre, 'tel': tel, 'dir': dir};
  factory Cliente.fromJson(Map j) => Cliente(j['id'], j['nombre'], j['tel'], j['dir']);
}
