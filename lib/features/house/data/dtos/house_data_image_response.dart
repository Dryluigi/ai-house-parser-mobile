class HouseDataImageResponse {
  final String imageKey;

  const HouseDataImageResponse({required this.imageKey});

  factory HouseDataImageResponse.fromJson(Map<String, dynamic> json) {
    return HouseDataImageResponse(imageKey: json['image_key']);
  }

  Map<String, dynamic> toJson() {
    return {'image_key': imageKey};
  }
}
