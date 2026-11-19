import 'dart:typed_data';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Contrato del vestuario del trabajador (prendas, tallas y solicitudes)
abstract class VestuarioRepository {
  /// Prendas entregadas al trabajador (activas y devueltas)
  Future<List<VestuarioEntity>> obtenerPrendas(String idPersonal);

  /// Solicitudes del trabajador (más recientes primero)
  Future<List<SolicitudVestuarioEntity>> obtenerSolicitudes(String idPersonal);

  /// Prendas y tallas que hay en almacén
  Future<List<PrendaCatalogoEntity>> obtenerCatalogo();

  /// Tallas registradas (null si aún no las ha guardado)
  Future<TallasPersonalEntity?> obtenerTallas(String idPersonal);

  Future<TallasPersonalEntity> guardarTallas(TallasPersonalEntity tallas);

  Future<SolicitudVestuarioEntity> crearSolicitud(SolicitudVestuarioEntity solicitud);

  Future<SolicitudVestuarioEntity> cancelarSolicitud(String id);

  /// Sube la foto de la prenda y devuelve su ruta
  Future<String> subirFoto({required Uint8List bytes, required String extension});
}
