import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/turnos/domain/repositories/intercambio_repository.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/intercambios_event.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/intercambios_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestión de intercambios de turnos
@injectable
class IntercambiosBloc extends Bloc<IntercambiosEvent, IntercambiosState> {
  IntercambiosBloc(this._repository) : super(const IntercambiosInitial()) {
    on<IntercambiosLoadRequested>(_onLoadRequested);
    on<IntercambiosPendientesTrabajadorRequested>(
      _onPendientesTrabajadorRequested,
    );
    on<IntercambiosPendientesResponsableRequested>(
      _onPendientesResponsableRequested,
    );
    on<IntercambioCreateRequested>(_onCreateRequested);
    on<IntercambioAprobarPorTrabajadorRequested>(
      _onAprobarPorTrabajadorRequested,
    );
    on<IntercambioRechazarPorTrabajadorRequested>(
      _onRechazarPorTrabajadorRequested,
    );
    on<IntercambioAprobarPorResponsableRequested>(
      _onAprobarPorResponsableRequested,
    );
    on<IntercambioRechazarPorResponsableRequested>(
      _onRechazarPorResponsableRequested,
    );
    on<IntercambioCancelarRequested>(_onCancelarRequested);
    on<IntercambiosRefreshRequested>(_onRefreshRequested);
  }

  final IntercambioRepository _repository;

