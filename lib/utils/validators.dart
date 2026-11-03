class AppValidators {
  static String? requiredText(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  static String? phone(String? value) {
    final required = requiredText(value, 'Contact number');
    if (required != null) return required;
    final digits = value!.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 7 || digits.length > 15) {
      return 'Enter a valid contact number';
    }
    return null;
  }

  static String? positiveInteger(String? value) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null || parsed <= 0) return 'Enter a quantity above 0';
    return null;
  }

  static String? nonNegativePrice(String? value) {
    final parsed = double.tryParse(value ?? '');
    if (parsed == null || !parsed.isFinite || parsed < 0) {
      return 'Enter a valid price';
    }
    return null;
  }
}
