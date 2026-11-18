import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/auth/enums/app_module.dart';
import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/auth/permissions/crud_permissions.dart';
import 'package:ambutrack_web/core/auth/services/role_service.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/vehiculo_repository.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestionar el estado de vehículos
///
/// ⚠️ PERMISOS CRUD:
/// - Admin: CRUD completo
/// - Jefe Tráfico: Create, Read, Update (NO Delete)
/// - Gestor: Read, Update (mantenimiento)
/// - Técnico: Read, Update (solo mantenimiento)
/// - Coordinador, Administrativo: Solo Read
@injectable
class VehiculosBloc extends Bloc<VehiculosEvent, VehiculosState> {
  VehiculosBloc(this._vehiculoRepository, this._roleService)
      : super(const VehiculosInitial()) {
    on<VehiculosLoadRequested>(_onLoadRequested);
    on<VehiculosRefreshRequested>(_onRefreshRequested);
    on<VehiculosSubscribeRequested>(_onSubscribeRequested);
    on<VehiculosUpdated>(_onVehiculosUpdated);
    on<VehiculoCreateRequested>(_onVehiculoCreateRequested);
    on<VehiculoUpdateRequested>(_onVehiculoUpdateRequested);
    on<VehiculosBulkUpdateRequested>(_onBulkUpdateRequested);
    on<VehiculosSillaElectricaRequested>(_onSillaElectricaRequested);
    on<VehiculoDeleteRequested>(_onVehiculoDeleteRequested);
  }

  final VehiculoRepository _vehiculoRepository;
  final RoleService _roleService;
  StreamSubscription<List<VehiculoEntity>>? _vehiculosSubscription;

