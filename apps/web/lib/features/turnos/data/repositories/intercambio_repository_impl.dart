import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/turnos/domain/repositories/intercambio_repository.dart';
import 'package:ambutrack_web/features/turnos/domain/repositories/turnos_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de intercambios
@LazySingleton(as: IntercambioRepository)
class IntercambioRepositoryImpl implements IntercambioRepository {
  IntercambioRepositoryImpl(this._turnosRepository)
      : _dataSource = SolicitudIntercambioDataSourceFactory.createSupabase();

  final SolicitudIntercambioDataSource _dataSource;
  final TurnosRepository _turnosRepository;

  @override
  Future<List<SolicitudIntercambioEntity>> getAll() async {
    debugPrint('📦 IntercambioRepository: Solicitando todas las solicitudes...');
    try {
      final List<SolicitudIntercambioEntity> solicitudes = await _dataSource.getAll();
      debugPrint(
        '📦 IntercambioRepository: ✅ ${solicitudes.length} solicitudes obtenidas',
      );
      return solicitudes;
    } catch (e) {
      debugPrint('📦 IntercambioRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<SolicitudIntercambioEntity>> getPendientesPorTrabajador(
    String idPersonal,
  ) async {
    debugPrint(
      '📦 IntercambioRepository: Solicitando pendientes por trabajador $idPersonal...',
    );
    try {
      final List<SolicitudIntercambioEntity> solicitudes = await _dataSource.getPendientesByPersonal(idPersonal);
      debugPrint(
        '📦 IntercambioRepository: ✅ ${solicitudes.length} solicitudes pendientes',
      );
      return solicitudes;
    } catch (e) {
      debugPrint('📦 IntercambioRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<SolicitudIntercambioEntity>> getPendientesResponsable() async {
    debugPrint(
      '📦 IntercambioRepository: Solicitando pendientes por responsable...',
    );
    try {
      // Filtrar solicitudes en estado pendienteAprobacionResponsable
      final List<SolicitudIntercambioEntity> todasSolicitudes = await _dataSource.getAll();
      final List<SolicitudIntercambioEntity> pendientes = todasSolicitudes
          .where(
            (SolicitudIntercambioEntity s) =>
                s.estado == EstadoSolicitud.pendienteAprobacionResponsable,
          )
          .toList();
      debugPrint(
        '📦 IntercambioRepository: ✅ ${pendientes.length} solicitudes pendientes',
      );
      return pendientes;
    } catch (e) {
      debugPrint('📦 IntercambioRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<SolicitudIntercambioEntity>> getHistorialPorPersonal(
    String idPersonal,
  ) async {
    debugPrint(
      '📦 IntercambioRepository: Solicitando historial de $idPersonal...',
    );
    try {
      // Obtener solicitudes donde el personal es solicitante o destino
      final List<SolicitudIntercambioEntity> solicitadas = await _dataSource.getBySolicitante(idPersonal);
      final List<SolicitudIntercambioEntity> recibidas = await _dataSource.getByDestino(idPersonal);

      // Combinar y eliminar duplicados
      final List<SolicitudIntercambioEntity> historial = <SolicitudIntercambioEntity>{
        ...solicitadas,
        ...recibidas,
      }.toList();

      debugPrint(
        '📦 IntercambioRepository: ✅ ${historial.length} solicitudes en historial',
      );
      return historial;
    } catch (e) {
      debugPrint('📦 IntercambioRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> create(SolicitudIntercambioEntity solicitud) async {
    debugPrint(
      '📦 IntercambioRepository: Creando solicitud de intercambio...',
    );
    try {
      await _dataSource.create(solicitud);
      debugPrint('📦 IntercambioRepository: ✅ Solicitud creada');
    } catch (e) {
      debugPrint('📦 IntercambioRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> update(SolicitudIntercambioEntity solicitud) async {
    debugPrint(
      '📦 IntercambioRepository: Actualizando solicitud ${solicitud.id}...',
    );
    try {
      await _dataSource.update(solicitud);
      debugPrint('📦 IntercambioRepository: ✅ Solicitud actualizada');
    } catch (e) {
      debugPrint('📦 IntercambioRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 IntercambioRepository: Eliminando solicitud $id...');
    try {
      await _dataSource.delete(id);
      debugPrint('📦 IntercambioRepository: ✅ Solicitud eliminada');
    } catch (e) {
      debugPrint('📦 IntercambioRepository: ❌ Error: $e');
      rethrow;
    }
  }

  // ===== MÉTODOS DE WORKFLOW (LÓGICA DE NEGOCIO) =====

  @override
  Future<void> aprobarPorTrabajador({
    required String idSolicitud,
    required String idPersonal,
  }) async {
    debugPrint(
      '📦 IntercambioRepository: Aprobando por trabajador $idPersonal...',
    );
    try {
      // Obtener solicitud actual
      final SolicitudIntercambioEntity? solicitud = await _dataSource.getById(idSolicitud);
      if (solicitud == null) {
        throw Exception('Solicitud no encontrada: $idSolicitud');
      }

      // Actualizar estado y fecha
      final SolicitudIntercambioEntity actualizada = solicitud.copyWith(
        estado: EstadoSolicitud.pendienteAprobacionResponsable,
        fechaRespuestaTrabajador: DateTime.now(),
      );

      await _dataSource.update(actualizada);
      debugPrint('📦 IntercambioRepository: ✅ Solicitud aprobada por trabajador');
    } catch (e) {
      debugPrint('📦 IntercambioRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> rechazarPorTrabajador({
    required String idSolicitud,
    required String idPersonal,
    String? motivoRechazo,
  }) async {
    debugPrint(
      '📦 IntercambioRepository: Rechazando por trabajador $idPersonal...',
    );
    try {
      // Obtener solicitud actual
      final SolicitudIntercambioEntity? solicitud = await _dataSource.getById(idSolicitud);
      if (solicitud == null) {
        throw Exception('Solicitud no encontrada: $idSolicitud');
      }

      // Actualizar estado, fecha y motivo
      final SolicitudIntercambioEntity actualizada = solicitud.copyWith(
        estado: EstadoSolicitud.rechazadaPorTrabajador,
        fechaRespuestaTrabajador: DateTime.now(),
        motivoRechazo: motivoRechazo,
      );

      await _dataSource.update(actualizada);
      debugPrint('📦 IntercambioRepository: ✅ Solicitud rechazada por trabajador');
    } catch (e) {
      debugPrint('📦 IntercambioRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> aprobarPorResponsable({
    required String idSolicitud,
    required String idResponsable,
    required String nombreResponsable,
  }) async {
    debugPrint(
      '📦 IntercambioRepository: Aprobando por responsable $nombreResponsable...',
    );
    try {
      // Obtener solicitud actual
      final SolicitudIntercambioEntity? solicitud = await _dataSource.getById(idSolicitud);
      if (solicitud == null) {
        throw Exception('Solicitud no encontrada: $idSolicitud');
      }

      // 1. Ejecutar el intercambio de turnos
      await ejecutarIntercambio(
        idTurno1: solicitud.idTurnoSolicitante,
        idTurno2: solicitud.idTurnoDestino,
        idPersonal1: solicitud.idPersonalSolicitante,
        idPersonal2: solicitud.idPersonalDestino,
      );

      // 2. Actualizar estado de la solicitud
      final SolicitudIntercambioEntity actualizada = solicitud.copyWith(
        estado: EstadoSolicitud.aprobada,
        fechaRespuestaResponsable: DateTime.now(),
        idResponsable: idResponsable,
        nombreResponsable: nombreResponsable,
      );

      await _dataSource.update(actualizada);
      debugPrint('📦 IntercambioRepository: ✅ Solicitud aprobada por responsable');
    } catch (e) {
      debugPrint('📦 IntercambioRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> rechazarPorResponsable({
    required String idSolicitud,
    required String idResponsable,
    required String nombreResponsable,
    String? motivoRechazo,
  }) async {
    debugPrint(
      '📦 IntercambioRepository: Rechazando por responsable $nombreResponsable...',
    );
    try {
      // Obtener solicitud actual
      final SolicitudIntercambioEntity? solicitud = await _dataSource.getById(idSolicitud);
      if (solicitud == null) {
        throw Exception('Solicitud no encontrada: $idSolicitud');
      }

      // Actualizar estado, fecha y motivo
      final SolicitudIntercambioEntity actualizada = solicitud.copyWith(
        estado: EstadoSolicitud.rechazadaPorResponsable,
        fechaRespuestaResponsable: DateTime.now(),
        idResponsable: idResponsable,
        nombreResponsable: nombreResponsable,
        motivoRechazo: motivoRechazo,
      );

      await _dataSource.update(actualizada);
      debugPrint(
        '📦 IntercambioRepository: ✅ Solicitud rechazada por responsable',
      );
    } catch (e) {
      debugPrint('📦 IntercambioRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> cancelar(String idSolicitud) async {
    debugPrint('📦 IntercambioRepository: Cancelando solicitud $idSolicitud...');
    try {
      // Obtener solicitud actual
      final SolicitudIntercambioEntity? solicitud = await _dataSource.getById(idSolicitud);
      if (solicitud == null) {
        throw Exception('Solicitud no encontrada: $idSolicitud');
      }

      // Actualizar estado
      final SolicitudIntercambioEntity actualizada = solicitud.copyWith(
        estado: EstadoSolicitud.cancelada,
      );

      await _dataSource.update(actualizada);
      debugPrint('📦 IntercambioRepository: ✅ Solicitud cancelada');
    } catch (e) {
      debugPrint('📦 IntercambioRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> ejecutarIntercambio({
    required String idTurno1,
    required String idTurno2,
    required String idPersonal1,
    required String idPersonal2,
  }) async {
    debugPrint(
      '📦 IntercambioRepository: Ejecutando intercambio de turnos...',
    );
    try {
      // Obtener ambos turnos
      final List<TurnoEntity> allTurnos = await _turnosRepository.getAll();

      final TurnoEntity turno1 = allTurnos.firstWhere(
        (TurnoEntity t) => t.id == idTurno1,
        orElse: () => throw Exception('Turno 1 no encontrado: $idTurno1'),
      );
      final TurnoEntity turno2 = allTurnos.firstWhere(
        (TurnoEntity t) => t.id == idTurno2,
        orElse: () => throw Exception('Turno 2 no encontrado: $idTurno2'),
      );

      // Intercambiar idPersonal: turno1 → personal2, turno2 → personal1
      final TurnoEntity turno1Actualizado = turno1.copyWith(
        idPersonal: idPersonal2,
        // nombrePersonal se actualiza en el BLoC cuando se recarga
      );
      final TurnoEntity turno2Actualizado = turno2.copyWith(
        idPersonal: idPersonal1,
        // nombrePersonal se actualiza en el BLoC cuando se recarga
      );

      // Actualizar ambos turnos
      await _turnosRepository.update(turno1Actualizado);
      await _turnosRepository.update(turno2Actualizado);

      debugPrint('📦 IntercambioRepository: ✅ Intercambio ejecutado correctamente');
    } catch (e) {
      debugPrint('📦 IntercambioRepository: ❌ Error: $e');
      rethrow;
    }
  }
}
