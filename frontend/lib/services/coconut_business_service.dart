import 'dart:convert';
import '../models/farmer.dart';
import '../models/trader.dart';
import '../models/resource_earning.dart';
import 'api_service.dart';

class CoconutBusinessService {
  final ApiService _api = ApiService();

  // ============ SUMMARY ============

  Future<CoconutSummary> getSummary() async {
    final response = await _api.get('/coconut/summary');
    return CoconutSummary.fromJson(jsonDecode(response.body));
  }

  // ============ FARMERS ============

  Future<List<Farmer>> getFarmers() async {
    final response = await _api.get('/farmers');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((j) => Farmer.fromJson(j)).toList();
  }

  Future<Farmer> getFarmerById(int id) async {
    final response = await _api.get('/farmers/$id');
    return Farmer.fromJson(jsonDecode(response.body));
  }

  Future<Farmer> addFarmer({
    required String name,
    String? phone,
    String? location,
    required double totalPurchaseAmount,
    String? note,
  }) async {
    final body = {
      'name': name,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (location != null && location.isNotEmpty) 'location': location,
      'totalPurchaseAmount': totalPurchaseAmount,
      if (note != null && note.isNotEmpty) 'note': note,
    };
    final response = await _api.post('/farmers', body);
    return Farmer.fromJson(jsonDecode(response.body));
  }

  Future<Farmer> updateFarmer({
    required int id,
    required String name,
    String? phone,
    String? location,
    required double totalPurchaseAmount,
    String? note,
  }) async {
    final body = {
      'name': name,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (location != null && location.isNotEmpty) 'location': location,
      'totalPurchaseAmount': totalPurchaseAmount,
      if (note != null && note.isNotEmpty) 'note': note,
    };
    final response = await _api.put('/farmers/$id', body);
    return Farmer.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteFarmer(int id) async {
    await _api.delete('/farmers/$id');
  }

  // ============ FARMER TRANSACTIONS ============

  Future<List<FarmerTransaction>> getFarmerTransactions(int farmerId) async {
    final response = await _api.get('/farmers/$farmerId/transactions');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((j) => FarmerTransaction.fromJson(j)).toList();
  }

  Future<FarmerTransaction> addFarmerTransaction({
    required int farmerId,
    required double amountGiven,
    required DateTime date,
    String? paymentMethod,
    String? note,
  }) async {
    final body = {
      'amountGiven': amountGiven,
      'date': date.toIso8601String().substring(0, 10),
      if (paymentMethod != null && paymentMethod.isNotEmpty)
        'paymentMethod': paymentMethod,
      if (note != null && note.isNotEmpty) 'note': note,
    };
    final response =
        await _api.post('/farmers/$farmerId/transactions', body);
    return FarmerTransaction.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteFarmerTransaction(int farmerId, int txId) async {
    await _api.delete('/farmers/$farmerId/transactions/$txId');
  }

  Future<List<FarmerTransaction>> getAllFarmerTransactions() async {
    final response = await _api.get('/farmers/transactions');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((j) => FarmerTransaction.fromJson(j)).toList();
  }

  // ============ TRADERS ============

  Future<List<Trader>> getTraders() async {
    final response = await _api.get('/traders');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((j) => Trader.fromJson(j)).toList();
  }

  Future<Trader> getTraderById(int id) async {
    final response = await _api.get('/traders/$id');
    return Trader.fromJson(jsonDecode(response.body));
  }

  Future<Trader> addTrader({
    required String name,
    String? phone,
    String? location,
    required double totalSaleAmount,
    String? note,
  }) async {
    final body = {
      'name': name,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (location != null && location.isNotEmpty) 'location': location,
      'totalSaleAmount': totalSaleAmount,
      if (note != null && note.isNotEmpty) 'note': note,
    };
    final response = await _api.post('/traders', body);
    return Trader.fromJson(jsonDecode(response.body));
  }

  Future<Trader> updateTrader({
    required int id,
    required String name,
    String? phone,
    String? location,
    required double totalSaleAmount,
    String? note,
  }) async {
    final body = {
      'name': name,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (location != null && location.isNotEmpty) 'location': location,
      'totalSaleAmount': totalSaleAmount,
      if (note != null && note.isNotEmpty) 'note': note,
    };
    final response = await _api.put('/traders/$id', body);
    return Trader.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteTrader(int id) async {
    await _api.delete('/traders/$id');
  }

  // ============ TRADER TRANSACTIONS ============

  Future<List<TraderTransaction>> getTraderTransactions(int traderId) async {
    final response = await _api.get('/traders/$traderId/transactions');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((j) => TraderTransaction.fromJson(j)).toList();
  }

  Future<TraderTransaction> addTraderTransaction({
    required int traderId,
    required double amountReceived,
    required DateTime date,
    String? paymentMethod,
    String? note,
  }) async {
    final body = {
      'amountReceived': amountReceived,
      'date': date.toIso8601String().substring(0, 10),
      if (paymentMethod != null && paymentMethod.isNotEmpty)
        'paymentMethod': paymentMethod,
      if (note != null && note.isNotEmpty) 'note': note,
    };
    final response =
        await _api.post('/traders/$traderId/transactions', body);
    return TraderTransaction.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteTraderTransaction(int traderId, int txId) async {
    await _api.delete('/traders/$traderId/transactions/$txId');
  }

  Future<List<TraderTransaction>> getAllTraderTransactions() async {
    final response = await _api.get('/traders/transactions');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((j) => TraderTransaction.fromJson(j)).toList();
  }

  // ============ RESOURCE EARNINGS (THOTTI & MATTAI) ============

  Future<List<ResourceEarning>> getResourceEarnings({String? resourceType}) async {
    final path = resourceType != null && resourceType.isNotEmpty && resourceType != 'All'
        ? '/resource-earnings?resourceType=$resourceType'
        : '/resource-earnings';
    final response = await _api.get(path);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((j) => ResourceEarning.fromJson(j)).toList();
  }

  Future<ResourceEarningSummary> getResourceEarningsSummary() async {
    final response = await _api.get('/resource-earnings/summary');
    return ResourceEarningSummary.fromJson(jsonDecode(response.body));
  }

  Future<ResourceEarning> addResourceEarning({
    required String resourceType,
    double? quantity,
    String? unit,
    double? ratePerUnit,
    required double totalAmount,
    String? buyerName,
    required DateTime date,
    String? paymentMethod,
    String? note,
  }) async {
    final body = {
      'resourceType': resourceType,
      if (quantity != null) 'quantity': quantity,
      if (unit != null && unit.isNotEmpty) 'unit': unit,
      if (ratePerUnit != null) 'ratePerUnit': ratePerUnit,
      'totalAmount': totalAmount,
      if (buyerName != null && buyerName.isNotEmpty) 'buyerName': buyerName,
      'date': date.toIso8601String().substring(0, 10),
      if (paymentMethod != null && paymentMethod.isNotEmpty)
        'paymentMethod': paymentMethod,
      if (note != null && note.isNotEmpty) 'note': note,
    };
    final response = await _api.post('/resource-earnings', body);
    return ResourceEarning.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteResourceEarning(int id) async {
    await _api.delete('/resource-earnings/$id');
  }
}

