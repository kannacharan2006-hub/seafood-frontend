import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/services/secure_storage.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockSecureStorage extends Mock implements SecureStorage {}

class MockResponse {
  final int statusCode;
  final String body;

  MockResponse({required this.statusCode, required this.body});

  http.Response toResponse() {
    return http.Response(body, statusCode);
  }
}

// Common test responses
final testResponses = {
  'success': MockResponse(
    statusCode: 200,
    body: '{"success": true, "data": {"id": 1}}',
  ),
  'created': MockResponse(
    statusCode: 201,
    body: '{"success": true, "data": {"id": 1}}',
  ),
  'badRequest': MockResponse(
    statusCode: 400,
    body: '{"message": "Invalid request"}',
  ),
  'unauthorized': MockResponse(
    statusCode: 401,
    body: '{"message": "Unauthorized"}',
  ),
  'forbidden': MockResponse(
    statusCode: 403,
    body: '{"message": "Forbidden"}',
  ),
  'notFound': MockResponse(
    statusCode: 404,
    body: '{"message": "Not found"}',
  ),
  'tooManyRequests': MockResponse(
    statusCode: 429,
    body: '{"message": "Too many requests"}',
  ),
  'serverError': MockResponse(
    statusCode: 500,
    body: '{"message": "Server error"}',
  ),
};
