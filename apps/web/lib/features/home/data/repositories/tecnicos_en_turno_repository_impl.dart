import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/home/domain/repositories/tecnicos_en_turno_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación pass-through del repositorio de técnicos en turno
@LazySingleton(as: TecnicosEnTurnoRepository)
class TecnicosEnTurnoRepositoryImpl implements TecnicosEnTurnoRepository {
  TecnicosEnTurnoRepositoryImpl() : _dataSource = TecnicosEnTurnoDataSourceFactory.createSupabase();

  final TecnicosEnTurnoDataSource _dataSource;

  @override
  Future<List<TecnicoEnTurnoEntity>> getTecnicosEnTurno({required DateTime ahora}) async {
    debugPrint('👷 TecnicosEnTurnoRepository: getTecnicosEnTurno($ahora)');
    return _dataSource.getTecnicosEnTurno(ahora: ahora);
  }
}
