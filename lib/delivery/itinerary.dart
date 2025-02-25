import 'package:flutter/material.dart';

class ItineraryPage extends StatelessWidget {
  const ItineraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Itineraire'),
      ),
      body: Center(
        child: Text('Page Itineraire'),
      ),
    );
  }
}