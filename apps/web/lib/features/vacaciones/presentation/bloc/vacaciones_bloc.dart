import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart' as core;
import 'package:ambutrack_web/features/notificaciones/domain/repositories/notificaciones_repository.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:ambutrack_web/features/vacaciones/domain/repositories/vacaciones_repository.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/bloc/vacaciones_event.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/bloc/vacaciones_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestión de Vacaciones
@injectable
class VacacionesBloc extends Bloc<VacacionesEvent, VacacionesState> {
  VacacionesBloc(
    this._repository,
    this._notificacionesRepository,
    this._personalRepository,
  ) : super(const VacacionesInitial()) {
    on<VacacionesLoadRequested>(_onLoadRequested);
    on<VacacionesLoadByYearRequested>(_onLoadByYearRequested);
    on<VacacionesCreateRequested>(_onCreateRequested);
    on<VacacionesUpdateRequested>(_onUpdateRequested);
    on<VacacionesDeleteRequested>(_onDeleteRequested);
    on<VacacionesFilterByPersonalRequested>(_onFilterByPersonalRequested);
    on<VacacionEliminarDiasParcialRequested>(_onEliminarDiasParcialRequested);
  }

  final VacacionesRepository _repository;
  final NotificacionesRepository _notificacionesRepository;
  final PersonalRepository _personalRepository;

  /// Maneja la carga de todas las vacaciones
  Future<void> _onLoadRequested(
    VacacionesLoadRequested event,
    Emitter<VacacionesState> emit,
  ) async {
    debugPrint('🏖️ VacacionesBloc: Cargando todas las vacaciones...');
    emit(const VacacionesLoading());

    try {
      final List<core.VacacionesEntity> vacaciones = await _repository.getAll();
      debugPrint('🏖️ VacacionesBloc: ✅ ${vacaciones.length} vacaciones cargadas');
      emit(VacacionesLoaded(vacaciones: vacaciones));
    } catch (e) {
      debugPrint('🏖️ VacacionesBloc: ❌ Error: $e');
      emit(VacacionesError(e.toString()));
    }
  }

  /// Maneja la carga de vacaciones por año
  Future<void> _onLoadByYearRequested(
    VacacionesLoadByYearRequested event,
    Emitter<VacacionesState> emit,
  ) async {
    debugPrint('🏖️ VacacionesBloc: Cargando vacaciones del año ${event.year}...');
    emit(const VacacionesLoading());

    try {
      final List<core.VacacionesEntity> allVacaciones = await _repository.getAll();
      final List<core.VacacionesEntity> vacaciones = allVacaciones.where((core.VacacionesEntity v) {
        return v.fechaInicio.year == event.year || v.fechaFin.year == event.year;
      }).toList();

      debugPrint(
        '🏖️ VacacionesBloc: ✅ ${vacaciones.length} vacaciones del año ${event.year} cargadas',
      );
      emit(VacacionesLoaded(vacaciones: vacaciones, year: event.year));
    } catch (e) {
      debugPrint('🏖️ VacacionesBloc: ❌ Error: $e');
      emit(VacacionesError(e.toString()));
    }
  }

  /// Maneja el filtrado por personal
  Future<void> _onFilterByPersonalRequested(
    VacacionesFilterByPersonalRequested event,
    Emitter<VacacionesState> emit,
  ) async {
    if (event.idPersonal == null) {
      add(const VacacionesLoadRequested());
      return;
    }

    debugPrint('🏖️ VacacionesBloc: Filtrando por personal ${event.idPersonal}...');
    emit(const VacacionesLoading());

    try {
      final List<core.VacacionesEntity> vacaciones =
          await _repository.getByPersonalId(event.idPersonal!);
      debugPrint('🏖️ VacacionesBloc: ✅ ${vacaciones.length} vacaciones del personal');
      emit(VacacionesLoaded(vacaciones: vacaciones));
    } catch (e) {
      debugPrint('🏖️ VacacionesBloc: ❌ Error: $e');
      emit(VacacionesError(e.toString()));
    }
  }

