import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:flutter_map/flutter_map.dart";
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sae_cocagne_mobile/main.dart';

const apikey = String.fromEnvironment('api_key', defaultValue: '0');
const tomtomkey = String.fromEnvironment('tomtom_key', defaultValue: '0');

class ItineraryPage extends StatefulWidget {
  final String tourneeId;
  static List<dynamic> validatedDepot = [];

  const ItineraryPage({super.key, required this.tourneeId});
  @override
  _ItineraryPageState createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  List<dynamic> depotData = [];
  bool isLoading = true;
  bool isLocated = false;
  bool isRouted = false;
  int depotIndex = 0;
  LatLng userLocation = LatLng(0, 0);
  List<LatLng> routeData = [];

  @override
  void initState() {
    super.initState();
    fetchItineraryData();
    determinePosition();
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
      body: FutureBuilder(
        future: Future.wait([
          isLoading ? fetchItineraryData() : Future.value(null),
          !isLocated ? determinePosition() : Future.value(null),
          isLocated && !isRouted ? getRoute() : Future.value(null),
        ]),
        builder: (context, snapshot) {
          if (isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (!isLocated) {
            return Center(child: CircularProgressIndicator());
          } else if (!isRouted) {
            return Center(child: Text("Calcul de l'itinéraire..."));
          } else {
            return Center(
              child: FlutterMap(
                mapController: MapController(),
                options: MapOptions(
                    initialCenter: LatLng(
                      (userLocation.latitude + depotData[depotIndex]["adresses"]["localisation"]["coordinates"][1]) / 2,
                      (userLocation.longitude + depotData[depotIndex]["adresses"]["localisation"]["coordinates"][0]) / 2,
                    ),
                  initialZoom: 10.0,
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
                        width: 400,
                        height: 300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_pin, color: Colors.red, size: 50),
                            SizedBox(
                              width: 100,
                              height: 50,
                              child: Text(
                                depotData[depotIndex]["depot"],
                                style: TextStyle(color: Colors.black, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routeData.isNotEmpty ? routeData : [
                          LatLng(depotData[depotIndex]["adresses"]["localisation"]["coordinates"][1], depotData[depotIndex]["adresses"]["localisation"]["coordinates"][0]),
                          userLocation,
                        ],
                        strokeWidth: 4.0,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Scanner QR Code'),
                content: SizedBox(
                  height: 300,
                  width: 300,
                  child: MobileScanner(
                    onDetect: _handleScannedBarcode,
                    controller: MobileScannerController(
                      detectionSpeed: DetectionSpeed.normal,
                      facing: CameraFacing.back,
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text('Fermer'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
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
      throw Exception('Failed to get user location');
    });
  }

  Future<void> getRoute() async {
    final start = '${userLocation.latitude},${userLocation.longitude}';
    final end = '${depotData[depotIndex]["adresses"]["localisation"]["coordinates"][1]},${depotData[depotIndex]["adresses"]["localisation"]["coordinates"][0]}';
    final response = await http.get(
      Uri.parse("https://api.tomtom.com/routing/1/calculateRoute/$start:$end/json?avoid=unpavedRoads&key=$tomtomkey"),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      setState(() {
        routeData = (data['routes'][0]['legs'][0]['points'] as List)
        .map((point) => LatLng(point['latitude'], point['longitude']))
        .toList();
        isRouted = true;
      });
    } 
  }

  void _handleScannedBarcode(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue == null) {
      
      return;
    }

    Navigator.of(context).pop();

    String scannedValue = barcode.rawValue!.toString();
    print("QR Code scanné : $scannedValue");
    if (scannedValue.isNotEmpty) {
      await _handleValidQRCode(context);
    }
  }

  Future<void> _handleValidQRCode(BuildContext context) async {
    ItineraryPage.validatedDepot.add(depotData[depotIndex]);
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Livraison validée pour ${depotData[depotIndex]["depot"]}'),
    ));
    if (depotIndex < depotData.length - 1) {
      setState(() {
        depotIndex++;
        isLocated = false;
      });
      Future.wait([
        determinePosition(),
        getRoute(),
      ]);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
        builder: (context) => MyApp(),
        ),
      );
    }
  }
}