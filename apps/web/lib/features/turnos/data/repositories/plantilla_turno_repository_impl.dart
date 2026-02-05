import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/turnos/domain/repositories/plantilla_turno_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

/// Implementación del repositorio de plantillas de turnos (pass-through a core datasource)
@LazySingleton(as: PlantillaTurnoRepository)
class PlantillaTurnoRepositoryImpl implements PlantillaTurnoRepository {
  PlantillaTurnoRepositoryImpl()
      : _dataSource = PlantillaTurnoDataSourceFactory.createSupabase();

  final PlantillaTurnoDataSource _dataSource;
  final Uuid _uuid = const Uuid();

  @override
  Future<List<PlantillaTurnoEntity>> getAll() async {
    debugPrint('📦 PlantillaTurnoRepository: Solicitando todas las plantillas...');
    try {
      final List<PlantillaTurnoEntity> plantillas = await _dataSource.getAll();
      debugPrint('📦 PlantillaTurnoRepository: ✅ ${plantillas.length} plantillas obtenidas');
      return plantillas;
    } catch (e) {
      debugPrint('📦 PlantillaTurnoRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<PlantillaTurnoEntity?> getById(String id) async {
    debugPrint('📦 PlantillaTurnoRepository: Solicitando plantilla $id...');
    try {
      final PlantillaTurnoEntity? plantilla = await _dataSource.getById(id);
      if (plantilla == null) {
        debugPrint('📦 PlantillaTurnoRepository: ⚠️ Plantilla no encontrada');
      } else {
        debugPrint('📦 PlantillaTurnoRepository: ✅ Plantilla obtenida');
      }
      return plantilla;
    } catch (e) {
      debugPrint('📦 PlantillaTurnoRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<PlantillaTurnoEntity> create(PlantillaTurnoEntity plantilla) async {
    debugPrint('📦 PlantillaTurnoRepository: Creando plantilla "${plantilla.nombre}"...');
    try {
      // Generar ID si no existe
      final PlantillaTurnoEntity plantillaConId = plantilla.id.isEmpty
          ? plantilla.copyWith(id: _uuid.v4())
          : plantilla;

      final PlantillaTurnoEntity created = await _dataSource.create(plantillaConId);
      debugPrint('📦 PlantillaTurnoRepository: ✅ Plantilla creada con ID ${created.id}');
      return created;
    } catch (e) {
      debugPrint('📦 PlantillaTurnoRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<PlantillaTurnoEntity> update(PlantillaTurnoEntity plantilla) async {
    debugPrint('📦 PlantillaTurnoRepository: Actualizando plantilla ${plantilla.id}...');
    try {
      final PlantillaTurnoEntity updated = await _dataSource.update(plantilla);
      debugPrint('📦 PlantillaTurnoRepository: ✅ Plantilla actualizada');
      return updated;
    } catch (e) {
      debugPrint('📦 PlantillaTurnoRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 PlantillaTurnoRepository: Eliminando plantilla $id...');
    try {
      await _dataSource.delete(id);
      debugPrint('📦 PlantillaTurnoRepository: ✅ Plantilla eliminada');
    } catch (e) {
      debugPrint('📦 PlantillaTurnoRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<PlantillaTurnoEntity> duplicate(String id) async {
    try {
      debugPrint('📋 PlantillaTurnoRepository: Duplicando plantilla $id...');

      // Obtener plantilla original
      final PlantillaTurnoEntity? original = await getById(id);

      if (original == null) {
        throw Exception('Plantilla $id no encontrada');
      }

      // Crear copia con nuevo ID y nombre modificado
      final PlantillaTurnoEntity duplicada = original.copyWith(
        id: _uuid.v4(),
        nombre: 'Copia de ${original.nombre}',
      );

      // Guardar la copia
      final PlantillaTurnoEntity creada = await create(duplicada);

      debugPrint('✅ PlantillaTurnoRepository: Plantilla duplicada exitosamente');

      return creada;
    } catch (e, stackTrace) {
      debugPrint('❌ PlantillaTurnoRepository.duplicate: Error - $e');
      debugPrint('   StackTrace: $stackTrace');
      rethrow;
    }
  }
}
