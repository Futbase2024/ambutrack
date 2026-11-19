import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/repositories/vestuario_repository.dart';
import 'vestuario_state.dart';

/// Datos de una nueva solicitud (salen del formulario)
class NuevaSolicitudVestuario {
  const NuevaSolicitudVestuario({
    required this.tipo,
    required this.prenda,
    this.talla,
    this.cantidad = 1,
    this.motivo,
    this.vestuarioId,
    this.foto,
  });

  final TipoSolicitudVestuario tipo;
  final String prenda;
  final String? talla;
  final int cantidad;
  final String? motivo;
  final String? vestuarioId;
  final Uint8List? foto;
}

/// Cubit de "Mi vestuario": prendas, solicitudes y tallas del trabajador
class VestuarioCubit extends Cubit<VestuarioState> {
  VestuarioCubit(this._repository, {required this.idPersonal}) : super(const VestuarioState());

  final VestuarioRepository _repository;
  final String idPersonal;

  Future<void> cargar() async {
    try {
      final List<Object?> datos = await Future.wait<Object?>(<Future<Object?>>[
        _repository.obtenerPrendas(idPersonal),
        _repository.obtenerSolicitudes(idPersonal),
        _seguro(_repository.obtenerCatalogo(), const <PrendaCatalogoEntity>[]),
        _seguro(_repository.obtenerTallas(idPersonal), null),
      ]);
      if (isClosed) {
        return;
      }
      final List<VestuarioEntity> prendas = (datos[0]! as List<VestuarioEntity>)
        ..sort((VestuarioEntity a, VestuarioEntity b) => b.fechaEntrega.compareTo(a.fechaEntrega));
      emit(
        VestuarioState(
          status: VestuarioStatus.listo,
          prendas: prendas,
          solicitudes: datos[1]! as List<SolicitudVestuarioEntity>,
          catalogo: datos[2]! as List<PrendaCatalogoEntity>,
          tallas: datos[3] as TallasPersonalEntity?,
        ),
      );
    } catch (e) {
      debugPrint('❌ [VestuarioCubit] Error al cargar: $e');
      if (!isClosed) {
        emit(VestuarioState(status: VestuarioStatus.error, error: '$e'));
      }
    }
  }

  /// Guarda las tallas. Devuelve el error o null si todo fue bien
  Future<String?> guardarTallas(TallasPersonalEntity tallas) async {
    emit(state.copyWith(guardando: true));
    try {
      final TallasPersonalEntity guardadas = await _repository.guardarTallas(tallas);
      emit(state.copyWith(tallas: guardadas, guardando: false));
      return null;
    } catch (e) {
      debugPrint('❌ [VestuarioCubit] Error al guardar tallas: $e');
      emit(state.copyWith(guardando: false));
      return _limpiar(e);
    }
  }

  /// Envía una solicitud. Devuelve el error o null si todo fue bien
  Future<String?> solicitar(NuevaSolicitudVestuario datos) async {
    emit(state.copyWith(guardando: true));
    try {
      final String? foto = await _subirFoto(datos.foto);
      final SolicitudVestuarioEntity creada = await _repository.crearSolicitud(
        SolicitudVestuarioEntity(
          id: const Uuid().v4(),
          personalId: idPersonal,
          tipo: datos.tipo,
          prenda: datos.prenda.trim().toUpperCase(),
          talla: datos.talla?.trim().toUpperCase(),
          cantidad: datos.cantidad,
          motivo: datos.motivo?.trim().isEmpty ?? true ? null : datos.motivo!.trim(),
          vestuarioId: datos.vestuarioId,
          fotoUrl: foto,
        ),
      );
      emit(state.copyWith(solicitudes: <SolicitudVestuarioEntity>[creada, ...state.solicitudes], guardando: false));
      return null;
    } catch (e) {
      debugPrint('❌ [VestuarioCubit] Error al solicitar: $e');
      emit(state.copyWith(guardando: false));
      return _limpiar(e);
    }
  }

  /// Cancela una solicitud pendiente. Devuelve el error o null
  Future<String?> cancelar(String id) async {
    try {
      final SolicitudVestuarioEntity cancelada = await _repository.cancelarSolicitud(id);
      emit(
        state.copyWith(
          solicitudes: state.solicitudes.map((SolicitudVestuarioEntity s) => s.id == id ? cancelada : s).toList(),
        ),
      );
      return null;
    } catch (e) {
      debugPrint('❌ [VestuarioCubit] Error al cancelar: $e');
      return _limpiar(e);
    }
  }

  Future<String?> _subirFoto(Uint8List? bytes) async {
    if (bytes == null) {
      return null;
    }
    try {
      return await _repository.subirFoto(bytes: bytes, extension: 'jpeg');
    } catch (e) {
      debugPrint('⚠️ [VestuarioCubit] Foto no subida: $e');
      return null;
    }
  }

  Future<T> _seguro<T>(Future<T> futuro, T porDefecto) async {
    try {
      return await futuro;
    } catch (e) {
      debugPrint('⚠️ [VestuarioCubit] Dato opcional no disponible: $e');
      return porDefecto;
    }
  }

  String _limpiar(Object e) => '$e'.replaceAll('Exception: ', '');
}
