import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/auth/services/role_service.dart';
import 'package:ambutrack_web/features/administracion/auditoria/domain/repositories/audit_log_repository.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/bloc/auditoria_event.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/bloc/auditoria_state.dart';
import 'package:ambutrack_web/features/usuarios/domain/repositories/usuarios_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC del visor de auditoría (tabla `audit_log`, solo lectura).
///
/// Carga paginada en servidor por bloques de [pageSize] con filtros de servidor.
@injectable
class AuditoriaBloc extends Bloc<AuditoriaEvent, AuditoriaState> {
  AuditoriaBloc(this._repository, this._usuariosRepository, this._roleService)
      : super(AuditoriaState(filtros: AuditoriaFiltros.inicial())) {
    on<AuditoriaLoadRequested>(_onLoadRequested);
    on<AuditoriaFiltrosChanged>(_onFiltrosChanged);
    on<AuditoriaLoadMoreRequested>(_onLoadMoreRequested);
  }

  /// Registros por bloque
  static const int pageSize = 200;

  final AuditLogRepository _repository;
  final UsuariosRepository _usuariosRepository;
  final RoleService _roleService;

  Future<void> _onLoadRequested(AuditoriaLoadRequested event, Emitter<AuditoriaState> emit) {
    return _cargar(emit, state.filtros);
  }

  Future<void> _onFiltrosChanged(AuditoriaFiltrosChanged event, Emitter<AuditoriaState> emit) {
    return _cargar(emit, event.filtros);
  }

  Future<void> _cargar(Emitter<AuditoriaState> emit, AuditoriaFiltros filtros) async {
    emit(state.copyWith(status: AuditoriaStatus.loading, filtros: filtros, errorMessage: () => null));
    try {
      final bool esAdmin = _roleService.getCurrentUserRoleSync().isAdmin;
      final List<Object?> results = await Future.wait<Object?>(<Future<Object?>>[
        _buscar(filtros, 0),
        _contar(filtros),
        _cargarUsuarios(),
      ]);
      final List<AuditLogEntity> registros = results[0]! as List<AuditLogEntity>;
      final int? total = results[1] as int?;
      final List<UserEntity> usuarios = results[2]! as List<UserEntity>;
      debugPrint('✅ AuditoriaBloc: ${registros.length} registros (total ${total ?? '?'})');
      emit(state.copyWith(
        status: AuditoriaStatus.loaded,
        registros: registros,
        total: () => total,
        hasMore: _hayMas(registros.length, registros.length, total),
        usuarios: usuarios,
        esAdmin: esAdmin,
      ));
    } catch (e) {
      debugPrint('❌ AuditoriaBloc Error: $e');
      emit(state.copyWith(status: AuditoriaStatus.error, errorMessage: e.toString));
    }
  }

  Future<void> _onLoadMoreRequested(
    AuditoriaLoadMoreRequested event,
    Emitter<AuditoriaState> emit,
  ) async {
    if (!state.hasMore || state.status != AuditoriaStatus.loaded) {
      return;
    }
    emit(state.copyWith(status: AuditoriaStatus.loadingMore));
    try {
      final List<AuditLogEntity> nuevos = await _buscar(state.filtros, state.registros.length);
      final List<AuditLogEntity> todos = <AuditLogEntity>[...state.registros, ...nuevos];
      debugPrint('✅ AuditoriaBloc: +${nuevos.length} registros (${todos.length} cargados)');
      emit(state.copyWith(
        status: AuditoriaStatus.loaded,
        registros: todos,
        hasMore: _hayMas(nuevos.length, todos.length, state.total),
      ));
    } catch (e) {
      debugPrint('❌ AuditoriaBloc Error al cargar más: $e');
      emit(state.copyWith(status: AuditoriaStatus.loaded, errorMessage: e.toString));
    }
  }

  Future<List<AuditLogEntity>> _buscar(AuditoriaFiltros f, int offset) {
    return _repository.search(
      tabla: f.tabla,
      accion: f.accion,
      usuarioId: f.usuarioId,
      desde: f.desde,
      hasta: f.hastaExclusivo,
      offset: offset,
    );
  }

  /// El recuento es informativo: si falla no bloquea la carga
  Future<int?> _contar(AuditoriaFiltros f) async {
    try {
      return await _repository.count(
        tabla: f.tabla,
        accion: f.accion,
        usuarioId: f.usuarioId,
        desde: f.desde,
        hasta: f.hastaExclusivo,
      );
    } catch (e) {
      debugPrint('⚠️ AuditoriaBloc: no se pudo contar la auditoría: $e');
      return null;
    }
  }

  /// Los usuarios solo alimentan el filtro: se cargan una vez y sin bloquear
  Future<List<UserEntity>> _cargarUsuarios() async {
    if (state.usuarios.isNotEmpty) {
      return state.usuarios;
    }
    try {
      return await _usuariosRepository.getAll();
    } catch (e) {
      debugPrint('⚠️ AuditoriaBloc: no se pudieron cargar usuarios: $e');
      return const <UserEntity>[];
    }
  }

  static bool _hayMas(int recibidos, int cargados, int? total) {
    if (total != null) {
      return cargados < total;
    }
    return recibidos == pageSize;
  }
}
