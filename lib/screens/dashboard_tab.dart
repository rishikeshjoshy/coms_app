import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../widgets/stat_card.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final ApiService _apiService = ApiService();
  late Future<Map<String , dynamic>> _statsFuture;


  @override
  void initState() {
    super.initState();
    _statsFuture = _apiService.fetchhStats();
  }

  // Pull-to-Refresh Logic


  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
