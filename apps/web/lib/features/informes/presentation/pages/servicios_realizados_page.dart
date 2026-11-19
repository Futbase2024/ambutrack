import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_formatters.dart';
import 'package:ambutrack_web/core/widgets/gestion_frame/gestion_frame_controls.dart';
import 'package:ambutrack_web/features/informes/domain/informe_calculos.dart';
import 'package:ambutrack_web/features/informes/domain/informe_filtro.dart';
import 'package:ambutrack_web/features/informes/domain/traslado_grupo.dart';
import 'package:ambutrack_web/features/informes/presentation/bloc/informe_bloc.dart';
import 'package:ambutrack_web/features/informes/presentation/bloc/servicios_realizados_bloc.dart';
import 'package:ambutrack_web/features/informes/presentation/widgets/informe_bar_chart.dart';
import 'package:ambutrack_web/features/informes/presentation/widgets/informe_body.dart';
import 'package:ambutrack_web/features/informes/presentation/widgets/informe_scaffold.dart';
import 'package:ambutrack_web/features/informes/presentation/widgets/informe_tabla.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Informe de servicios (traslados) realizados en un periodo
class ServiciosRealizadosPage extends StatelessWidget {
  const ServiciosRealizadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ServiciosRealizadosBloc>(
      create: (_) => getIt<ServiciosRealizadosBloc>()..add(const InformeRefreshRequested()),
      child: InformeScaffold<ServiciosRealizadosBloc, ServiciosRealizadosData>(
        title: 'Servicios Realizados',
        icon: Icons.analytics_outlined,
        filtrosBuilder: _filtros,
        statusBuilder: (ServiciosRealizadosData d) => <String>[
          '${d.total} servicios en el periodo',
          '${d.filas.length} en la tabla',
        ],
        impresion: (ServiciosRealizadosData d) => informeImpresion(serviciosColumnas, d.filas),
        contentBuilder: (ServiciosRealizadosData d) => _ServiciosRealizadosView(data: d),
      ),
    );
  }

  static List<Widget> _filtros(
    InformeFiltro filtro,
    ServiciosRealizadosData? data,
    ValueChanged<InformeFiltro> onChanged,
  ) {
    return <Widget>[
      GestionCompactDropdown<String>(
        label: 'Vehículo',
        width: 170,
        value: filtro.extra(ServiciosRealizadosBloc.kVehiculo),
        options: <String?, String>{
          null: 'Todos',
          for (final String v in data?.vehiculos ?? <String>[]) v: v,
        },
        onChanged: (String? v) => onChanged(filtro.conExtra(ServiciosRealizadosBloc.kVehiculo, v)),
      ),
      GestionCompactDropdown<String>(
        label: 'Estado',
        width: 210,
        value: filtro.extra(ServiciosRealizadosBloc.kGrupo),
        options: <String?, String>{
          null: 'Todos',
          for (final TrasladoGrupo g in TrasladoGrupo.values) g.name: g.label,
        },
        onChanged: (String? v) => onChanged(filtro.conExtra(ServiciosRealizadosBloc.kGrupo, v)),
      ),
    ];
  }
}

class _ServiciosRealizadosView extends StatelessWidget {
  const _ServiciosRealizadosView({required this.data});

  final ServiciosRealizadosData data;

  @override
  Widget build(BuildContext context) {
    return InformeBody(
      kpis: data.kpis,
      charts: <Widget>[
        InformeBarChart(title: 'Servicios por estado', items: data.porEstado),
        InformeBarChart(
          title: 'Servicios por motivo de traslado',
          items: data.porMotivo,
          color: AppColors.secondary,
        ),
      ],
      tablaTitulo: 'Detalle de servicios',
      tablaTrailing: '${data.filas.length} registros',
      tabla: InformeTabla<TrasladoEntity>(
        columnas: serviciosColumnas,
        filas: data.filas,
        rowId: (TrasladoEntity t) => t.id,
      ),
    );
  }
}

/// Columnas de la tabla (y del PDF) de servicios realizados
final List<InformeColumna<TrasladoEntity>> serviciosColumnas = <InformeColumna<TrasladoEntity>>[
  InformeColumna<TrasladoEntity>(
    label: 'Fecha',
    width: 92,
    texto: (TrasladoEntity t) => GestionFormatters.fecha(t.fecha),
    orden: (TrasladoEntity t) => t.fecha ?? InformeCalculos.fechaMinima,
  ),
  InformeColumna<TrasladoEntity>(
    label: 'Hora',
    width: 60,
    texto: (TrasladoEntity t) => InformeCalculos.hora(t.horaProgramada),
    orden: (TrasladoEntity t) => InformeCalculos.hora(t.horaProgramada),
  ),
  InformeColumna<TrasladoEntity>(
    label: 'Código',
    width: 110,
    texto: (TrasladoEntity t) => GestionFormatters.texto(t.codigo),
    orden: (TrasladoEntity t) => t.codigo ?? '',
  ),
  InformeColumna<TrasladoEntity>(
    label: 'Paciente',
    flex: 3,
    negrita: true,
    texto: (TrasladoEntity t) => GestionFormatters.texto(t.pacienteNombre),
    orden: (TrasladoEntity t) => t.pacienteNombre ?? '',
  ),
  InformeColumna<TrasladoEntity>(
    label: 'Tipo',
    width: 70,
    texto: (TrasladoEntity t) => GestionFormatters.texto(t.tipoTraslado?.toUpperCase()),
    orden: (TrasladoEntity t) => t.tipoTraslado ?? '',
  ),
  const InformeColumna<TrasladoEntity>(
    label: 'Motivo',
    flex: 2,
    texto: TrasladoTextos.motivo,
    orden: TrasladoTextos.motivo,
  ),
  InformeColumna<TrasladoEntity>(
    label: 'Origen',
    flex: 3,
    texto: (TrasladoEntity t) => GestionFormatters.texto(t.origen),
  ),
  InformeColumna<TrasladoEntity>(
    label: 'Destino',
    flex: 3,
    texto: (TrasladoEntity t) => GestionFormatters.texto(t.destino),
  ),
  const InformeColumna<TrasladoEntity>(
    label: 'Vehículo',
    width: 100,
    texto: TrasladoTextos.vehiculo,
    orden: TrasladoTextos.vehiculo,
  ),
  const InformeColumna<TrasladoEntity>(
    label: 'Estado',
    width: 150,
    texto: TrasladoTextos.estado,
    orden: TrasladoTextos.estado,
  ),
  InformeColumna<TrasladoEntity>(
    label: 'Km',
    width: 70,
    numerica: true,
    texto: (TrasladoEntity t) => t.kmTotales == null ? '—' : InformeCalculos.entero(t.kmTotales!),
    orden: (TrasladoEntity t) => t.kmTotales ?? 0,
  ),
  InformeColumna<TrasladoEntity>(
    label: 'Duración',
    width: 80,
    numerica: true,
    texto: (TrasladoEntity t) => t.duracionRealMinutos == null ? '—' : '${t.duracionRealMinutos} min',
    orden: (TrasladoEntity t) => t.duracionRealMinutos ?? 0,
  ),
];
