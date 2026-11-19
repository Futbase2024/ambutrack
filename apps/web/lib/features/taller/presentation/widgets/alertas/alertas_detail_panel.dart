import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/alerta_mantenimiento.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/alertas_mantenimiento_calculator.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/alertas/alertas_columns.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/consulta/taller_consulta_common.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/taller_gestion_common.dart';
import 'package:flutter/material.dart';

/// Ficha lateral de la alerta seleccionada con acción "Abrir"
class AlertasDetailPanel extends StatelessWidget {
  const AlertasDetailPanel({required this.alerta, required this.onAbrir, super.key});

  final AlertaMantenimiento? alerta;
  final ValueChanged<AlertaMantenimiento> onAbrir;

  @override
  Widget build(BuildContext context) {
    final AlertaMantenimiento? a = alerta;
    if (a == null) {
      return const GestionDetailEmpty(message: 'Selecciona una alerta para ver su detalle');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(a.id),
      title: a.vehiculoMatricula == null ? a.tipo.displayName : '${a.tipo.displayName} · ${a.vehiculoMatricula}',
      badges: <Widget>[
        GestionDotLabel(label: a.severidad.displayName, color: severidadAlertaColor(a.severidad)),
        GestionDotLabel(label: a.diasTexto, color: severidadAlertaColor(a.severidad)),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'Detalle', child: _DetalleTab(alerta: a)),
      ],
      actions: <Widget>[
        TallerDetailNavButton(
          label: 'Abrir ${a.tipo.pantalla}',
          tooltip: 'Ir a la pantalla de ${a.tipo.pantalla}',
          onPressed: () => onAbrir(a),
        ),
      ],
    );
  }
}

class _DetalleTab extends StatelessWidget {
  const _DetalleTab({required this.alerta});

  final AlertaMantenimiento alerta;

  @override
  Widget build(BuildContext context) {
    final AlertaMantenimiento a = alerta;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Alerta'),
        TallerDetailText(a.detalle),
        GestionDetailField(label: 'Tipo', value: a.tipo.displayName),
        GestionDetailField(label: 'Severidad', value: a.severidad.displayName),
        GestionDetailField(label: 'Vehículo', value: a.vehiculoMatricula),
        if (a.esPlazo) GestionDetailField(label: 'Fecha límite', value: GestionFormatters.fecha(a.fechaLimite)),
        GestionDetailField(label: a.esPlazo ? 'Plazo' : 'Tiempo', value: a.diasTexto),
        if (a.datos.isNotEmpty) ...<Widget>[
          const GestionDetailSection(title: 'Datos relacionados'),
          for (final MapEntry<String, String> e in a.datos.entries)
            GestionDetailField(label: e.key, value: e.value),
        ],
        const GestionDetailSection(title: 'Criterio'),
        TallerDetailText(_criterio(a)),
      ],
    );
  }

  String _criterio(AlertaMantenimiento a) {
    const int proximo = AlertasMantenimientoCalculator.diasProximo;
    const int urgente = AlertasMantenimientoCalculator.diasUrgente;
    const int espera = AlertasMantenimientoCalculator.diasEspera;
    const int critica = AlertasMantenimientoCalculator.diasEsperaCritica;
    return a.esPlazo
        ? 'Crítica si está vencida, aviso si vence en $urgente días o menos, '
            'informativa si vence en $proximo días o menos.'
        : 'Aviso a partir de $espera días, crítica a partir de $critica días.';
  }
}
