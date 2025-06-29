import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:house_parser_mobile/constants/config.dart';
import 'package:house_parser_mobile/features/house/widgets/contact_information_card.dart';
import 'package:house_parser_mobile/features/house/presentation/pages/edit_house/edit_house_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:house_parser_mobile/features/house/data/dtos/house_data_response.dart';

class HouseDetailPage extends StatefulWidget {
  final String houseId;

  const HouseDetailPage({super.key, required this.houseId});

  @override
  State<HouseDetailPage> createState() => _HouseDetailPageState();
}

class HouseDetailContent extends StatelessWidget {
  final HouseDataResponse houseData;
  final Future<void> Function() onRefresh;

  const HouseDetailContent({
    super.key,
    required this.houseData,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      left: false,
      right: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(houseData.number),
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditHousePage(houseData: houseData),
                  ),
                );

                // If edit was successful, refresh the data
                if (result == true) {
                  await onRefresh();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Share feature coming soon'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: onRefresh,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Image
                if (houseData.mainImageKey != null)
                  SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: houseData.getImageUrl(),
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[500],
                          size: 40,
                        ),
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Number and Price
                      Text(
                        houseData.number,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        houseData.formatPriceRupiah().isEmpty
                            ? 'Belum diset'
                            : houseData.formatPriceRupiah(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Availability Status
                      Row(
                        children: [
                          if (houseData.isSale == true)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'For Sale',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          if (houseData.isSale == true &&
                              houseData.isRent == true)
                            const SizedBox(width: 8),
                          if (houseData.isRent == true)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'For Rent',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Address
                      if (houseData.address != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Address',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              houseData.address!,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),

                      // Property Details
                      const Text(
                        'Property Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              if (houseData.bedroomCount != null)
                                _buildDetailRow(
                                  'Bedrooms',
                                  '${houseData.bedroomCount!.toInt()}',
                                ),
                              if (houseData.bathroomCount != null)
                                _buildDetailRow(
                                  'Bathrooms',
                                  '${houseData.bathroomCount!.toInt()}',
                                ),
                              if (houseData.areaSize != null)
                                _buildDetailRow(
                                  'Area Size',
                                  '${houseData.areaSize!.toStringAsFixed(0)} m²',
                                ),
                              if (houseData.buildingAreaSize != null)
                                _buildDetailRow(
                                  'Building Area',
                                  '${houseData.buildingAreaSize!.toStringAsFixed(0)} m²',
                                ),
                              if (houseData.length != null &&
                                  houseData.width != null)
                                _buildDetailRow(
                                  'Dimensions',
                                  '${houseData.length!.toStringAsFixed(1)} × ${houseData.width!.toStringAsFixed(1)} m',
                                ),
                              if (houseData.streetRowWidth != null)
                                _buildDetailRow(
                                  'Street Width',
                                  '${houseData.streetRowWidth!.toStringAsFixed(1)} m',
                                ),
                              if (houseData.electricityCapacity != null)
                                _buildDetailRow(
                                  'Electricity',
                                  '${houseData.electricityCapacity!.toInt()} VA',
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Features
                      const Text(
                        'Features',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildFeatureChips(),

                      const SizedBox(height: 16),

                      // Location
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDetailRow(
                                      'Latitude',
                                      houseData.latitude.toStringAsFixed(6),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.map,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Open in Google Maps',
                                    onPressed: () {
                                      final lat = houseData.latitude;
                                      final lng = houseData.longitude;
                                      final googleMapsUrl =
                                          'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
                                      launchUrl(Uri.parse(googleMapsUrl));
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDetailRow(
                                      'Longitude',
                                      houseData.longitude.toStringAsFixed(6),
                                    ),
                                  ),
                                ],
                              ),
                              if (houseData.regionId != null)
                                _buildDetailRow(
                                  'Region ID',
                                  houseData.regionId!,
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Contact Information
                      if (houseData.contacts.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Contact Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...houseData.contacts.map(
                              (contact) => ContactInformationCard(
                                number: houseData.number,
                                companyName: contact.companyName,
                                name: contact.name,
                                phoneNumber: contact.phoneNumber,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // Other Images
                      if (houseData.otherImages.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gallery',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: houseData.otherImages.length,
                                itemBuilder: (context, index) {
                                  final image = houseData.otherImages[index];
                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    width: 120,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        image.imageKey,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.image,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // Created Info
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Listing Information',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                'Created By',
                                houseData.createdBy,
                              ),
                              _buildDetailRow(
                                'Created At',
                                '${houseData.createdAt.day}/${houseData.createdAt.month}/${houseData.createdAt.year}',
                              ),
                              _buildDetailRow('ID', houseData.id),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contact feature coming soon'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('Contact'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Favorite feature coming soon'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.favorite_border),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChips() {
    List<Widget> chips = [];

    if (houseData.isSHM == true) {
      chips.add(_buildChip('SHM Certificate', Colors.green));
    }
    if (houseData.isPDAM == true) {
      chips.add(_buildChip('PDAM Water', Colors.blue));
    }
    if (houseData.isWellWater == true) {
      chips.add(_buildChip('Well Water', Colors.cyan));
    }
    if (houseData.isOneGate == true) {
      chips.add(_buildChip('One Gate System', Colors.orange));
    }
    if (houseData.hasCarport == true) {
      chips.add(_buildChip('Carport', Colors.purple));
    }

    if (chips.isEmpty) {
      return const Text('No special features listed');
    }

    return Wrap(spacing: 8.0, runSpacing: 4.0, children: chips);
  }

  Widget _buildChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }
}

class _HouseDetailPageState extends State<HouseDetailPage> {
  late Future<HouseDataResponse?> futureHouseData;

  Future<HouseDataResponse?> fetchHouseDetail(String id) async {
    final url = Uri.parse('${Config.apiBaseUrl}/api/house-data/$id');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return HouseDataResponse.fromJson(data);
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    futureHouseData = fetchHouseDetail(widget.houseId);
  }

  Future<void> _refresh() async {
    final newData = await fetchHouseDetail(widget.houseId);
    if (newData != null) {
      setState(() {
        futureHouseData = Future.value(newData);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HouseDataResponse?>(
      future: futureHouseData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SafeArea(
            bottom: true,
            top: false,
            left: false,
            right: false,
            child: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (snapshot.hasError) {
          return SafeArea(
            bottom: true,
            top: false,
            left: false,
            right: false,
            child: Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return SafeArea(
            bottom: true,
            top: false,
            left: false,
            right: false,
            child: const Scaffold(body: Center(child: Text('Data not found'))),
          );
        } else {
          return HouseDetailContent(
            houseData: snapshot.data!,
            onRefresh: _refresh,
          );
        }
      },
    );
  }
}
