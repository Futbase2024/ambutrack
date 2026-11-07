import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_formatters.dart';
import 'package:ambutrack_web/core/widgets/gestion_frame/gestion_frame_controls.dart';
import 'package:ambutrack_web/features/informes/domain/flota_informe_models.dart';
import 'package:ambutrack_web/features/informes/domain/informe_calculos.dart';
import 'package:ambutrack_web/features/informes/domain/informe_filtro.dart';
import 'package:ambutrack_web/features/informes/presentation/bloc/flota_informe_bloc.dart';
import 'package:ambutrack_web/features/informes/presentation/bloc/informe_bloc.dart';
import 'package:ambutrack_web/features/informes/presentation/widgets/informe_bar_chart.dart';
import 'package:ambutrack_web/features/informes/presentation/widgets/informe_body.dart';
import 'package:ambutrack_web/features/informes/presentation/widgets/informe_scaffold.dart';
import 'package:ambutrack_web/features/informes/presentation/widgets/informe_tabla.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Informe de estadísticas de uso de la flota
class FlotaInformePage extends StatelessWidget {
  const FlotaInformePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FlotaInformeBloc>(
      create: (_) => getIt<FlotaInformeBloc>()..add(const InformeRefreshRequested()),
      child: InformeScaffold<FlotaInformeBloc, FlotaInformeData>(
        title: 'Estadísticas de Flota',
        icon: Icons.local_shipping_outlined,
        filtrosBuilder: _filtros,
        statusBuilder: (FlotaInformeData d) => <String>[
          '${d.filas.length} vehículos',
          'Consumo según repostajes del periodo',
        ],
        impresion: (FlotaInformeData d) => informeImpresion(flotaColumnas, d.filas),
        contentBuilder: (FlotaInformeData d) => _FlotaInformeView(data: d),
      ),
    );
  }

  static List<Widget> _filtros(
    InformeFiltro filtro,
    FlotaInformeData? data,
    ValueChanged<InformeFiltro> onChanged,
  ) {
    return <Widget>[
      GestionCompactDropdown<String>(
        label: 'Categoría',
        width: 180,
        value: filtro.extra(FlotaInformeBloc.kCategoria),
        options: <String?, String>{
          null: 'Todas',
          for (final String c in data?.categorias ?? <String>[]) c: c,
        },
        onChanged: (String? v) => onChanged(filtro.conExtra(FlotaInformeBloc.kCategoria, v)),
      ),
      GestionCompactDropdown<String>(
        label: 'Estado',
        width: 160,
        value: filtro.extra(FlotaInformeBloc.kEstado),
        options: <String?, String>{
          null: 'Todos',
          for (final VehiculoEstado e in VehiculoEstado.values) e.name: vehiculoEstadoLabel(e),
        },
        onChanged: (String? v) => onChanged(filtro.conExtra(FlotaInformeBloc.kEstado, v)),
      ),
    ];
  }
}

class _FlotaInformeView extends StatelessWidget {
  const _FlotaInformeView({required this.data});

  final FlotaInformeData data;

  @override
  Widget build(BuildContext context) {
    return InformeBody(
      kpis: data.kpis,
      charts: <Widget>[
        InformeBarChart(
          title: 'Servicios finalizados por vehículo (top 10)',
          items: data.serviciosPorVehiculo,
        ),
        InformeBarChart(
          title: 'Estado actual de la flota',
          items: data.estadoFlota,
          color: AppColors.secondary,
          emptyMessage: 'No hay vehículos',
        ),
      ],
      tablaTitulo: 'Desglose por vehículo',
      tablaTrailing: '${data.filas.length} vehículos',
      tabla: InformeTabla<FlotaInformeFila>(
        columnas: flotaColumnas,
        filas: data.filas,
        rowId: (FlotaInformeFila f) => f.vehiculo.id,
      ),
    );
  }
}

/// Columnas de la tabla (y del PDF) del informe de flota
final List<InformeColumna<FlotaInformeFila>> flotaColumnas = <InformeColumna<FlotaInformeFila>>[
  InformeColumna<FlotaInformeFila>(
    label: 'Matrícula',
    width: 100,
    negrita: true,
    texto: (FlotaInformeFila f) => f.vehiculo.matricula,
    orden: (FlotaInformeFila f) => f.vehiculo.matricula,
  ),
  InformeColumna<FlotaInformeFila>(
    label: 'Vehículo',
    flex: 2,
    texto: (FlotaInformeFila f) => '${f.vehiculo.marca} ${f.vehiculo.modelo}'.trim(),
    orden: (FlotaInformeFila f) => '${f.vehiculo.marca} ${f.vehiculo.modelo}',
  ),
  InformeColumna<FlotaInformeFila>(
    label: 'Categoría',
    flex: 2,
    texto: (FlotaInformeFila f) => GestionFormatters.texto(f.vehiculo.categoria),
    orden: (FlotaInformeFila f) => f.vehiculo.categoria,
  ),
  InformeColumna<FlotaInformeFila>(
    label: 'Estado',
    width: 110,
    texto: (FlotaInformeFila f) => vehiculoEstadoLabel(f.vehiculo.estado),
    orden: (FlotaInformeFila f) => vehiculoEstadoLabel(f.vehiculo.estado),
  ),
  InformeColumna<FlotaInformeFila>(
    label: 'Servicios',
    numerica: true,
    texto: (FlotaInformeFila f) => InformeCalculos.entero(f.servicios),
    orden: (FlotaInformeFila f) => f.servicios,
  ),
  InformeColumna<FlotaInformeFila>(
    label: 'Km servicio',
    numerica: true,
    texto: (FlotaInformeFila f) => InformeCalculos.entero(f.kmServicio),
    orden: (FlotaInformeFila f) => f.kmServicio,
  ),
  InformeColumna<FlotaInformeFila>(
    label: 'Litros',
    numerica: true,
    texto: (FlotaInformeFila f) => InformeCalculos.decimal(f.litros),
    orden: (FlotaInformeFila f) => f.litros,
  ),
  InformeColumna<FlotaInformeFila>(
    label: 'L/100 km',
    numerica: true,
    texto: (FlotaInformeFila f) => f.consumo100 == null ? '—' : InformeCalculos.decimal(f.consumo100!),
    orden: (FlotaInformeFila f) => f.consumo100 ?? 0,
  ),
  InformeColumna<FlotaInformeFila>(
    label: 'Averías',
    numerica: true,
    texto: (FlotaInformeFila f) => InformeCalculos.entero(f.averias),
    orden: (FlotaInformeFila f) => f.averias,
  ),
  InformeColumna<FlotaInformeFila>(
    label: 'Días taller',
    numerica: true,
    texto: (FlotaInformeFila f) => InformeCalculos.entero(f.diasTaller),
    orden: (FlotaInformeFila f) => f.diasTaller,
  ),
  InformeColumna<FlotaInformeFila>(
    label: 'Próxima ITV',
    width: 96,
    texto: (FlotaInformeFila f) => GestionFormatters.fecha(f.vehiculo.proximaItv),
    orden: (FlotaInformeFila f) => f.vehiculo.proximaItv,
  ),
];
