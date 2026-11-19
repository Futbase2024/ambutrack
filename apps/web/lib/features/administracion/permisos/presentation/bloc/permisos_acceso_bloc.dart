import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/administracion/permisos/presentation/bloc/permisos_acceso_event.dart';
import 'package:ambutrack_web/features/administracion/permisos/presentation/bloc/permisos_acceso_state.dart';
import 'package:ambutrack_web/features/usuarios/domain/repositories/usuarios_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC de la vista de Permisos de Acceso.
///
/// La matriz Rol × Módulo es estática (definida en `RolePermissions` y
/// `CrudPermissions`); el BLoC solo carga los usuarios para mostrar
/// quién tiene cada rol.
@injectable
class PermisosAccesoBloc extends Bloc<PermisosAccesoEvent, PermisosAccesoState> {
  PermisosAccesoBloc(this._usuariosRepository) : super(const PermisosAccesoInitial()) {
    on<PermisosAccesoLoadRequested>(_onLoadRequested);
  }

  final UsuariosRepository _usuariosRepository;

  Future<void> _onLoadRequested(
    PermisosAccesoLoadRequested event,
    Emitter<PermisosAccesoState> emit,
  ) async {
    emit(const PermisosAccesoLoading());
    try {
      final List<UserEntity> usuarios = await _usuariosRepository.getAll();
      debugPrint('✅ PermisosAccesoBloc: ${usuarios.length} usuarios cargados');
      emit(PermisosAccesoLoaded(usuarios: usuarios));
    } catch (e) {
      debugPrint('❌ PermisosAccesoBloc Error: $e');
      emit(PermisosAccesoError(message: e.toString()));
    }
  }
}
