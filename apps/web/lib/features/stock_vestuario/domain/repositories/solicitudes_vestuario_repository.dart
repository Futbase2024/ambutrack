import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Repositorio de gestión de solicitudes de vestuario y tallas del trabajador
///
/// Usa las entidades del core: SolicitudVestuarioEntity, TallasPersonalEntity
abstract class SolicitudesVestuarioRepository {
  /// Todas las solicitudes (más recientes primero), opcionalmente por estado
  Future<List<SolicitudVestuarioEntity>> getAll({EstadoSolicitudVestuario? estado});

  Future<SolicitudVestuarioEntity> aprobar(String id);

  Future<SolicitudVestuarioEntity> rechazar(String id, {required String motivo});

  /// Entrega (o registra la devolución) moviendo el stock de forma atómica
  Future<String?> entregar(String id, {String? stockId, bool? devolverAStock});

  /// URL firmada temporal (1 h) de la foto de la prenda
  Future<String> getUrlFoto(String ruta);

  /// Tallas registradas del trabajador (null si no tiene)
  Future<TallasPersonalEntity?> getTallas(String personalId);

  /// Guarda (crea o actualiza) las tallas del trabajador
  Future<TallasPersonalEntity> guardarTallas(TallasPersonalEntity tallas);
}
