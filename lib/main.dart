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
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
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
  
    return Center(
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
    );
  }

  
}