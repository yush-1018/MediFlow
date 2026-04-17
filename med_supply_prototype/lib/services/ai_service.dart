import 'package:cloud_functions/cloud_functions.dart';

class AIService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<Map<String, dynamic>> getDemandForecast(String stockId, String medicineName) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('forecastDemand');
      final result = await callable.call({
        'stockId': stockId,
        'medicineName': medicineName,
      });

      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      throw Exception("AI Forecast failed: ${e.toString()}");
    }
  }
}
