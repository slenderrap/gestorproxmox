import 'package:flutter/material.dart';
import 'package:gestor_proxmox/HomeView.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override 
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor Proxmox',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  HomeView(),
      debugShowCheckedModeBanner: false,
    );
  }
}

