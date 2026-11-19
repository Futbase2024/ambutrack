import '../../core/base_datasource.dart';
import 'entities/motivo_traslado_entity.dart';

/// Contrato para operaciones de datasource de motivos de traslado
///
/// Extiende [BaseDatasource] con operaciones CRUD estándar.
/// Todas las implementaciones (Supabase, Firebase, etc.) deben adherirse a este contrato.
abstract class MotivoTrasladoDataSource
    extends BaseDatasource<MotivoTrasladoEntity> {
  // El contrato base ya incluye todos los métodos necesarios
}
