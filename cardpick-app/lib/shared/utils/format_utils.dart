import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(',', '');
    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }
    final buffer = StringBuffer();
    for (var i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && (digitsOnly.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digitsOnly[i]);
    }
    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

String formatCurrency(num amount) {
  final str = amount.toInt().abs().toString();
  final sign = amount < 0 ? '-' : '';
  final buffer = StringBuffer();
  for (var i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
    buffer.write(str[i]);
  }
  return '$sign$buffer';
}

Color getCompanyColor(String company) {
  return switch (company) {
    '삼성카드' => const Color(0xFF1428A0),
    '신한카드' => const Color(0xFF0046FF),
    '현대카드' => const Color(0xFF000000),
    'KB국민카드' => const Color(0xFFFFB300),
    '롯데카드' => const Color(0xFFED1C24),
    '우리카드' => const Color(0xFF0066B3),
    '하나카드' => const Color(0xFF009775),
    'NH농협카드' => const Color(0xFF02A651),
    'BC카드' => const Color(0xFFEE2737),
    _ => const Color(0xFF6B7280),
  };
}

IconData getCategoryIcon(String categoryGroup) {
  return switch (categoryGroup) {
    'FOOD' => Icons.restaurant_rounded,
    'CAFE' => Icons.coffee_rounded,
    'SHOPPING' => Icons.shopping_bag_rounded,
    'TRANSPORT' => Icons.directions_bus_rounded,
    'CONVENIENCE' => Icons.store_rounded,
    'CULTURE' => Icons.movie_rounded,
    'TRAVEL' => Icons.flight_rounded,
    'GAS' => Icons.local_gas_station_rounded,
    'TELECOM' => Icons.phone_android_rounded,
    'INSURANCE' => Icons.shield_rounded,
    'UTILITY' => Icons.receipt_long_rounded,
    _ => Icons.category_rounded,
  };
}
