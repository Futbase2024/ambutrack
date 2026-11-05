import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Filtros que se aplican en servidor
class AuditoriaFiltros extends Equatable {
  const AuditoriaFiltros({
    this.tabla,
    this.accion,
    this.usuarioId,
    this.desde,
    this.hasta,
  });

  /// Por defecto: últimos 7 días (hoy incluido)
  factory AuditoriaFiltros.inicial() {
    final DateTime now = DateTime.now();
    final DateTime hoy = DateTime(now.year, now.month, now.day);
    return AuditoriaFiltros(desde: hoy.subtract(const Duration(days: 6)), hasta: hoy);
  }

  final String? tabla;

  /// `INSERT` | `UPDATE` | `DELETE`
  final String? accion;
  final String? usuarioId;

  /// Primer día del rango (local, incluido)
  final DateTime? desde;

  /// Último día del rango (local, incluido)
  final DateTime? hasta;

  /// Instante final exclusivo para la consulta (día siguiente a [hasta])
  DateTime? get hastaExclusivo {
    final DateTime? h = hasta;
    return h == null ? null : DateTime(h.year, h.month, h.day + 1);
  }

  bool get tieneRango => desde != null || hasta != null;

  @override
  List<Object?> get props => <Object?>[tabla, accion, usuarioId, desde, hasta];
}

enum AuditoriaStatus { initial, loading, loaded, loadingMore, error }

/// Estado único del AuditoriaBloc
class AuditoriaState extends Equatable {
  const AuditoriaState({
    required this.filtros,
    this.status = AuditoriaStatus.initial,
    this.registros = const <AuditLogEntity>[],
    this.total,
    this.hasMore = false,
    this.usuarios = const <UserEntity>[],
    this.esAdmin = true,
    this.errorMessage,
  });

  final AuditoriaStatus status;
  final AuditoriaFiltros filtros;
  final List<AuditLogEntity> registros;

  /// Total en servidor con los filtros actuales (null si no se pudo contar)
  final int? total;
  final bool hasMore;

  /// Usuarios de la empresa (para el filtro "Usuario")
  final List<UserEntity> usuarios;

  /// Rol del usuario actual (la RLS solo devuelve filas a administradores)
  final bool esAdmin;
  final String? errorMessage;

  bool get isLoading => status == AuditoriaStatus.loading || status == AuditoriaStatus.initial;
  bool get isLoadingMore => status == AuditoriaStatus.loadingMore;

  AuditoriaState copyWith({
    AuditoriaStatus? status,
    AuditoriaFiltros? filtros,
    List<AuditLogEntity>? registros,
    int? Function()? total,
    bool? hasMore,
    List<UserEntity>? usuarios,
    bool? esAdmin,
    String? Function()? errorMessage,
  }) {
    return AuditoriaState(
      status: status ?? this.status,
      filtros: filtros ?? this.filtros,
      registros: registros ?? this.registros,
      total: total != null ? total() : this.total,
      hasMore: hasMore ?? this.hasMore,
      usuarios: usuarios ?? this.usuarios,
      esAdmin: esAdmin ?? this.esAdmin,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      <Object?>[status, filtros, registros, total, hasMore, usuarios, esAdmin, errorMessage];
}
