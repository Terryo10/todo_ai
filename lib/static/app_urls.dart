class AppUrls {
  // static const String baseUrl ='http://127.0.0.1:8000/';
  static const String baseUrl = 'http://192.168.139.73:8000';
  static const String api = '/api/';

  static const String apiBase = '$baseUrl$api';

  // Authentication endpoints
  static const String auth = '${apiBase}auth';
  static const String register = '$auth/register';
  static const String login = '$auth/login';
  static const String logout = '$auth/logout';
  static const String verifyEmail = '$auth/verify-email';
  static const String verifyOtp = '$auth/verify-otp';

  // Social Authentication
  static const String googleAuth = '$auth/google';
  static const String googleCallback = '$auth/google/callback';
  static const String appleAuth = '$auth/apple';
  static const String appleCallback = '$auth/apple/callback';

  // Password Reset
  static const String forgotPassword = '$auth/forgot-password';
  static const String resetPassword = '$auth/reset-password';
}
