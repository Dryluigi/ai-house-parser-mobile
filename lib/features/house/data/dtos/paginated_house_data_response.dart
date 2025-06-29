import 'package:house_parser_mobile/features/house/data/dtos/house_data_response.dart';

class PaginatedHouseDataResponse {
  final List<HouseDataResponse> data;
  final int page;
  final int limit;
  final int totalItems;
  final int totalPages;

  const PaginatedHouseDataResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.totalItems,
    required this.totalPages,
  });

  factory PaginatedHouseDataResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedHouseDataResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => HouseDataResponse.fromJson(e))
          .toList(),
      page: json['page'],
      limit: json['limit'],
      totalItems: json['total_items'],
      totalPages: json['total_pages'],
    );
  }
}
