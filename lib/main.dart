import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'models/contacto_model.dart';
import 'screens/login_screen.dart';
import 'screens/contactos_screen.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  // autenticacion
  final prefs = await SharedPreferences.getInstance();
  final bool loggedIn = prefs.getBool('isLoggedIn') ?? false; // null = false

  runApp(
    ChangeNotifierProvider(
      create: (context) => ContactosProvider(),
      child: MiAgendaApp(isLoggedIn: loggedIn), 
    ),
  );
}

class MiAgendaApp extends StatelessWidget {
  final bool isLoggedIn;
  
  // estado de sesion
  const MiAgendaApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi Agenda',
      // si esta log entra, sino al login
      home: isLoggedIn ? const ContactosScreen() : const LoginScreen(),
    );
  }
}