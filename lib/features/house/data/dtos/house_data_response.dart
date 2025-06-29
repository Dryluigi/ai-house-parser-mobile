import 'package:house_parser_mobile/constants/config.dart';
import 'package:house_parser_mobile/features/house/data/dtos/house_data_contact_response.dart';
import 'package:house_parser_mobile/features/house/data/dtos/house_data_image_response.dart';

class HouseDataResponse {
  final String id;
  final String number;
  final String? address;
  final String? mainImageKey;
  final double? price;
  final double latitude;
  final double longitude;
  final double? length;
  final double? width;
  final double? areaSize;
  final double? buildingAreaSize;
  final bool? isSHM;
  final bool? isWellWater;
  final bool? isPDAM;
  final bool? isSale;
  final bool? isRent;
  final bool? isOneGate;
  final bool? hasCarport;
  final double? streetRowWidth;
  final double? bedroomCount;
  final double? bathroomCount;
  final double? electricityCapacity;
  final String? regionId;
  final String createdBy;
  final DateTime createdAt;
  final List<HouseDataContactResponse> contacts;
  final List<HouseDataImageResponse> otherImages;

  const HouseDataResponse({
    required this.id,
    this.address,
    required this.number,
    this.mainImageKey,
    this.price,
    required this.latitude,
    required this.longitude,
    this.length,
    this.width,
    this.areaSize,
    this.buildingAreaSize,
    this.isSHM,
    this.isWellWater,
    this.isPDAM,
    this.isSale,
    this.isRent,
    this.isOneGate,
    this.hasCarport,
    this.streetRowWidth,
    this.bedroomCount,
    this.bathroomCount,
    this.electricityCapacity,
    this.regionId,
    required this.createdBy,
    required this.createdAt,
    required this.contacts,
    required this.otherImages,
  });

  factory HouseDataResponse.fromJson(Map<String, dynamic> json) {
    return HouseDataResponse(
      id: json['id'],
      number: json['number'],
      address: json['address'],
      mainImageKey: json['main_image_key'],
      price: json['price']?.toDouble(),
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      length: json['length']?.toDouble(),
      width: json['width']?.toDouble(),
      areaSize: json['area_size']?.toDouble(),
      buildingAreaSize: json['building_area_size']?.toDouble(),
      isSHM: json['is_shm'],
      isWellWater: json['is_well_water'],
      isPDAM: json['is_pdam'],
      isSale: json['is_sale'],
      isRent: json['is_rent'],
      isOneGate: json['is_one_gate'],
      hasCarport: json['has_carport'],
      streetRowWidth: json['street_row_width']?.toDouble(),
      bedroomCount: json['bedroom_count']?.toDouble(),
      bathroomCount: json['bathroom_count']?.toDouble(),
      electricityCapacity: json['electricity_capacity']?.toDouble(),
      regionId: json['region_id'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      contacts:
          (json['contacts'] as List<dynamic>?)
              ?.map((e) => HouseDataContactResponse.fromJson(e))
              .toList() ??
          [],
      otherImages:
          (json['other_images'] as List<dynamic>?)
              ?.map((e) => HouseDataImageResponse.fromJson(e))
              .toList() ??
          [],
    );
  }

  String getImageUrl() {
    if (mainImageKey != null && mainImageKey!.isNotEmpty) {
      return '${Config.apiBaseUrl}/api/files?image_path=${Uri.encodeComponent(mainImageKey!)}';
    }

    return "";
  }

  String formatPriceRupiah() {
    if (price == null) {
      return "";
    }
    return 'Rp ${price?.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.') ?? ''}';
  }
}
