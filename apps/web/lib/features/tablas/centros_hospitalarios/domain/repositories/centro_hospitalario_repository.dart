import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Contrato del repositorio de Centros Hospitalarios
abstract class CentroHospitalarioRepository {
  /// Obtiene todos los centros hospitalarios
  Future<List<CentroHospitalarioEntity>> getAll();

  /// Obtiene un centro hospitalario por ID
  Future<CentroHospitalarioEntity> getById(String id);

  /// Crea un nuevo centro hospitalario
  Future<CentroHospitalarioEntity> create(CentroHospitalarioEntity centro);

  /// Actualiza un centro hospitalario existente
  Future<CentroHospitalarioEntity> update(CentroHospitalarioEntity centro);

  /// Elimina un centro hospitalario
  Future<void> delete(String id);
}
