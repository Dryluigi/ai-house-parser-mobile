import 'package:flutter/material.dart';
import 'package:house_parser_mobile/features/house/presentation/pages/house_list/house_list_state.dart';

class HouseListPage extends StatefulWidget {
  const HouseListPage({super.key, required this.title});

  final String title;

  @override
  State<HouseListPage> createState() => HouseListPageState();
}
