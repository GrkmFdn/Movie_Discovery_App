/// Email validation fonksiyonu
/// RFC 5322 standardına yakın basit regex kullanır
String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'E-posta adresi gerekli';
  }
  
  // Email regex pattern
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  if (!emailRegex.hasMatch(value.trim())) {
    return 'Geçerli bir e-posta adresi girin (örn: kullanici@example.com)';
  }
  
  return null; // Geçerli
}

/// Telefon validation fonksiyonu
/// +90 XXXXXXXXXX formatını kontrol eder (10 rakam)
String? validatePhone(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null; // Opsiyonel field
  }
  
  // +90 ile başlayıp 10 rakam olmalı
  final phoneRegex = RegExp(r'^\+90 \d{10}$');
  
  if (!phoneRegex.hasMatch(value.trim())) {
    return 'Telefon formatı: +90 XXXXXXXXXX (10 rakam)';
  }
  
  return null; // Geçerli
}