  Future<void> _onLoadRequested(
    IntercambiosLoadRequested event,
    Emitter<IntercambiosState> emit,
  ) async {
    try {
      emit(const IntercambiosLoading());
      final List<SolicitudIntercambioEntity> solicitudes =
          await _repository.getAll();
      emit(IntercambiosLoaded(solicitudes));
    } catch (e, stackTrace) {
      debugPrint('❌ Error al cargar solicitudes de intercambio: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(IntercambiosError('Error al cargar solicitudes: $e'));
    }
  }

  Future<void> _onPendientesTrabajadorRequested(
    IntercambiosPendientesTrabajadorRequested event,
    Emitter<IntercambiosState> emit,
  ) async {
    try {
      emit(const IntercambiosLoading());
      final List<SolicitudIntercambioEntity> solicitudes =
          await _repository.getPendientesPorTrabajador(event.idPersonal);
      emit(IntercambiosLoaded(solicitudes));
    } catch (e, stackTrace) {
      debugPrint('❌ Error al cargar pendientes del trabajador: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(IntercambiosError('Error al cargar pendientes: $e'));
    }
  }

  Future<void> _onPendientesResponsableRequested(
    IntercambiosPendientesResponsableRequested event,
    Emitter<IntercambiosState> emit,
  ) async {
    try {
      emit(const IntercambiosLoading());
      final List<SolicitudIntercambioEntity> solicitudes =
          await _repository.getPendientesResponsable();
      emit(IntercambiosLoaded(solicitudes));
    } catch (e, stackTrace) {
      debugPrint('❌ Error al cargar pendientes de responsable: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(IntercambiosError('Error al cargar pendientes de responsable: $e'));
    }
  }

  Future<void> _onCreateRequested(
    IntercambioCreateRequested event,
    Emitter<IntercambiosState> emit,
  ) async {
    try {
      debugPrint('🚀 Creando solicitud de intercambio...');
      emit(const IntercambiosProcessing());

      await _repository.create(event.solicitud);

      debugPrint('✅ Solicitud creada exitosamente');
      emit(const IntercambiosSuccess('Solicitud de intercambio creada'));

      // Recargar lista
      add(const IntercambiosLoadRequested());
    } catch (e, stackTrace) {
      debugPrint('❌ Error al crear solicitud: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(IntercambiosError('Error al crear solicitud: $e'));
    }
  }

  Future<void> _onAprobarPorTrabajadorRequested(
    IntercambioAprobarPorTrabajadorRequested event,
    Emitter<IntercambiosState> emit,
  ) async {
    try {
      debugPrint('🚀 Aprobando solicitud por trabajador...');
      emit(const IntercambiosProcessing());

      await _repository.aprobarPorTrabajador(
        idSolicitud: event.idSolicitud,
        idPersonal: event.idPersonal,
      );

      debugPrint('✅ Solicitud aprobada por trabajador');
      emit(const IntercambiosSuccess('Solicitud aprobada. Pendiente de responsable'));

      // Recargar lista
      add(const IntercambiosLoadRequested());
    } catch (e, stackTrace) {
      debugPrint('❌ Error al aprobar solicitud: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(IntercambiosError('Error al aprobar solicitud: $e'));
    }
  }

  Future<void> _onRechazarPorTrabajadorRequested(
    IntercambioRechazarPorTrabajadorRequested event,
    Emitter<IntercambiosState> emit,
  ) async {
    try {
      debugPrint('🚀 Rechazando solicitud por trabajador...');
      emit(const IntercambiosProcessing());

      await _repository.rechazarPorTrabajador(
        idSolicitud: event.idSolicitud,
        idPersonal: event.idPersonal,
        motivoRechazo: event.motivoRechazo,
      );

      debugPrint('✅ Solicitud rechazada por trabajador');
      emit(const IntercambiosSuccess('Solicitud rechazada'));

      // Recargar lista
      add(const IntercambiosLoadRequested());
    } catch (e, stackTrace) {
      debugPrint('❌ Error al rechazar solicitud: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(IntercambiosError('Error al rechazar solicitud: $e'));
    }
  }

  Future<void> _onAprobarPorResponsableRequested(
    IntercambioAprobarPorResponsableRequested event,
    Emitter<IntercambiosState> emit,
  ) async {
    try {
      debugPrint('🚀 Aprobando solicitud por responsable...');
      emit(const IntercambiosProcessing());

      await _repository.aprobarPorResponsable(
        idSolicitud: event.idSolicitud,
        idResponsable: event.idResponsable,
        nombreResponsable: event.nombreResponsable,
      );

      debugPrint('✅ Solicitud aprobada por responsable. Turnos intercambiados');
      emit(const IntercambiosSuccess('Intercambio aprobado y ejecutado'));

      // Recargar lista
      add(const IntercambiosLoadRequested());
    } catch (e, stackTrace) {
      debugPrint('❌ Error al aprobar por responsable: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(IntercambiosError('Error al aprobar intercambio: $e'));
    }
  }

  Future<void> _onRechazarPorResponsableRequested(
    IntercambioRechazarPorResponsableRequested event,
    Emitter<IntercambiosState> emit,
  ) async {
    try {
      debugPrint('🚀 Rechazando solicitud por responsable...');
      emit(const IntercambiosProcessing());

      await _repository.rechazarPorResponsable(
        idSolicitud: event.idSolicitud,
        idResponsable: event.idResponsable,
        nombreResponsable: event.nombreResponsable,
        motivoRechazo: event.motivoRechazo,
      );

      debugPrint('✅ Solicitud rechazada por responsable');
      emit(const IntercambiosSuccess('Intercambio rechazado'));

      // Recargar lista
      add(const IntercambiosLoadRequested());
    } catch (e, stackTrace) {
      debugPrint('❌ Error al rechazar por responsable: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(IntercambiosError('Error al rechazar intercambio: $e'));
    }
  }

  Future<void> _onCancelarRequested(
    IntercambioCancelarRequested event,
    Emitter<IntercambiosState> emit,
  ) async {
    try {
      debugPrint('🚀 Cancelando solicitud...');
      emit(const IntercambiosProcessing());

      await _repository.cancelar(event.idSolicitud);

      debugPrint('✅ Solicitud cancelada');
      emit(const IntercambiosSuccess('Solicitud cancelada'));

      // Recargar lista
      add(const IntercambiosLoadRequested());
    } catch (e, stackTrace) {
      debugPrint('❌ Error al cancelar solicitud: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(IntercambiosError('Error al cancelar solicitud: $e'));
    }
  }

  Future<void> _onRefreshRequested(
    IntercambiosRefreshRequested event,
    Emitter<IntercambiosState> emit,
  ) async {
    add(const IntercambiosLoadRequested());
  }
}
