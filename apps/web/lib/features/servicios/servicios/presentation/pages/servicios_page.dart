import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion_frame/gestion_frame.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/entities/servicio_entity.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/bloc/servicios_bloc.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/bloc/servicios_event.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/bloc/servicios_state.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/servicio_form_wizard_dialog.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/servicios_page_bars.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/servicios_side_panel.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/servicios_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Página de gestión de servicios
class ServiciosPage extends StatelessWidget {
  const ServiciosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ServiciosBloc>(
      create: (_) => getIt<ServiciosBloc>()
        ..add(const ServiciosEvent.estadoFilterChanged(estado: 'ACTIVO')),
      child: const SafeArea(
        child: _ServiciosView(),
      ),
    );
  }
}

/// Vista principal de servicios
class _ServiciosView extends StatefulWidget {
  const _ServiciosView();

  @override
  State<_ServiciosView> createState() => _ServiciosViewState();
}

class _ServiciosViewState extends State<_ServiciosView> {
  DateTime? _pageStartTime;
  String? _selectedServicioId;

  // Filtros
  final TextEditingController _searchController = TextEditingController();
  int? _yearSeleccionado;
  String? _estadoSeleccionado;

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();
    _yearSeleccionado = DateTime.now().year;
    _estadoSeleccionado = 'ACTIVO'; // Estado por defecto
    debugPrint('⏱️ ServiciosPage: Inicio de carga de página');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageStartTime != null) {
        final Duration elapsed = DateTime.now().difference(_pageStartTime!);
        debugPrint('⏱️ Tiempo total de carga de página: ${elapsed.inMilliseconds}ms');
        _pageStartTime = null;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onServicioSelected(String? servicioId) {
    setState(() {
      _selectedServicioId = servicioId;
    });
  }

  void _applyFilters() {
    debugPrint('🔍 Aplicando filtros: búsqueda=${_searchController.text}, año=$_yearSeleccionado, estado=$_estadoSeleccionado');

    final ServiciosBloc bloc = context.read<ServiciosBloc>();

    // Aplicar búsqueda
    if (_searchController.text.isNotEmpty) {
      bloc.add(ServiciosEvent.searchChanged(query: _searchController.text));
      return;
    }

    // Aplicar filtro de año
    if (_yearSeleccionado != null && _estadoSeleccionado == null) {
      bloc.add(ServiciosEvent.yearFilterChanged(year: _yearSeleccionado));
      return;
    }

    // Aplicar filtro de estado
    if (_estadoSeleccionado != null) {
      bloc.add(ServiciosEvent.estadoFilterChanged(estado: _estadoSeleccionado));
      return;
    }

    // Sin filtros, cargar todos
    bloc.add(const ServiciosEvent.loadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiciosBloc, ServiciosState>(
      builder: (BuildContext context, ServiciosState state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: GestionFrame(
            toolbar: ServiciosToolbar(
              state: state,
              onNuevo: _showNewServicioDialog,
              onEditar: (ServicioEntity s) => _handleEditar(context, s),
              onEliminar: (ServicioEntity s) => _handleEliminar(context, s),
              onFinalizar: (ServicioEntity s) => _handleFinalizar(context, s),
              onSuspender: (ServicioEntity s) => _handleSuspender(context, s),
              onReanudar: (ServicioEntity s) => _handleReanudar(context, s),
              onExcluir: (ServicioEntity s) => _handleExcluir(context, s),
            ),
            filterBar: ServiciosFilterBar(
              searchController: _searchController,
              onSearchChanged: (_) => _applyFilters(),
              year: _yearSeleccionado,
              onYearChanged: (int value) {
                setState(() => _yearSeleccionado = value);
                _applyFilters();
              },
              estado: _estadoSeleccionado,
              onEstadoChanged: (String? value) {
                setState(() => _estadoSeleccionado = value);
                _applyFilters();
              },
            ),
            statusBar: ServiciosStatusBar(state: state),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Contenido principal: Tabla (50%) + Panel lateral (50%)
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Tabla de servicios (izquierda - 50%)
                      Expanded(
                        flex: 5,
                        child: ServiciosTable(
                          onServicioSelected: _onServicioSelected,
                        ),
                      ),

                      const SizedBox(width: AppSizes.spacingSmall),

                      // Panel lateral derecho con pestañas (50%)
                      Expanded(
                        flex: 5,
                        child: ServiciosSidePanel(
                          servicioId: _selectedServicioId,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showNewServicioDialog() async {
    debugPrint('=== Botón Nuevo Servicio presionado ===');

    // Abrir formulario wizard (4 pasos)
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BlocProvider<ServiciosBloc>.value(
          value: context.read<ServiciosBloc>(),
          child: const ServicioFormWizardDialog(),
        );
      },
    );

    // Recargar servicios si se creó uno nuevo
    if (mounted) {
      context.read<ServiciosBloc>().add(const ServiciosEvent.loadRequested());
    }
  }

  /// Maneja la edición de un servicio
  Future<void> _handleEditar(BuildContext context, ServicioEntity servicio) async {
    debugPrint('🖊️ Editar servicio: ${servicio.codigo} (${servicio.id})');

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return ServicioFormWizardDialog(
          servicio: servicio, // Pasar servicio para modo edición
        );
      },
    );

    // Refrescar lista después de editar
    if (context.mounted) {
      context.read<ServiciosBloc>().add(const ServiciosEvent.loadRequested());
    }
  }

  /// Maneja la eliminación de un servicio
  Future<void> _handleEliminar(BuildContext context, ServicioEntity servicio) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message:
          '¿Estás seguro de que deseas eliminar este servicio? Esta acción eliminará todos los trayectos asociados.',
      itemDetails: <String, String>{
        if (servicio.codigo != null) 'Código': servicio.codigo!,
        if (servicio.tipoRecurrencia != null)
          'Tipo': servicio.tipoRecurrencia!,
        if (servicio.fechaServicioInicio != null)
          'Fecha Inicio':
              DateFormat('dd/MM/yyyy').format(servicio.fechaServicioInicio!),
        'Estado': servicio.estado.toUpperCase(),
      },
      warningMessage: '⚠️ Esta acción no se puede deshacer',
    );

    if (confirmed == true && context.mounted) {
      context.read<ServiciosBloc>().add(
            ServiciosEvent.deleteRequested(id: servicio.id!),
          );
    }
  }

  /// Maneja la finalización de un servicio
  Future<void> _handleFinalizar(BuildContext context, ServicioEntity servicio) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Finalización',
      message:
          '¿Deseas finalizar este servicio? El servicio se marcará como FINALIZADO y no se generarán más trayectos.',
      itemDetails: <String, String>{
        if (servicio.codigo != null) 'Código': servicio.codigo!,
        if (servicio.tipoRecurrencia != null)
          'Tipo': servicio.tipoRecurrencia!,
        if (servicio.fechaServicioInicio != null)
          'Fecha Inicio':
              DateFormat('dd/MM/yyyy').format(servicio.fechaServicioInicio!),
      },
      confirmText: 'Finalizar',
      confirmButtonColor: AppColors.info,
      icon: Icons.done_all,
      iconColor: AppColors.info,
    );

    if (confirmed == true && context.mounted) {
      context.read<ServiciosBloc>().add(
            ServiciosEvent.updateEstadoRequested(
              id: servicio.id!,
              estado: 'FINALIZADO',
            ),
          );
    }
  }

  /// Maneja la suspensión de un servicio
  Future<void> _handleSuspender(BuildContext context, ServicioEntity servicio) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Suspensión',
      message:
          '¿Deseas suspender este servicio? Los trayectos ya generados no se cancelarán, pero no se crearán nuevos trayectos.',
      itemDetails: <String, String>{
        if (servicio.codigo != null) 'Código': servicio.codigo!,
        if (servicio.tipoRecurrencia != null)
          'Tipo': servicio.tipoRecurrencia!,
        if (servicio.fechaServicioInicio != null)
          'Fecha Inicio':
              DateFormat('dd/MM/yyyy').format(servicio.fechaServicioInicio!),
      },
      confirmText: 'Suspender',
      confirmButtonColor: AppColors.warning,
      iconColor: AppColors.warning,
    );

    if (confirmed == true && context.mounted) {
      context.read<ServiciosBloc>().add(
            ServiciosEvent.updateEstadoRequested(
              id: servicio.id!,
              estado: 'SUSPENDIDO',
            ),
          );
    }
  }

  /// Maneja la reanudación de un servicio suspendido
  Future<void> _handleReanudar(BuildContext context, ServicioEntity servicio) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Reanudación',
      message:
          '¿Deseas reanudar este servicio? Se regenerarán los trayectos desde hoy en adelante.',
      itemDetails: <String, String>{
        if (servicio.codigo != null) 'Código': servicio.codigo!,
        if (servicio.tipoRecurrencia != null)
          'Tipo': servicio.tipoRecurrencia!,
        if (servicio.fechaServicioInicio != null)
          'Fecha Inicio':
              DateFormat('dd/MM/yyyy').format(servicio.fechaServicioInicio!),
      },
      confirmText: 'Reanudar',
      confirmButtonColor: AppColors.success,
      iconColor: AppColors.success,
    );

    if (confirmed == true && context.mounted) {
      context.read<ServiciosBloc>().add(
            ServiciosEvent.reanudarRequested(id: servicio.id!),
          );
    }
  }

  /// Maneja la exclusión de fechas de trayectos
  void _handleExcluir(BuildContext context, ServicioEntity servicio) {
    // TODO(dev): Implementar diálogo de exclusión de fechas
    debugPrint('🚫 Excluir trayectos: ${servicio.codigo}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de exclusión en desarrollo'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
