import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import '../../domain/repositories/checklist_repository.dart';

/// Implementación del repositorio de Checklists de Ambulancia
///
/// Patrón: Pass-through directo al DataSource sin conversiones Entity ↔ Entity
@LazySingleton(as: ChecklistRepository)
class ChecklistRepositoryImpl implements ChecklistRepository {
  /// Constructor que crea el DataSource usando Factory
  ChecklistRepositoryImpl()
      : _dataSource = ChecklistVehiculoDataSourceFactory.createSupabase(),
        _vehiculoDataSource = VehiculoDataSourceFactory.createSupabase();

  final ChecklistVehiculoDataSource _dataSource;
  final VehiculoDataSource _vehiculoDataSource;

  @override
  Future<List<ChecklistVehiculoEntity>> getAll() async {
    debugPrint('📦 ChecklistRepository: Solicitando todos los checklists...');
    try {
      final checklists = await _dataSource.getAll();
      debugPrint(
        '✅ ChecklistRepository: ${checklists.length} checklists obtenidos',
      );
      return checklists;
    } catch (e) {
      debugPrint('❌ ChecklistRepository.getAll: Error - $e');
      rethrow;
    }
  }

  @override
  Future<ChecklistVehiculoEntity> getById(String id) async {
    debugPrint('📦 ChecklistRepository: Solicitando checklist con ID: $id');
    try {
      final checklist = await _dataSource.getById(id);
      debugPrint('✅ ChecklistRepository: Checklist obtenido - ${checklist.id}');
      return checklist;
    } catch (e) {
      debugPrint('❌ ChecklistRepository.getById: Error - $e');
      rethrow;
    }
  }

  @override
  Future<List<ChecklistVehiculoEntity>> getHistorialVehiculo(
    String vehiculoId,
  ) async {
    debugPrint(
      '📦 ChecklistRepository: Solicitando historial de vehículo: $vehiculoId',
    );
    try {
      final historial = await _dataSource.getByVehiculoId(vehiculoId);
      debugPrint(
        '✅ ChecklistRepository: ${historial.length} checklists en historial',
      );
      return historial;
    } catch (e) {
      debugPrint('❌ ChecklistRepository.getHistorialVehiculo: Error - $e');
      rethrow;
    }
  }

  @override
  Future<ChecklistVehiculoEntity?> getUltimoChecklist(
    String vehiculoId,
    TipoChecklist tipo,
  ) async {
    debugPrint(
      '📦 ChecklistRepository: Solicitando último checklist - '
      'Vehículo: $vehiculoId, Tipo: ${tipo.nombre}',
    );
    try {
      final ultimoChecklist = await _dataSource.getUltimoChecklist(
        vehiculoId,
        tipo,
      );
      if (ultimoChecklist != null) {
        debugPrint(
          '✅ ChecklistRepository: Último checklist encontrado - '
          'Fecha: ${ultimoChecklist.fechaRealizacion}',
        );
      } else {
        debugPrint(
          '⚠️ ChecklistRepository: No hay checklists previos de tipo ${tipo.nombre}',
        );
      }
      return ultimoChecklist;
    } catch (e) {
      debugPrint('❌ ChecklistRepository.getUltimoChecklist: Error - $e');
      rethrow;
    }
  }

  @override
  Future<List<ItemChecklistEntity>> getPlantillaItems(
    TipoChecklist tipo,
  ) async {
    debugPrint(
      '📦 ChecklistRepository: Solicitando plantilla de items - Tipo: ${tipo.nombre}',
    );
    try {
      final items = await _dataSource.getPlantillaItems(tipo);
      debugPrint(
        '✅ ChecklistRepository: ${items.length} items en plantilla',
      );
      return items;
    } catch (e) {
      debugPrint('❌ ChecklistRepository.getPlantillaItems: Error - $e');
      rethrow;
    }
  }

  @override
  Future<ChecklistVehiculoEntity> crearChecklist(
    ChecklistVehiculoEntity checklist,
  ) async {
    debugPrint(
      '📦 ChecklistRepository: Creando nuevo checklist - '
      'Vehículo: ${checklist.vehiculoId}, Tipo: ${checklist.tipo.nombre}',
    );
    try {
      final nuevoChecklist = await _dataSource.create(checklist);
      debugPrint(
        '✅ ChecklistRepository: Checklist creado exitosamente - '
        'ID: ${nuevoChecklist.id}, Items: ${nuevoChecklist.items.length}',
      );
      return nuevoChecklist;
    } catch (e) {
      debugPrint('❌ ChecklistRepository.crearChecklist: Error - $e');
      rethrow;
    }
  }

  @override
  Future<ChecklistVehiculoEntity> actualizarChecklist(
    ChecklistVehiculoEntity checklist,
  ) async {
    debugPrint(
      '📦 ChecklistRepository: Actualizando checklist - ID: ${checklist.id}',
    );
    try {
      final checklistActualizado = await _dataSource.update(checklist);
      debugPrint(
        '✅ ChecklistRepository: Checklist actualizado exitosamente',
      );
      return checklistActualizado;
    } catch (e) {
      debugPrint('❌ ChecklistRepository.actualizarChecklist: Error - $e');
      rethrow;
    }
  }

  @override
  Future<void> eliminarChecklist(String id) async {
    debugPrint('📦 ChecklistRepository: Eliminando checklist - ID: $id');
    try {
      await _dataSource.delete(id);
      debugPrint('✅ ChecklistRepository: Checklist eliminado exitosamente');
    } catch (e) {
      debugPrint('❌ ChecklistRepository.eliminarChecklist: Error - $e');
      rethrow;
    }
  }

  @override
  Stream<List<ChecklistVehiculoEntity>> watchChecklistsVehiculo(
    String vehiculoId,
  ) {
    debugPrint(
      '📡 ChecklistRepository: Iniciando stream de checklists - '
      'Vehículo: $vehiculoId',
    );
    return _dataSource.watchByVehiculoId(vehiculoId);
  }

  @override
  Future<String?> getVehiculoAsignadoHoy(String personalId) async {
    debugPrint(
      '🚗 ChecklistRepository: Buscando vehículo asignado hoy - '
      'Personal: $personalId',
    );
    try {
      final vehiculoId = await _dataSource.getVehiculoAsignadoHoy(personalId);
      if (vehiculoId != null) {
        debugPrint(
          '✅ ChecklistRepository: Vehículo asignado encontrado - '
          'ID: $vehiculoId',
        );
      } else {
        debugPrint(
          '⚠️ ChecklistRepository: No hay vehículo asignado hoy para personal $personalId',
        );
      }
      return vehiculoId;
    } catch (e) {
      debugPrint(
        '❌ ChecklistRepository.getVehiculoAsignadoHoy: Error - $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<VehiculoEntity>> getTodosVehiculos(String empresaId) async {
    debugPrint(
      '🚗 ChecklistRepository: Obteniendo todos los vehículos - '
      'Empresa: $empresaId',
    );
    try {
      final vehiculos = await _vehiculoDataSource.getAll();
      // Filtrar por empresa y solo activos
      final vehiculosFiltrados = vehiculos
          .where(
            (v) =>
                v.empresaId == empresaId && v.estado == VehiculoEstado.activo,
          )
          .toList();
      debugPrint(
        '✅ ChecklistRepository: ${vehiculosFiltrados.length} vehículos activos encontrados',
      );
      return vehiculosFiltrados;
    } catch (e) {
      debugPrint('❌ ChecklistRepository.getTodosVehiculos: Error - $e');
      rethrow;
    }
  }
}
