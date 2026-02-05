import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/paciente_repository.dart';

/// Implementación del repositorio de Pacientes
/// Pass-through directo al DataSource (patrón obligatorio AmbuTrack)
@LazySingleton(as: PacienteRepository)
class PacienteRepositoryImpl implements PacienteRepository {
  PacienteRepositoryImpl() : _dataSource = PacienteDataSourceFactory.createSupabase();

  final PacienteDataSource _dataSource;

  @override
  Future<List<PacienteEntity>> getAll() async {
    debugPrint('📦 PacienteRepository: Solicitando todos los pacientes...');
    try {
      final List<PacienteEntity> pacientes = await _dataSource.getAll();
      debugPrint('📦 PacienteRepository: ✅ ${pacientes.length} pacientes obtenidos');
      return pacientes;
    } catch (e) {
      debugPrint('📦 PacienteRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<PacienteEntity> getById(String id) async {
    debugPrint('📦 PacienteRepository: Obteniendo paciente ID: $id');
    try {
      final PacienteEntity paciente = await _dataSource.getById(id);
      debugPrint('📦 PacienteRepository: ✅ Paciente obtenido: ${paciente.nombreCompleto}');
      return paciente;
    } catch (e) {
      debugPrint('📦 PacienteRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<PacienteEntity>> search(String query) async {
    debugPrint('📦 PacienteRepository: Buscando pacientes: "$query"');
    try {
      final List<PacienteEntity> pacientes = await _dataSource.search(query);
      debugPrint('📦 PacienteRepository: ✅ ${pacientes.length} pacientes encontrados');
      return pacientes;
    } catch (e) {
      debugPrint('📦 PacienteRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<PacienteEntity> create(PacienteEntity paciente) async {
    debugPrint('📦 PacienteRepository: Creando paciente: ${paciente.nombreCompleto}');
    try {
      final PacienteEntity nuevoPaciente = await _dataSource.create(paciente);
      debugPrint('📦 PacienteRepository: ✅ Paciente creado exitosamente');
      return nuevoPaciente;
    } catch (e) {
      debugPrint('📦 PacienteRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<PacienteEntity> update(PacienteEntity paciente) async {
    debugPrint('📦 PacienteRepository: Actualizando paciente: ${paciente.nombreCompleto}');
    try {
      final PacienteEntity pacienteActualizado = await _dataSource.update(paciente);
      debugPrint('📦 PacienteRepository: ✅ Paciente actualizado exitosamente');
      return pacienteActualizado;
    } catch (e) {
      debugPrint('📦 PacienteRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 PacienteRepository: Eliminando paciente ID: $id');
    try {
      await _dataSource.delete(id);
      debugPrint('📦 PacienteRepository: ✅ Paciente eliminado exitosamente');
    } catch (e) {
      debugPrint('📦 PacienteRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Stream<List<PacienteEntity>> watchAll() {
    debugPrint('📦 PacienteRepository: Iniciando stream de pacientes...');
    return _dataSource.watchAll();
  }

  @override
  Stream<PacienteEntity?> watchById(String id) {
    debugPrint('📦 PacienteRepository: Iniciando stream del paciente ID: $id');
    return _dataSource.watchById(id);
  }
}
