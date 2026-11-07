import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/widgets/historial/registro_historial_tab.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/widgets/gestion/vacacion_gestion_columns.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/widgets/gestion/vacacion_historial_tab.dart';
import 'package:flutter/material.dart';

/// Ficha lateral de las vacaciones seleccionadas
class VacacionDetailPanel extends StatelessWidget {
  const VacacionDetailPanel({
    required this.vacacion,
    required this.todas,
    required this.personal,
    required this.onGestionar,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final VacacionesEntity? vacacion;

  /// Todas las vacaciones cargadas del año (para el historial del trabajador)
  final List<VacacionesEntity> todas;
  final Map<String, PersonalEntity> personal;
  final VoidCallback onGestionar;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final VacacionesEntity? v = vacacion;
    if (v == null) {
      return const GestionDetailEmpty(message: 'Selecciona unas vacaciones para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(v.id),
      title: vacacionNombre(personal, v.idPersonal),
      badges: <Widget>[
        VacacionEstadoDot(estado: v.estado),
        GestionDotLabel(label: '${v.diasSolicitados} días', color: AppColors.info),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(
          label: 'General',
          child: _VacacionGeneralTab(
            vacacion: v,
            personal: personal[v.idPersonal],
            aprobadoPor: vacacionAprobador(personal, v.aprobadoPor),
          ),
        ),
        GestionDetailTab(
          label: 'Historial',
          child: VacacionHistorialTab(vacacion: v, todas: todas),
        ),
        GestionDetailTab(label: 'Cambios', child: RegistroHistorialTab(tabla: 'vacaciones', registroId: v.id)),
      ],
      actions: <Widget>[
        _PanelButton(
          label: 'Gestionar',
          icon: Icons.fact_check_outlined,
          color: AppColors.secondary,
          onPressed: onGestionar,
        ),
        _PanelButton(label: 'Editar', icon: Icons.edit_outlined, color: AppColors.primary, onPressed: onEdit),
        _PanelButton(
          label: 'Eliminar',
          icon: Icons.delete_outline,
          color: AppColors.error,
          onPressed: onDelete,
        ),
      ],
    );
  }
}

class _PanelButton extends StatelessWidget {
  const _PanelButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _VacacionGeneralTab extends StatelessWidget {
  const _VacacionGeneralTab({required this.vacacion, required this.personal, required this.aprobadoPor});

  final VacacionesEntity vacacion;
  final PersonalEntity? personal;
  final String? aprobadoPor;

  @override
  Widget build(BuildContext context) {
    final VacacionesEntity v = vacacion;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Personal'),
        GestionDetailField(label: 'Nombre', value: personal?.nombreCompleto),
        GestionDetailField(label: 'DNI', value: personal?.dni),
        GestionDetailField(label: 'Categoría', value: personal?.categoria),
        const GestionDetailSection(title: 'Periodo'),
        GestionDetailField(label: 'Inicio', value: GestionFormatters.fecha(v.fechaInicio)),
        GestionDetailField(label: 'Fin', value: GestionFormatters.fecha(v.fechaFin)),
        GestionDetailField(label: 'Días', value: '${v.diasSolicitados}'),
        const GestionDetailSection(title: 'Solicitud'),
        GestionDetailField(label: 'Estado', child: VacacionEstadoDot(estado: v.estado)),
        GestionDetailField(
          label: 'Solicitada',
          value: v.fechaSolicitud == null ? null : GestionFormatters.fecha(v.fechaSolicitud),
        ),
        GestionDetailField(label: 'Aprobado por', value: aprobadoPor),
        GestionDetailField(
          label: 'Fecha aprob.',
          value: v.fechaAprobacion == null ? null : GestionFormatters.fecha(v.fechaAprobacion),
        ),
        GestionDetailField(label: 'Documento', value: v.documentoAdjunto),
        const GestionDetailSection(title: 'Observaciones'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            GestionFormatters.texto(v.observaciones),
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: v.observaciones?.trim().isNotEmpty ?? false ? AppColors.gray800 : AppColors.gray300,
            ),
          ),
        ),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Activo', value: v.activo ? 'Sí' : 'No'),
        GestionDetailField(
          label: 'Alta',
          value: v.createdAt == null ? null : GestionFormatters.fecha(v.createdAt),
        ),
        GestionDetailField(
          label: 'Modificado',
          value: v.updatedAt == null ? null : GestionFormatters.fecha(v.updatedAt),
        ),
      ],
    );
  }
}
