import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/registro_horario_repository.dart';

/// Implementación del RegistroHorarioRepository
///
/// Adapta los métodos en español del contrato a los métodos en inglés del datasource del core.
class RegistroHorarioRepositoryImpl implements RegistroHorarioRepository {
  RegistroHorarioRepositoryImpl()
      : _dataSource = RegistroHorarioDataSourceFactory.createSupabase();

  final RegistroHorarioDataSource _dataSource;

  @override
  Future<RegistroHorarioEntity> crear(RegistroHorarioEntity registro) async {
    debugPrint('📦 [RegistroHorarioRepository] Creando fichaje: ${registro.tipo}');

    // Adaptar al datasource del core según el tipo
    if (registro.tipo.toLowerCase() == 'entrada') {
      return await _dataSource.registrarEntrada(
        personalId: registro.personalId,
        nombrePersonal: registro.nombrePersonal,
        ubicacion: registro.ubicacion,
        latitud: registro.latitud,
        longitud: registro.longitud,
        notas: registro.notas,
      );
    } else {
      return await _dataSource.registrarSalida(
        personalId: registro.personalId,
        nombrePersonal: registro.nombrePersonal,
        ubicacion: registro.ubicacion,
        latitud: registro.latitud,
        longitud: registro.longitud,
        notas: registro.notas,
      );
    }
  }

  @override
  Future<List<RegistroHorarioEntity>> obtenerPorPersonal(
    String personalId, {
    int limit = 10,
  }) async {
    debugPrint('📦 [RegistroHorarioRepository] Obteniendo registros de: $personalId');
    final registros = await _dataSource.getByPersonalId(personalId);
    // Limitar los resultados si es necesario
    return registros.take(limit).toList();
  }

  @override
  Future<RegistroHorarioEntity?> obtenerUltimo(String personalId) async {
    debugPrint('📦 [RegistroHorarioRepository] Obteniendo último registro');
    return await _dataSource.getUltimoRegistro(personalId);
  }

  @override
  Future<List<RegistroHorarioEntity>> obtenerPorRangoFechas(
    String personalId,
    DateTime inicio,
    DateTime fin,
  ) async {
    debugPrint('📦 [RegistroHorarioRepository] Obteniendo registros por rango');
    return await _dataSource.getByPersonalIdAndDateRange(personalId, inicio, fin);
  }

  @override
  Future<List<RegistroHorarioEntity>> obtenerTodos(String personalId) async {
    debugPrint('📦 [RegistroHorarioRepository] Obteniendo TODOS los registros');
    return await _dataSource.getByPersonalId(personalId);
  }
}
