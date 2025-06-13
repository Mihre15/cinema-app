import 'package:flutter/material.dart';
import 'nav.dart';
import 'splash.dart';
import 'login.dart';

void main(){
runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // int? _userId;
// updated
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const SplashScreen(),
         '/login': (context) => const Login(),
        '/nav': (context) => const Navigation(),
        },
    );
  }
}