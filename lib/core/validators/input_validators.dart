/// Input validation utilities
class InputValidators {
  // Email validation regex
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Password validation regex patterns
  static final RegExp _uppercaseRegex = RegExp(r'[A-Z]');
  static final RegExp _lowercaseRegex = RegExp(r'[a-z]');
  static final RegExp _numberRegex = RegExp(r'[0-9]');
  static final RegExp _specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return 'Email is required';
    }

    if (!_emailRegex.hasMatch(trimmedValue)) {
      return 'Please enter a valid email address';
    }

    if (trimmedValue.length > 254) {
      return 'Email is too long';
    }

    return null;
  }

  /// Validate password with strength requirements
  static String? validatePassword(String? value, {
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireNumber = true,
    bool requireSpecialChar = false,
  }) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    if (requireUppercase && !_uppercaseRegex.hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (requireLowercase && !_lowercaseRegex.hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (requireNumber && !_numberRegex.hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    if (requireSpecialChar && !_specialCharRegex.hasMatch(value)) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  /// Validate password confirmation
  static String? validatePasswordConfirmation(
    String? value,
    String? password,
  ) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate display name
  static String? validateDisplayName(String? value, {
    int minLength = 2,
    int maxLength = 50,
  }) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return 'Name is required';
    }

    if (trimmedValue.length < minLength) {
      return 'Name must be at least $minLength characters';
    }

    if (trimmedValue.length > maxLength) {
      return 'Name must be less than $maxLength characters';
    }

    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(trimmedValue)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  /// Validate message context
  static String? validateMessageContext(String? value, {
    int minLength = 3,
    int maxLength = 500,
  }) {
    if (value == null || value.isEmpty) {
      return 'Context is required';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return 'Context is required';
    }

    if (trimmedValue.length < minLength) {
      return 'Context must be at least $minLength characters';
    }

    if (trimmedValue.length > maxLength) {
      return 'Context must be less than $maxLength characters';
    }

    return null;
  }

  /// Validate phone number (basic)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (cleanedValue.length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    if (!RegExp(r'^[0-9+]+$').hasMatch(cleanedValue)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(
    String? value,
    int minLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(
    String? value,
    int maxLength,
    String fieldName,
  ) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }

    return null;
  }

  /// Validate numeric input
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (int.tryParse(value) == null) {
      return '$fieldName must be a number';
    }

    return null;
  }

  /// Validate range
  static String? validateRange(
    String? value,
    int min,
    int max,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    final numValue = int.tryParse(value);
    if (numValue == null) {
      return '$fieldName must be a number';
    }

    if (numValue < min || numValue > max) {
      return '$fieldName must be between $min and $max';
    }

    return null;
  }

  /// Validate URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }

    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
        return 'Please enter a valid URL';
      }
    } catch (e) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Check password strength and return a score (0-4)
  static int getPasswordStrength(String password) {
    int strength = 0;

    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (_uppercaseRegex.hasMatch(password) &&
        _lowercaseRegex.hasMatch(password)) {
      strength++;
    }
    if (_numberRegex.hasMatch(password)) strength++;
    if (_specialCharRegex.hasMatch(password)) strength++;

    return strength.clamp(0, 4);
  }

  /// Get password strength label
  static String getPasswordStrengthLabel(String password) {
    final strength = getPasswordStrength(password);

    switch (strength) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return 'Unknown';
    }
  }

  /// Sanitize input to prevent XSS
  static String sanitizeInput(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
  }

  /// Validate and sanitize message content
  static String? validateAndSanitizeMessage(String? value, {
    int maxLength = 1000,
  }) {
    final validation = validateMessageContext(value, maxLength: maxLength);
    if (validation != null) return validation;

    // Check for potential malicious content
    if (value!.contains(RegExp(r'<script|javascript:|onerror=', caseSensitive: false))) {
      return 'Invalid content detected';
    }

    return null;
  }
}
