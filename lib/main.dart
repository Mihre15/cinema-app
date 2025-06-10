import 'package:flutter/material.dart';
import 'nav.dart';

void main(){
runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
// updated
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:Navigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}