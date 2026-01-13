import 'package:flutter/services.dart';

/// +90 prefix ile telefon numarası formatter
/// Sadece rakam girişine izin verir ve 10 karakter ile sınırlar
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Sadece rakamları al
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    // Maksimum 10 rakam
    if (digitsOnly.length > 10) {
      digitsOnly = digitsOnly.substring(0, 10);
    }
    
    // +90 prefix ile birleştir
    String formatted = digitsOnly.isEmpty ? '' : '+90 $digitsOnly';
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
