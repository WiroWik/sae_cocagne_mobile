import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sae_cocagne_mobile/delivery/itinerary.dart';

const apikey = String.fromEnvironment('api_key', defaultValue: '0');

class BasketPage extends StatefulWidget {
  final String tourneeId;

  const BasketPage({super.key, required this.tourneeId});
  @override
  _BasketPageState createState() => _BasketPageState();
}

class _BasketPageState extends State<BasketPage> {
  List<dynamic> basketData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBasketData();
  }

  Future<void> fetchBasketData() async {
    final response = await http.get(
      Uri.parse('https://qjnieztpwnwroinqrolm.supabase.co/rest/v1/detail_livraisons?tournee_id=eq.${widget.tourneeId}&select=produit_id,produit,qte.sum()'),
      headers: {
        'apikey': apikey,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        basketData = json.decode(response.body);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load basket data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text('Liste des paniers'),
      ),
      body: isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            
            itemCount: basketData.length,
            itemBuilder: (context, index) {
            final item = basketData[index];
              return ListTile(
                leading: Icon(Icons.shopping_basket),
                title: Text(item['produit']),
                subtitle: Text('Quantité de produits : ${item['sum']}'),
              );
            },
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItineraryPage(tourneeId: widget.tourneeId,),
            ),
          );
        },
        label: Text('Démarrer la livraison'),
        icon: Icon(Icons.local_shipping),
      ),
    );
  }
}