import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String BASE_URL = 'https://api-saymotion.deepmotion.com';
  String? _sessionCookie;
  String? _lastRid;
  DateTime? _sessionStoredDate;
  static const int SESSION_EXPIRY_DAYS = 5;

  Future<void> _loadStoredSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load session date first
    String? storedDateStr = prefs.getString('sessionStoredDate');
    if (storedDateStr != null) {
      _sessionStoredDate = DateTime.parse(storedDateStr);

      // Check if session is expired (5 days or more)
      if (DateTime.now().difference(_sessionStoredDate!).inDays >= SESSION_EXPIRY_DAYS) {
        // Clear all stored values if session is expired
        await prefs.remove('dmsess');
        await prefs.remove('lastRid');
        await prefs.remove('sessionStoredDate');
        _sessionCookie = null;
        _lastRid = null;
        _sessionStoredDate = null;
        return;
      }
    }

    // Load other values only if session is not expired
    _sessionCookie = prefs.getString('dmsess');
    _lastRid = prefs.getString('lastRid');
  }

  Future<void> _saveSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Update the stored date whenever we save a new session
    _sessionStoredDate = DateTime.now();
    await prefs.setString('sessionStoredDate', _sessionStoredDate!.toIso8601String());

    if (_sessionCookie != null) {
      await prefs.setString('dmsess', _sessionCookie!);
    }
    if (_lastRid != null) {
      await prefs.setString('lastRid', _lastRid!);
    }
  }

  Future<Map<String, dynamic>> authenticate(String clientId, String clientSecret) async {
    await _loadStoredSession();
    if (_sessionCookie != null && _sessionStoredDate != null) {
      return {
        'success': true,
        'message': 'Using stored session',
        'sessionAge': DateTime.now().difference(_sessionStoredDate!).inDays
      };
    }

    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/account/v1/auth'),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}'
        },
      );

      log("Response of auth: ${response.statusCode.toString()}");

      if (response.statusCode == 200) {
        String? cookie = response.headers['set-cookie'];
        log("cookie of auth: ${cookie.toString()}");
        if (cookie != null) {
          RegExp regExp = RegExp(r'dmsess=([^;]+)');
          Match? match = regExp.firstMatch(cookie);
          if (match != null) {
            _sessionCookie = 'dmsess=${match.group(1)}';
            await _saveSession();
            return {'success': true};
          }
        }
        return {'success': false, 'error': 'No valid session cookie found'};
      } else {
        return {
          'success': false,
          'error': 'Authentication failed. Status code: ${response.statusCode}',
          'body': response.body
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Exception during authentication: $e'};
    }
  }

  String? _selectedModelId;
  Future<String> getModelId() async {
    if (_selectedModelId != null) {
      return _selectedModelId!;
    }

    if (_sessionCookie == null) {
      throw Exception('Not authenticated');
    }

    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/character/v1/listModels?stockModel=deepmotion'),
        headers: {
          'Cookie': _sessionCookie!,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> models = data['list'];
        if (models.isNotEmpty) {
          _selectedModelId = models[0]['id']; // Select the first model
          return _selectedModelId!;
        } else {
          throw Exception('No models available');
        }
      } else {
        log("getModelId error: ${response.statusCode}", error: response.body);
        throw Exception('Failed to fetch models: ${response.statusCode}');
      }
    } catch (e) {
      log("getModelId exception", error: e);
      throw Exception('An unexpected error occurred while fetching models: $e');
    }
  }

  Future<Map<String, dynamic>> startTextToMotionJob(String prompt, double duration) async {
    if (_sessionCookie == null) {
      throw Exception('Not authenticated');
    }

    if (_lastRid != null) {
      // Check if there's a stored job that matches the current parameters
      final statusData = await getJobStatus(_lastRid!);
      if (statusData['status'][0]['status'] == 'SUCCESS') {
        return {'rid': _lastRid, 'message': 'Using stored job'};
      }
    }

    final modelId = await getModelId();

    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/job/v1/process/text2motion'),
        headers: {
          'Cookie': _sessionCookie!,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "params": [
            "prompt=\"$prompt\"",
            "requestedAnimationDuration=$duration",
            "model=$modelId"
          ]
        }),
      );
      if (response.statusCode == 200) {
        log("AfterJob response: ${response.body.toString()}");
        final responseData = json.decode(response.body);
        _lastRid = responseData['rid'];
        await _saveSession();
        return responseData;
      } else {
        log("startTextToMotionJob error: ${response.statusCode}", error: response.body);
        return {
          'error': true,
          'statusCode': response.statusCode,
          'message': 'Server error occurred',
          'body': response.body,
        };
      }
    } catch (e) {
      log("startTextToMotionJob exception", error: e);
      return {
        'error': true,
        'message': 'An unexpected error occurred',
        'exception': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getJobStatus(String rid) async {
    if (_sessionCookie == null) {
      throw Exception('Not authenticated');
    }
    final response = await http.get(
      Uri.parse('$BASE_URL/job/v1/status/$rid'),
      headers: {'Cookie': _sessionCookie!},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    else{
      SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('dmsess');
          await prefs.remove('lastRid');
          await prefs.remove('sessionStoredDate');
    }
    throw Exception('Failed to get job status');
  }

  Future<Map<String, dynamic>> downloadGlbFile(String rid) async {
    log("started downloading");
    if (_sessionCookie == null) {
      throw Exception('Not authenticated');
    }
    final response = await http.get(
      Uri.parse('$BASE_URL/job/v1/download/$rid'),
      headers: {'Cookie': _sessionCookie!},
    );
    if (response.statusCode == 200) {
      try {
        final decodedBody = json.decode(response.body);
        log('Decoded download response: $decodedBody');
        return decodedBody;
      } catch (e) {
        log('Error decoding JSON: $e');
        log('Raw response body: ${response.body}');
        return {'error': true, 'message': 'Failed to decode JSON response'};
      }
    }
    log('Download failed with status code: ${response.statusCode}');
    log('Response body: ${response.body}');
    return {'error': true, 'message': 'Failed to download GLB file', 'statusCode': response.statusCode};
  }
}