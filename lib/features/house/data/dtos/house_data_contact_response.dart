class HouseDataContactResponse {
  final String? name;
  final String? phoneNumber;
  final String? companyName;

  const HouseDataContactResponse({
    this.name,
    this.phoneNumber,
    this.companyName,
  });

  factory HouseDataContactResponse.fromJson(Map<String, dynamic> json) {
    return HouseDataContactResponse(
      name: json['name'],
      phoneNumber: json['phone_number'],
      companyName: json['company_name'],
    );
  }
}
