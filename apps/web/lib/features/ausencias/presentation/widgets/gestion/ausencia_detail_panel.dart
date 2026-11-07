import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/widgets/historial/registro_historial_tab.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/gestion/ausencia_gestion_columns.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/gestion/ausencia_historial_tab.dart';
import 'package:flutter/material.dart';

/// Ficha lateral de la ausencia seleccionada
class AusenciaDetailPanel extends StatelessWidget {
  const AusenciaDetailPanel({
    required this.ausencia,
    required this.todas,
    required this.lookup,
    required this.onGestionar,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final AusenciaEntity? ausencia;

  /// Todas las ausencias cargadas (para el historial del trabajador)
  final List<AusenciaEntity> todas;
  final AusenciaLookup lookup;
  final VoidCallback onGestionar;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final AusenciaEntity? a = ausencia;
    if (a == null) {
      return const GestionDetailEmpty(message: 'Selecciona una ausencia para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(a.id),
      title: lookup.nombre(a.idPersonal),
      badges: <Widget>[
        AusenciaEstadoDot(estado: a.estado),
        GestionDotLabel(
          label: lookup.tipoNombre(a.idTipoAusencia),
          color: tipoAusenciaColor(lookup.tipo(a.idTipoAusencia)),
        ),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _AusenciaGeneralTab(ausencia: a, lookup: lookup)),
        GestionDetailTab(
          label: 'Historial',
          child: AusenciaHistorialTab(ausencia: a, todas: todas, lookup: lookup),
        ),
        GestionDetailTab(label: 'Cambios', child: RegistroHistorialTab(tabla: 'ausencias', registroId: a.id)),
      ],
      actions: <Widget>[
        _PanelButton(
          label: 'Gestionar',
          icon: Icons.fact_check_outlined,
          color: AppColors.secondary,
          onPressed: onGestionar,
        ),
        _PanelButton(
          label: 'Editar',
          icon: Icons.edit_outlined,
          color: AppColors.primary,
          onPressed: onEdit,
        ),
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

class _AusenciaGeneralTab extends StatelessWidget {
  const _AusenciaGeneralTab({required this.ausencia, required this.lookup});

  final AusenciaEntity ausencia;
  final AusenciaLookup lookup;

  @override
  Widget build(BuildContext context) {
    final AusenciaEntity a = ausencia;
    final TipoAusenciaEntity? tipo = lookup.tipo(a.idTipoAusencia);
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Ausencia'),
        GestionDetailField(label: 'Personal', value: lookup.nombre(a.idPersonal)),
        GestionDetailField(label: 'Tipo', value: tipo?.nombre),
        GestionDetailField(label: 'Inicio', value: GestionFormatters.fecha(a.fechaInicio)),
        GestionDetailField(label: 'Fin', value: GestionFormatters.fecha(a.fechaFin)),
        GestionDetailField(label: 'Días', value: '${a.diasAusencia}'),
        GestionDetailField(label: 'Motivo', value: a.motivo),
        const GestionDetailSection(title: 'Aprobación'),
        GestionDetailField(label: 'Estado', child: AusenciaEstadoDot(estado: a.estado)),
        GestionDetailField(
          label: 'Requiere aprob.',
          value: tipo == null ? null : (tipo.requiereAprobacion ? 'Sí' : 'No'),
        ),
        GestionDetailField(label: 'Aprobado por', value: lookup.aprobador(a.aprobadoPor)),
        GestionDetailField(
          label: 'Fecha aprob.',
          value: a.fechaAprobacion == null ? null : GestionFormatters.fecha(a.fechaAprobacion),
        ),
        const GestionDetailSection(title: 'Documentación'),
        GestionDetailField(
          label: 'Requiere doc.',
          value: tipo == null ? null : (tipo.requiereDocumento ? 'Sí' : 'No'),
        ),
        GestionDetailField(label: 'Documento', value: a.documentoAdjunto),
        const GestionDetailSection(title: 'Observaciones'),
        _ObservacionesText(text: a.observaciones),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Activo', value: a.activo ? 'Sí' : 'No'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(a.createdAt)),
        GestionDetailField(label: 'Modificado', value: GestionFormatters.fecha(a.updatedAt)),
      ],
    );
  }
}

class _ObservacionesText extends StatelessWidget {
  const _ObservacionesText({required this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        GestionFormatters.texto(text),
        style: TextStyle(
          fontSize: 12.5,
          height: 1.4,
          color: text?.trim().isNotEmpty ?? false ? AppColors.gray800 : AppColors.gray300,
        ),
      ),
    );
  }
}
