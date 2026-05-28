import 'package:flutter/material.dart';
import '../database/db_helper.dart'; // <--- IMPORTANTE

// datos de los contactos para sqLite
class Contacto {
  final int? id; // id opcional porque al crear un contacto nuevo sqlite lo genera solo
  final String nombre;
  final String apellido;
  final String telefono;
  final String domicilio;
  final String genero;

  Contacto({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.domicilio,
    required this.genero,
  });

  // covert un objeto contacto en un map para guardarlo en la bd
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'domicilio': domicilio,
      'genero': genero,
    };
  }

  // convertir map proveniente de la bd en un objeto contacto
  factory Contacto.fromMap(Map<String, dynamic> map) {
    return Contacto(
      id: map['id'],
      nombre: map['nombre'],
      apellido: map['apellido'],
      telefono: map['telefono'],
      domicilio: map['domicilio'],
      genero: map['genero'],
    );
  }
}

// clase para provider conectada directamente con sqlite
class ContactosProvider with ChangeNotifier {
  List<Contacto> _contactos = [];

  List<Contacto> get contactos => _contactos;

  // carga de contactos desde SQLite y actualiza la interfaz
  Future<void> cargarContactos() async {
    _contactos = await DBHelper.instance.queryAllRows();
    notifyListeners();
  }

  // alta en bd
  Future<void> agregarContacto(Contacto nuevo) async {
    await DBHelper.instance.insert(nuevo);
    await cargarContactos(); // recarga lista para reflejar los cambios 
  }

  // modif en bd
  Future<void> editarContacto(Contacto contactoEditado) async {
    await DBHelper.instance.update(contactoEditado);
    await cargarContactos();
  }

  // baja en bd
  Future<void> eliminarContacto(int id) async {
    await DBHelper.instance.delete(id);
    await cargarContactos();
  }
}