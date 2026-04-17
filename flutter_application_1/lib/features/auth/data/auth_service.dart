import '/config/api.dart';
import '/services/secure_storage.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
    String emailOrPhone,
    String password,
  ) async {
    final data = await Api.post("/api/auth/login", {
      "email_or_phone": emailOrPhone,
      "password": password,
    });

    final token = data["token"];
    final refreshToken = data["refreshToken"];

    if (token == null || token.isEmpty) {
      throw Exception("Token not received from server");
    }

    await SecureStorage.saveToken(token);

    if (refreshToken != null) {
      await SecureStorage.saveRefreshToken(refreshToken);
    }

    if (data["user"] != null) {
      await SecureStorage.saveData(
          "user_role", data["user"]["role"] ?? "EMPLOYEE");
    }

    return data;
  }

  static Future<Map<String, dynamic>> registerCompany({
    required String companyName,
    required String ownerName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final data = await Api.post("/api/auth/register-company", {
      "company_name": companyName,
      "owner_name": ownerName,
      "email": email,
      "phone": phone,
      "password": password,
    });

    if (data["token"] != null) {
      await SecureStorage.saveToken(data["token"]);
    }

    if (data["refreshToken"] != null) {
      await SecureStorage.saveRefreshToken(data["refreshToken"]);
    }

    return data;
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final data = await Api.post("/api/auth/forgot-password", {
      "email": email,
    });

    if (data["success"] == false || data["error"] != null) {
      throw Exception(data["message"] ?? "Failed to send reset email");
    }

    return data;
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final data = await Api.post("/api/auth/reset-password", {
      "email": email,
      "otp": otp,
      "newPassword": newPassword,
    });

    if (data["success"] == false || data["error"] != null) {
      throw Exception(data["message"] ?? "Password reset failed");
    }

    return data;
  }

  static Future<String?> getToken() async {
    return await SecureStorage.getToken();
  }

  static Future<bool> isLoggedIn() async {
    return await SecureStorage.isLoggedIn();
  }

  static Future<void> logout() async {
    await Api.logout();
  }
}
