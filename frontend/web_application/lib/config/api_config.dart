class ApiConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  
  static String get baseUrl {
    if (isProduction) {
      return 'https://vinub.eu.pythonanywhere.com';
    } else {
      return 'http://127.0.0.1:5000';
    }
  }
  
  static Uri askEndpoint() {
    return Uri.parse('$baseUrl/ask');
  }
}