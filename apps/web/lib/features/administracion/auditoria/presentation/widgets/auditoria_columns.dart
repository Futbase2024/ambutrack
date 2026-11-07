import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/widgets/auditoria_helpers.dart';
import 'package:ambutrack_web/features/administracion/shared/admin_shared_widgets.dart';
import 'package:flutter/material.dart';

/// Indicador de la acción: Alta (verde), Modificación (azul), Baja (rojo)
class AuditoriaAccionDot extends StatelessWidget {
  const AuditoriaAccionDot({required this.accion, super.key});

  final String accion;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(
      label: auditoriaAccionLabel(accion),
      color: auditoriaAccionColor(accion),
    );
  }
}

/// Columnas de la rejilla de auditoría
final List<GestionColumn<AuditLogEntity>> auditoriaColumns = <GestionColumn<AuditLogEntity>>[
  GestionColumn<AuditLogEntity>(
    label: 'Fecha / hora',
    width: 150,
    sortValue: (AuditLogEntity e) => e.createdAt.millisecondsSinceEpoch,
    cell: (AuditLogEntity e) => AdminCellText(auditoriaFechaHora(e.createdAt)),
  ),
  GestionColumn<AuditLogEntity>(
    label: 'Usuario',
    flex: 2,
    sortValue: (AuditLogEntity e) => auditoriaUsuarioLabel(e).toLowerCase(),
    cell: (AuditLogEntity e) =>
        AdminCellText(auditoriaUsuarioLabel(e), muted: e.usuarioEmail == null),
  ),
  GestionColumn<AuditLogEntity>(
    label: 'Tabla',
    width: 170,
    sortValue: (AuditLogEntity e) => auditoriaTablaLabel(e.tabla).toLowerCase(),
    cell: (AuditLogEntity e) => AdminCellText(auditoriaTablaLabel(e.tabla)),
  ),
  GestionColumn<AuditLogEntity>(
    label: 'Acción',
    width: 120,
    sortValue: (AuditLogEntity e) => auditoriaAccionLabel(e.accion),
    cell: (AuditLogEntity e) => AuditoriaAccionDot(accion: e.accion),
  ),
  GestionColumn<AuditLogEntity>(
    label: 'Registro',
    flex: 3,
    sortValue: (AuditLogEntity e) => auditoriaDescripcion(e).toLowerCase(),
    cell: (AuditLogEntity e) => AdminCellText(auditoriaDescripcion(e), bold: true),
  ),
  GestionColumn<AuditLogEntity>(
    label: 'Campos modificados',
    flex: 3,
    cell: (AuditLogEntity e) => AdminCellText(auditoriaCamposResumen(e)),
  ),
];
