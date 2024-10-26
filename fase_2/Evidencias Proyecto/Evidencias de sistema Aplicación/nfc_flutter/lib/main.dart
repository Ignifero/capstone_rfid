// main.dart
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
import 'views/screen/inventario.dart';
import 'views/screen/scanner.dart';
import 'views/screen/sincronizar.dart';
import 'firebase_options.dart'; // Asegúrate de que esta línea esté presente
import 'package:nfc_flutter/business_logic/service/firestore_service.dart';
import 'package:nfc_flutter/viewmodels/inventario_viewmodel.dart';

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
        Provider(create: (_) => AuthService()),
        ChangeNotifierProvider(
            create: (context) =>
                AuthViewModel(AuthUseCase(context.read<AuthService>()))),
        Provider(create: (_) => FirestoreService()), // Servicio Firestore
        ChangeNotifierProvider(
          create: (context) =>
              InventarioViewModel(context.read<FirestoreService>()),
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
      },
    );
  }
}
