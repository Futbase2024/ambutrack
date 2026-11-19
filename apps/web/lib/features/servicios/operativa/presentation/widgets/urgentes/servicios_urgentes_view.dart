import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion_frame/gestion_frame.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/traslados_consulta_bloc.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/traslados_consulta_event.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslado_gestion_helpers.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslados_auto_refresh.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslados_gestion_config.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslados_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Ámbito temporal de la vista de urgentes
enum _Ambito { hoy, todos }

/// Servicios urgentes: traslados activos con prioridad alta (1–3) o motivo
/// de urgencias, refrescados automáticamente cada 30 segundos
class ServiciosUrgentesView extends StatefulWidget {
  const ServiciosUrgentesView({super.key});

  @override
  State<ServiciosUrgentesView> createState() => _ServiciosUrgentesViewState();
}

class _ServiciosUrgentesViewState extends State<ServiciosUrgentesView>
    with TrasladosAutoRefresh<ServiciosUrgentesView> {
  _Ambito _ambito = _Ambito.hoy;

  static const List<String> _estadosActivos = <String>[
    'pendiente',
    'asignado',
    'enviado',
    'recibido_conductor',
    'en_origen',
    'saliendo_origen',
    'en_transito',
    'en_destino',
  ];

  @override
  Duration get autoRefreshInterval => const Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    _load();
    startAutoRefresh();
  }

  void _load() {
    context
        .read<TrasladosConsultaBloc>()
        .add(TrasladosConsultaRequested(consulta: TrasladosConsulta.enCurso()));
  }

  List<TrasladoEntity> _urgentes(List<TrasladoEntity> traslados) {
    final DateTime now = DateTime.now();
    final DateTime manana = DateTime(now.year, now.month, now.day + 1);
    return traslados.where((TrasladoEntity t) {
      if (!TrasladoGestion.esUrgente(t)) {
        return false;
      }
      if (_ambito == _Ambito.todos) {
        return true;
      }
      final DateTime? fecha = t.fecha;
      return fecha == null || fecha.isBefore(manana);
    }).toList();
  }

  static List<String> _resumen(List<TrasladoEntity> base) {
    int count(bool Function(TrasladoEntity t) test) => base.where(test).length;
    return <String>[
      'Críticas ${count((TrasladoEntity t) => t.prioridad <= 2)}',
      'Sin asignar ${count((TrasladoEntity t) => t.estado == 'pendiente')}',
      'En ruta ${count((TrasladoEntity t) => TrasladoGestion.estadosEnRuta.contains(t.estado))}',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return TrasladosGestionView(
      onRefresh: _load,
      config: TrasladosGestionConfig(
        title: 'Servicios Urgentes',
        icon: Icons.emergency,
        estados: _estadosActivos,
        leadingFilters: <Widget>[
          GestionFilterDropdown<_Ambito>(
            label: 'Ámbito',
            value: _ambito,
            options: const <_Ambito, String>{
              _Ambito.hoy: 'Hoy y atrasados',
              _Ambito.todos: 'Todos los activos',
            },
            onChanged: (_Ambito v) => setState(() => _ambito = v),
          ),
          GestionToggleChip(
            label: 'Auto (30 s)',
            icon: Icons.autorenew,
            value: autoRefresh,
            onChanged: (bool v) => setState(() => autoRefresh = v),
          ),
        ],
        preFilter: _urgentes,
        extraStatus: _resumen,
        emptyMessage: 'No hay servicios urgentes activos',
        printSubtitle: 'Prioridad 1–3 o motivo de urgencias · estados activos',
        filtersSignature: _ambito,
      ),
    );
  }
}
