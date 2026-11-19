import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion_frame/gestion_frame.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/traslados_consulta_bloc.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/traslados_consulta_event.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslado_gestion_helpers.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslados_auto_refresh.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslados_gestion_config.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslados_gestion_view.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/estado/estado_resumen_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Estado del servicio: monitorización de los traslados de un día por estado
class EstadoServiciosView extends StatefulWidget {
  const EstadoServiciosView({super.key});

  @override
  State<EstadoServiciosView> createState() => _EstadoServiciosViewState();
}

class _EstadoServiciosViewState extends State<EstadoServiciosView>
    with TrasladosAutoRefresh<EstadoServiciosView> {
  late DateTime _dia;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _dia = DateTime(now.year, now.month, now.day);
    _load();
    startAutoRefresh();
  }

  void _load() {
    context
        .read<TrasladosConsultaBloc>()
        .add(TrasladosConsultaRequested(consulta: TrasladosConsulta.dia(_dia)));
  }

  void _setDia(DateTime dia) {
    setState(() => _dia = DateTime(dia.year, dia.month, dia.day));
    _load();
  }

  Future<void> _pickDia() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: _dia,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('es', 'ES'),
      builder: (BuildContext context, Widget? child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onSurface: AppColors.textPrimaryLight,
          ),
        ),
        child: child!,
      ),
    );
    if (fecha != null) {
      _setDia(fecha);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String diaLabel = DateFormat('EEEE, dd MMMM yyyy', 'es_ES').format(_dia);
    return TrasladosGestionView(
      onRefresh: _load,
      config: TrasladosGestionConfig(
        title: 'Estado del Servicio',
        icon: Icons.monitor_heart_outlined,
        estados: TrasladoGestion.todosLosEstados,
        conFecha: false,
        extraActions: <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.today,
            label: 'Hoy',
            onPressed: () => _setDia(DateTime.now()),
          ),
        ],
        toolbarTrailing: GestionPeriodNavigator(
          label: diaLabel,
          previousTooltip: 'Día anterior',
          nextTooltip: 'Día siguiente',
          onPrevious: () => _setDia(_dia.subtract(const Duration(days: 1))),
          onNext: () => _setDia(_dia.add(const Duration(days: 1))),
          onLabelTap: _pickDia,
        ),
        leadingFilters: <Widget>[
          GestionToggleChip(
            label: 'Auto (60 s)',
            icon: Icons.autorenew,
            value: autoRefresh,
            onChanged: (bool v) => setState(() => autoRefresh = v),
          ),
        ],
        banner: const EstadoResumenBanner(),
        extraStatus: TrasladoGestion.recuentosEstado,
        emptyMessage: 'No hay traslados programados para este día',
        printSubtitle: diaLabel,
        filtersSignature: _dia,
      ),
    );
  }
}