  Future<void> _onLoadRequested(
    VehiculosLoadRequested event,
    Emitter<VehiculosState> emit,
  ) async {
    final DateTime startTime = DateTime.now();
    debugPrint('🚗 VehiculosBloc: Iniciando carga de vehículos...');
    emit(const VehiculosLoading());

    try {
      debugPrint('🚗 VehiculosBloc: Llamando a repository.getAll()');
      final List<VehiculoEntity> vehiculos = await _vehiculoRepository.getAll();

      debugPrint('🚗 VehiculosBloc: ✅ Recibidos ${vehiculos.length} vehículos');
      // Mostrar solo primeros 3 vehículos para debug (optimización de rendimiento)
      if (vehiculos.length > 3) {
        for (int i = 0; i < 3; i++) {
          final VehiculoEntity v = vehiculos[i];
          debugPrint('   - ${v.matricula}: ${v.marca} ${v.modelo} (${v.estado})');
        }
        debugPrint('   ... y ${vehiculos.length - 3} vehículos más');
      } else {
        for (final VehiculoEntity v in vehiculos) {
          debugPrint('   - ${v.matricula}: ${v.marca} ${v.modelo} (${v.estado})');
        }
      }

      final Duration elapsed = DateTime.now().difference(startTime);
      debugPrint('⏱️ Tiempo de carga BLoC: ${elapsed.inMilliseconds}ms');
      debugPrint('🚗 VehiculosBloc: Emitiendo VehiculosLoaded con ${vehiculos.length} vehículos');

      emit(_loadedState(vehiculos));
    } on Exception catch (e) {
      debugPrint('❌ VehiculosBloc: ERROR - $e');
      emit(VehiculosError(message: e.toString()));
    } catch (e, stackTrace) {
      debugPrint('❌ VehiculosBloc: ERROR INESPERADO - $e');
      debugPrint('Stack trace: $stackTrace');
      emit(VehiculosError(message: e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    VehiculosRefreshRequested event,
    Emitter<VehiculosState> emit,
  ) async {
    try {
      final List<VehiculoEntity> vehiculos = await _vehiculoRepository.getAll();

      emit(_loadedState(vehiculos));
    } on Exception catch (e) {
      emit(VehiculosError(message: e.toString()));
    }
  }

  Future<void> _onSubscribeRequested(
    VehiculosSubscribeRequested event,
    Emitter<VehiculosState> emit,
  ) async {
    debugPrint('⚡ VehiculosBloc: Suscribiéndose a actualizaciones en tiempo real...');
    emit(const VehiculosLoading());

    try {
      // Cancelar suscripción previa si existe
      await _vehiculosSubscription?.cancel();

      debugPrint('⚡ VehiculosBloc: Llamando a repository.watchAll()');
      _vehiculosSubscription = _vehiculoRepository.watchAll().listen(
        (List<VehiculoEntity> vehiculos) {
          debugPrint('⚡ VehiculosBloc: ✅ Stream emitió ${vehiculos.length} vehículos');
          // Solo agregar evento si el BLoC no está cerrado
          if (!isClosed) {
            add(VehiculosUpdated(vehiculos));
          } else {
            debugPrint('⚠️ VehiculosBloc: BLoC cerrado, ignorando actualización del stream');
          }
        },
        onError: (Object error) {
          debugPrint('❌ VehiculosBloc: Error en stream - $error');
          if (!isClosed) {
            emit(VehiculosError(message: error.toString()));
          }
        },
      );
    } on Exception catch (e) {
      debugPrint('❌ VehiculosBloc: ERROR al suscribirse - $e');
      emit(VehiculosError(message: e.toString()));
    }
  }

  void _onVehiculosUpdated(
    VehiculosUpdated event,
    Emitter<VehiculosState> emit,
  ) {
    debugPrint('⚡ VehiculosBloc: Procesando actualización con ${event.vehiculos.length} vehículos');

    debugPrint('⚡ VehiculosBloc: Emitiendo VehiculosLoaded actualizado');
    emit(_loadedState(event.vehiculos));
  }

  /// Maneja la creación de un nuevo vehículo
  Future<void> _onVehiculoCreateRequested(
    VehiculoCreateRequested event,
    Emitter<VehiculosState> emit,
  ) async {
    try {
      debugPrint('🚗 VehiculosBloc: Creando nuevo vehículo (entity)...');

      await _vehiculoRepository.create(event.vehiculo);

      debugPrint('🚗 VehiculosBloc: ✅ Vehículo creado exitosamente');

      // Recargar la lista después de crear
      final List<VehiculoEntity> vehiculos = await _vehiculoRepository.getAll();

      emit(_loadedState(vehiculos));
    } on Exception catch (e) {
      debugPrint('❌ VehiculosBloc: Error al crear vehículo - $e');
      emit(VehiculosError(message: e.toString()));
    }
  }

  /// Maneja la actualización de un vehículo
  Future<void> _onVehiculoUpdateRequested(
    VehiculoUpdateRequested event,
    Emitter<VehiculosState> emit,
  ) async {
    try {
      // ✅ VALIDAR PERMISOS: Admin, Jefe Tráfico, Gestor, Técnico
      final UserRole role = await _roleService.getCurrentUserRole();
      if (!CrudPermissions.canUpdate(role, AppModule.vehiculos)) {
        debugPrint('🚫 VehiculosBloc: Usuario sin permisos para actualizar vehículos');
        emit(const VehiculosError(
          message: 'No tienes permisos para actualizar vehículos.\n'
              'Solo usuarios autorizados pueden editar vehículos.',
        ));
        return;
      }

      debugPrint('🚗 VehiculosBloc: Actualizando vehículo ${event.vehiculo.id}...');

      await _vehiculoRepository.update(event.vehiculo);

      debugPrint('🚗 VehiculosBloc: ✅ Vehículo actualizado exitosamente');

      // Recargar la lista después de actualizar
      final List<VehiculoEntity> vehiculos = await _vehiculoRepository.getAll();

      emit(_loadedState(vehiculos));
    } on Exception catch (e) {
      debugPrint('❌ VehiculosBloc: Error al actualizar vehículo - $e');
      emit(VehiculosError(message: e.toString()));
    }
  }

  /// Maneja la eliminación de un vehículo
  Future<void> _onVehiculoDeleteRequested(
    VehiculoDeleteRequested event,
    Emitter<VehiculosState> emit,
  ) async {
    try {
      // ✅ VALIDAR PERMISOS: Solo Admin puede eliminar vehículos
      final UserRole role = await _roleService.getCurrentUserRole();
      if (!CrudPermissions.canDelete(role, AppModule.vehiculos)) {
        debugPrint('🚫 VehiculosBloc: Usuario sin permisos para eliminar vehículos');
        emit(const VehiculosError(
          message: 'No tienes permisos para eliminar vehículos.\n'
              'Solo usuarios con rol Administrador pueden eliminar vehículos.',
        ));
        return;
      }

      debugPrint('🚗 VehiculosBloc: Eliminando vehículo ${event.vehiculoId}...');

      await _vehiculoRepository.delete(event.vehiculoId);

      debugPrint('🚗 VehiculosBloc: ✅ Vehículo eliminado exitosamente');

      // Recargar la lista después de eliminar
      final List<VehiculoEntity> vehiculos = await _vehiculoRepository.getAll();

      emit(_loadedState(vehiculos));
    } on Exception catch (e) {
      debugPrint('❌ VehiculosBloc: Error al eliminar vehículo - $e');
      emit(VehiculosError(message: e.toString()));
    }
  }

  /// Actualiza varios vehículos a la vez (edición en bloque desde la rejilla)
  Future<void> _onBulkUpdateRequested(
    VehiculosBulkUpdateRequested event,
    Emitter<VehiculosState> emit,
  ) async {
    try {
      final UserRole role = await _roleService.getCurrentUserRole();
      if (!CrudPermissions.canUpdate(role, AppModule.vehiculos)) {
        emit(const VehiculosError(message: 'No tienes permisos para actualizar vehículos.'));
        return;
      }
      debugPrint('🚗 VehiculosBloc: Actualizando ${event.vehiculos.length} vehículos en bloque...');
      await Future.wait(event.vehiculos.map(_vehiculoRepository.update));
      emit(_loadedState(await _vehiculoRepository.getAll()));
    } on Exception catch (e) {
      debugPrint('❌ VehiculosBloc: Error en la actualización en bloque - $e');
      emit(VehiculosError(message: e.toString()));
    }
  }

  /// Marca o quita la silla eléctrica (modifica el stock; la BD recalcula el campo)
  Future<void> _onSillaElectricaRequested(
    VehiculosSillaElectricaRequested event,
    Emitter<VehiculosState> emit,
  ) async {
    try {
      final UserRole role = await _roleService.getCurrentUserRole();
      if (!CrudPermissions.canUpdate(role, AppModule.vehiculos)) {
        emit(const VehiculosError(message: 'No tienes permisos para actualizar vehículos.'));
        return;
      }
      debugPrint('🚗 VehiculosBloc: Silla eléctrica=${event.tiene} en ${event.vehiculoIds.length} vehículos');
      await _vehiculoRepository.setSillaElectrica(event.vehiculoIds, tiene: event.tiene);
      emit(_loadedState(await _vehiculoRepository.getAll()));
    } on Exception catch (e) {
      debugPrint('❌ VehiculosBloc: Error al cambiar la silla eléctrica - $e');
      emit(VehiculosError(message: e.toString()));
    }
  }

  /// Estado cargado con las estadísticas calculadas
  static VehiculosLoaded _loadedState(List<VehiculoEntity> vehiculos) {
    bool enTaller(VehiculoEntity v) =>
        v.estado == VehiculoEstado.mantenimiento || v.estado == VehiculoEstado.reparacion;
    final int disponibles = vehiculos.where((VehiculoEntity v) => v.estado == VehiculoEstado.activo).length;
    return VehiculosLoaded(
      vehiculos: vehiculos,
      total: vehiculos.length,
      disponibles: disponibles,
      enServicio: disponibles,
      mantenimiento: vehiculos.where(enTaller).length,
    );
  }

  @override
  Future<void> close() {
    _vehiculosSubscription?.cancel();
    return super.close();
  }
}
