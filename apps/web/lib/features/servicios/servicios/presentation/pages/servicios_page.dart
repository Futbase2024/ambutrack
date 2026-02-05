import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/entities/servicio_entity.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/bloc/servicios_bloc.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/bloc/servicios_event.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/bloc/servicios_state.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/servicio_form_wizard_dialog.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/servicios_side_panel.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/servicios_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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
          body: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.paddingXl,
              AppSizes.paddingXl,
              AppSizes.paddingXl,
              AppSizes.paddingLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Header compacto con botones y filtros
                _buildCompactHeader(state),
                const SizedBox(height: AppSizes.spacing),

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

                      const SizedBox(width: AppSizes.spacing),

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

  /// Construye el header compacto con título, filtros y botones de acción en una línea
  Widget _buildCompactHeader(ServiciosState state) {
    // Obtener servicio seleccionado desde el estado
    final ServicioEntity? selectedServicio = state.maybeWhen(
      loaded: (
        List<ServicioEntity> servicios,
        String searchQuery,
        int? yearFilter,
        String? estadoFilter,
        bool isRefreshing,
        ServicioEntity? selectedServicio,
        bool isLoadingDetails,
      ) =>
          selectedServicio,
      orElse: () => null,
    );

    final bool hasSelection = selectedServicio != null;
    final bool isActive = hasSelection && selectedServicio.estado == 'ACTIVO';
    final bool isSuspended = hasSelection && selectedServicio.estado == 'SUSPENDIDO';

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: <Widget>[
          // Icono y título
          const Icon(
            Icons.medical_services,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppSizes.spacingSmall),
          Text(
            'Gestión de Servicios',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(width: AppSizes.spacing),

          // Filtros
          SizedBox(
            width: 250,
            child: _buildSearchField(),
          ),
          const SizedBox(width: AppSizes.spacingSmall),
          SizedBox(
            width: 120,
            child: _buildYearSelector(),
          ),
          const SizedBox(width: AppSizes.spacingSmall),
          SizedBox(
            width: 180,
            child: _buildEstadoSelector(),
          ),

          const Spacer(),

          // Botones de acción
          Wrap(
            spacing: AppSizes.spacingSmall,
            children: <Widget>[
              _buildCompactButton(
                label: 'NUEVO',
                icon: Icons.add,
                color: AppColors.primary.withValues(alpha: 0.8),
                onPressed: _showNewServicioDialog,
              ),
              _buildCompactButton(
                label: 'EDITAR',
                icon: Icons.edit,
                color: AppColors.primary.withValues(alpha: 0.8),
                onPressed: hasSelection
                    ? () => _handleEditar(context, selectedServicio)
                    : null,
              ),
              _buildCompactButton(
                label: 'ELIMINAR',
                icon: Icons.delete_outline,
                color: AppColors.primary.withValues(alpha: 0.8),
                onPressed: hasSelection
                    ? () => _handleEliminar(context, selectedServicio)
                    : null,
              ),
              _buildCompactButton(
                label: 'FINALIZAR',
                icon: Icons.done_all,
                color: AppColors.primary.withValues(alpha: 0.8),
                onPressed: isActive
                    ? () => _handleFinalizar(context, selectedServicio)
                    : null,
              ),
              _buildCompactButton(
                label: 'SUSPENDER',
                icon: Icons.pause_circle_outline,
                color: AppColors.primary.withValues(alpha: 0.8),
                onPressed: isActive
                    ? () => _handleSuspender(context, selectedServicio)
                    : null,
              ),
              _buildCompactButton(
                label: 'REANUDAR',
                icon: Icons.play_circle_outline,
                color: AppColors.success.withValues(alpha: 0.8),
                onPressed: isSuspended
                    ? () => _handleReanudar(context, selectedServicio)
                    : null,
              ),
              _buildCompactButton(
                label: 'EXCLUIR',
                icon: Icons.block,
                color: AppColors.primary.withValues(alpha: 0.8),
                onPressed: isActive
                    ? () => _handleExcluir(context, selectedServicio)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Campo de búsqueda
  Widget _buildSearchField() {
    return SizedBox(
      height: 36,
      child: TextField(
        controller: _searchController,
        onChanged: (_) => _applyFilters(),
        decoration: InputDecoration(
          hintText: 'Buscar servicio...',
          hintStyle: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondaryLight,
          ),
          prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textSecondaryLight),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 16, color: AppColors.textSecondaryLight),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingSmall,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            borderSide: const BorderSide(color: AppColors.gray300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            borderSide: const BorderSide(color: AppColors.gray300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        style: GoogleFonts.inter(fontSize: 13),
      ),
    );
  }

  /// Selector de año profesional
  Widget _buildYearSelector() {
    final int currentYear = DateTime.now().year;
    final List<int> years = List<int>.generate(5, (int i) => currentYear - i);

    return SizedBox(
      width: 120,
      height: 36,
      child: PopupMenuButton<int>(
        onSelected: (int value) {
          setState(() {
            _yearSeleccionado = value;
          });
          _applyFilters();
        },
        offset: const Offset(0, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        color: Colors.white,
        elevation: 8,
        itemBuilder: (BuildContext context) {
          return years.map((int year) {
            final bool isSelected = year == _yearSeleccionado;
            return PopupMenuItem<int>(
              value: year,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: isSelected ? AppColors.primary : AppColors.gray400,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    year.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.textPrimaryLight,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    const Icon(
                      Icons.check,
                      size: 18,
                      color: AppColors.primary,
                    ),
                ],
              ),
            );
          }).toList();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: AppColors.gray300),
          ),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                _yearSeleccionado?.toString() ?? currentYear.toString(),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_drop_down,
                size: 20,
                color: AppColors.textSecondaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Selector de estado profesional
  Widget _buildEstadoSelector() {
    // Lista de estados incluyendo "Todos"
    const List<String> estados = <String>[
      'TODOS', // Valor especial que se convertirá a null
      'ACTIVO',
      'SUSPENDIDO',
      'FINALIZADO',
      'ELIMINADO',
    ];

    return SizedBox(
      width: 180,
      height: 36,
      child: PopupMenuButton<String>(
        onSelected: (String value) {
          debugPrint('🔄 Estado seleccionado: $value (antes: $_estadoSeleccionado)');
          setState(() {
            _estadoSeleccionado = value == 'TODOS' ? null : value;
            debugPrint('🔄 Estado actualizado a: $_estadoSeleccionado');
          });
          _applyFilters();
        },
        offset: const Offset(0, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        color: Colors.white,
        elevation: 8,
        itemBuilder: (BuildContext context) {
          return estados.map((String estado) {
            final String? estadoReal = estado == 'TODOS' ? null : estado;
            final bool isSelected = estadoReal == _estadoSeleccionado;
            final String displayText = estado == 'TODOS' ? 'Todos' : estado;
            final Color? iconColor = estado != 'TODOS' ? _getEstadoColor(estado) : null;

            return PopupMenuItem<String>(
              value: estado,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: <Widget>[
                  if (estado != 'TODOS')
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: iconColor,
                    )
                  else
                    const Icon(
                      Icons.filter_list,
                      size: 16,
                      color: AppColors.gray400,
                    ),
                  const SizedBox(width: 12),
                  Text(
                    displayText,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.textPrimaryLight,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    const Icon(
                      Icons.check,
                      size: 18,
                      color: AppColors.primary,
                    ),
                ],
              ),
            );
          }).toList();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: AppColors.gray300),
          ),
          child: Row(
            children: <Widget>[
              if (_estadoSeleccionado != null)
                Icon(
                  Icons.circle,
                  size: 8,
                  color: _getEstadoColor(_estadoSeleccionado!),
                )
              else
                const Icon(
                  Icons.filter_list,
                  size: 16,
                  color: AppColors.primary,
                ),
              const SizedBox(width: 8),
              Text(
                _estadoSeleccionado ?? 'Todos',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_drop_down,
                size: 20,
                color: AppColors.textSecondaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Obtiene el color según el estado
  Color _getEstadoColor(String estado) {
    switch (estado) {
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

  /// Construye un botón compacto para el header
  Widget _buildCompactButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 32, // Altura compacta
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          elevation: 0,
        ),
      ),
    );
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
