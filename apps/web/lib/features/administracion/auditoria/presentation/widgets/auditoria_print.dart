import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/bloc/auditoria_state.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/widgets/auditoria_helpers.dart';

/// Texto del rango de fechas aplicado
String auditoriaRangoTexto(AuditoriaFiltros f) {
  if (!f.tieneRango) {
    return 'Sin límite de fechas';
  }
  return 'Del ${GestionFormatters.fecha(f.desde)} al ${GestionFormatters.fecha(f.hasta)}';
}

/// Imprime el listado de registros visibles
Future<void> imprimirAuditoria({
  required List<AuditLogEntity> rows,
  required AuditoriaFiltros filtros,
}) {
  final List<String> partes = <String>[
    auditoriaRangoTexto(filtros),
    if (filtros.tabla != null) 'Tabla: ${auditoriaTablaLabel(filtros.tabla!)}',
    if (filtros.accion != null) 'Acción: ${auditoriaAccionLabel(filtros.accion!)}',
  ];
  return GestionPrint.listado(
    title: 'Auditoría de cambios',
    subtitle: partes.join('  ·  '),
    headers: const <String>['Fecha / hora', 'Usuario', 'Tabla', 'Acción', 'Registro', 'Campos modificados'],
    rows: rows
        .map(
          (AuditLogEntity e) => <String>[
            auditoriaFechaHora(e.createdAt),
            auditoriaUsuarioLabel(e),
            auditoriaTablaLabel(e.tabla),
            auditoriaAccionLabel(e.accion),
            auditoriaDescripcion(e),
            auditoriaCamposResumen(e, max: 6),
          ],
        )
        .toList(),
  );
}
