import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sae_cocagne_mobile/delivery/basket.dart';

const apikey = String.fromEnvironment('api_key', defaultValue: '0');

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});

  @override
  State<StatefulWidget> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  late Future<List<Tournee>> futureTournees;

  @override
  void initState() {
    super.initState();
    futureTournees = fetchTournees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page Livreur'),
      ),
      body: FutureBuilder(
        future: futureTournees,
        builder: (context, snapshot) {
            if (snapshot.hasData) {
            List<Tournee> tournees = snapshot.data as List<Tournee>;
            return ListView.builder(
              itemCount: tournees.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.local_shipping, color: Color(int.parse(tournees[index].couleur.replaceAll('#', '0xff')))),
                  title: Text(tournees[index].tournee),
                  subtitle: Text('Tournée n°${tournees[index].tourneeId}'),
                  onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                    builder: (context) => BasketPage(tourneeId: tournees[index].tourneeId.toString()),
                    ),
                  );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }

          return const Center(
            child: CircularProgressIndicator()
          );
        },
      ),
    );
  }
  
}

Future<List<Tournee>> fetchTournees() async {
  final response = await http.get(
    Uri.parse('https://qjnieztpwnwroinqrolm.supabase.co/rest/v1/tournees'),
    headers: {
      'Content-Type': 'application/json',
      'apikey': apikey, // Replace with your actual API key
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = jsonDecode(response.body) as List<dynamic>;
    return jsonResponse.map((data) => Tournee.fromJson(data as Map<String, dynamic>)).toList();
  } else {
    throw Exception('Failed to load tournees');
  }
}

class Tournee {
  final int tourneeId;
  final int jardinId;
  final String tournee;
  final int preparationId;
  final int calendrierId;
  final int ordre;
  final String couleur;

  Tournee({
    required this.tourneeId,
    required this.jardinId,
    required this.tournee,
    required this.preparationId,
    required this.calendrierId,
    required this.ordre,
    required this.couleur,
  });

  factory Tournee.fromJson(Map<String, dynamic> json) {
    return Tournee(
      tourneeId: json['tournee_id'],
      jardinId: json['jardin_id'],
      tournee: json['tournee'],
      preparationId: json['preparation_id'],
      calendrierId: json['calendrier_id'],
      ordre: json['ordre'],
      couleur: json['couleur'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tournee_id': tourneeId,
      'jardin_id': jardinId,
      'tournee': tournee,
      'preparation_id': preparationId,
      'calendrier_id': calendrierId,
      'ordre': ordre,
      'couleur': couleur,
    };
  }
}