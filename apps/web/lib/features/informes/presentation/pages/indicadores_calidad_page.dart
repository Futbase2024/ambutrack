import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion_frame/gestion_frame_controls.dart';
import 'package:ambutrack_web/features/informes/domain/calidad_metricas.dart';
import 'package:ambutrack_web/features/informes/domain/informe_calculos.dart';
import 'package:ambutrack_web/features/informes/domain/informe_filtro.dart';
import 'package:ambutrack_web/features/informes/presentation/bloc/indicadores_calidad_bloc.dart';
import 'package:ambutrack_web/features/informes/presentation/bloc/informe_bloc.dart';
import 'package:ambutrack_web/features/informes/presentation/widgets/informe_bar_chart.dart';
import 'package:ambutrack_web/features/informes/presentation/widgets/informe_body.dart';
import 'package:ambutrack_web/features/informes/presentation/widgets/informe_scaffold.dart';
import 'package:ambutrack_web/features/informes/presentation/widgets/informe_tabla.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Informe de indicadores de calidad del servicio (por vehículo)
class IndicadoresCalidadPage extends StatelessWidget {
  const IndicadoresCalidadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<IndicadoresCalidadBloc>(
      create: (_) => getIt<IndicadoresCalidadBloc>()..add(const InformeRefreshRequested()),
      child: InformeScaffold<IndicadoresCalidadBloc, IndicadoresCalidadData>(
        title: 'Indicadores de Calidad',
        icon: Icons.trending_up,
        filtrosBuilder: _filtros,
        statusBuilder: (IndicadoresCalidadData d) => <String>[
          '${d.global.servicios} servicios analizados',
          '${d.global.retrasos.length} con llegada a origen registrada',
          'Tolerancia de puntualidad: $kToleranciaPuntualidad min',
        ],
        impresion: (IndicadoresCalidadData d) => informeImpresion(calidadColumnas, d.porVehiculo),
        contentBuilder: (IndicadoresCalidadData d) => _IndicadoresCalidadView(data: d),
      ),
    );
  }

  static List<Widget> _filtros(
    InformeFiltro filtro,
    IndicadoresCalidadData? data,
    ValueChanged<InformeFiltro> onChanged,
  ) {
    return <Widget>[
      GestionCompactDropdown<String>(
        label: 'Vehículo',
        width: 170,
        value: filtro.extra(IndicadoresCalidadBloc.kVehiculo),
        options: <String?, String>{
          null: 'Todos',
          for (final String v in data?.vehiculos ?? <String>[]) v: v,
        },
        onChanged: (String? v) => onChanged(filtro.conExtra(IndicadoresCalidadBloc.kVehiculo, v)),
      ),
    ];
  }
}

class _IndicadoresCalidadView extends StatelessWidget {
  const _IndicadoresCalidadView({required this.data});

  final IndicadoresCalidadData data;

  @override
  Widget build(BuildContext context) {
    return InformeBody(
      kpis: data.kpis,
      charts: <Widget>[
        InformeBarChart(
          title: 'Llegada a origen respecto a la hora programada',
          items: data.distribucionRetrasos,
          emptyMessage: 'No hay llegadas a origen registradas',
        ),
        InformeBarChart(
          title: 'Motivos de cancelación / no realización',
          items: data.motivosIncidencia,
          color: AppColors.warning,
          emptyMessage: 'Sin cancelaciones en el periodo',
        ),
      ],
      tablaTitulo: 'Indicadores por vehículo',
      tablaTrailing: '${data.porVehiculo.length} vehículos',
      tabla: InformeTabla<CalidadMetricas>(
        columnas: calidadColumnas,
        filas: data.porVehiculo,
        rowId: (CalidadMetricas m) => m.clave,
      ),
    );
  }
}

String _pct(double? v) => v == null ? '—' : '${InformeCalculos.decimal(v)} %';

String _min(List<int> muestras, double valor) => muestras.isEmpty ? '—' : '${InformeCalculos.entero(valor)} min';

/// Columnas de la tabla (y del PDF) de indicadores por vehículo
final List<InformeColumna<CalidadMetricas>> calidadColumnas = <InformeColumna<CalidadMetricas>>[
  InformeColumna<CalidadMetricas>(
    label: 'Vehículo',
    flex: 2,
    negrita: true,
    texto: (CalidadMetricas m) => m.clave,
    orden: (CalidadMetricas m) => m.clave,
  ),
  InformeColumna<CalidadMetricas>(
    label: 'Servicios',
    numerica: true,
    texto: (CalidadMetricas m) => InformeCalculos.entero(m.servicios),
    orden: (CalidadMetricas m) => m.servicios,
  ),
  InformeColumna<CalidadMetricas>(
    label: 'Finalizados',
    numerica: true,
    texto: (CalidadMetricas m) => InformeCalculos.entero(m.finalizados),
    orden: (CalidadMetricas m) => m.finalizados,
  ),
  InformeColumna<CalidadMetricas>(
    label: 'Cancel./No real.',
    numerica: true,
    texto: (CalidadMetricas m) => InformeCalculos.entero(m.cancelados + m.noRealizados),
    orden: (CalidadMetricas m) => m.cancelados + m.noRealizados,
  ),
  InformeColumna<CalidadMetricas>(
    label: '% Realización',
    numerica: true,
    texto: (CalidadMetricas m) => _pct(m.tasaRealizacion),
    orden: (CalidadMetricas m) => m.tasaRealizacion ?? -1,
  ),
  InformeColumna<CalidadMetricas>(
    label: '% Puntualidad',
    numerica: true,
    texto: (CalidadMetricas m) => _pct(m.tasaPuntualidad),
    orden: (CalidadMetricas m) => m.tasaPuntualidad ?? -1,
  ),
  InformeColumna<CalidadMetricas>(
    label: 'Retraso medio',
    numerica: true,
    texto: (CalidadMetricas m) => _min(m.retrasos, m.retrasoMedio),
    orden: (CalidadMetricas m) => m.retrasoMedio,
  ),
  InformeColumna<CalidadMetricas>(
    label: 'Aceptación media',
    numerica: true,
    texto: (CalidadMetricas m) => _min(m.aceptaciones, m.aceptacionMedia),
    orden: (CalidadMetricas m) => m.aceptacionMedia,
  ),
  InformeColumna<CalidadMetricas>(
    label: 'Duración media',
    numerica: true,
    texto: (CalidadMetricas m) => _min(m.duraciones, m.duracionMedia),
    orden: (CalidadMetricas m) => m.duracionMedia,
  ),
];
