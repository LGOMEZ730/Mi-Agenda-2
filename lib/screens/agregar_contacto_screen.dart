import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../models/contacto_model.dart'; 

class AgregarContactoScreen extends StatefulWidget {
  // recibe contacto de forma opcional - Si viene estamos MODIFICANDO, si es null es un ALTA
  final Contacto? contacto;
  const AgregarContactoScreen({super.key, this.contacto});

  @override
  _AgregarContactoScreenState createState() => _AgregarContactoScreenState();
}

class _AgregarContactoScreenState extends State<AgregarContactoScreen> {
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _domicilioController = TextEditingController();
  String _genero = 'Masculino';

  @override
  void initState() {
    super.initState();
    // si llega un contacto para editar, cargamos sus datos
    if (widget.contacto != null) {
      _nombreController.text = widget.contacto!.nombre;
      _apellidoController.text = widget.contacto!.apellido;
      _telefonoController.text = widget.contacto!.telefono;
      _domicilioController.text = widget.contacto!.domicilio;
      _genero = widget.contacto!.genero;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    _domicilioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // cambiar el titulo segn la accion
    final esEdicion = widget.contacto != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar Contacto' : 'Agregar Contacto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // valida obligatoria de campos
              if (_nombreController.text.trim().isNotEmpty && _telefonoController.text.trim().isNotEmpty) {
                
                final provider = Provider.of<ContactosProvider>(context, listen: false);

                if (esEdicion) {
                  // modificacion
                  final contactoEditado = Contacto(
                    id: widget.contacto!.id, // id de sqlite
                    nombre: _nombreController.text.trim(),
                    apellido: _apellidoController.text.trim(),
                    telefono: _telefonoController.text.trim(),
                    domicilio: _domicilioController.text.trim(),
                    genero: _genero,
                  );
                  provider.editarContacto(contactoEditado);
                } else {
                  // alta
                  final nuevo = Contacto(
                    nombre: _nombreController.text.trim(),
                    apellido: _apellidoController.text.trim(),
                    telefono: _telefonoController.text.trim(),
                    domicilio: _domicilioController.text.trim(),
                    genero: _genero,
                  );
                  provider.agregarContacto(nuevo);
                }

                // vuelve atras lista
                Navigator.pop(context);
                
                // mje exito
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(esEdicion ? "Contacto actualizado correctamente" : "Contacto guardado correctamente"),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Por favor completa Nombre y Teléfono"),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nombreController, 
                decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _apellidoController, 
                decoration: const InputDecoration(labelText: 'Apellido', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _telefonoController, 
                decoration: const InputDecoration(labelText: 'Número de teléfono', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _domicilioController, 
                decoration: const InputDecoration(labelText: 'Domicilio', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              
              // Género
              Row(
                children: [
                  const Text("Género: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  Radio<String>(
                    value: 'Masculino', 
                    groupValue: _genero, 
                    onChanged: (val) => setState(() => _genero = val!),
                  ),
                  const Text("M"),
                  Radio<String>(
                    value: 'Femenino', 
                    groupValue: _genero, 
                    onChanged: (val) => setState(() => _genero = val!),
                  ),
                  const Text("F"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}