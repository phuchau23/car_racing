import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'utils/orientation_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Set landscape orientation from the start
  OrientationHelper.setLandscape();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Racing Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
