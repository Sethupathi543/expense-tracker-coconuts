import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;
  String _baseUrl = AppConstants.defaultBaseUrl;

  String get baseUrl => _baseUrl;

  void setBaseUrl(String url) {
    _baseUrl = url;
  }

  void setToken(String? token) {
    _token = token;
  }

  String? get token => _token;

  Future<void> initToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    final savedUrl = prefs.getString('custom_base_url');
    if (savedUrl != null && savedUrl.isNotEmpty) {
      _baseUrl = savedUrl;
    }
  }

  Map<String, String> _getHeaders({bool withAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth && _token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<http.Response> get(String endpoint, {Map<String, dynamic>? queryParams, bool withAuth = true}) async {
    Uri uri;
    if (queryParams != null && queryParams.isNotEmpty) {
      final cleanParams = <String, String>{};
      queryParams.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          cleanParams[key] = value.toString();
        }
      });
      uri = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: cleanParams);
    } else {
      uri = Uri.parse('$_baseUrl$endpoint');
    }

    return await http.get(uri, headers: _getHeaders(withAuth: withAuth));
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body, {bool withAuth = true}) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    return await http.post(
      uri,
      headers: _getHeaders(withAuth: withAuth),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body, {bool withAuth = true}) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    return await http.put(
      uri,
      headers: _getHeaders(withAuth: withAuth),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String endpoint, {bool withAuth = true}) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    return await http.delete(uri, headers: _getHeaders(withAuth: withAuth));
  }
}
