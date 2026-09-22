class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final email = value.trim();

    final regex = RegExp(
      r'^(?!\d+@)[a-zA-Z0-9._%+-]+@(gmail\.com|yahoo\.com|ac\.mw|rbm\.mw)$',
    );

    if (!regex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    final hasNumeral = RegExp(r'[0-9]').hasMatch(value);
    if (!hasNumeral) {
      return 'Password must contain at least one number';
    }

    final hasSymbol = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value);
    if (!hasSymbol) {
      return 'Password must contain at least one symbol';
    }

    return null;
  }
}
