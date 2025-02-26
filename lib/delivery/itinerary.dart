import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:flutter_map/flutter_map.dart";
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

const apikey = String.fromEnvironment('api_key', defaultValue: '0');
const tomtomkey = String.fromEnvironment('tomtom_key', defaultValue: '0');

class ItineraryPage extends StatefulWidget {
  final String tourneeId;

  const ItineraryPage({super.key, required this.tourneeId});
  @override
  _ItineraryPageState createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  List<dynamic> depotData = [];
  bool isLoading = true;
  bool isLocated = false;
  int depotIndex = 0;
  LatLng userLocation = LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    fetchItineraryData();
    determinePosition();
    print(userLocation);
    print(isLocated);
  }

  Future<void> fetchItineraryData() async {
    final response = await http.get(
      Uri.parse('https://qjnieztpwnwroinqrolm.supabase.co/rest/v1/detail_livraisons?tournee_id=eq.${widget.tourneeId}&select=depot_id,depot,qte.sum(),adresses(adresse,codepostal,ville,localisation)'),
      headers: {
        'apikey': apikey,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        depotData = json.decode(response.body);
        depotData.removeWhere((depot) => depot['adresses'] == null);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load depot data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text('Liste des dépôts'),
      ),
      body: isLoading
        ? Center(child: CircularProgressIndicator())
        : !isLocated
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: FlutterMap(
                mapController: MapController(),
                options: MapOptions(
              initialCenter: LatLng(depotData[depotIndex]["adresses"]["localisation"]["coordinates"][1], depotData[depotIndex]["adresses"]["localisation"]["coordinates"][0]),
              initialZoom: 13.0,
                ),
                children: [
              TileLayer(
                urlTemplate: 'https://api.tomtom.com/map/1/tile/basic/main/{z}/{x}/{y}.png?key=$tomtomkey',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                point: LatLng(depotData[depotIndex]["adresses"]["localisation"]["coordinates"][1], depotData[depotIndex]["adresses"]["localisation"]["coordinates"][0]),
                width: 50,
                height: 50,
                child: Icon(Icons.location_pin, color: Colors.red, size: 50),
                  ),
                ],
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [
                      LatLng(depotData[depotIndex]["adresses"]["localisation"]["coordinates"][1], depotData[depotIndex]["adresses"]["localisation"]["coordinates"][0]),
                      LatLng(userLocation.latitude, userLocation.longitude),
                    ],
                    strokeWidth: 4.0,
                    color: Colors.blue,
                  ),
                ],
              ),
                ],
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (depotIndex < depotData.length - 1) {
            setState(() {
              depotIndex++;
              isLocated = false;
              determinePosition();
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Toutes les livraisons ont été effectuées'),
            ));
          }
        },
        label: Text('Scanner pour valider'),
        icon: Icon(Icons.qr_code),
      ),
    );
  }
  
  Future<void> determinePosition() async {
    Geolocator.getCurrentPosition().then((Position position) {
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
        isLocated = true;
      });
    }).catchError((e) {
      print(e);
    });
  }
}