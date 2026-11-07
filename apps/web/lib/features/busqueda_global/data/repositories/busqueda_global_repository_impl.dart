import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/busqueda_global/domain/repositories/busqueda_global_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación pass-through de la búsqueda global
@LazySingleton(as: BusquedaGlobalRepository)
class BusquedaGlobalRepositoryImpl implements BusquedaGlobalRepository {
  BusquedaGlobalRepositoryImpl() : _dataSource = BusquedaGlobalDataSourceFactory.createSupabase();

  final BusquedaGlobalDataSource _dataSource;

  @override
  Future<List<ResultadoBusquedaEntity>> buscar(String texto, {int limitePorTipo = 6}) {
    debugPrint('📦 BusquedaGlobalRepository: buscando "$texto"...');
    return _dataSource.buscar(texto, limitePorTipo: limitePorTipo);
  }
}
