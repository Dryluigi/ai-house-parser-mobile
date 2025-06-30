import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:house_parser_mobile/constants/config.dart';
import 'package:house_parser_mobile/features/house/data/dtos/house_data_response.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<HouseDataResponse> houseData = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHouseData();
  }

  Future<void> _fetchHouseData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final uri = Uri.parse(
      '${Config.apiBaseUrl}/api/house-data?limit=999&page=1',
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'];

        setState(() {
          houseData = data
              .map((item) => HouseDataResponse.fromJson(item))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to fetch house data. Status code: ${response.statusCode}';
          isLoading = false;
        });
        debugPrint(errorMessage);
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching house data: $e';
        isLoading = false;
      });
      debugPrint(errorMessage);
    }
  }

  List<Marker> _buildHouseMarkers() {
    return houseData.map((house) {
      return Marker(
        width: 80,
        height: 80,
        point: LatLng(house.latitude, house.longitude),
        child: GestureDetector(
          onTap: () => _showHouseDetails(house),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: house.isSale == true ? Colors.green : Colors.blue,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.home,
              color: house.isSale == true ? Colors.green : Colors.blue,
              size: 30,
            ),
          ),
        ),
      );
    }).toList();
  }

  void _showHouseDetails(HouseDataResponse house) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (house.mainImageKey != null &&
                        house.mainImageKey!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: house.getImageUrl(),
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      'House #${house.number}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (house.address != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        house.address!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                    if (house.price != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        house.formatPriceRupiah(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (house.bedroomCount != null)
                          _buildInfoChip(
                            Icons.bed,
                            '${house.bedroomCount!.toInt()} BR',
                          ),
                        if (house.bathroomCount != null)
                          _buildInfoChip(
                            Icons.bathroom,
                            '${house.bathroomCount!.toInt()} BA',
                          ),
                        if (house.areaSize != null)
                          _buildInfoChip(
                            Icons.square_foot,
                            '${house.areaSize!.toInt()} m²',
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (house.isSale == true)
                          _buildStatusChip('For Sale', Colors.green),
                        if (house.isRent == true)
                          _buildStatusChip('For Rent', Colors.blue),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  LatLng _calculateMapCenter() {
    if (houseData.isEmpty) {
      return LatLng(-6.200000, 106.816666); // Default Jakarta coordinates
    }

    double totalLat = 0;
    double totalLng = 0;

    for (var house in houseData) {
      totalLat += house.latitude;
      totalLng += house.longitude;
    }

    return LatLng(totalLat / houseData.length, totalLng / houseData.length);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error loading map data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchHouseData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('House Map'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchHouseData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialZoom: houseData.isEmpty ? 13 : 12,
          initialCenter: _calculateMapCenter(),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.house_parser_mobile',
          ),
          MarkerLayer(markers: _buildHouseMarkers()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchHouseData,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
