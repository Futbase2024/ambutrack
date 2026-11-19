import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';

import '../../domain/repositories/vestuario_repository.dart';

/// Implementación pass-through de [VestuarioRepository]
class VestuarioRepositoryImpl implements VestuarioRepository {
  VestuarioRepositoryImpl()
    : _vestuarioDataSource = VestuarioDataSourceFactory.createSupabase(),
      _solicitudesDataSource = SolicitudesVestuarioDataSourceFactory.createSupabase();

  final VestuarioDataSource _vestuarioDataSource;
  final SolicitudesVestuarioDataSource _solicitudesDataSource;

  @override
  Future<List<VestuarioEntity>> obtenerPrendas(String idPersonal) async {
    debugPrint('📦 [VestuarioRepository] Prendas de $idPersonal');
    return _vestuarioDataSource.getByPersonalId(idPersonal);
  }

  @override
  Future<List<SolicitudVestuarioEntity>> obtenerSolicitudes(String idPersonal) async {
    return _solicitudesDataSource.getByPersonal(idPersonal);
  }

  @override
  Future<List<PrendaCatalogoEntity>> obtenerCatalogo() async {
    return _solicitudesDataSource.getCatalogo();
  }

  @override
  Future<TallasPersonalEntity?> obtenerTallas(String idPersonal) async {
    return _solicitudesDataSource.getTallas(idPersonal);
  }

  @override
  Future<TallasPersonalEntity> guardarTallas(TallasPersonalEntity tallas) async {
    debugPrint('📦 [VestuarioRepository] Guardando tallas');
    return _solicitudesDataSource.guardarTallas(tallas);
  }

  @override
  Future<SolicitudVestuarioEntity> crearSolicitud(SolicitudVestuarioEntity solicitud) async {
    debugPrint('📦 [VestuarioRepository] Nueva solicitud (${solicitud.tipo.value})');
    return _solicitudesDataSource.create(solicitud);
  }

  @override
  Future<SolicitudVestuarioEntity> cancelarSolicitud(String id) async {
    return _solicitudesDataSource.cancelar(id);
  }

  @override
  Future<String> subirFoto({required Uint8List bytes, required String extension}) async {
    return _solicitudesDataSource.subirFoto(bytes: bytes, extension: extension);
  }
}
