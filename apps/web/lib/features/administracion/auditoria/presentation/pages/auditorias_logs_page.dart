import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion_frame/gestion_frame.dart';
import 'package:ambutrack_web/features/administracion/shared/admin_pending_state.dart';
import 'package:flutter/material.dart';

/// Auditorías y Logs.
///
/// No existe todavía una tabla de auditoría general en la BD; la pantalla
/// muestra un estado vacío explicando la propuesta
/// (`docs/plans/administracion_auditoria.md`).
class AuditoriasLogsPage extends StatelessWidget {
  const AuditoriasLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: GestionFrame(
          toolbar: GestionToolbar(
            title: 'Auditorías y Logs',
            icon: Icons.manage_search,
            groups: <List<GestionToolbarAction>>[],
            trailing: GestionToolbarBadge(
              label: 'Pendiente de implantar',
              color: AppColors.info,
              icon: Icons.schedule,
            ),
          ),
          content: AdminPendingState(
            icon: Icons.manage_search,
            title: 'Registro de auditoría pendiente',
            message: 'La base de datos todavía no dispone de una tabla de auditoría general '
                '(quién cambió qué, cuándo y en qué tabla). Cuando se implante, aquí podrás '
                'filtrar la actividad por usuario, tabla, acción y rango de fechas.',
            itemsTitle: 'Registros de actividad que ya existen (solo traslados)',
            items: <AdminPendingItem>[
              AdminPendingItem(
                icon: Icons.history,
                title: 'historial_estados_traslado',
                detail: 'Cambios de estado de cada traslado. Visible en el detalle del servicio.',
              ),
              AdminPendingItem(
                icon: Icons.swap_horiz,
                title: 'traslados_eventos (event ledger)',
                detail: 'Asignaciones, desasignaciones y cambios de estado de conductor '
                    'con el usuario que los realizó.',
              ),
              AdminPendingItem(
                icon: Icons.fact_check_outlined,
                title: 'traslados_audit',
                detail: 'Cambios de campos críticos de traslados (definida en la app móvil).',
              ),
            ],
            planPath: 'docs/plans/administracion_auditoria.md',
          ),
          statusBar: GestionStatusBar(
            items: <String>['Sin tabla de auditoría general', 'Propuesta: tabla audit_log + triggers'],
          ),
        ),
      ),
    );
  }
}
