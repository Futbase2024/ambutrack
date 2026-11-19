import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/generacion_traslados_bloc.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/generacion_traslados_event.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/generacion_traslados_state.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/traslados_consulta_bloc.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/traslados_consulta_event.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslado_gestion_helpers.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslados_gestion_config.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslados_gestion_view.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/generar/generacion_resumen_banner.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/widgets/generate_traslados_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Días de la ventana de generación (igual que Planificar servicios)
const int _kDiasVentana = 14;

/// Generar servicios diarios: estado de la generación, ejecución manual
/// (con confirmación) y listado de los traslados de la ventana de 14 días
class GenerarDiariosView extends StatefulWidget {
  const GenerarDiariosView({super.key});

  @override
  State<GenerarDiariosView> createState() => _GenerarDiariosViewState();
}

class _GenerarDiariosViewState extends State<GenerarDiariosView> {
  late DateTime _hoy;

  /// Día seleccionado en el filtro (null = toda la ventana)
  DateTime? _dia;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _hoy = DateTime(now.year, now.month, now.day);
    _load();
  }

  void _load() {
    context.read<TrasladosConsultaBloc>().add(
          TrasladosConsultaRequested(
            consulta: TrasladosConsulta.rango(
              _hoy,
              _hoy.add(const Duration(days: _kDiasVentana)),
            ),
          ),
        );
    context.read<GeneracionTrasladosBloc>().add(const GeneracionEstadoRequested());
  }

  Future<void> _generar() async {
    final bool confirmado = await confirmarGeneracionTraslados(context);
    if (confirmado && mounted) {
      context
          .read<GeneracionTrasladosBloc>()
          .add(const GeneracionEjecutarRequested());
    }
  }

  void _onGeneracionChanged(BuildContext context, GeneracionTrasladosState state) {
    final String? error = state.errorGeneracion;
    if (error != null) {
      showResultDialog(
        context: context,
        title: 'Error al generar traslados',
        message: 'No se pudo completar la generación de traslados.',
        details: error,
        type: ResultType.error,
      );
      return;
    }
    final ResultadoGeneracionTrasladosEntity? r = state.ultimoResultado;
    if (r == null) {
      return;
    }
    context.read<TrasladosConsultaBloc>().add(const TrasladosConsultaRefreshRequested());
    showResultDialog(
      context: context,
      title: r.tieneErrores ? 'Generación con incidencias' : 'Generación completada',
      message: 'Servicios procesados: ${r.serviciosProcesados}\n'
          'Traslados generados: ${r.trasladosGenerados} '
          '(${r.trasladosIda} ida / ${r.trasladosVuelta} vuelta)\n'
          'Periodo: ${GestionFormatters.fecha(r.fechaDesde)} – ${GestionFormatters.fecha(r.fechaHasta)}',
      details: r.tieneErrores
          ? 'Servicios con error: ${r.serviciosConError}\n${r.errores.join('\n')}'
          : null,
      type: r.tieneErrores ? ResultType.warning : ResultType.success,
    );
  }

  List<TrasladoEntity> _delDia(List<TrasladoEntity> traslados) {
    final DateTime? dia = _dia;
    if (dia == null) {
      return traslados;
    }
    return traslados.where((TrasladoEntity t) {
      final DateTime? f = t.fecha;
      return f != null && f.year == dia.year && f.month == dia.month && f.day == dia.day;
    }).toList();
  }

  static List<String> _resumen(List<TrasladoEntity> base) {
    final int recurrentes =
        base.where((TrasladoEntity t) => t.idServicioRecurrente != null).length;
    final int sinAsignar =
        base.where((TrasladoEntity t) => t.estado == 'pendiente').length;
    return <String>[
      'De servicios recurrentes $recurrentes',
      'Pendientes de asignar $sinAsignar',
    ];
  }

  Map<DateTime?, String> get _opcionesDia {
    final DateFormat fmt = DateFormat('EEE dd/MM', 'es_ES');
    return <DateTime?, String>{
      null: 'Ventana completa',
      for (int i = 0; i <= _kDiasVentana; i++)
        _hoy.add(Duration(days: i)): fmt.format(_hoy.add(Duration(days: i))),
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GeneracionTrasladosBloc, GeneracionTrasladosState>(
      listenWhen: (GeneracionTrasladosState prev, GeneracionTrasladosState curr) =>
          prev.ultimoResultado != curr.ultimoResultado ||
          (curr.errorGeneracion != null && prev.errorGeneracion != curr.errorGeneracion),
      listener: _onGeneracionChanged,
      buildWhen: (GeneracionTrasladosState prev, GeneracionTrasladosState curr) =>
          prev.generando != curr.generando,
      builder: (BuildContext context, GeneracionTrasladosState gen) {
        final String ventana = '${GestionFormatters.fecha(_hoy)} – '
            '${GestionFormatters.fecha(_hoy.add(const Duration(days: _kDiasVentana)))}';
        return TrasladosGestionView(
          onRefresh: _load,
          config: TrasladosGestionConfig(
            title: 'Generar Servicios Diarios',
            icon: Icons.today,
            estados: TrasladoGestion.todosLosEstados,
            extraActions: <GestionToolbarAction>[
              GestionToolbarAction(
                icon: Icons.event_repeat_rounded,
                label: gen.generando ? 'Generando...' : 'Generar ($_kDiasVentana días)',
                primary: true,
                tooltip: 'Genera los traslados de los servicios recurrentes vigentes',
                onPressed: gen.generando ? null : _generar,
              ),
            ],
            leadingFilters: <Widget>[
              GestionFilterDropdown<DateTime?>(
                label: 'Día',
                value: _dia,
                options: _opcionesDia,
                onChanged: (DateTime? v) => setState(() => _dia = v),
              ),
            ],
            banner: const GeneracionResumenBanner(),
            preFilter: _delDia,
            extraStatus: _resumen,
            emptyMessage: 'No hay traslados generados en la ventana. Pulsa "Generar".',
            printSubtitle: 'Ventana $ventana',
            filtersSignature: _dia,
          ),
        );
      },
    );
  }
}
