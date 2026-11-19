import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/stock_vestuario/domain/repositories/solicitudes_vestuario_repository.dart';
import 'package:flutter/foundation.dart';

/// Implementación pass-through del repositorio de solicitudes de vestuario
///
/// Se instancia directamente desde la página (sin injectable).
class SolicitudesVestuarioRepositoryImpl implements SolicitudesVestuarioRepository {
  SolicitudesVestuarioRepositoryImpl() : _dataSource = SolicitudesVestuarioDataSourceFactory.createSupabase();

  final SolicitudesVestuarioDataSource _dataSource;

  @override
  Future<List<SolicitudVestuarioEntity>> getAll({EstadoSolicitudVestuario? estado}) {
    debugPrint('📦 SolicitudesVestuarioRepository: solicitudes (estado: ${estado?.value ?? 'todas'})');
    return _dataSource.getAll(estado: estado);
  }

  @override
  Future<SolicitudVestuarioEntity> aprobar(String id) {
    debugPrint('📦 SolicitudesVestuarioRepository: aprobar $id');
    return _dataSource.aprobar(id);
  }

  @override
  Future<SolicitudVestuarioEntity> rechazar(String id, {required String motivo}) {
    debugPrint('📦 SolicitudesVestuarioRepository: rechazar $id');
    return _dataSource.rechazar(id, motivo: motivo);
  }

  @override
  Future<String?> entregar(String id, {String? stockId, bool? devolverAStock}) {
    debugPrint('📦 SolicitudesVestuarioRepository: entregar $id (stock: $stockId, devolver: $devolverAStock)');
    return _dataSource.entregar(id, stockId: stockId, devolverAStock: devolverAStock);
  }

  @override
  Future<String> getUrlFoto(String ruta) => _dataSource.getUrlFoto(ruta);

  @override
  Future<TallasPersonalEntity?> getTallas(String personalId) {
    debugPrint('📦 SolicitudesVestuarioRepository: tallas de $personalId');
    return _dataSource.getTallas(personalId);
  }

  @override
  Future<TallasPersonalEntity> guardarTallas(TallasPersonalEntity tallas) {
    debugPrint('📦 SolicitudesVestuarioRepository: guardar tallas de ${tallas.personalId}');
    return _dataSource.guardarTallas(tallas);
  }
}
