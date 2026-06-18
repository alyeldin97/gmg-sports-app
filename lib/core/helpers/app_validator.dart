class AppValidator {
  AppValidator._();

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final cleaned = value.trim().replaceAll(RegExp(r'\s+|-'), '');
    final phoneRegex = RegExp(r'^(\+20|0020|0)?1[0125][0-9]{8}$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Enter a valid Egyptian mobile number (e.g. 01012345678)';
    }
    return null;
  }

  static String? validateNotEmpty(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }
}
