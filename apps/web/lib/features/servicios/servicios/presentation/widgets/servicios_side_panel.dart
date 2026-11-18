import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/entities/servicio_entity.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/bloc/servicios_bloc.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/bloc/servicios_state.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/ficha/servicio_adicional_tab.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/ficha/servicio_general_tab.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/ficha/servicio_trayectos_tab.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/gestion/servicio_gestion_columns.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/servicios_page_bars.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/bloc/tipo_vehiculo_bloc.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/bloc/tipo_vehiculo_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Ficha lateral del servicio seleccionado (estilo programa de gestión)
class ServiciosSidePanel extends StatefulWidget {
  const ServiciosSidePanel({this.servicioId, super.key});

  final String? servicioId;

  @override
  State<ServiciosSidePanel> createState() => _ServiciosSidePanelState();
}

class _ServiciosSidePanelState extends State<ServiciosSidePanel> {
  /// Tipos de vehículo para mostrar el nombre del tipo de ambulancia
  final TipoVehiculoBloc _tipoVehiculoBloc = getIt<TipoVehiculoBloc>()
    ..add(const TipoVehiculoLoadAllRequested());

  @override
  void dispose() {
    _tipoVehiculoBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.servicioId == null) {
      return const GestionDetailEmpty(message: 'Selecciona un servicio para ver su ficha');
    }
    return BlocProvider<TipoVehiculoBloc>.value(
      value: _tipoVehiculoBloc,
      child: BlocBuilder<ServiciosBloc, ServiciosState>(
        builder: (BuildContext context, ServiciosState state) {
          final bool cargando = state.maybeWhen(
            loaded: (
              List<ServicioEntity> servicios,
              String searchQuery,
              int? yearFilter,
              String? estadoFilter,
              bool isRefreshing,
              ServicioEntity? selectedServicio,
              bool isLoadingDetails,
            ) =>
                isLoadingDetails,
            orElse: () => false,
          );
          final ServicioEntity? servicio = servicioSeleccionado(state);
          if (cargando) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          if (servicio == null) {
            return const GestionDetailEmpty(message: 'No se pudieron cargar los datos del servicio');
          }
          return _ServicioFicha(servicio: servicio);
        },
      ),
    );
  }
}

class _ServicioFicha extends StatelessWidget {
  const _ServicioFicha({required this.servicio});

  final ServicioEntity servicio;

  @override
  Widget build(BuildContext context) {
    final ServicioEntity s = servicio;
    return GestionDetailPanel(
      key: ValueKey<String?>(s.id),
      title: s.paciente?.nombreCompleto ?? s.codigo ?? 'Servicio',
      badges: <Widget>[
        Text(
          GestionFormatters.texto(s.codigo),
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.gray600),
        ),
        GestionDotLabel(label: ServicioGestion.estadoLabel(s.estado), color: ServicioGestion.estadoColor(s.estado)),
        if (s.tipoRecurrencia != null)
          GestionDotLabel(label: ServicioGestion.recurrencia(s), color: AppColors.info),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: ServicioGeneralTab(servicio: s)),
        GestionDetailTab(label: 'Trayectos', child: ServicioTrayectosTab(servicio: s)),
        GestionDetailTab(label: 'Adicional', child: ServicioAdicionalTab(servicio: s)),
      ],
    );
  }
}
