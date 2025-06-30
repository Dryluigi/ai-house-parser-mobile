import 'dart:convert';
import 'package:house_parser_mobile/constants/config.dart';
import 'package:house_parser_mobile/features/house/data/dtos/house_data_response.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:house_parser_mobile/features/house/presentation/pages/create_house_manual/create_house_manual_page.dart';
import 'package:house_parser_mobile/features/house/presentation/pages/house_list/house_list_page.dart';
import 'package:house_parser_mobile/features/house/widgets/house_list_item.dart';

class HouseListPageState extends State<HouseListPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final ImagePicker _picker = ImagePicker();
  List<dynamic> houseData = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fetchHouseData(); // call the API when the page loads
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchHouseData() async {
    final uri = Uri.parse(
      '${Config.apiBaseUrl}/api/house-data?limit=999&page=1',
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        setState(() {
          houseData =
              jsonData['data']; // adjust this if your response format differs
        });
      } else {
        debugPrint(
          'Failed to fetch house data. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching house data: $e');
    }
  }

  void _openManualForm() {
    // Navigate to manual form page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateHouseManualPage()),
    ).then((value) => {_fetchHouseData()});
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _openCamera() async {
    try {
      final position = await _getCurrentLocation();
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        debugPrint('Image path: ${image.path}');
        debugPrint(
          'Latitude: ${position.latitude}, Longitude: ${position.longitude}',
        );

        // Step 1: Upload the image
        final uploadUri = Uri.parse('${Config.apiBaseUrl}/api/upload');
        final request = http.MultipartRequest('POST', uploadUri)
          ..files.add(await http.MultipartFile.fromPath('file', image.path))
          ..fields['path'] = 'house';

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final uploadResult = json.decode(response.body);
          final mainImageKey = uploadResult['image_path'];

          debugPrint('Uploaded image key: $mainImageKey');

          // Step 2: Create house data using image and GPS
          final createUri = Uri.parse('${Config.apiBaseUrl}/api/house-data');
          final createBody = jsonEncode({
            "main_image_key": mainImageKey,
            "latitude": position.latitude,
            "longitude": position.longitude,
          });

          final createResponse = await http.post(
            createUri,
            headers: {'Content-Type': 'application/json'},
            body: createBody,
          );

          if (createResponse.statusCode == 200 ||
              createResponse.statusCode == 201) {
            debugPrint('House data created successfully!');
            _fetchHouseData(); // refresh list
          } else {
            debugPrint(
              'Failed to create house data. Status: ${createResponse.statusCode}, Body: ${createResponse.body}',
            );
          }
        } else {
          debugPrint(
            'Upload failed. Status: ${response.statusCode}, Body: ${response.body}',
          );
        }
      }
    } catch (e) {
      debugPrint('Error in camera flow: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      left: false,
      right: false,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.blue),
        body: RefreshIndicator(
          onRefresh: _fetchHouseData,
          child: ListView.builder(
            itemCount: houseData.length,
            padding: const EdgeInsets.all(8.0),
            itemBuilder: (context, index) {
              final item = houseData[index];
              return HouseListItem(
                data: HouseDataResponse.fromJson(item),
                refreshList: _fetchHouseData,
              );
            },
          ),
        ),
        floatingActionButton: SpeedDial(
          icon: Icons.add,
          activeIcon: Icons.close,
          backgroundColor: Colors.blue,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.camera_alt),
              label: 'Camera',
              onTap: _openCamera,
            ),
            SpeedDialChild(
              child: const Icon(Icons.edit),
              label: 'Edit',
              onTap: _openManualForm,
            ),
          ],
        ),
      ),
    );
  }
}
