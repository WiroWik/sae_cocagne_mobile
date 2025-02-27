import 'package:flutter/material.dart';
import 'package:sae_cocagne_mobile/delivery/itinerary.dart';

class CustomerPage extends StatelessWidget {

  Future<List<dynamic>> fetchValidatedDepot() async {
    
    return ItineraryPage.validatedDepot;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page Client'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchValidatedDepot(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Center(child: Text('Aucun dépôt livré'));
          } else {
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(snapshot.data![index]['depot']),
              subtitle: Text("${snapshot.data![index]['adresses']['adresse']} ${snapshot.data![index]['adresses']['codepostal']} ${snapshot.data![index]['adresses']['ville']}"),
              leading: Icon(Icons.check_circle, color: Colors.green),
            );
          },
        );
          }
        },
      ),
    );
  }
}