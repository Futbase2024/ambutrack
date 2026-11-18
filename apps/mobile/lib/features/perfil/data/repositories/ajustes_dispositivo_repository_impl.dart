import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';

import '../../domain/repositories/ajustes_dispositivo_repository.dart';

/// Implementación pass-through de [AjustesDispositivoRepository]
class AjustesDispositivoRepositoryImpl implements AjustesDispositivoRepository {
  AjustesDispositivoRepositoryImpl() : _dataSource = InicioTurnoDataSourceFactory.createSupabase();

  final InicioTurnoDataSource _dataSource;

  @override
  Future<String?> obtenerRolUsuario() async {
    debugPrint('📦 [AjustesDispositivoRepository] Rol del usuario actual');
    return _dataSource.getRolUsuarioActual();
  }
}
