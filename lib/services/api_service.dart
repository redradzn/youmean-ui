import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class ApiService {
  // API base URL - can be overridden at build time with:
  // flutter build web --dart-define=API_URL=https://your-ngrok-url.ngrok-free.dev
  // For local development: http://localhost:3000
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
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
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
        headers: {
          'ngrok-skip-browser-warning': 'true',
        },
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

/// Mind Selfie result with 3 modes: Light, Psychology, Astronomy
class MindSelfie {
  final String beliefSystem; // "science", "god", or "spirituality"
  final String location;
  final String babylonianDate;
  final List<YearData> lightYears;      // Light mode data
  final List<YearData> psychologyYears; // Psychology mode data
  final List<YearData> astronomyYears;  // Astronomy mode data
  final int userAge;
  final int totalYearsAvailable;

  MindSelfie({
    required this.beliefSystem,
    this.location = '',
    this.babylonianDate = '',
    required this.lightYears,
    List<YearData>? psychologyYears,
    List<YearData>? astronomyYears,
    required this.userAge,
    required this.totalYearsAvailable,
  }) : psychologyYears = psychologyYears ?? lightYears,
       astronomyYears = astronomyYears ?? lightYears;

  // Legacy getter for backward compatibility
  List<YearData> get years => lightYears;

  // Row labels for each mode
  static const List<String> lightRowLabels = [
    'Right Now',
    'Advice'
  ];

  static const List<String> psychologyRowLabels = [
    'Self Summary',
    'Neural Pattern',
    'Life Experience',
    'Developmental Context',
    'Integration Insight'
  ];

  static const List<String> astronomyRowLabels = [
    'Season/Year',
    'Planetary Positions',
    'Lunar Cycle',
    'Major Transits',
    'Babylonian Calendar'
  ];

  List<String> get rowLabels => lightRowLabels;

  List<String> getRowLabelsForMode(String mode) {
    switch (mode) {
      case 'light':
        return lightRowLabels;
      case 'psychology':
        return psychologyRowLabels;
      case 'astronomy':
        return astronomyRowLabels;
      default:
        return lightRowLabels;
    }
  }

  List<YearData> getYearsForMode(String mode) {
    switch (mode) {
      case 'light':
        return lightYears;
      case 'psychology':
        return psychologyYears;
      case 'astronomy':
        return astronomyYears;
      default:
        return lightYears;
    }
  }

  factory MindSelfie.fromJson(Map<String, dynamic> json) {
    // Parse light years (required, also serves as fallback)
    final lightYears = json['light_years'] != null
        ? (json['light_years'] as List).map((y) => YearData.fromJson(y)).toList()
        : json['years'] != null
            ? (json['years'] as List).map((y) => YearData.fromJson(y)).toList()
            : <YearData>[];

    // Parse psychology years (optional)
    final psychologyYears = json['psychology_years'] != null
        ? (json['psychology_years'] as List).map((y) => YearData.fromJson(y)).toList()
        : null;

    // Parse astronomy years (optional)
    final astronomyYears = json['astronomy_years'] != null
        ? (json['astronomy_years'] as List).map((y) => YearData.fromJson(y)).toList()
        : null;

    return MindSelfie(
      beliefSystem: json['belief_system'] as String? ?? 'spirituality',
      location: json['location'] as String? ?? '',
      babylonianDate: json['babylonian_date'] as String? ?? '',
      lightYears: lightYears,
      psychologyYears: psychologyYears,
      astronomyYears: astronomyYears,
      userAge: json['user_age'] as int? ?? 0,
      totalYearsAvailable: json['total_years_available'] as int? ?? lightYears.length,
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
