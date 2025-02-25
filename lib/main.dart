import 'package:flutter/material.dart';
import 'package:sae_cocagne_mobile/customer.dart';
import 'package:sae_cocagne_mobile/delivery/delivery.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jardins de Cocagne',
      theme: ThemeData(
        // This is the theme of your application.
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DeliveryPage()),
                  );
                },
                icon: const Icon(
                Icons.local_shipping,
                size: 24,
                ),
                label: const Text('Livreur'),
                style: ElevatedButton.styleFrom(
                minimumSize: const Size(150, 50), // Set the size of the button
                ),
              ),
              const SizedBox(height: 20), // Add a gap between the buttons
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CustomerPage()),
                  );
                },
                icon: const Icon(
                Icons.person,
                size: 24,
                ),
                label: const Text('Client'),
                style: ElevatedButton.styleFrom(
                minimumSize: const Size(150, 50), // Set the size of the button
                ),
              ),
          ],
        ),
      )
    );
  }
}