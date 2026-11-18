import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/core/widgets/menus/action_menu.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/entities/servicio_entity.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/bloc/servicios_bloc.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/bloc/servicios_state.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/servicio_fechas_excepcion_panel.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/trayecto_form_dialog.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/bloc/tipo_vehiculo_bloc.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/bloc/tipo_vehiculo_event.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/bloc/tipo_vehiculo_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Panel lateral con tabs para detalles del servicio
class ServiciosSidePanel extends StatefulWidget {
  const ServiciosSidePanel({
    this.servicioId,
    super.key,
  });

  final String? servicioId;

  @override
  State<ServiciosSidePanel> createState() => _ServiciosSidePanelState();
}

class _ServiciosSidePanelState extends State<ServiciosSidePanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TipoVehiculoBloc _tipoVehiculoBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tipoVehiculoBloc = getIt<TipoVehiculoBloc>();
    // Cargar tipos de vehículo al inicializar
    _tipoVehiculoBloc.add(const TipoVehiculoLoadAllRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tipoVehiculoBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.servicioId == null) {
      return _buildEmptyState();
    }

    return BlocProvider<TipoVehiculoBloc>.value(
      value: _tipoVehiculoBloc,
      child: BlocBuilder<ServiciosBloc, ServiciosState>(
      builder: (BuildContext context, ServiciosState state) {
        return state.maybeWhen(
          loaded: (
            List<ServicioEntity> servicios,
            String searchQuery,
            int? yearFilter,
            String? estadoFilter,
            bool isRefreshing,
            ServicioEntity? selectedServicio,
            bool isLoadingDetails,
          ) {
            // Mostrar loading si está cargando detalles
            if (isLoadingDetails) {
              return _buildLoadingState();
            }

            // Mostrar mensaje si no hay servicio seleccionado
            if (selectedServicio == null) {
              return _buildNoDataState();
            }

            // Mostrar detalles del servicio
            return DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radius),
                border: Border.all(color: AppColors.gray200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Header profesional
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          AppColors.primary.withValues(alpha: 0.05),
                          Colors.white,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: const Border(
                        bottom: BorderSide(color: AppColors.gray200),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        // Icono con fondo
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSizes.paddingSmall),
                        // Título
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'Detalles del Servicio',
                                style: GoogleFonts.inter(
                                  fontSize: AppSizes.fontMedium,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimaryLight,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                selectedServicio.codigo ?? 'Sin código',
                                style: GoogleFonts.inter(
                                  fontSize: AppSizes.fontSmall,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Badge de estado
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingSmall,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getEstadoColor(selectedServicio.estado).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                            border: Border.all(
                              color: _getEstadoColor(selectedServicio.estado).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            selectedServicio.estado.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _getEstadoColor(selectedServicio.estado),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tabs
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.gray200),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondaryLight,
                      indicatorColor: AppColors.primary,
                      labelStyle: const TextStyle(
                        fontSize: AppSizes.fontSmall,
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: const <Tab>[
                        Tab(text: 'DATOS DEL SERVICIO'),
                        Tab(text: 'TRAYECTOS/EXCEPCIONES'),
                        Tab(text: 'DATOS ADICIONALES'),
                      ],
                    ),
                  ),

                  // Tab content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        _DatosServicioTab(servicio: selectedServicio),
                        _TrayectosExcepcionesTab(servicio: selectedServicio),
                        _DatosAdicionalesTab(servicio: selectedServicio),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          orElse: _buildEmptyState,
        );
      },
      ),
    );
  }

  Widget _buildLoadingState() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: const Center(
        child: AppLoadingIndicator(message: 'Cargando detalles del servicio...'),
      ),
    );
  }

  Widget _buildNoDataState() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.error_outline, size: 64, color: AppColors.gray400),
            SizedBox(height: AppSizes.spacing),
            Text(
              'Error al cargar detalles',
              style: TextStyle(
                fontSize: AppSizes.fontMedium,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.touch_app,
              size: 64,
              color: AppColors.gray400,
            ),
            SizedBox(height: AppSizes.spacing),
            Text(
              'Selecciona un servicio',
              style: TextStyle(
                fontSize: AppSizes.fontMedium,
                color: AppColors.textSecondaryLight,
              ),
            ),
            SizedBox(height: AppSizes.spacingSmall),
            Text(
              'Haz clic en un servicio de la tabla',
              style: TextStyle(
                fontSize: AppSizes.fontSmall,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Obtiene el color según el estado del servicio
  Color _getEstadoColor(String estado) {
    switch (estado.toUpperCase()) {
      case 'ACTIVO':
        return AppColors.success;
      case 'SUSPENDIDO':
        return AppColors.warning;
      case 'FINALIZADO':
        return AppColors.info;
      case 'ELIMINADO':
      case 'CANCELADO':
        return AppColors.error;
      default:
        return AppColors.textSecondaryLight;
    }
  }
}

/// Tab con datos del servicio
class _DatosServicioTab extends StatelessWidget {
  const _DatosServicioTab({required this.servicio});

  final ServicioEntity servicio;

  @override
  Widget build(BuildContext context) {
    // Helper para formatear fechas
    String formatDate(DateTime? date) {
      if (date == null) {
        return '-';
      }
      return DateFormat('dd/MM/yyyy').format(date);
    }

    // Helper para formatear días de la semana
    // Sistema ISO 8601 europeo: 1=Lunes, 2=Martes, 3=Miércoles, 4=Jueves, 5=Viernes, 6=Sábado, 7=Domingo
    String formatDiasSemana() {
      if (servicio.diasSemana == null || servicio.diasSemana!.isEmpty) {
        return '-';
      }
      final List<String> dias = <String>['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      return servicio.diasSemana!
          .where((int d) => d >= 1 && d <= 7)
          .map((int d) => dias[d])
          .join(', ');
    }

    // Helper para estado badge
    Color getEstadoColor() {
      switch (servicio.estado) {
        case 'ACTIVO':
          return AppColors.success; // Verde
        case 'SUSPENDIDO':
          return AppColors.warning; // Amarillo/Naranja
        case 'FINALIZADO':
          return AppColors.info; // Azul
        case 'ELIMINADO':
          return AppColors.error; // Rojo
        default:
          return AppColors.textSecondaryLight;
      }
    }

    String getEstadoLabel() {
      return servicio.estado;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // PRIMERA FILA: Información General + Datos del Paciente
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Columna izquierda: Información General
              Expanded(
                child: _InfoCard(
                  title: 'Información General',
                  icon: Icons.info_outline,
                  iconColor: AppColors.primary,
                  children: <Widget>[
                    _InfoRow(
                      label: 'Estado',
                      value: getEstadoLabel(),
                      valueWidget: _StatusBadge(
                        label: getEstadoLabel(),
                        color: getEstadoColor(),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.gray200),
                    _InfoRow(
                      label: 'Tipo Recurrencia',
                      value: servicio.tipoRecurrencia ?? '-',
                    ),
                    const Divider(height: 1, color: AppColors.gray200),
                    _InfoRow(
                      label: 'Fecha Inicio',
                      value: formatDate(servicio.fechaServicioInicio),
                    ),
                    if (servicio.fechaServicioFin != null) ...<Widget>[
                      const Divider(height: 1, color: AppColors.gray200),
                      _InfoRow(
                        label: 'Fecha Fin',
                        value: formatDate(servicio.fechaServicioFin),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Columna derecha: Datos del Paciente
              if (servicio.paciente != null)
                Expanded(
                  child: _InfoCard(
                    title: 'Datos del Paciente',
                    icon: Icons.person_outline,
                    iconColor: AppColors.primary,
                    children: <Widget>[
                      _InfoRow(
                        label: 'Nombre',
                        value: servicio.paciente!.nombreCompleto,
                      ),
                      if (servicio.paciente!.documento.isNotEmpty) ...<Widget>[
                        const Divider(height: 1, color: AppColors.gray200),
                        _InfoRow(
                          label: servicio.paciente!.tipoDocumento,
                          value: servicio.paciente!.documento,
                        ),
                      ],
                      const Divider(height: 1, color: AppColors.gray200),
                      _InfoRow(
                        label: 'Fecha Nacimiento',
                        value: formatDate(servicio.paciente!.fechaNacimiento),
                      ),
                      if (servicio.paciente!.domicilioDireccion != null &&
                          servicio.paciente!.domicilioDireccion!.isNotEmpty) ...<Widget>[
                        const Divider(height: 1, color: AppColors.gray200),
                        _InfoRow(
                          label: 'Domicilio',
                          value: servicio.paciente!.domicilioDireccion!,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // SEGUNDA FILA: Detalles del Servicio + Horarios
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Columna izquierda: Detalles del Servicio
              Expanded(
                child: _InfoCard(
                  title: 'Detalles del Servicio',
                  icon: Icons.local_hospital_outlined,
                  iconColor: AppColors.primary,
                  children: <Widget>[
                    // Tipo de Servicio (Motivo de Traslado)
                    if (servicio.motivoTraslado != null) ...<Widget>[
                      _InfoRow(
                        label: 'Tipo de Servicio',
                        value: servicio.motivoTraslado!.nombre,
                      ),
                      const Divider(height: 1, color: AppColors.gray200),
                    ],
                    if (servicio.tipoAmbulancia != null) ...<Widget>[
                      BlocBuilder<TipoVehiculoBloc, TipoVehiculoState>(
                        builder: (BuildContext context, TipoVehiculoState tipoVehiculoState) {
                          String tipoAmbulanciaDisplay = 'Cargando...';

                          if (tipoVehiculoState is TipoVehiculoLoaded) {
                            // Buscar el tipo de vehículo por ID
                            final TipoVehiculoEntity? tipo = tipoVehiculoState.tiposVehiculo
                                .cast<TipoVehiculoEntity?>()
                                .firstWhere(
                                  (TipoVehiculoEntity? t) => t?.id == servicio.tipoAmbulancia,
                                  orElse: () => null,
                                );

                            tipoAmbulanciaDisplay = tipo?.nombre ?? 'Tipo desconocido';
                          }

                          return _InfoRow(
                            label: 'Tipo Ambulancia',
                            value: tipoAmbulanciaDisplay,
                          );
                        },
                      ),
                      const Divider(height: 1, color: AppColors.gray200),
                    ],
                    _InfoRow(
                      label: 'Necesita ayuda',
                      value: servicio.requiereAyuda ? 'Sí' : 'No',
                      valueWidget: servicio.requiereAyuda
                          ? const Icon(
                              Icons.check_circle,
                              size: 16,
                              color: AppColors.success,
                            )
                          : const Icon(
                              Icons.cancel,
                              size: 16,
                              color: AppColors.gray400,
                            ),
                    ),
                    if (servicio.diasSemana != null &&
                        servicio.diasSemana!.isNotEmpty) ...<Widget>[
                      const Divider(height: 1, color: AppColors.gray200),
                      _InfoRow(
                        label: 'Días de la Semana',
                        value: formatDiasSemana(),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Columna derecha: Horarios
              Expanded(
                child: _InfoCard(
                  title: 'Horarios',
                  icon: Icons.access_time_outlined,
                  iconColor: AppColors.primary,
                  children: <Widget>[
                    if (servicio.horaRecogida != null) ...<Widget>[
                      _InfoRow(
                        label: 'Hora en Centro',
                        value: _formatHora(servicio.horaRecogida!),
                      ),
                    ],
                    if (servicio.requiereVuelta &&
                        servicio.horaVuelta != null) ...<Widget>[
                      const Divider(height: 1, color: AppColors.gray200),
                      _InfoRow(
                        label: 'Hora Vuelta',
                        value: _formatHora(servicio.horaVuelta!),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Equipamiento (ancho completo si existe)
          if (servicio.requiereSillaRuedas ||
              servicio.requiereCamilla ||
              servicio.requiereAcompanante) ...<Widget>[
            const SizedBox(height: 12),
            _InfoCard(
              title: 'Equipamiento/Requisitos',
              icon: Icons.medical_services_outlined,
              iconColor: AppColors.primary,
              children: <Widget>[
                if (servicio.requiereSillaRuedas)
                  const _InfoRow(
                    label: 'Silla de Ruedas',
                    value: 'Sí',
                    valueWidget: Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.success,
                    ),
                  ),
                if (servicio.requiereCamilla) ...<Widget>[
                  const Divider(height: 1, color: AppColors.gray200),
                  const _InfoRow(
                    label: 'Camilla',
                    value: 'Sí',
                    valueWidget: Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.success,
                    ),
                  ),
                ],
                if (servicio.requiereAcompanante) ...<Widget>[
                  const Divider(height: 1, color: AppColors.gray200),
                  const _InfoRow(
                    label: 'Acompañante',
                    value: 'Sí',
                    valueWidget: Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Tarjeta de información agrupada
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Header de la tarjeta
          DecoratedBox(
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusSmall),
                topRight: Radius.circular(AppSizes.radiusSmall),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: AppSizes.paddingSmall,
              ),
              child: Row(
                children: <Widget>[
                  Icon(icon, size: 18, color: iconColor),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppSizes.fontSmall,
                      fontWeight: FontWeight.w700,
                      color: iconColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenido
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila de información dentro de una tarjeta (diseño compacto y profesional)
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueWidget,
  });

  final String label;
  final String value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Label (flexible en lugar de ancho fijo)
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: AppSizes.fontSmall,
                color: AppColors.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(width: AppSizes.spacing),

          // Value (ocupa espacio proporcional)
          Expanded(
            flex: 3,
            child: valueWidget ??
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: AppSizes.fontSmall,
                    color: AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

/// Badge de estado
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingSmall,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.check_circle, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tab con trayectos y excepciones
class _TrayectosExcepcionesTab extends StatefulWidget {
  const _TrayectosExcepcionesTab({required this.servicio});

  final ServicioEntity servicio;

  @override
  State<_TrayectosExcepcionesTab> createState() => _TrayectosExcepcionesTabState();
}

class _TrayectosExcepcionesTabState extends State<_TrayectosExcepcionesTab>
    with TickerProviderStateMixin {
  late TabController _trayectosTabController;
  final TrasladoDataSource _trasladoDataSource = TrasladoDataSourceFactory.createSupabase();

  List<TrasladoEntity> _trayectosActivos = <TrasladoEntity>[];
  List<TrasladoEntity> _trayectosHistorico = <TrasladoEntity>[];
  List<TrasladoEntity> _todosTrayectos = <TrasladoEntity>[];
  bool _isLoading = true;
  String? _error;
  int _selectedTrayectoTab = 0;
  int? _selectedRowIndex;
  bool _sortAscending = true; // Ordenación ascendente por defecto

  @override
  void initState() {
    super.initState();
    _trayectosTabController = TabController(length: 3, vsync: this);
    _trayectosTabController.addListener(() {
      if (_trayectosTabController.indexIsChanging) {
        setState(() {
          _selectedTrayectoTab = _trayectosTabController.index;
          _selectedRowIndex = null; // Resetear selección al cambiar de tab
        });
      }
    });
    _loadTrayectos();
  }

  @override
  void dispose() {
    _trayectosTabController.dispose();
    super.dispose();
  }

  Future<void> _loadTrayectos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final String servicioId = widget.servicio.id ?? '';
      debugPrint('🔍 Cargando trayectos para servicio ID: "$servicioId"');
      debugPrint('🔍 Servicio codigo: ${widget.servicio.codigo}');
      debugPrint('🔍 Tipo de recurrencia: ${widget.servicio.tipoRecurrencia}');

      List<TrasladoEntity> trayectos = <TrasladoEntity>[];

      // Buscar traslados directamente por id_servicio (funciona para ambos: únicos y recurrentes)
      debugPrint('🔍 Buscando traslados por id_servicio: "$servicioId"');
      final List<PostgrestMap> trasladosResponse = await Supabase.instance.client
          .from('traslados')
          .select()
          .eq('id_servicio', servicioId)
          .order('fecha', ascending: true);

      if (trasladosResponse.isNotEmpty) {
        debugPrint('📄 Primer traslado JSON: ${trasladosResponse.first}');
        trayectos = trasladosResponse
            .map((PostgrestMap json) => TrasladoSupabaseModel.fromJson(json).toEntity())
            .toList();
        debugPrint('✅ Trayectos cargados: ${trayectos.length}');
      } else {
        debugPrint('⚠️ No se encontraron trayectos para este servicio');
      }

      if (trayectos.isNotEmpty) {
        debugPrint('📋 Primeros trayectos:');
        for (final TrasladoEntity t in trayectos.take(3)) {
          debugPrint('  - ${t.codigo}: ${t.origen} → ${t.destino} (Estado: ${t.estado})');
        }
      }

      // Estados considerados "en curso" (activos)
      const Set<String> estadosEnCurso = <String>{
        'pendiente',
        'asignado',
        'recibido_conductor',
        'en_origen',
        'saliendo_origen',
        'en_destino',
      };
      final List<TrasladoEntity> activos = trayectos.where((TrasladoEntity t) => estadosEnCurso.contains(t.estado)).toList();
      final List<TrasladoEntity> historico = trayectos.where((TrasladoEntity t) => !estadosEnCurso.contains(t.estado)).toList();

      setState(() {
        _trayectosActivos = activos;
        _trayectosHistorico = historico;
        _todosTrayectos = trayectos;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error al cargar trayectos: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Verifica si dos fechas son del mismo día
  bool _isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) {
      return false;
    }
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Sección de TRAYECTOS (arriba)
        Expanded(
          flex: 2,
          child: _buildTrayectosSection(),
        ),

        const SizedBox(height: AppSizes.spacing),

        // Sección de fechas excluidas/incluidas (abajo)
        Expanded(
          child: ServicioFechasExcepcionPanel(
            servicioId: widget.servicio.id ?? '',
            onChanged: _loadTrayectos,
          ),
        ),
      ],
    );
  }

  /// Sección de trayectos con tabla
  Widget _buildTrayectosSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.gray200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header de sección con tabs
          Row(
            children: <Widget>[
              const Text(
                'TRAYECTOS',
                style: TextStyle(
                  fontSize: AppSizes.fontSmall,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const Spacer(),
              // Tabs de filtro
              InkWell(
                onTap: () => _trayectosTabController.animateTo(0),
                child: _buildFilterChip(
                  'Trayectos Activos: ${_trayectosActivos.length}',
                  isActive: _selectedTrayectoTab == 0,
                ),
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              InkWell(
                onTap: () => _trayectosTabController.animateTo(1),
                child: _buildFilterChip(
                  'Histórico de Trayectos',
                  isActive: _selectedTrayectoTab == 1,
                ),
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              InkWell(
                onTap: () => _trayectosTabController.animateTo(2),
                child: _buildFilterChip(
                  'Todos los Trayectos',
                  isActive: _selectedTrayectoTab == 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing),

          // Contenido de tabla
          Expanded(
            child: _isLoading
                ? const Center(child: AppLoadingIndicator(message: 'Cargando trayectos...'))
                : _error != null
                    ? _buildErrorView()
                    : _buildTrayectosTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: AppSizes.spacing),
          const Text(
            'Error al cargar trayectos',
            style: TextStyle(
              fontSize: AppSizes.fontMedium,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            _error ?? 'Error desconocido',
            style: const TextStyle(
              fontSize: AppSizes.fontSmall,
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spacing),
          ElevatedButton.icon(
            onPressed: _loadTrayectos,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrayectosTable() {
    return TabBarView(
      controller: _trayectosTabController,
      children: <Widget>[
        _buildTrayectosList(_trayectosActivos),
        _buildTrayectosList(_trayectosHistorico),
        _buildTrayectosList(_todosTrayectos),
      ],
    );
  }

  /// Maneja las acciones del menú de trayectos
  Future<void> _handleTrayectoAction(String action, TrasladoEntity trayecto) async {
    debugPrint('🎬 Acción seleccionada: $action para trayecto ${trayecto.id}');

    try {
      String nuevoEstado;

      switch (action) {
        case 'cancelar':
          nuevoEstado = 'cancelado';
          break;
        case 'anular':
          // Anular: marcarlo como anulado (definitivo)
          nuevoEstado = 'anulado';
          break;
        case 'recuperar':
          // Recuperar: volver a pendiente para que pueda ser reasignado
          nuevoEstado = 'pendiente';
          break;
        case 'analizar':
          // Mostrar diálogo de análisis del trayecto
          if (mounted) {
            await showDialog<void>(
              context: context,
              builder: (BuildContext context) => _TrayectoAnalisisDialog(
                trayecto: trayecto,
                servicio: widget.servicio,
              ),
            );
          }
          return;
        case 'eliminar':
          // Confirmar antes de eliminar (con diálogo profesional de doble confirmación)
          final bool? confirmado = await showConfirmationDialog(
            context: context,
            title: 'Confirmar Eliminación',
            message: '¿Estás seguro de que deseas eliminar este trayecto? Esta acción no se puede deshacer.',
            itemDetails: <String, String>{
              'Código': trayecto.codigo ?? 'Sin código',
              'Tipo': trayecto.tipoTraslado ?? 'Sin tipo',
              if (trayecto.fecha != null)
                'Fecha': DateFormat('dd/MM/yyyy').format(trayecto.fecha!),
              if (trayecto.horaProgramada != null)
                'Hora': DateFormat('HH:mm').format(trayecto.horaProgramada!),
              if (trayecto.origen != null && trayecto.origen!.isNotEmpty)
                'Origen': trayecto.origen!,
              if (trayecto.destino != null && trayecto.destino!.isNotEmpty)
                'Destino': trayecto.destino!,
              'Estado': (EstadoTraslado.fromValue(trayecto.estado)?.label ?? trayecto.estado ?? 'Desconocido').toUpperCase(),
            },
            warningMessage: '⚠️ El trayecto será eliminado permanentemente de la base de datos.',
          );

          if (confirmado != true) {
            return;
          }

          // Eliminar (hard delete - elimina de la base de datos)
          await _trasladoDataSource.hardDelete(trayecto.id);

          if (mounted) {
            // ✅ OPTIMIZACIÓN: Eliminar solo el trayecto de las listas locales
            setState(() {
              _trayectosActivos.removeWhere((TrasladoEntity t) => t.id == trayecto.id);
              _trayectosHistorico.removeWhere((TrasladoEntity t) => t.id == trayecto.id);
              _todosTrayectos.removeWhere((TrasladoEntity t) => t.id == trayecto.id);
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Trayecto eliminado exitosamente'),
                backgroundColor: AppColors.success,
              ),
            );
          }

          return;
        case 'editar':
          // Mostrar formulario de edición
          if (mounted) {
            await showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext dialogContext) {
                return TrayectoFormDialog(
                  trayecto: trayecto,
                  onSave: (TrasladoEntity trayectoActualizado) {
                    // ✅ OPTIMIZACIÓN: Actualizar solo el trayecto modificado
                    setState(() {
                      final int indexActivos = _trayectosActivos.indexWhere((TrasladoEntity t) => t.id == trayectoActualizado.id);
                      final int indexHistorico = _trayectosHistorico.indexWhere((TrasladoEntity t) => t.id == trayectoActualizado.id);
                      final int indexTodos = _todosTrayectos.indexWhere((TrasladoEntity t) => t.id == trayectoActualizado.id);

                      if (indexActivos != -1) {
                        _trayectosActivos[indexActivos] = trayectoActualizado;
                      }
                      if (indexHistorico != -1) {
                        _trayectosHistorico[indexHistorico] = trayectoActualizado;
                      }
                      if (indexTodos != -1) {
                        _todosTrayectos[indexTodos] = trayectoActualizado;
                      }
                    });

                    // Mostrar mensaje de éxito
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Trayecto actualizado exitosamente'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                );
              },
            );
          }
          return;
        default:
          debugPrint('⚠️ Acción no reconocida: $action');
          return;
      }

      // Actualizar estado del trayecto
      final TrasladoEntity trayectoActualizado = await _trasladoDataSource.updateEstado(
        id: trayecto.id,
        nuevoEstado: nuevoEstado,
      );

      debugPrint('✅ Trayecto ${trayecto.codigo} actualizado a estado: $nuevoEstado');

      // ✅ OPTIMIZACIÓN: Actualizar solo el trayecto modificado en lugar de recargar todo
      if (mounted) {
        setState(() {
          // Actualizar en todas las listas
          final int indexActivos = _trayectosActivos.indexWhere((TrasladoEntity t) => t.id == trayecto.id);
          final int indexHistorico = _trayectosHistorico.indexWhere((TrasladoEntity t) => t.id == trayecto.id);
          final int indexTodos = _todosTrayectos.indexWhere((TrasladoEntity t) => t.id == trayecto.id);

          // Actualizar en lista correspondiente
          if (indexActivos != -1) {
            _trayectosActivos[indexActivos] = trayectoActualizado;
          }
          if (indexHistorico != -1) {
            _trayectosHistorico[indexHistorico] = trayectoActualizado;
          }
          if (indexTodos != -1) {
            _todosTrayectos[indexTodos] = trayectoActualizado;
          }

          // Si el estado cambió a inactivo (cancelado/anulado/finalizado), moverlo de activos a histórico
          final bool esInactivo = nuevoEstado == 'cancelado' ||
                                  nuevoEstado == 'anulado' ||
                                  nuevoEstado == 'finalizado';

          if (esInactivo && indexActivos != -1) {
            _trayectosActivos.removeAt(indexActivos);
            _trayectosHistorico.insert(0, trayectoActualizado);
          }

          // Si recuperamos (pendiente) y estaba en histórico, moverlo a activos
          if (nuevoEstado == 'pendiente' && indexHistorico != -1) {
            _trayectosHistorico.removeAt(indexHistorico);
            _trayectosActivos.insert(0, trayectoActualizado);
          }
        });

        // Si cancelamos, anulamos o finalizamos desde "Trayectos Activos", cambiar al tab "Todos los Trayectos"
        if (_selectedTrayectoTab == 0 && (nuevoEstado == 'cancelado' || nuevoEstado == 'anulado' || nuevoEstado == 'finalizado')) {
          _trayectosTabController.animateTo(2);
        }
      }
    } catch (e) {
      debugPrint('❌ Error al ejecutar acción $action: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _toggleSort() {
    setState(() {
      _sortAscending = !_sortAscending;
    });
  }

  Widget _buildTrayectosList(List<TrasladoEntity> trayectos) {
    if (trayectos.isEmpty) {
      return const Center(
        child: Text(
          'No hay trayectos',
          style: TextStyle(
            fontSize: AppSizes.fontSmall,
            color: AppColors.textSecondaryLight,
          ),
        ),
      );
    }

    // Ordenar trayectos por fecha y hora programada
    final List<TrasladoEntity> trayectosOrdenados = List<TrasladoEntity>.from(trayectos)
      ..sort((TrasladoEntity a, TrasladoEntity b) {
        // Primero ordenar por fecha
        final DateTime fechaA = a.fecha ?? DateTime(2000);
        final DateTime fechaB = b.fecha ?? DateTime(2000);
        final int fechaComparison = fechaA.compareTo(fechaB);

        // Si las fechas son iguales, ordenar por hora programada
        if (fechaComparison == 0) {
          final DateTime horaA = a.horaProgramada ?? DateTime(2000);
          final DateTime horaB = b.horaProgramada ?? DateTime(2000);
          final int horaComparison = horaA.compareTo(horaB);
          return _sortAscending ? horaComparison : -horaComparison;
        }

        return _sortAscending ? fechaComparison : -fechaComparison;
      });

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Column(
        children: <Widget>[
          // Header de tabla
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingSmall,
              vertical: AppSizes.paddingSmall,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusSmall),
                topRight: Radius.circular(AppSizes.radiusSmall),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: _toggleSort,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          'Fecha',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppSizes.fontSmall,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                const Expanded(flex: 2, child: _TrayectoHeaderCell('Estado')),
                const Expanded(child: _TrayectoHeaderCell('I/V')),
                const Expanded(child: _TrayectoHeaderCell('H. Prog')),
                const Expanded(child: _TrayectoHeaderCell('H. Rec')),
                const Expanded(child: _TrayectoHeaderCell('H. Tras')),
                const Expanded(child: _TrayectoHeaderCell('Vehículo')),
                const Expanded(child: _TrayectoHeaderCell('Conductor')),
                const Expanded(child: _TrayectoHeaderCell('Acciones')),
              ],
            ),
          ),

          // Filas de datos agrupadas por fecha
          Expanded(
            child: ListView.builder(
              itemCount: trayectosOrdenados.length,
              itemBuilder: (BuildContext context, int index) {
                final TrasladoEntity trayecto = trayectosOrdenados[index];
                final TrasladoEntity? prevTrayecto = index > 0 ? trayectosOrdenados[index - 1] : null;

                // Verificar si es un nuevo grupo de fecha
                final bool isNewGroup = prevTrayecto == null ||
                    !_isSameDay(prevTrayecto.fecha, trayecto.fecha);

                // Alternar color solo dentro del mismo grupo de fecha
                final bool isEven = index % 2 == 0;

                return Column(
                  children: <Widget>[
                    // Separador visual entre grupos de fechas
                    if (isNewGroup && index > 0)
                      Container(
                        height: 3,
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    _buildTrayectoRow(trayecto, index, isEven),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.gray200,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: isActive ? Colors.white : AppColors.textSecondaryLight,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildTrayectoRow(TrasladoEntity trayecto, int index, bool isEven) {
    final bool isSelected = _selectedRowIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRowIndex = isSelected ? null : index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : (isEven ? AppColors.surfaceLight : Colors.white),
          border: Border(
            bottom: const BorderSide(color: AppColors.gray200),
            left: isSelected
                ? const BorderSide(color: AppColors.primary, width: 3)
                : BorderSide.none,
          ),
        ),
        child: Row(
        children: <Widget>[
          // Fecha
          Expanded(
            flex: 2,
            child: _TrayectoDataCell(
              trayecto.fecha != null
                  ? DateFormat('dd/MM/yyyy').format(trayecto.fecha!)
                  : 'Sin fecha',
            ),
          ),
          // Estado
          Expanded(
            flex: 2,
            child: _TrayectoStatusCell(
              EstadoTraslado.fromValue(trayecto.estado)?.label ?? trayecto.estado ?? 'Desconocido'
            ),
          ),
          // Ida/Vuelta
          Expanded(
            child: _TrayectoIdaVueltaCell(
              trayecto.tipoTraslado ?? 'Sin tipo',
            ),
          ),
          // Hora Programada
          Expanded(
            child: _TrayectoDataCell(
              trayecto.horaProgramada != null
                  ? DateFormat('HH:mm').format(trayecto.horaProgramada!)
                  : 'Sin hora',
              textAlign: TextAlign.center,
            ),
          ),
          // H. Recogida
          Expanded(
            child: _TrayectoDataCell(
              trayecto.fechaSaliendoOrigen != null
                  ? DateFormat('HH:mm').format(trayecto.fechaSaliendoOrigen!.toLocal())
                  : '-',
              textAlign: TextAlign.center,
            ),
          ),
          // H. Llegada
          Expanded(
            child: _TrayectoDataCell(
              trayecto.fechaEnDestino != null
                  ? DateFormat('HH:mm').format(trayecto.fechaEnDestino!.toLocal())
                  : '-',
              textAlign: TextAlign.center,
            ),
          ),
          // Vehículo
          Expanded(
            child: _TrayectoDataCell(trayecto.idVehiculo ?? '-'),
          ),
          // Conductor
          Expanded(
            child: _TrayectoDataCell(trayecto.conductorNombre ?? trayecto.idConductor ?? '-'),
          ),
          // Acciones
          Expanded(
            child: _TrayectoAccionesCell(
              trayecto: trayecto,
              onAction: (String action) => _handleTrayectoAction(action, trayecto),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

/// Celda de header de tabla de trayectos
class _TrayectoHeaderCell extends StatelessWidget {
  const _TrayectoHeaderCell(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Celda de datos de tabla de trayectos
class _TrayectoDataCell extends StatelessWidget {
  const _TrayectoDataCell(this.text, {this.textAlign});

  final String text;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textPrimaryLight,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Celda de estado con color
class _TrayectoStatusCell extends StatelessWidget {
  const _TrayectoStatusCell(this.estado);

  final String estado;

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (estado) {
      // Estados inactivos/cancelados - ROJO
      case 'Cancelado':
      case 'Anulado':
        color = AppColors.error;
        icon = Icons.cancel;

      // Estado pendiente - GRIS
      case 'Pendiente':
        color = AppColors.textSecondaryLight;
        icon = Icons.schedule;

      // Estados activos/en curso - VERDE
      case 'Asignado':
        color = AppColors.success;
        icon = Icons.assignment_turned_in;
      case 'Enviado':
        color = AppColors.success;
        icon = Icons.send;
      case 'Recibido por Conductor':
        color = AppColors.success;
        icon = Icons.check_circle;
      case 'En Origen':
        color = AppColors.success;
        icon = Icons.location_on;
      case 'Saliendo de Origen':
        color = AppColors.success;
        icon = Icons.directions_car;
      case 'En Tránsito':
        color = AppColors.success;
        icon = Icons.drive_eta;
      case 'En Destino':
        color = AppColors.success;
        icon = Icons.place;
      case 'Finalizado':
        color = AppColors.success;
        icon = Icons.check_circle;

      // No realizado - AMARILLO
      case 'No Realizado':
        color = AppColors.warning;
        icon = Icons.warning;

      default:
        color = AppColors.textSecondaryLight;
        icon = Icons.info;
    }

    return Row(
      children: <Widget>[
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            estado,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Celda de Ida/Vuelta con colores
class _TrayectoIdaVueltaCell extends StatelessWidget {
  const _TrayectoIdaVueltaCell(this.tipoTraslado);

  final String tipoTraslado;

  @override
  Widget build(BuildContext context) {
    final bool isIda = tipoTraslado.toLowerCase() == 'ida';
    final Color color = isIda ? AppColors.success : AppColors.error;

    return Text(
      tipoTraslado.toUpperCase(),
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: 12,
        color: color,
        fontWeight: FontWeight.w600,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Celda de acciones con menú desplegable
class _TrayectoAccionesCell extends StatelessWidget {
  const _TrayectoAccionesCell({
    required this.trayecto,
    required this.onAction,
  });

  final TrasladoEntity trayecto;
  final void Function(String action) onAction;

  @override
  Widget build(BuildContext context) {
    // Determinar estado del trayecto
    final bool estaCancelado = trayecto.estado == EstadoTraslado.cancelado.value;
    final bool estaAnulado = trayecto.estado == EstadoTraslado.noRealizado.value;
    final bool estaFinalizado = trayecto.estado == EstadoTraslado.finalizado.value;

    // Estado inactivo: cancelado o anulado
    final bool estaInactivo = estaCancelado || estaAnulado;

    // Estado activo: NO está cancelado, anulado ni finalizado
    final bool estaActivo = !estaCancelado && !estaAnulado && !estaFinalizado;

    final List<ActionMenuItem> items = <ActionMenuItem>[
      // Editar (siempre disponible) - ✏️
      const ActionMenuItem(
        value: 'editar',
        label: '✏️ Editar',
      ),
    ];

    if (estaInactivo) {
      // Está cancelado o anulado → Mostrar Recuperar - ♻️
      items.add(
        const ActionMenuItem(
          value: 'recuperar',
          label: '♻️ Recuperar',
          description: 'Recuperar trayecto',
        ),
      );
    } else if (estaActivo) {
      // Está activo → Mostrar Cancelar y Anular
      // Cancelar - 🚫
      items
        ..add(
          const ActionMenuItem(
            value: 'cancelar',
            label: '🚫 Cancelar',
            description: 'Cancelar este trayecto',
          ),
        )
        // Anular - ⛔
        ..add(
          const ActionMenuItem(
            value: 'anular',
            label: '⛔ Anular',
            isDanger: true,
            description: 'Anular este trayecto',
          ),
        );
    }

    // Analizar (siempre disponible) - 📊
    items.add(
      const ActionMenuItem(
        value: 'analizar',
        label: '📊 Analizar',
        description: 'Analizar trayecto',
      ),
    );

    return ActionMenu(
      items: items,
      onSelected: onAction,
      tooltip: 'Acciones del trayecto',
    );
  }
}

/// Tab con datos adicionales y registro
class _DatosAdicionalesTab extends StatelessWidget {
  const _DatosAdicionalesTab({required this.servicio});

  final ServicioEntity servicio;

  @override
  Widget build(BuildContext context) {
    // Helper para formatear fechas con hora
    String formatDateTime(DateTime? date) {
      if (date == null) {
        return '-';
      }
      // ✅ Convertir de UTC a hora local antes de formatear
      return DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Información Adicional
          if (servicio.observaciones != null ||
              servicio.observacionesMedicas != null) ...<Widget>[
            _InfoCard(
              title: 'Información Adicional',
              icon: Icons.note_alt_outlined,
              iconColor: AppColors.primary,
              children: <Widget>[
                if (servicio.observaciones != null &&
                    servicio.observaciones!.isNotEmpty) ...<Widget>[
                  _InfoRow(
                    label: 'Observaciones',
                    value: servicio.observaciones!,
                  ),
                ],
                if (servicio.observacionesMedicas != null &&
                    servicio.observacionesMedicas!.isNotEmpty) ...<Widget>[
                  if (servicio.observaciones != null &&
                      servicio.observaciones!.isNotEmpty)
                    const Divider(height: 1, color: AppColors.gray200),
                  _InfoRow(
                    label: 'Observaciones Médicas',
                    value: servicio.observacionesMedicas!,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Registro
          _InfoCard(
            title: 'Registro',
            icon: Icons.history_outlined,
            iconColor: AppColors.primary,
            children: <Widget>[
              if (servicio.createdAt != null) ...<Widget>[
                _InfoRow(
                  label: 'Fecha creación',
                  value: formatDateTime(servicio.createdAt),
                ),
              ],
              if (servicio.updatedAt != null) ...<Widget>[
                const Divider(height: 1, color: AppColors.gray200),
                Builder(
                  builder: (BuildContext context) {
                    debugPrint('🕐 updatedAt RAW: ${servicio.updatedAt}');
                    debugPrint('🕐 updatedAt isUtc: ${servicio.updatedAt!.isUtc}');
                    debugPrint('🕐 updatedAt toLocal: ${servicio.updatedAt!.toLocal()}');
                    debugPrint('🕐 formatDateTime result: ${formatDateTime(servicio.updatedAt)}');
                    return _InfoRow(
                      label: 'Última modificación',
                      value: formatDateTime(servicio.updatedAt),
                    );
                  },
                ),
              ],
              if (servicio.archivedAt != null) ...<Widget>[
                const Divider(height: 1, color: AppColors.gray200),
                _InfoRow(
                  label: 'Archivado',
                  value: formatDateTime(servicio.archivedAt),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Diálogo de análisis detallado del trayecto
class _TrayectoAnalisisDialog extends StatefulWidget {
  const _TrayectoAnalisisDialog({
    required this.trayecto,
    required this.servicio,
  });

  final TrasladoEntity trayecto;
  final ServicioEntity servicio;

  @override
  State<_TrayectoAnalisisDialog> createState() => _TrayectoAnalisisDialogState();
}

class _TrayectoAnalisisDialogState extends State<_TrayectoAnalisisDialog> {
  String? _localidadNombre;

  @override
  void initState() {
    super.initState();
    _loadLocalidadNombre();
  }

  /// Carga el nombre de la localidad del paciente desde Supabase
  Future<void> _loadLocalidadNombre() async {
    final String? localidadId = widget.servicio.paciente?.localidadId;

    debugPrint('🔍 _loadLocalidadNombre - localidadId: $localidadId');
    debugPrint('🔍 _loadLocalidadNombre - paciente completo: ${widget.servicio.paciente}');

    if (localidadId == null || localidadId.isEmpty) {
      debugPrint('⚠️ localidadId es null o vacío');
      return;
    }

    try {
      debugPrint('📡 Consultando tpoblaciones con id: $localidadId');
      final Map<String, dynamic>? response = await Supabase.instance.client
          .from('tpoblaciones')
          .select('nombre')
          .eq('id', localidadId)
          .maybeSingle();

      debugPrint('📥 Respuesta de Supabase: $response');

      if (response != null && mounted) {
        final String? nombre = response['nombre'] as String?;
        debugPrint('✅ Localidad encontrada: $nombre');
        setState(() {
          _localidadNombre = nombre;
        });
      } else {
        debugPrint('⚠️ No se encontró localidad o widget no montado');
      }
    } catch (e) {
      debugPrint('❌ Error al cargar localidad: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final DateFormat dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Container(
        width: 900,
        constraints: const BoxConstraints(maxHeight: 800),
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Header
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.analytics,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSizes.spacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Análisis Detallado del Trayecto',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        'Código: ${widget.trayecto.codigo}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacing),
            const Divider(),
            const SizedBox(height: AppSizes.spacing),

            // Contenido scrolleable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // SECCIÓN: Información General y Recursos Asignados (lado a lado)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: _buildSection(
                            title: '📋 Información General',
                            children: <Widget>[
                              _buildInfoRow('Estado', EstadoTraslado.fromValue(widget.trayecto.estado)?.label ?? widget.trayecto.estado ?? 'Desconocido'),
                              _buildInfoRow('Tipo', widget.trayecto.tipoTraslado ?? 'Sin tipo'),
                              _buildInfoRow('Fecha', widget.trayecto.fecha != null ? dateFormat.format(widget.trayecto.fecha!) : 'Sin fecha'),
                              _buildInfoRow('Hora Programada', widget.trayecto.horaProgramada != null ? DateFormat('HH:mm').format(widget.trayecto.horaProgramada!) : 'Sin hora'),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSizes.spacing),
                        Expanded(
                          child: _buildSection(
                            title: '👥 Recursos Asignados',
                            children: <Widget>[
                              _buildInfoRow('Conductor', widget.trayecto.conductorNombre ?? widget.trayecto.idConductor ?? 'Sin asignar'),
                              _buildInfoRow('Vehículo', widget.trayecto.vehiculoMatricula ?? widget.trayecto.idVehiculo ?? 'Sin asignar'),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // SECCIÓN: Origen y Destino
                    _buildSection(
                      title: '📍 Origen y Destino',
                      children: <Widget>[
                        _buildInfoRow(
                          'Origen',
                          _formatUbicacion(
                            tipo: widget.trayecto.tipoOrigen,
                            ubicacion: widget.trayecto.origen,
                            domicilioPaciente: widget.servicio.paciente?.domicilioDireccion,
                            localidadNombre: _localidadNombre,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacingSmall),
                        _buildInfoRow(
                          'Destino',
                          _formatUbicacion(
                            tipo: widget.trayecto.tipoDestino,
                            ubicacion: widget.trayecto.destino,
                            domicilioPaciente: widget.servicio.paciente?.domicilioDireccion,
                            localidadNombre: _localidadNombre,
                          ),
                        ),
                      ],
                    ),

                    // SECCIÓN: Kilometraje y Duración
                    if (widget.trayecto.kilometrosRecorridos != null || widget.trayecto.tiempoViajeMinutos != null || widget.trayecto.tiempoEsperaOrigenMinutos != null)
                      _buildSection(
                        title: '🛣️ Métricas del Trayecto',
                        children: <Widget>[
                          if (widget.trayecto.kilometrosRecorridos != null)
                            _buildInfoRow('KM Recorridos', widget.trayecto.kilometrosRecorridos!.toStringAsFixed(2)),
                          if (widget.trayecto.tiempoViajeMinutos != null)
                            _buildInfoRow('Tiempo de Viaje', '${widget.trayecto.tiempoViajeMinutos} min'),
                          if (widget.trayecto.tiempoEsperaOrigenMinutos != null)
                            _buildInfoRow('Tiempo de Espera', '${widget.trayecto.tiempoEsperaOrigenMinutos} min'),
                        ],
                      ),

                    // SECCIÓN: Cronología del Trayecto (COMPLETA - siempre visible)
                    _buildSection(
                      title: '📅 Cronología del Trayecto',
                      children: <Widget>[
                        // Estados activos del ciclo de vida normal
                        _buildInfoRow(
                          'Enviado',
                          widget.trayecto.fechaEnviado != null
                              ? dateTimeFormat.format(widget.trayecto.fechaEnviado!)
                              : 'Pendiente',
                        ),
                        _buildInfoRow(
                          'Recibido por Conductor',
                          widget.trayecto.fechaRecibidoConductor != null
                              ? dateTimeFormat.format(widget.trayecto.fechaRecibidoConductor!)
                              : 'Pendiente',
                        ),
                        _buildInfoRow(
                          'En Origen',
                          widget.trayecto.fechaEnOrigen != null
                              ? dateTimeFormat.format(widget.trayecto.fechaEnOrigen!)
                              : 'Pendiente',
                        ),
                        _buildInfoRow(
                          'Saliendo de Origen',
                          widget.trayecto.fechaSaliendoOrigen != null
                              ? dateTimeFormat.format(widget.trayecto.fechaSaliendoOrigen!)
                              : 'Pendiente',
                        ),
                        _buildInfoRow(
                          'En Destino',
                          widget.trayecto.fechaEnDestino != null
                              ? dateTimeFormat.format(widget.trayecto.fechaEnDestino!)
                              : 'Pendiente',
                        ),
                        _buildInfoRow(
                          'Finalizado',
                          widget.trayecto.fechaFinalizado != null
                              ? dateTimeFormat.format(widget.trayecto.fechaFinalizado!)
                              : 'Pendiente',
                        ),

                        // Separador visual para estados anormales
                        const Divider(height: 20, color: AppColors.gray300),
                        const SizedBox(height: 8),

                        // Estados de finalización anormal
                        _buildInfoRow(
                          'Cancelado',
                          widget.trayecto.fechaCancelacion != null
                              ? dateTimeFormat.format(widget.trayecto.fechaCancelacion!)
                              : '-',
                        ),
                        _buildInfoRow(
                          'Suspendido',
                          widget.trayecto.fechaSuspendido != null
                              ? dateTimeFormat.format(widget.trayecto.fechaSuspendido!)
                              : '-',
                        ),
                        _buildInfoRow(
                          'No Realizado',
                          widget.trayecto.fechaNoRealizado != null
                              ? dateTimeFormat.format(widget.trayecto.fechaNoRealizado!)
                              : '-',
                        ),
                      ],
                    ),

                    // SECCIÓN: Observaciones
                    if (widget.trayecto.observaciones != null || widget.trayecto.observacionesMedicas != null)
                      _buildSection(
                        title: '📝 Observaciones',
                        children: <Widget>[
                          if (widget.trayecto.observaciones != null)
                            _buildInfoRow('Generales', widget.trayecto.observaciones!),
                          if (widget.trayecto.observacionesMedicas != null)
                            _buildInfoRow('Médicas', widget.trayecto.observacionesMedicas!),
                        ],
                      ),

                    // SECCIÓN: Motivos de Cancelación
                    if (widget.trayecto.motivoCancelacion != null || widget.trayecto.observacionesCancelacion != null)
                      _buildSection(
                        title: '⚠️ Motivos de Cancelación',
                        children: <Widget>[
                          if (widget.trayecto.motivoCancelacion != null)
                            _buildInfoRow('Motivo', widget.trayecto.motivoCancelacion!),
                          if (widget.trayecto.observacionesCancelacion != null)
                            _buildInfoRow('Observaciones', widget.trayecto.observacionesCancelacion!),
                        ],
                      ),

                    // SECCIÓN: Auditoría
                    _buildSection(
                      title: '🔍 Auditoría',
                      children: <Widget>[
                        if (widget.trayecto.usuarioAsignacion != null)
                          _buildInfoRow('Usuario Asignación', widget.trayecto.usuarioAsignacion!),
                        if (widget.trayecto.fechaAsignacion != null)
                          _buildInfoRow('Fecha Asignación', dateTimeFormat.format(widget.trayecto.fechaAsignacion!)),
                        if (widget.trayecto.usuarioEnvio != null)
                          _buildInfoRow('Usuario Envío', widget.trayecto.usuarioEnvio!),
                        if (widget.trayecto.fechaEnviado != null)
                          _buildInfoRow('Fecha Envío', dateTimeFormat.format(widget.trayecto.fechaEnviado!.toLocal())),
                        if (widget.trayecto.usuarioCancelacion != null)
                          _buildInfoRow('Usuario Cancelación', widget.trayecto.usuarioCancelacion!),
                        if (widget.trayecto.createdAt != null)
                          _buildInfoRow('Creado', dateTimeFormat.format(widget.trayecto.createdAt!.toLocal())),
                        if (widget.trayecto.updatedAt != null)
                          _buildInfoRow('Actualizado', dateTimeFormat.format(widget.trayecto.updatedAt!.toLocal())),
                        if (widget.trayecto.createdBy != null)
                          _buildInfoRow('Creado Por', widget.trayecto.createdBy!),
                        if (widget.trayecto.updatedBy != null)
                          _buildInfoRow('Actualizado Por', widget.trayecto.updatedBy!),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Footer con botón cerrar
            const SizedBox(height: AppSizes.spacing),
            const Divider(),
            const SizedBox(height: AppSizes.spacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                AppButton(
                  onPressed: () => Navigator.of(context).pop(),
                  label: 'Cerrar',
                  variant: AppButtonVariant.text,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacing),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacing),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 200,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Formatea una ubicación (origen/destino) mostrando la dirección completa
  /// Si es domicilio del paciente y hay dirección disponible, la incluye con la población
  String _formatUbicacion({
    required String? tipo,
    required String? ubicacion,
    required String? domicilioPaciente,
    String? localidadNombre,
  }) {
    debugPrint('🗺️ _formatUbicacion llamado:');
    debugPrint('   - tipo: $tipo');
    debugPrint('   - ubicacion: $ubicacion');
    debugPrint('   - domicilioPaciente: $domicilioPaciente');
    debugPrint('   - localidadNombre: $localidadNombre');

    // Si es domicilio del paciente, intentar agregar localidad
    if (tipo == 'domicilio_paciente') {
      // Obtener la dirección (priorizar ubicacion explícita, luego domicilioPaciente)
      final String? direccion = (ubicacion != null && ubicacion.isNotEmpty)
          ? ubicacion
          : domicilioPaciente;

      if (direccion != null && direccion.isNotEmpty) {
        // Si hay localidad disponible, agregarla entre paréntesis
        if (localidadNombre != null && localidadNombre.isNotEmpty) {
          final String resultado = '$direccion ($localidadNombre)';
          debugPrint('   ✅ Retornando con localidad: $resultado');
          return resultado;
        }
        debugPrint('   ⚠️ Retornando sin localidad (localidad vacía/null): $direccion');
        return direccion;
      }
      // Si no hay dirección, mostrar solo "Domicilio del Paciente"
      debugPrint('   ⚠️ Retornando texto genérico: Domicilio del Paciente');
      return 'Domicilio del Paciente';
    }

    // Para otros tipos, usar ubicación tal cual
    if (ubicacion != null && ubicacion.isNotEmpty) {
      debugPrint('   ✅ Retornando ubicacion: $ubicacion');
      return ubicacion;
    }

    // Para otros tipos sin ubicación
    debugPrint('   ⚠️ Retornando "-" (sin datos)');
    return '-';
  }
}

/// Formatea una hora de formato HH:MM:SS a HH:mm
String _formatHora(String hora) {
  // Si ya está en formato HH:mm, retornar tal cual
  if (hora.length == 5 && hora.contains(':')) {
    return hora;
  }

  // Si está en formato HH:MM:SS, extraer HH:mm
  if (hora.length >= 5) {
    return hora.substring(0, 5);
  }

  // Si no cumple ningún formato esperado, retornar tal cual
  return hora;
}
