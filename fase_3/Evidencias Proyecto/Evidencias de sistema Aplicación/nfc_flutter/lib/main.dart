import 'package:flutter/material.dart';
import 'package:nfc_flutter/viewmodels/scanner_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nfc_flutter/business_logic/actions/User_actions/auth_actions.dart';
import 'package:nfc_flutter/business_logic/service/authService.dart';
import 'package:nfc_flutter/viewmodels/User_viewmodel/auth_viewmodel.dart';
import 'views/screen/home_screen.dart';
import 'views/screen/login_screen.dart';
import 'views/screen/register_screen.dart';
import 'views/screen/inicio_screen.dart';
import 'views/screen/inventario_screen.dart';
import 'views/screen/scanner.dart';
import 'views/screen/scanner_comparar.dart';
import 'firebase_options.dart';
import 'package:nfc_flutter/business_logic/service/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Pantalla de Ajustes
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Pantalla de Ajustes'),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Error inicializando Firebase: $e');
  }
  // Limpiar la persistencia si es necesario y solo una vez al inicio
  // Esto se hace si es necesario limpiar los datos persistentes previos, por ejemplo, cuando se cambia de usuario
  try {
    await FirebaseFirestore.instance.clearPersistence();
    print('Persistencia de Firestore limpiada');
  } catch (e) {
    print('Error al limpiar persistencia: $e');
  }

  // Establecer configuraciones de persistencia
  FirebaseFirestore.instance.settings = Settings(persistenceEnabled: false);
  print('Persistencia habilitada para Firestore');

  // Ejecutar la app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => ScannerViewModel(FirebaseFirestore.instance)),

        // Proveedor para AuthService
        Provider(create: (_) => AuthService()),

        // Proveedor para AuthViewModel
        ChangeNotifierProvider(
            create: (context) =>
                AuthViewModel(AuthUseCase(context.read<AuthService>()))),

        // Proveedor para FirestoreService
        Provider(create: (_) => FirestoreService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute:
          '/', // Mantengo la ruta original, puedes cambiarla si lo necesitas
      routes: {
        '/': (context) => InicioScreen(),
        '/register': (context) => RegisterScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => MyHomePage(),
        '/inventario': (context) => InventarioScreen(),
        '/scanner': (context) => ScannerScreen(),
        '/sincronizar': (context) => PickingScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
