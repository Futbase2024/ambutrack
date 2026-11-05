import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_formatters.dart';
import 'package:ambutrack_web/core/widgets/gestion_frame/gestion_frame_controls.dart';
import 'package:ambutrack_web/features/informes/domain/costes_informe_models.dart';
import 'package:ambutrack_web/features/informes/domain/informe_calculos.dart';
import 'package:ambutrack_web/features/informes/domain/informe_filtro.dart';
import 'package:ambutrack_web/features/informes/presentation/bloc/costes_informe_bloc.dart';
import 'package:ambutrack_web/features/informes/presentation/bloc/informe_bloc.dart';
import 'package:ambutrack_web/features/informes/presentation/widgets/informe_bar_chart.dart';
import 'package:ambutrack_web/features/informes/presentation/widgets/informe_body.dart';
import 'package:ambutrack_web/features/informes/presentation/widgets/informe_scaffold.dart';
import 'package:ambutrack_web/features/informes/presentation/widgets/informe_tabla.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Informe de costes operativos de la flota
class CostesInformePage extends StatelessWidget {
  const CostesInformePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CostesInformeBloc>(
      create: (_) => getIt<CostesInformeBloc>()..add(const InformeRefreshRequested()),
      child: InformeScaffold<CostesInformeBloc, CostesInformeData>(
        title: 'Costes Operativos',
        icon: Icons.euro_outlined,
        filtrosBuilder: _filtros,
        statusBuilder: (CostesInformeData d) => <String>[
          'Total ${GestionFormatters.moneda(d.total)}',
          '${d.filas.length} vehículos con coste o actividad',
        ],
        impresion: (CostesInformeData d) => informeImpresion(costesColumnas, d.filas),
        contentBuilder: (CostesInformeData d) => _CostesInformeView(data: d),
      ),
    );
  }

  static List<Widget> _filtros(
    InformeFiltro filtro,
    CostesInformeData? data,
    ValueChanged<InformeFiltro> onChanged,
  ) {
    return <Widget>[
      GestionCompactDropdown<String>(
        label: 'Vehículo',
        width: 170,
        value: filtro.extra(CostesInformeBloc.kVehiculo),
        options: <String?, String>{
          null: 'Todos',
          ...?data?.vehiculos,
        },
        onChanged: (String? v) => onChanged(filtro.conExtra(CostesInformeBloc.kVehiculo, v)),
      ),
    ];
  }
}

class _CostesInformeView extends StatelessWidget {
  const _CostesInformeView({required this.data});

  final CostesInformeData data;

  @override
  Widget build(BuildContext context) {
    return InformeBody(
      kpis: data.kpis,
      charts: <Widget>[
        InformeBarChart(title: 'Coste por concepto', items: data.porConcepto),
        InformeBarChart(
          title: 'Evolución mensual del coste',
          items: data.porMes,
          color: AppColors.secondary,
        ),
      ],
      tablaTitulo: 'Desglose de costes por vehículo',
      tablaTrailing: GestionFormatters.moneda(data.total),
      tabla: InformeTabla<CostesInformeFila>(
        columnas: costesColumnas,
        filas: data.filas,
        rowId: (CostesInformeFila f) => f.vehiculoId,
      ),
    );
  }
}

InformeColumna<CostesInformeFila> _concepto(String label, CosteConcepto c) {
  return InformeColumna<CostesInformeFila>(
    label: label,
    numerica: true,
    texto: (CostesInformeFila f) => GestionFormatters.moneda(f.importe(c)),
    orden: (CostesInformeFila f) => f.importe(c),
  );
}

/// Columnas de la tabla (y del PDF) del informe de costes
final List<InformeColumna<CostesInformeFila>> costesColumnas = <InformeColumna<CostesInformeFila>>[
  InformeColumna<CostesInformeFila>(
    label: 'Vehículo',
    width: 110,
    negrita: true,
    texto: (CostesInformeFila f) => f.matricula,
    orden: (CostesInformeFila f) => f.matricula,
  ),
  _concepto('Combustible', CosteConcepto.combustible),
  _concepto('Reparaciones', CosteConcepto.reparaciones),
  _concepto('Mantenimiento', CosteConcepto.mantenimiento),
  _concepto('ITV / revisiones', CosteConcepto.itv),
  _concepto('Averías s/orden', CosteConcepto.averias),
  InformeColumna<CostesInformeFila>(
    label: 'Total',
    numerica: true,
    negrita: true,
    texto: (CostesInformeFila f) => GestionFormatters.moneda(f.total),
    orden: (CostesInformeFila f) => f.total,
  ),
  InformeColumna<CostesInformeFila>(
    label: 'Servicios',
    numerica: true,
    texto: (CostesInformeFila f) => InformeCalculos.entero(f.servicios),
    orden: (CostesInformeFila f) => f.servicios,
  ),
  InformeColumna<CostesInformeFila>(
    label: 'Coste/servicio',
    numerica: true,
    texto: (CostesInformeFila f) => f.porServicio == null ? '—' : GestionFormatters.moneda(f.porServicio!),
    orden: (CostesInformeFila f) => f.porServicio ?? 0,
  ),
  InformeColumna<CostesInformeFila>(
    label: 'Coste/km',
    numerica: true,
    texto: (CostesInformeFila f) => f.porKm == null ? '—' : GestionFormatters.moneda(f.porKm!),
    orden: (CostesInformeFila f) => f.porKm ?? 0,
  ),
];
