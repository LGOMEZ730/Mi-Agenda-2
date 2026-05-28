import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../models/contacto_model.dart';
import 'agregar_contacto_screen.dart';
import 'login_screen.dart'; 

class ContactosScreen extends StatefulWidget {
  const ContactosScreen({super.key});

  @override
  State<ContactosScreen> createState() => _ContactosScreenState();
}

class _ContactosScreenState extends State<ContactosScreen> {
  bool _estaBuscando = false;
  String _textoBusqueda = "";

  @override
  void initState() {
    super.initState();
    // cargar los contactos desde SQLite al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContactosProvider>(context, listen: false).cargarContactos();
    });
  }

  // metodo para cerrar sesion
  void _cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false); // Modificamos el valor de la clave

    if (mounted) {
      // volver al login eliminando el historial para que no pueda volver con el btn atras
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _estaBuscando 
          ? TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Buscar contacto...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Color.fromARGB(179, 0, 0, 0)),
              ),
              style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              onChanged: (value) {
                setState(() {
                  _textoBusqueda = value.toLowerCase();
                });
              },
            )
          : const Text('Contactos'),
        actions: [
          IconButton(
            icon: Icon(_estaBuscando ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _estaBuscando = !_estaBuscando;
                if (!_estaBuscando) _textoBusqueda = "";
              });
            },
          ),
          // btn cerrar sesion
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Cerrar Sesión',
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: Consumer<ContactosProvider>(
        builder: (context, provider, child) {
          final listaFiltrada = provider.contactos.where((c) {
            final nombreCompleto = "${c.nombre} ${c.apellido}".toLowerCase();
            return nombreCompleto.contains(_textoBusqueda);
          }).toList();

          if (listaFiltrada.isEmpty) {
            return const Center(child: Text('Sin resultados'));
          }

          return ListView.builder(
            itemCount: listaFiltrada.length,
            itemBuilder: (context, index) {
              final contacto = listaFiltrada[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(contacto.nombre[0].toUpperCase()),
                ),
                title: Text('${contacto.nombre} ${contacto.apellido}'),
                subtitle: Text(contacto.telefono),
                // botones de modificacion
                trailing: Row(
                  mainAxisSize: MainAxisSize.min, // fila solo ocupa el espacio de los iconos
                  children: [
                    // btn editar
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        // pantalla de agregar pasandole el contacto a editar
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AgregarContactoScreen(contacto: contacto),
                          ),
                        );
                      },
                    ),
                    // btn eliminar
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // texto confima
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Eliminar Contacto'),
                            content: Text('¿Seguro que querés borrar a ${contacto.nombre}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  provider.eliminarContacto(contacto.id!); // llama a la baja en SQLite
                                  Navigator.pop(context);
                                },
                                child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AgregarContactoScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}