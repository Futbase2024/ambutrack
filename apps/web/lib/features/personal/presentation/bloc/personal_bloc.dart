import 'package:ambutrack_web/core/auth/enums/app_module.dart';
import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/auth/permissions/crud_permissions.dart';
import 'package:ambutrack_web/core/auth/services/role_service.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestionar el estado de personal
///
/// ⚠️ PERMISOS CRUD:
/// - Admin: CRUD completo
/// - Jefe Personal: Create, Read, Update (NO Delete)
/// - Jefe Tráfico, Coordinador, Administrativo: Solo Read
/// - Conductor/Sanitario: Read/Update solo sus propios datos
/// - Operador: Solo Read
@injectable
class PersonalBloc extends Bloc<PersonalEvent, PersonalState> {
  PersonalBloc(this._personalRepository, this._roleService)
      : super(const PersonalInitial()) {
    on<PersonalLoadRequested>(_onLoadRequested);
    on<PersonalRefreshRequested>(_onRefreshRequested);
    on<PersonalCreateRequested>(_onCreateRequested);
    on<PersonalUpdateRequested>(_onUpdateRequested);
    on<PersonalDeleteRequested>(_onDeleteRequested);
  }

  final PersonalRepository _personalRepository;
  final RoleService _roleService;

  Future<void> _onLoadRequested(
    PersonalLoadRequested event,
    Emitter<PersonalState> emit,
  ) async {
    final DateTime startTime = DateTime.now();
    debugPrint('👥 PersonalBloc: Iniciando carga de personal...');

    emit(const PersonalLoading());

    try {
      final List<PersonalEntity> personal = await _personalRepository.getAll();

      final Duration elapsed = DateTime.now().difference(startTime);
      debugPrint('⏱️ Tiempo de carga BLoC: ${elapsed.inMilliseconds}ms');

      emit(PersonalLoaded(
        personal: personal,
        total: personal.length,
        enServicio: 0,
        disponibles: 0,
        ausentes: 0,
      ));
    } on Exception catch (e) {
      emit(PersonalError(message: e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    PersonalRefreshRequested event,
    Emitter<PersonalState> emit,
  ) async {
    try {
      final List<PersonalEntity> personal = await _personalRepository.getAll();

      emit(PersonalLoaded(
        personal: personal,
        total: personal.length,
        enServicio: 0,
        disponibles: 0,
        ausentes: 0,
      ));
    } on Exception catch (e) {
      emit(PersonalError(message: e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    PersonalCreateRequested event,
    Emitter<PersonalState> emit,
  ) async {
    try {
      // ✅ VALIDAR PERMISOS: Solo Admin y Jefe Personal pueden crear
      final UserRole role = await _roleService.getCurrentUserRole();
      if (!CrudPermissions.canCreate(role, AppModule.personal)) {
        debugPrint('🚫 PersonalBloc: Usuario sin permisos para crear personal');
        emit(const PersonalError(
          message: 'No tienes permisos para crear personal.\n'
              'Solo usuarios con rol Administrador o Jefe de Personal pueden crear.',
        ));
        return;
      }

      final DateTime startTime = DateTime.now();
      debugPrint('⏱️ PersonalBloc: Iniciando creación de personal...');

      final DateTime t1 = DateTime.now();
      await _personalRepository.create(event.persona);
      debugPrint('⏱️ PersonalBloc: Create completado en ${DateTime.now().difference(t1).inMilliseconds}ms');

      final DateTime t2 = DateTime.now();
      final List<PersonalEntity> personal = await _personalRepository.getAll();
      debugPrint('⏱️ PersonalBloc: GetAll completado en ${DateTime.now().difference(t2).inMilliseconds}ms');

      emit(PersonalLoaded(
        personal: personal,
        total: personal.length,
        enServicio: 0,
        disponibles: 0,
        ausentes: 0,
      ));

      final Duration totalTime = DateTime.now().difference(startTime);
      debugPrint('⏱️ PersonalBloc: ✅ TOTAL creación: ${totalTime.inMilliseconds}ms');
    } on Exception catch (e) {
      debugPrint('❌ PersonalBloc: Error al crear personal - $e');
      emit(PersonalError(message: e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    PersonalUpdateRequested event,
    Emitter<PersonalState> emit,
  ) async {
    try {
      // ✅ VALIDAR PERMISOS: Admin, Jefe Personal, Conductor/Sanitario (sus datos)
      final UserRole role = await _roleService.getCurrentUserRole();
      if (!CrudPermissions.canUpdate(role, AppModule.personal)) {
        debugPrint('🚫 PersonalBloc: Usuario sin permisos para actualizar personal');
        emit(const PersonalError(
          message: 'No tienes permisos para actualizar personal.\n'
              'Solo usuarios autorizados pueden editar datos de personal.',
        ));
        return;
      }

      final DateTime startTime = DateTime.now();
      debugPrint('⏱️ PersonalBloc: Iniciando actualización de personal...');

      final DateTime t1 = DateTime.now();
      await _personalRepository.update(event.persona);
      debugPrint('⏱️ PersonalBloc: Update completado en ${DateTime.now().difference(t1).inMilliseconds}ms');

      final DateTime t2 = DateTime.now();
      final List<PersonalEntity> personal = await _personalRepository.getAll();
      debugPrint('⏱️ PersonalBloc: GetAll completado en ${DateTime.now().difference(t2).inMilliseconds}ms');

      emit(PersonalLoaded(
        personal: personal,
        total: personal.length,
        enServicio: 0,
        disponibles: 0,
        ausentes: 0,
      ));

      final Duration totalTime = DateTime.now().difference(startTime);
      debugPrint('⏱️ PersonalBloc: ✅ TOTAL actualización: ${totalTime.inMilliseconds}ms');
    } on Exception catch (e) {
      debugPrint('❌ PersonalBloc: Error al actualizar personal - $e');
      emit(PersonalError(message: e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    PersonalDeleteRequested event,
    Emitter<PersonalState> emit,
  ) async {
    // NO emitir PersonalLoading para evitar que se desmonte el widget
    // El loading se maneja en la UI con un diálogo

    try {
      // ✅ VALIDAR PERMISOS: Solo Admin puede eliminar personal
      final UserRole role = await _roleService.getCurrentUserRole();
      if (!CrudPermissions.canDelete(role, AppModule.personal)) {
        debugPrint('🚫 PersonalBloc: Usuario sin permisos para eliminar personal');
        emit(const PersonalError(
          message: 'No tienes permisos para eliminar personal.\n'
              'Solo usuarios con rol Administrador pueden eliminar personal.',
        ));
        return;
      }

      final DateTime startTime = DateTime.now();
      debugPrint('⏱️ PersonalBloc: Iniciando eliminación de personal...');

      final DateTime t1 = DateTime.now();
      await _personalRepository.delete(event.id);
      debugPrint('⏱️ PersonalBloc: Delete completado en ${DateTime.now().difference(t1).inMilliseconds}ms');

      final DateTime t2 = DateTime.now();
      final List<PersonalEntity> personal = await _personalRepository.getAll();
      debugPrint('⏱️ PersonalBloc: GetAll completado en ${DateTime.now().difference(t2).inMilliseconds}ms');

      emit(PersonalLoaded(
        personal: personal,
        total: personal.length,
        enServicio: 0,
        disponibles: 0,
        ausentes: 0,
      ));

      final Duration totalTime = DateTime.now().difference(startTime);
      debugPrint('⏱️ PersonalBloc: ✅ TOTAL eliminación: ${totalTime.inMilliseconds}ms');
    } on Exception catch (e) {
      debugPrint('❌ PersonalBloc: Error al eliminar personal - $e');
      emit(PersonalError(message: e.toString()));
    }
  }
}
