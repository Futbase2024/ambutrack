import 'dart:typed_data';

import 'entities/solicitud_vestuario_entity.dart';

/// Contrato del datasource de solicitudes de vestuario y tallas del trabajador
abstract class SolicitudesVestuarioDataSource {
  // ===== Trabajador =====

  /// Solicitudes de un trabajador (más recientes primero)
  Future<List<SolicitudVestuarioEntity>> getByPersonal(String personalId);

  /// Crea una solicitud (queda pendiente)
  Future<SolicitudVestuarioEntity> create(SolicitudVestuarioEntity entity);

  /// Cancela una solicitud pendiente propia
  Future<SolicitudVestuarioEntity> cancelar(String id);

  /// Prendas y tallas que hay en almacén
  Future<List<PrendaCatalogoEntity>> getCatalogo();

  /// Tallas del trabajador (null si no las ha registrado)
  Future<TallasPersonalEntity?> getTallas(String personalId);

  /// Guarda (crea o actualiza) las tallas del trabajador
  Future<TallasPersonalEntity> guardarTallas(TallasPersonalEntity tallas);

  /// Sube una foto de la prenda y devuelve su ruta en storage
  Future<String> subirFoto({required Uint8List bytes, required String extension});

  /// URL firmada temporal (1 h) para ver una foto
  Future<String> getUrlFoto(String ruta);

  // ===== Gestión (almacén) =====

  /// Todas las solicitudes, opcionalmente filtradas por estado
  Future<List<SolicitudVestuarioEntity>> getAll({EstadoSolicitudVestuario? estado});

  Future<SolicitudVestuarioEntity> aprobar(String id);

  Future<SolicitudVestuarioEntity> rechazar(String id, {required String motivo});

  /// Entrega (o registra la devolución) moviendo el stock de forma atómica.
  ///
  /// [stockId]: fila de `stock_vestuario` a entregar (no hace falta en devoluciones).
  /// [devolverAStock]: la prenda antigua vuelve al almacén (true) o se da de baja (false);
  /// null = por defecto (reposición → baja; cambio de talla / devolución → vuelve).
  /// Devuelve el id de la prenda entregada (null en devoluciones).
  Future<String?> entregar(String id, {String? stockId, bool? devolverAStock});
}