  /// Maneja la creación de una vacación
  Future<void> _onCreateRequested(
    VacacionesCreateRequested event,
    Emitter<VacacionesState> emit,
  ) async {
    debugPrint('🏖️ VacacionesBloc: Creando nueva vacación...');

    try {
      final core.VacacionesEntity createdVacacion = await _repository.create(event.vacacion);
      debugPrint('🏖️ VacacionesBloc: ✅ Vacación creada exitosamente');

      // Si la vacación está pendiente, notificar a los jefes de personal
      if (createdVacacion.estado == 'pendiente') {
        await _notificarNuevaVacacion(createdVacacion);
      }

      // Agregar la nueva vacación al estado actual sin recargar todo
      if (state is VacacionesLoaded) {
        final VacacionesLoaded currentState = state as VacacionesLoaded;
        final List<core.VacacionesEntity> updatedVacaciones = <core.VacacionesEntity>[
          ...currentState.vacaciones,
          createdVacacion,
        ];

        debugPrint('🏖️ VacacionesBloc: Agregando vacación al estado sin recargar desde BD');
        emit(VacacionesLoaded(
          vacaciones: updatedVacaciones,
          year: currentState.year,
        ));
      } else {
        // Si no hay estado cargado, recargar todo
        add(const VacacionesLoadRequested());
      }
    } catch (e) {
      debugPrint('🏖️ VacacionesBloc: ❌ Error al crear: $e');
      emit(VacacionesError(e.toString()));
    }
  }

  /// Notifica a los jefes de personal sobre una nueva solicitud de vacaciones
  Future<void> _notificarNuevaVacacion(core.VacacionesEntity vacacion) async {
    try {
      // Obtener datos del personal
      final PersonalEntity personal = await _personalRepository.getById(vacacion.idPersonal);

      final String nombrePersonal = '${personal.nombre} ${personal.apellidos ?? ''}'.trim();
      final String fechaInicioStr = '${vacacion.fechaInicio.day}/${vacacion.fechaInicio.month}/${vacacion.fechaInicio.year}';
      final String fechaFinStr = '${vacacion.fechaFin.day}/${vacacion.fechaFin.month}/${vacacion.fechaFin.year}';

      // Crear notificación para jefes de personal
      await _notificacionesRepository.notificarJefesPersonal(
        tipo: 'vacacion_solicitada',
        titulo: 'Nueva Solicitud de Vacaciones',
        mensaje: '$nombrePersonal ha solicitado ${vacacion.diasSolicitados} días de vacaciones ($fechaInicioStr - $fechaFinStr)',
        entidadTipo: 'vacacion',
        entidadId: vacacion.id,
        metadata: <String, dynamic>{
          'personal_id': vacacion.idPersonal,
          'personal_nombre': nombrePersonal,
          'fecha_inicio': vacacion.fechaInicio.toIso8601String(),
          'fecha_fin': vacacion.fechaFin.toIso8601String(),
          'dias': vacacion.diasSolicitados,
        },
      );

      debugPrint('🏖️ VacacionesBloc: ✅ Notificación enviada a jefes de personal');
    } catch (e) {
      debugPrint('🏖️ VacacionesBloc: ❌ Error al enviar notificación: $e');
      // No fallar el flujo principal si falla la notificación
    }
  }

  /// Maneja la actualización de una vacación
  Future<void> _onUpdateRequested(
    VacacionesUpdateRequested event,
    Emitter<VacacionesState> emit,
  ) async {
    debugPrint('🏖️ VacacionesBloc: Actualizando vacación ${event.vacacion.id}...');

    try {
      await _repository.update(event.vacacion);
      debugPrint('🏖️ VacacionesBloc: ✅ Vacación actualizada exitosamente');

      // Actualizar solo la vacación en el estado actual sin recargar todo
      if (state is VacacionesLoaded) {
        final VacacionesLoaded currentState = state as VacacionesLoaded;
        final List<core.VacacionesEntity> updatedVacaciones = currentState.vacaciones.map((core.VacacionesEntity v) {
          return v.id == event.vacacion.id ? event.vacacion : v;
        }).toList();

        debugPrint('🏖️ VacacionesBloc: Actualizando estado sin recargar desde BD');
        emit(VacacionesLoaded(
          vacaciones: updatedVacaciones,
          year: currentState.year,
        ));
      } else {
        // Si no hay estado cargado, recargar todo
        add(const VacacionesLoadRequested());
      }
    } catch (e) {
      debugPrint('🏖️ VacacionesBloc: ❌ Error al actualizar: $e');
      emit(VacacionesError(e.toString()));
    }
  }

