import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// Converter para campo tmotivos_traslado desde Supabase join
///
/// Supabase retorna el objeto como:
/// ```json
/// {
///   "tmotivos_traslado": {
///     "id": "uuid",
///     "nombre": "ALTA"
///   }
/// }
/// ```
class MotivoTrasladoJsonConverter implements JsonConverter<MotivoTrasladoEntity?, Object?> {
  const MotivoTrasladoJsonConverter();

  @override
  MotivoTrasladoEntity? fromJson(Object? json) {
    if (json == null) {
      return null;
    }

    if (json is Map<String, dynamic>) {
      // Usar el modelo Supabase para deserializar y luego convertir a Entity
      return MotivoTrasladoSupabaseModel.fromJson(json).toEntity();
    }

    return null;
  }

  @override
  Object? toJson(MotivoTrasladoEntity? object) {
    if (object == null) {
      return null;
    }

    // Convertir Entity a modelo Supabase y luego a JSON
    return MotivoTrasladoSupabaseModel.fromEntity(object).toJson();
  }
}
