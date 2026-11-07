import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/administracion/multicentro/domain/repositories/empresas_tenant_repository.dart';
import 'package:ambutrack_web/features/administracion/multicentro/presentation/bloc/multicentro_event.dart';
import 'package:ambutrack_web/features/administracion/multicentro/presentation/bloc/multicentro_state.dart';
import 'package:ambutrack_web/features/usuarios/domain/repositories/usuarios_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC de la vista Multi-centro / Multi-empresa (solo lectura)
@injectable
class MulticentroBloc extends Bloc<MulticentroEvent, MulticentroState> {
  MulticentroBloc(this._empresasRepository, this._usuariosRepository)
      : super(const MulticentroInitial()) {
    on<MulticentroLoadRequested>(_onLoadRequested);
  }

  final EmpresasTenantRepository _empresasRepository;
  final UsuariosRepository _usuariosRepository;

  Future<void> _onLoadRequested(
    MulticentroLoadRequested event,
    Emitter<MulticentroState> emit,
  ) async {
    emit(const MulticentroLoading());
    try {
      final List<Object> results = await Future.wait<Object>(<Future<Object>>[
        _empresasRepository.getAll(),
        _usuariosRepository.getAll(),
      ]);
      final List<EmpresaTenantEntity> empresas = results[0] as List<EmpresaTenantEntity>;
      final List<UserEntity> usuarios = results[1] as List<UserEntity>;
      debugPrint('✅ MulticentroBloc: ${empresas.length} empresas, ${usuarios.length} usuarios');
      emit(MulticentroLoaded(empresas: empresas, usuarios: usuarios));
    } catch (e) {
      debugPrint('❌ MulticentroBloc Error: $e');
      emit(MulticentroError(message: e.toString()));
    }
  }
}
