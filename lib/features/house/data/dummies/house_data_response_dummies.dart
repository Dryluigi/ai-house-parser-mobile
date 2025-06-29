import 'package:house_parser_mobile/features/house/data/dtos/house_data_contact_response.dart';
import 'package:house_parser_mobile/features/house/data/dtos/house_data_image_response.dart';
import 'package:house_parser_mobile/features/house/data/dtos/house_data_response.dart';

final List<HouseDataResponse> houseItemDummies = [
  HouseDataResponse(
    id: 'uuid-1',
    number: 'H00001',
    address: 'Jln. Raya Cempaka No. 123, Jakarta Pusat',
    mainImageKey:
        'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800&h=600&fit=crop',
    price: 450000,
    latitude: -6.2088,
    longitude: 106.8456,
    length: 12.0,
    width: 8.0,
    areaSize: 120.0,
    buildingAreaSize: 96.0,
    isSHM: true,
    isWellWater: false,
    isPDAM: true,
    isSale: true,
    isRent: false,
    isOneGate: true,
    hasCarport: true,
    streetRowWidth: 6.0,
    bedroomCount: 3,
    bathroomCount: 2,
    electricityCapacity: 2200,
    regionId: 'region-1',
    createdBy: 'admin',
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    contacts: [
      const HouseDataContactResponse(
        name: 'John Doe',
        phoneNumber: '+62812345678',
        companyName: 'ABC Property',
      ),
    ],
    otherImages: [
      HouseDataImageResponse(
        imageKey:
            'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&h=600&fit=crop',
      ),
      HouseDataImageResponse(
        imageKey:
            'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800&h=600&fit=crop',
      ),
    ],
  ),
  HouseDataResponse(
    id: 'uuid-2',
    number: 'H00002',
    address: 'Jln. Raya Cempaka No. 456, Jakarta Selatan',
    mainImageKey:
        'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&h=600&fit=crop',
    price: 320000,
    latitude: -6.1751,
    longitude: 106.8650,
    length: 10.0,
    width: 6.0,
    areaSize: 80.0,
    buildingAreaSize: 60.0,
    isSHM: false,
    isWellWater: true,
    isPDAM: false,
    isSale: true,
    isRent: true,
    isOneGate: false,
    hasCarport: false,
    streetRowWidth: 4.0,
    bedroomCount: 2,
    bathroomCount: 1,
    electricityCapacity: 1300,
    regionId: 'region-2',
    createdBy: 'agent1',
    createdAt: DateTime.now().subtract(const Duration(days: 15)),
    contacts: [
      const HouseDataContactResponse(
        name: 'Jane Smith',
        phoneNumber: '+62887654321',
        companyName: 'Downtown Realty',
      ),
    ],
    otherImages: [
      HouseDataImageResponse(
        imageKey:
            'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&h=600&fit=crop',
      ),
    ],
  ),
];
