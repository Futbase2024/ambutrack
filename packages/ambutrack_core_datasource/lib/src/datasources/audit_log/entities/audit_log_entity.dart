import 'package:equatable/equatable.dart';

/// Entity: Registro de la tabla `audit_log` (auditoría general de cambios).
///
/// Lo escribe el trigger `fn_audit_row`; la app solo lo consulta.
class AuditLogEntity extends Equatable {
  const AuditLogEntity({
    required this.id,
    required this.tabla,
    required this.accion,
    required this.createdAt,
    this.empresaId,
    this.registroId,
    this.usuarioId,
    this.usuarioEmail,
    this.datosAntes,
    this.datosDespues,
    this.camposModificados = const <String>[],
  });

  final int id;
  final String? empresaId;

  /// Tabla auditada (`tvehiculos`, `usuarios`, ...)
  final String tabla;

  /// Clave primaria del registro afectado (como texto)
  final String? registroId;

  /// `INSERT` | `UPDATE` | `DELETE`
  final String accion;

  /// Usuario que hizo el cambio (null si fue un proceso del sistema)
  final String? usuarioId;
  final String? usuarioEmail;

  /// Fila antes del cambio (UPDATE / DELETE)
  final Map<String, dynamic>? datosAntes;

  /// Fila después del cambio (INSERT / UPDATE)
  final Map<String, dynamic>? datosDespues;

  /// Columnas que cambiaron (solo UPDATE)
  final List<String> camposModificados;
  final DateTime createdAt;

  bool get esAlta => accion == 'INSERT';
  bool get esModificacion => accion == 'UPDATE';
  bool get esBaja => accion == 'DELETE';

  /// Datos más representativos del registro (después, o antes si fue baja)
  Map<String, dynamic> get datos => datosDespues ?? datosAntes ?? const <String, dynamic>{};

  @override
  List<Object?> get props => <Object?>[
        id,
        empresaId,
        tabla,
        registroId,
        accion,
        usuarioId,
        usuarioEmail,
        datosAntes,
        datosDespues,
        camposModificados,
        createdAt,
      ];
}
