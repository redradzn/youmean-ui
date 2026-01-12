import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class ApiService {
  // API base URL - can be overridden at build time with:
  // flutter build web --dart-define=API_URL=https://your-backend.railway.app
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// Submit birth data to local server and get request ID
  static Future<String?> submitRequest({
    required String birthCity,
    required String birthDate,
    required String birthTime,
    required String emotionalState,
    required bool believeScience,
    required bool believeGod,
    required bool believeSpirituality,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/submit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'birth_city': birthCity,
          'birth_date': birthDate,
          'birth_time': birthTime,
          'emotional_state': emotionalState,
          'belief_science': believeScience,
          'belief_god': believeGod,
          'belief_spirituality': believeSpirituality,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['request_id'];
        }
      }
      return null;
    } catch (e) {
      print('Error submitting request: $e');
      return null;
    }
  }

  /// Poll for results by request ID
  static Future<Map<String, dynamic>?> pollResults(String requestId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/poll/$requestId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error polling results: $e');
      return null;
    }
  }

  /// Wait for results with polling (checks every 2 seconds)
  static Future<Map<String, dynamic>?> waitForResults(
    String requestId, {
    Duration timeout = const Duration(minutes: 5),
    Function(String)? onStatusUpdate,
  }) async {
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < timeout) {
      final result = await pollResults(requestId);

      if (result == null) {
        await Future.delayed(const Duration(seconds: 2));
        continue;
      }

      final status = result['status'];

      if (onStatusUpdate != null) {
        onStatusUpdate(status);
      }

      if (status == 'completed') {
        return result;
      } else if (status == 'failed') {
        return result;
      }

      // Still pending or processing, wait and try again
      await Future.delayed(const Duration(seconds: 2));
    }

    return null; // Timeout
  }
}

/// Mind Selfie year data
class YearData {
  final int age;
  final String row1;
  final String row2;
  final String row3;
  final String row4;
  final String row5;

  YearData({
    required this.age,
    required this.row1,
    required this.row2,
    required this.row3,
    required this.row4,
    required this.row5,
  });

  factory YearData.fromJson(Map<String, dynamic> json) {
    return YearData(
      age: json['age'] as int,
      row1: json['row1'] as String,
      row2: json['row2'] as String,
      row3: json['row3'] as String,
      row4: json['row4'] as String,
      row5: json['row5'] as String,
    );
  }
}

/// Mind Selfie result
class MindSelfie {
  final String beliefSystem; // "science", "god", or "spirituality"
  final List<YearData> years;
  final int userAge;
  final int totalYearsAvailable;

  MindSelfie({
    required this.beliefSystem,
    required this.years,
    required this.userAge,
    required this.totalYearsAvailable,
  });

  List<String> get rowLabels {
    switch (beliefSystem) {
      case 'science':
        return ['Self Summary', 'Mental Health', 'Spark', 'Integration', 'Completion'];
      case 'god':
        return ['Self Summary', 'Inner Peace', 'Trust', 'Devotion', 'Unity'];
      case 'spirituality':
        return ['Self Summary', 'Inner Harmony', 'Motivation', 'Journey', 'Enlightenment'];
      default:
        return ['Self Summary', 'Inner Harmony', 'Motivation', 'Journey', 'Enlightenment'];
    }
  }

  factory MindSelfie.fromJson(Map<String, dynamic> json) {
    return MindSelfie(
      beliefSystem: json['belief_system'] as String,
      years: (json['years'] as List).map((y) => YearData.fromJson(y)).toList(),
      userAge: json['user_age'] as int,
      totalYearsAvailable: json['total_years_available'] as int,
    );
  }
}

/// Result data model
class CalculationResult {
  final double probabilityScore;
  final List<String> insights;
  final List<String> historicalCorrelations;
  final MindSelfie? mindSelfie;

  CalculationResult({
    required this.probabilityScore,
    required this.insights,
    required this.historicalCorrelations,
    this.mindSelfie,
  });

  factory CalculationResult.fromJson(Map<String, dynamic> json) {
    return CalculationResult(
      probabilityScore: (json['probability_score'] as num).toDouble(),
      insights: List<String>.from(json['insights']),
      historicalCorrelations: List<String>.from(json['historical_correlations']),
      mindSelfie: json['mind_selfie'] != null
        ? MindSelfie.fromJson(json['mind_selfie'])
        : null,
    );
  }
}
