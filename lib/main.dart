import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
// importamos firebase y el archivo de configuración
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // nos aseguramos de que los procesos asíncronos terminan antes de hacer runApp
  WidgetsFlutterBinding.ensureInitialized();
  // inicializamos Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // Remove the debug banner
      debugShowCheckedModeBanner: false,
      title: 'Kindacode.com',
      home: HomeScreen(),
    );
  }
}
