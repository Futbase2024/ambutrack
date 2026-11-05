import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion_frame/gestion_frame_controls.dart';
import 'package:ambutrack_web/features/informes/domain/informe_calculos.dart';
import 'package:ambutrack_web/features/informes/domain/informe_filtro.dart';
import 'package:ambutrack_web/features/informes/domain/personal_informe_models.dart';
import 'package:ambutrack_web/features/informes/presentation/bloc/informe_bloc.dart';
import 'package:ambutrack_web/features/informes/presentation/bloc/personal_informe_bloc.dart';
import 'package:ambutrack_web/features/informes/presentation/widgets/informe_bar_chart.dart';
import 'package:ambutrack_web/features/informes/presentation/widgets/informe_body.dart';
import 'package:ambutrack_web/features/informes/presentation/widgets/informe_scaffold.dart';
import 'package:ambutrack_web/features/informes/presentation/widgets/informe_tabla.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Informe de personal: actividad, horas, ausencias, vacaciones y formación
class PersonalInformePage extends StatelessWidget {
  const PersonalInformePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PersonalInformeBloc>(
      create: (_) => getIt<PersonalInformeBloc>()..add(const InformeRefreshRequested()),
      child: InformeScaffold<PersonalInformeBloc, PersonalInformeData>(
        title: 'Informes de Personal',
        icon: Icons.people_outline,
        filtrosBuilder: _filtros,
        statusBuilder: (PersonalInformeData d) => <String>[
          '${d.filas.length} empleados activos',
          'Formación: estado a fecha de hoy',
        ],
        impresion: (PersonalInformeData d) => informeImpresion(personalColumnas, d.filas),
        contentBuilder: (PersonalInformeData d) => _PersonalInformeView(data: d),
      ),
    );
  }

  static List<Widget> _filtros(
    InformeFiltro filtro,
    PersonalInformeData? data,
    ValueChanged<InformeFiltro> onChanged,
  ) {
    return <Widget>[
      GestionCompactDropdown<String>(
        label: 'Categoría',
        width: 190,
        value: filtro.extra(PersonalInformeBloc.kCategoria),
        options: <String?, String>{
          null: 'Todas',
          for (final String c in data?.categorias ?? <String>[]) c: c,
        },
        onChanged: (String? v) => onChanged(filtro.conExtra(PersonalInformeBloc.kCategoria, v)),
      ),
      GestionCompactDropdown<String>(
        label: 'Base',
        width: 190,
        value: filtro.extra(PersonalInformeBloc.kBase),
        options: <String?, String>{
          null: 'Todas',
          ...?data?.bases,
        },
        onChanged: (String? v) => onChanged(filtro.conExtra(PersonalInformeBloc.kBase, v)),
      ),
    ];
  }
}

class _PersonalInformeView extends StatelessWidget {
  const _PersonalInformeView({required this.data});

  final PersonalInformeData data;

  @override
  Widget build(BuildContext context) {
    return InformeBody(
      kpis: data.kpis,
      charts: <Widget>[
        InformeBarChart(
          title: 'Días de ausencia por tipo',
          items: data.ausenciasPorTipo,
          color: AppColors.warning,
          emptyMessage: 'Sin ausencias aprobadas en el periodo',
        ),
        InformeBarChart(
          title: 'Horas fichadas por categoría',
          items: data.horasPorCategoria,
          emptyMessage: 'Sin fichajes en el periodo',
        ),
      ],
      tablaTitulo: 'Desglose por empleado',
      tablaTrailing: '${data.filas.length} empleados',
      tabla: InformeTabla<PersonalInformeFila>(
        columnas: personalColumnas,
        filas: data.filas,
        rowId: (PersonalInformeFila f) => f.id,
      ),
    );
  }
}

/// Columnas de la tabla (y del PDF) del informe de personal
final List<InformeColumna<PersonalInformeFila>> personalColumnas = <InformeColumna<PersonalInformeFila>>[
  InformeColumna<PersonalInformeFila>(
    label: 'Empleado',
    flex: 3,
    negrita: true,
    texto: (PersonalInformeFila f) => f.nombre,
    orden: (PersonalInformeFila f) => f.nombre,
  ),
  InformeColumna<PersonalInformeFila>(
    label: 'Categoría',
    flex: 2,
    texto: (PersonalInformeFila f) => f.categoria,
    orden: (PersonalInformeFila f) => f.categoria,
  ),
  InformeColumna<PersonalInformeFila>(
    label: 'Base',
    flex: 2,
    texto: (PersonalInformeFila f) => f.base,
    orden: (PersonalInformeFila f) => f.base,
  ),
  InformeColumna<PersonalInformeFila>(
    label: 'Servicios',
    numerica: true,
    texto: (PersonalInformeFila f) => InformeCalculos.entero(f.servicios),
    orden: (PersonalInformeFila f) => f.servicios,
  ),
  InformeColumna<PersonalInformeFila>(
    label: 'Horas fichadas',
    numerica: true,
    texto: (PersonalInformeFila f) => InformeCalculos.decimal(f.horas),
    orden: (PersonalInformeFila f) => f.horas,
  ),
  InformeColumna<PersonalInformeFila>(
    label: 'Días ausencia',
    numerica: true,
    texto: (PersonalInformeFila f) => InformeCalculos.entero(f.diasAusencia),
    orden: (PersonalInformeFila f) => f.diasAusencia,
  ),
  InformeColumna<PersonalInformeFila>(
    label: 'Días vacaciones',
    numerica: true,
    texto: (PersonalInformeFila f) => InformeCalculos.entero(f.diasVacaciones),
    orden: (PersonalInformeFila f) => f.diasVacaciones,
  ),
  InformeColumna<PersonalInformeFila>(
    label: 'Form. vencida',
    numerica: true,
    texto: (PersonalInformeFila f) => InformeCalculos.entero(f.formacionVencida),
    orden: (PersonalInformeFila f) => f.formacionVencida,
  ),
  InformeColumna<PersonalInformeFila>(
    label: 'Vence ≤ 30 d',
    numerica: true,
    texto: (PersonalInformeFila f) => InformeCalculos.entero(f.formacionProxima),
    orden: (PersonalInformeFila f) => f.formacionProxima,
  ),
];
