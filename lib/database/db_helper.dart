import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contacto_model.dart';

class DBHelper {
  static const _databaseName = "agenda_contactos.db";
  static const _databaseVersion = 1;
  static const table = 'contactos';

  // Nombres de las columnas (deben coincidir con el modelo)
  static const columnId = 'id';
  static const columnNombre = 'nombre';
  static const columnApellido = 'apellido';
  static const columnTelefono = 'telefono';
  static const columnDomicilio = 'domicilio';
  static const columnGenero = 'genero';

  // Estructura Singleton para usar la misma instancia en toda la app
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // Crear la tabla con todas tus variables
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnNombre TEXT NOT NULL,
            $columnApellido TEXT NOT NULL,
            $columnTelefono TEXT NOT NULL,
            $columnDomicilio TEXT NOT NULL,
            $columnGenero TEXT NOT NULL
          )
          ''');
  }

  // ALTA
  Future<int> insert(Contacto contacto) async {
    Database db = await instance.database;
    return await db.insert(table, contacto.toMap());
  }

  // LISTADO
  Future<List<Contacto>> queryAllRows() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(table);
    return List.generate(maps.length, (i) => Contacto.fromMap(maps[i]));
  }

  // MODIFICACIÓN
  Future<int> update(Contacto contacto) async {
    Database db = await instance.database;
    return await db.update(
      table,
      contacto.toMap(),
      where: '$columnId = ?',
      whereArgs: [contacto.id],
    );
  }

  // BAJA
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}