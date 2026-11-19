import 'package:freezed_annotation/freezed_annotation.dart';

/// Converter personalizado para parsear DateTime como UTC desde Supabase
/// 
/// Supabase devuelve timestamps sin el sufijo 'Z', lo que causa que
/// DateTime.parse() los interprete como hora local en lugar de UTC.
/// Este converter fuerza la interpretación como UTC.
class UtcDateTimeConverter implements JsonConverter<DateTime?, String?> {
  const UtcDateTimeConverter();

  @override
  DateTime? fromJson(String? json) {
    if (json == null) {
      return null;
    }
    
    // Si la fecha ya tiene 'Z' al final, parsearla normalmente
    if (json.endsWith('Z')) {
      return DateTime.parse(json);
    }
    
    // Si no tiene 'Z', agregarla para forzar interpretación UTC
    return DateTime.parse('${json}Z');
  }

  @override
  String? toJson(DateTime? date) {
    return date?.toUtc().toIso8601String();
  }
}
