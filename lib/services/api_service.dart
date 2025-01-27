// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/config_model.dart';

class ApiService {
  static const String apiUrl = 'https://gist.githubusercontent.com/motgi/8fc373cbfccee534c820875ba20ae7b5/raw/7143758ff2caa773e651dc3576de57cc829339c0/config.json';

  Future<List<Config>> fetchConfig() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Config.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load config');
    }
  }
}