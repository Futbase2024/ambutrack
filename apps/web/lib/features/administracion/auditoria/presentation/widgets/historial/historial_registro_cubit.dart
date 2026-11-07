import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/administracion/auditoria/domain/repositories/audit_log_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Estado del historial de cambios de un registro
class HistorialRegistroState extends Equatable {
  const HistorialRegistroState({this.cargando = true, this.cambios = const <AuditLogEntity>[], this.error});

  final bool cargando;
  final List<AuditLogEntity> cambios;
  final String? error;

  @override
  List<Object?> get props => <Object?>[cargando, cambios, error];
}

/// Carga el historial (audit_log) de un registro concreto
class HistorialRegistroCubit extends Cubit<HistorialRegistroState> {
  HistorialRegistroCubit(this._repository, {required this.tabla, required this.registroId})
      : super(const HistorialRegistroState());

  final AuditLogRepository _repository;
  final String tabla;
  final String registroId;

  Future<void> cargar() async {
    emit(const HistorialRegistroState());
    try {
      final List<AuditLogEntity> cambios = await _repository.getByRegistro(tabla: tabla, registroId: registroId);
      if (!isClosed) {
        emit(HistorialRegistroState(cargando: false, cambios: cambios));
      }
    } catch (e) {
      debugPrint('❌ HistorialRegistroCubit: $e');
      if (!isClosed) {
        emit(HistorialRegistroState(cargando: false, error: e.toString()));
      }
    }
  }
}
