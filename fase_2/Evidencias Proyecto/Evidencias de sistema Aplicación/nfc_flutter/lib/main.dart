import 'package:flutter/material.dart';
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
import 'views/screen/sincronizar.dart';
import 'firebase_options.dart';
import 'package:nfc_flutter/business_logic/service/firestore_service.dart';
import 'package:nfc_flutter/viewmodels/inventario_viewmodel.dart';
import 'package:nfc_flutter/business_logic/actions/User_actions/nfc_action.dart';
import 'package:nfc_flutter/business_logic/actions/User_actions/inventory_action.dart';

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
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Error inicializando Firebase: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        // Proveedor para AuthService
        Provider(create: (_) => AuthService()),

        // Proveedor para AuthViewModel
        ChangeNotifierProvider(
            create: (context) =>
                AuthViewModel(AuthUseCase(context.read<AuthService>()))),

        // Proveedor para FirestoreService
        Provider(create: (_) => FirestoreService()),

        // Proveedor para NFCAction
        Provider(create: (_) => NFCAction()),

        // Proveedor para InventoryAction, pasando FirestoreService como parámetro
        ProxyProvider<FirestoreService, InventoryAction>(
          update: (context, firestoreService, inventoryAction) =>
              InventoryAction(firestoreService: firestoreService),
        ),
        // Proveedor para InventarioViewModel
        ChangeNotifierProvider(
          create: (context) => InventarioViewModel(
            context.read<InventoryAction>(), // Pasar InventoryAction
            context.read<NFCAction>(), // Pasar NFCAction
            context.read<FirestoreService>(), // Pasar FirestoreService
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => InicioScreen(),
        '/register': (context) => RegisterScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => MyHomePage(),
        '/inventario': (context) => InventarioScreen(),
        '/scanner': (context) => ScannerScreen(),
        '/sincronizar': (context) => SincronizarScreen(),
        '/settings': (context) =>
            SettingsScreen(), // Nueva ruta para la pantalla de Ajustes
      },
    );
  }
}
