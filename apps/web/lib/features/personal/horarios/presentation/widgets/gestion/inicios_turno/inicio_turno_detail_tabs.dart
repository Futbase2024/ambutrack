import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/gestion/fichajes/fichajes_gestion_columns.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/gestion/inicios_turno/inicios_turno_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Pestaña General: turno, vehículo, ubicación y validación
class InicioTurnoGeneralTab extends StatelessWidget {
  const InicioTurnoGeneralTab({required this.inicio, super.key});

  final InicioTurnoEntity inicio;

  @override
  Widget build(BuildContext context) {
    final InicioTurnoEntity i = inicio;
    final bool hayCoords = i.latitud != null && i.longitud != null;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Inicio de turno'),
        GestionDetailField(label: 'Técnico', value: i.personalNombre),
        GestionDetailField(label: 'Fecha/Hora', value: inicioFechaHora(i)),
        GestionDetailField(label: 'Rol', value: i.rol?.label),
        GestionDetailField(label: 'Compañero', value: i.companeroNombre),
        GestionDetailField(label: 'Apto (declara)', value: i.declaracionAptitud ? 'Sí' : 'No'),
        GestionDetailField(label: 'Dispositivo', value: i.modoDispositivo),
        const GestionDetailSection(title: 'Vehículo'),
        GestionDetailField(label: 'Matrícula', value: i.vehiculoMatricula),
        GestionDetailField(label: 'Km inicial', value: i.kmInicial == null ? null : inicioKm(i.kmInicial)),
        GestionDetailField(label: 'Combustible', value: i.combustible?.label),
        GestionDetailField(label: 'Foto km', value: (i.fotoKmUrl?.isNotEmpty ?? false) ? 'Disponible' : null),
        const GestionDetailSection(title: 'Ubicación'),
        GestionDetailField(
          label: 'Situación',
          child: InicioFueraBaseBadge(fueraDeBase: i.fueraDeBase),
        ),
        GestionDetailField(
          label: 'Distancia base',
          value: i.distanciaBaseM == null ? null : inicioDistancia(i.distanciaBaseM),
        ),
        GestionDetailField(
          label: 'Coordenadas',
          value: hayCoords ? '${i.latitud!.toStringAsFixed(5)}, ${i.longitud!.toStringAsFixed(5)}' : null,
        ),
        GestionDetailField(label: 'Motivo fuera', value: i.motivoFueraBase),
        const GestionDetailSection(title: 'Validación'),
        GestionDetailField(
          label: 'Estado',
          child: InicioEstadoBadge(estado: i.estadoValidacion),
        ),
        GestionDetailField(label: 'Validado el', value: i.validadoAt == null ? null : fichajeFechaHora(i.validadoAt!)),
        GestionDetailField(label: 'Motivo rechazo', value: i.motivoRechazo),
      ],
    );
  }
}

/// Pestaña Checklist: puntos revisados con su resultado y observación
class InicioTurnoChecklistTab extends StatelessWidget {
  const InicioTurnoChecklistTab({required this.inicio, super.key});

  final InicioTurnoEntity inicio;

  @override
  Widget build(BuildContext context) {
    final List<ChecklistInicioItem> items = inicio.checklistItems;
    final int incidencias = items.where((ChecklistInicioItem c) => !c.correcto).length;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Resumen'),
        GestionDetailField(label: 'Puntos', value: '${items.length}'),
        GestionDetailField(
          label: 'Incidencias',
          child: InicioTurnoBadge(
            label: incidencias == 0 ? 'Sin incidencias' : '$incidencias con incidencia',
            color: incidencias == 0 ? AppColors.success : AppColors.warning,
          ),
        ),
        GestionDetailField(label: 'Apto (declara)', value: inicio.declaracionAptitud ? 'Sí' : 'No'),
        const GestionDetailSection(title: 'Puntos revisados'),
        if (items.isEmpty) const _EmptyText('Sin checklist registrado'),
        for (final ChecklistInicioItem item in items) _ChecklistRow(item: item),
      ],
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.item});

  final ChecklistInicioItem item;

  @override
  Widget build(BuildContext context) {
    final Color color = item.correcto ? AppColors.success : AppColors.warning;
    final String? obs = item.observacion?.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(item.correcto ? Icons.check_circle : Icons.error_outline, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.nombre,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.gray900),
                ),
                if (obs != null && obs.isNotEmpty)
                  Text(obs, style: const TextStyle(fontSize: 12, height: 1.3, color: AppColors.gray600)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InicioTurnoBadge(label: item.correcto ? 'Correcto' : 'Incidencia', color: color, inCell: false),
        ],
      ),
    );
  }
}

/// Pestaña Avisos: avisos generados y motivo fuera de base
class InicioTurnoAvisosTab extends StatelessWidget {
  const InicioTurnoAvisosTab({required this.inicio, super.key});

  final InicioTurnoEntity inicio;

  @override
  Widget build(BuildContext context) {
    final String? motivo = inicio.motivoFueraBase?.trim();
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Avisos'),
        if (inicio.avisos.isEmpty) const _EmptyText('Sin avisos'),
        for (final String aviso in inicio.avisos) _AvisoRow(texto: aviso),
        const GestionDetailSection(title: 'Fuera de base'),
        GestionDetailField(
          label: 'Situación',
          child: InicioFueraBaseBadge(fueraDeBase: inicio.fueraDeBase),
        ),
        GestionDetailField(
          label: 'Distancia',
          value: inicio.distanciaBaseM == null ? null : inicioDistancia(inicio.distanciaBaseM),
        ),
        if (motivo == null || motivo.isEmpty) const _EmptyText('Sin motivo indicado') else _AvisoRow(texto: motivo),
      ],
    );
  }
}

class _AvisoRow extends StatelessWidget {
  const _AvisoRow({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(texto, style: const TextStyle(fontSize: 12.5, height: 1.4, color: AppColors.gray800)),
          ),
        ],
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: const TextStyle(fontSize: 12.5, color: AppColors.gray300)),
    );
  }
}
