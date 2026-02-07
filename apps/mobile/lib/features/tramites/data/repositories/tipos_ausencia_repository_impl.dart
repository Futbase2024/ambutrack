import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/tipos_ausencia_repository.dart';

/// Implementación del repositorio de tipos de ausencias.
/// Patrón pass-through: delega directamente al datasource sin conversiones.
@LazySingleton(as: TiposAusenciaRepository)
class TiposAusenciaRepositoryImpl implements TiposAusenciaRepository {
  TiposAusenciaRepositoryImpl()
      : _dataSource = TipoAusenciaDataSourceFactory.createSupabase();

  final TipoAusenciaDataSource _dataSource;

  @override
  Future<List<TipoAusenciaEntity>> getAll() async {
    debugPrint(
        '📦 TiposAusenciaRepository: Solicitando tipos de ausencias...');
    try {
      final items = await _dataSource.getAll();
      debugPrint(
          '📦 TiposAusenciaRepository: ✅ ${items.length} tipos obtenidos');
      return items;
    } catch (e) {
      debugPrint('📦 TiposAusenciaRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<TipoAusenciaEntity> getById(String id) async {
    debugPrint('📦 TiposAusenciaRepository: Obteniendo tipo ID: $id');
    return await _dataSource.getById(id);
  }

  @override
  Stream<List<TipoAusenciaEntity>> watchAll() {
    debugPrint(
        '📦 TiposAusenciaRepository: Observando tipos de ausencias...');
    return _dataSource.watchAll();
  }
}
