import 'package:flutter/material.dart';
import 'package:loan_application/services/api_service.dart';
import '../models/config_model.dart';

class ConfigProvider with ChangeNotifier {
  List<Config> _configs = [];
  List<Config> get configs => _configs;
  
  Future<void> fetchConfigs() async {
    final apiService = ApiService();
    _configs = await apiService.fetchConfig();
    notifyListeners();
  }
}