  /// Maneja la eliminación de una vacación
  Future<void> _onDeleteRequested(
    VacacionesDeleteRequested event,
    Emitter<VacacionesState> emit,
  ) async {
    debugPrint('🏖️ VacacionesBloc: Eliminando vacación ${event.id}...');

    try {
      await _repository.delete(event.id);
      debugPrint('🏖️ VacacionesBloc: ✅ Vacación eliminada exitosamente');

      // Eliminar la vacación del estado actual sin recargar todo
      if (state is VacacionesLoaded) {
        final VacacionesLoaded currentState = state as VacacionesLoaded;
        final List<core.VacacionesEntity> updatedVacaciones = currentState.vacaciones
            .where((core.VacacionesEntity v) => v.id != event.id)
            .toList();

        debugPrint('🏖️ VacacionesBloc: Eliminando vacación del estado sin recargar desde BD');
        emit(VacacionesLoaded(
          vacaciones: updatedVacaciones,
          year: currentState.year,
        ));
      } else {
        // Si no hay estado cargado, recargar todo
        add(const VacacionesLoadRequested());
      }
    } catch (e) {
      debugPrint('🏖️ VacacionesBloc: ❌ Error al eliminar: $e');
      emit(VacacionesError(e.toString()));
    }
  }

  /// Maneja la eliminación parcial de días de una vacación
  ///
  /// Casos posibles:
  /// 1. Eliminar todo el rango → eliminar vacación completa
  /// 2. Eliminar desde el inicio → ajustar fechaInicio
  /// 3. Eliminar desde el final → ajustar fechaFin
  /// 4. Eliminar del medio → dividir en dos vacaciones
  Future<void> _onEliminarDiasParcialRequested(
    VacacionEliminarDiasParcialRequested event,
    Emitter<VacacionesState> emit,
  ) async {
    debugPrint('✂️ VacacionesBloc: Eliminando días parciales de vacación ${event.vacacion.id}');
    debugPrint('✂️ Rango a eliminar: ${event.fechaInicioEliminar} - ${event.fechaFinEliminar}');

    try {
      final core.VacacionesEntity vacacion = event.vacacion;
      final DateTime inicioEliminar = _normalizeDate(event.fechaInicioEliminar);
      final DateTime finEliminar = _normalizeDate(event.fechaFinEliminar);
      final DateTime inicioOriginal = _normalizeDate(vacacion.fechaInicio);
      final DateTime finOriginal = _normalizeDate(vacacion.fechaFin);

      // Caso 1: Se elimina todo el rango
      if (_isSameDay(inicioEliminar, inicioOriginal) &&
          _isSameDay(finEliminar, finOriginal)) {
        debugPrint('✂️ Caso 1: Eliminando vacación completa');
        add(VacacionesDeleteRequested(vacacion.id));
        return;
      }

      // Caso 2: Se elimina desde el inicio
      if (_isSameDay(inicioEliminar, inicioOriginal) &&
          finEliminar.isBefore(finOriginal)) {
        debugPrint('✂️ Caso 2: Eliminando desde el inicio');
        final DateTime nuevaFechaInicio = finEliminar.add(const Duration(days: 1));
        final int nuevosDias = finOriginal.difference(nuevaFechaInicio).inDays + 1;

        final core.VacacionesEntity vacacionActualizada = vacacion.copyWith(
          fechaInicio: nuevaFechaInicio,
          diasSolicitados: nuevosDias,
          updatedAt: DateTime.now(),
        );

        await _repository.update(vacacionActualizada);
        _actualizarEstadoOptimista(vacacionActualizada, emit);
        return;
      }

      // Caso 3: Se elimina desde el final
      if (inicioEliminar.isAfter(inicioOriginal) &&
          _isSameDay(finEliminar, finOriginal)) {
        debugPrint('✂️ Caso 3: Eliminando desde el final');
        final DateTime nuevaFechaFin = inicioEliminar.subtract(const Duration(days: 1));
        final int nuevosDias = nuevaFechaFin.difference(inicioOriginal).inDays + 1;

        final core.VacacionesEntity vacacionActualizada = vacacion.copyWith(
          fechaFin: nuevaFechaFin,
          diasSolicitados: nuevosDias,
          updatedAt: DateTime.now(),
        );

        await _repository.update(vacacionActualizada);
        _actualizarEstadoOptimista(vacacionActualizada, emit);
        return;
      }

      // Caso 4: Se elimina del medio → dividir en dos vacaciones
      if (inicioEliminar.isAfter(inicioOriginal) &&
          finEliminar.isBefore(finOriginal)) {
        debugPrint('✂️ Caso 4: Eliminando del medio, dividiendo vacación');

        // Primera parte: desde inicio original hasta día antes de eliminar
        final DateTime nuevaFechaFin1 = inicioEliminar.subtract(const Duration(days: 1));
        final int nuevosDias1 = nuevaFechaFin1.difference(inicioOriginal).inDays + 1;

        final core.VacacionesEntity vacacionActualizada = vacacion.copyWith(
          fechaFin: nuevaFechaFin1,
          diasSolicitados: nuevosDias1,
          updatedAt: DateTime.now(),
        );

        // Segunda parte: desde día después de eliminar hasta fin original
        final DateTime nuevaFechaInicio2 = finEliminar.add(const Duration(days: 1));
        final int nuevosDias2 = finOriginal.difference(nuevaFechaInicio2).inDays + 1;

        final core.VacacionesEntity nuevaVacacion = core.VacacionesEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          idPersonal: vacacion.idPersonal,
          fechaInicio: nuevaFechaInicio2,
          fechaFin: finOriginal,
          diasSolicitados: nuevosDias2,
          estado: vacacion.estado,
          observaciones: vacacion.observaciones,
          documentoAdjunto: vacacion.documentoAdjunto,
          fechaSolicitud: vacacion.fechaSolicitud,
          aprobadoPor: vacacion.aprobadoPor,
          fechaAprobacion: vacacion.fechaAprobacion,
          activo: vacacion.activo,
          createdAt: DateTime.now(),
        );

        // Actualizar primera vacación y crear segunda
        await _repository.update(vacacionActualizada);
        await _repository.create(nuevaVacacion);

        // Actualizar estado con ambas vacaciones
        if (state is VacacionesLoaded) {
          final VacacionesLoaded currentState = state as VacacionesLoaded;
          final List<core.VacacionesEntity> updatedVacaciones =
              currentState.vacaciones.map((core.VacacionesEntity v) {
            return v.id == vacacion.id ? vacacionActualizada : v;
          }).toList()
                ..add(nuevaVacacion);

          debugPrint('✂️ VacacionesBloc: ✅ Vacación dividida exitosamente');
          emit(VacacionesLoaded(
            vacaciones: updatedVacaciones,
            year: currentState.year,
          ));
        }
      }
    } catch (e) {
      debugPrint('✂️ VacacionesBloc: ❌ Error al eliminar días: $e');
      emit(VacacionesError('Error al eliminar días: $e'));
    }
  }

  /// Normaliza una fecha a medianoche (00:00:00)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Compara si dos fechas son el mismo día
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Actualiza el estado de forma optimista con una vacación actualizada
  void _actualizarEstadoOptimista(
    core.VacacionesEntity vacacionActualizada,
    Emitter<VacacionesState> emit,
  ) {
    if (state is VacacionesLoaded) {
      final VacacionesLoaded currentState = state as VacacionesLoaded;
      final List<core.VacacionesEntity> updatedVacaciones =
          currentState.vacaciones.map((core.VacacionesEntity v) {
        return v.id == vacacionActualizada.id ? vacacionActualizada : v;
      }).toList();

      debugPrint('✂️ VacacionesBloc: ✅ Vacación actualizada exitosamente');
      emit(VacacionesLoaded(
        vacaciones: updatedVacaciones,
        year: currentState.year,
      ));
    }
  }
}
