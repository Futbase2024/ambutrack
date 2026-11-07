import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/widgets/auditoria_cambios_tab.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/widgets/auditoria_columns.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/widgets/auditoria_helpers.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del registro de auditoría seleccionado
class AuditoriaDetailPanel extends StatelessWidget {
  const AuditoriaDetailPanel({required this.registro, super.key});

  final AuditLogEntity? registro;

  @override
  Widget build(BuildContext context) {
    final AuditLogEntity? e = registro;
    if (e == null) {
      return const GestionDetailEmpty(message: 'Selecciona un registro para ver los cambios');
    }
    final int numCambios = auditoriaCambios(e).length;
    return GestionDetailPanel(
      key: ValueKey<int>(e.id),
      title: '${auditoriaTablaLabel(e.tabla)} · ${auditoriaDescripcion(e)}',
      badges: <Widget>[
        AuditoriaAccionDot(accion: e.accion),
        GestionDotLabel(label: auditoriaFechaHora(e.createdAt), color: AppColors.gray400),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'Cambios ($numCambios)', child: AuditoriaCambiosTab(registro: e)),
        GestionDetailTab(label: 'Datos', child: _AuditoriaDatosTab(registro: e)),
      ],
    );
  }
}

class _AuditoriaDatosTab extends StatelessWidget {
  const _AuditoriaDatosTab({required this.registro});

  final AuditLogEntity registro;

  @override
  Widget build(BuildContext context) {
    final AuditLogEntity e = registro;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Cambio'),
        GestionDetailField(label: 'Acción', child: AuditoriaAccionDot(accion: e.accion)),
        GestionDetailField(label: 'Fecha / hora', value: auditoriaFechaHora(e.createdAt)),
        GestionDetailField(
          label: 'Campos',
          value: e.camposModificados.isEmpty ? null : e.camposModificados.join(', '),
        ),
        const GestionDetailSection(title: 'Registro afectado'),
        GestionDetailField(label: 'Tabla', value: '${auditoriaTablaLabel(e.tabla)} (${e.tabla})'),
        GestionDetailField(label: 'Descripción', value: auditoriaDescripcion(e)),
        GestionDetailField(label: 'ID registro', child: _SelectableValue(e.registroId)),
        const GestionDetailSection(title: 'Usuario'),
        GestionDetailField(label: 'Email', value: auditoriaUsuarioLabel(e)),
        GestionDetailField(label: 'ID usuario', child: _SelectableValue(e.usuarioId)),
        const GestionDetailSection(title: 'Auditoría'),
        GestionDetailField(label: 'ID auditoría', value: '${e.id}'),
        GestionDetailField(label: 'Empresa', child: _SelectableValue(e.empresaId)),
      ],
    );
  }
}

/// Valor copiable (identificadores largos)
class _SelectableValue extends StatelessWidget {
  const _SelectableValue(this.value);

  final String? value;

  @override
  Widget build(BuildContext context) {
    final String text = GestionFormatters.texto(value);
    final bool empty = text == GestionFormatters.vacio;
    return SelectableText(
      text,
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        color: empty ? AppColors.gray300 : AppColors.gray900,
      ),
    );
  }
}
