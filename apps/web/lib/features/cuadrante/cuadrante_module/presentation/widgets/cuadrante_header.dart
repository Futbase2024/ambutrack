import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/features/contratos/domain/repositories/contrato_repository.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/cuadrante_filter.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/cuadrante_view_mode.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_bloc.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_event.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_state.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/copiar_semana_dialog.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/domain/repositories/dotaciones_repository.dart';
import 'package:ambutrack_web/features/turnos/presentation/widgets/generacion_automatica_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Header del cuadrante con controles y filtros
class CuadranteHeader extends StatefulWidget {
  const CuadranteHeader({required this.state, super.key});

  final CuadranteLoaded state;

  @override
  State<CuadranteHeader> createState() => _CuadranteHeaderState();
}

class _CuadranteHeaderState extends State<CuadranteHeader> {
  List<ContratoEntity> _contratos = <ContratoEntity>[];
  List<DotacionEntity> _dotaciones = <DotacionEntity>[];
  bool _isLoadingFilters = true;

  @override
  void initState() {
    super.initState();
    _loadFilterData();
  }

  /// Carga los datos para los filtros (contratos y dotaciones)
  Future<void> _loadFilterData() async {
    try {
      final ContratoRepository contratoRepo = getIt<ContratoRepository>();
      final DotacionesRepository dotacionRepo = getIt<DotacionesRepository>();

      final List<ContratoEntity> contratos = await contratoRepo.getActivos();
      final List<DotacionEntity> dotaciones = await dotacionRepo.getActivas();

      // Ordenar alfabéticamente
      contratos.sort((ContratoEntity a, ContratoEntity b) {
        final String labelA = a.tipoContrato ?? a.codigo;
        final String labelB = b.tipoContrato ?? b.codigo;
        return labelA.toLowerCase().compareTo(labelB.toLowerCase());
      });

      dotaciones.sort((DotacionEntity a, DotacionEntity b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));

      if (mounted) {
        setState(() {
          _contratos = contratos;
          _dotaciones = dotaciones;
          _isLoadingFilters = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error cargando filtros: $e');
      if (mounted) {
        setState(() {
          _isLoadingFilters = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: Container(
        padding: const EdgeInsets.only(
          left: 15,
          right: 50,
          top: 8,
          bottom: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(color: AppColors.gray200),
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Primera fila: Título, Vista, Badges, Navegación de Semana y Botones
          Row(
            children: <Widget>[
              // Título compacto
              Text(
                '📊 Cuadrante',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),

              const SizedBox(width: AppSizes.spacingSmall),

              // Selector de modo de vista
              _buildViewModeSelector(context),

              const SizedBox(width: AppSizes.spacingSmall),

              // Badges de estadísticas compactos
              _buildEstadisticaChip(
                icon: Icons.people,
                label: 'Personal',
                value: '${widget.state.totalPersonal}',
                color: AppColors.info,
              ),
              const SizedBox(width: 4),
              _buildEstadisticaChip(
                icon: Icons.schedule,
                label: 'Turnos',
                value: '${widget.state.totalTurnos}',
                color: AppColors.success,
              ),

              const SizedBox(width: AppSizes.spacingSmall),

              // Navegación con fecha (movido aquí)
              _buildNavegacion(context),

              const SizedBox(width: AppSizes.spacingSmall),

              // Botones de acción (misma altura que badges)
              SizedBox(
                height: 40, // Altura similar a los badges
                child: ElevatedButton.icon(
                  onPressed: () => _mostrarDialogoGeneracionAutomatica(context),
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: Text(
                    'Auto',
                    style: AppTextStyles.chipText,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),

              const SizedBox(width: AppSizes.spacingSmall),

              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: () => _mostrarDialogoCopiarSemana(context),
                  icon: const Icon(Icons.content_copy, size: 16),
                  label: Text(
                    'Copiar',
                    style: AppTextStyles.chipText,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryLight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),

              const SizedBox(width: AppSizes.spacingSmall),

              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<CuadranteBloc>().add(const CuadranteRefreshRequested());
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(
                    'Refrescar',
                    style: AppTextStyles.chipText,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),

              const Spacer(),

              // Botón limpiar filtros
              if (widget.state.filter.hasActiveFilters)
                Tooltip(
                  message: 'Limpiar filtros',
                  child: IconButton(
                    icon: const Icon(Icons.filter_alt_off, size: 20),
                    onPressed: () {
                      context.read<CuadranteBloc>().add(const CuadranteFilterCleared());
                    },
                    color: AppColors.warning,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 6),

          // Segunda fila: Buscador, Switch y Filtros de Contrato/Dotación
          _buildFiltros(context),
        ],
      ),
      ),
    );
  }

  Widget _buildViewModeSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: CuadranteViewMode.values.map((CuadranteViewMode mode) {
          final bool isSelected = widget.state.viewMode == mode;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: InkWell(
              onTap: () {
                context.read<CuadranteBloc>().add(CuadranteViewModeChanged(mode));
              },
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingSmall,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Text(
                  mode.displayText,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavegacion(BuildContext context) {
    final String rangoTexto = _getSemanaTexto();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              icon: const Icon(Icons.chevron_left, size: 18),
              onPressed: () {
                context.read<CuadranteBloc>().add(const CuadranteSemanaChanged(-1));
              },
              color: AppColors.primary,
              tooltip: 'Semana anterior',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              rangoTexto,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              icon: const Icon(Icons.chevron_right, size: 18),
              onPressed: () {
                context.read<CuadranteBloc>().add(const CuadranteSemanaChanged(1));
              },
              color: AppColors.primary,
              tooltip: 'Semana siguiente',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros(BuildContext context) {
    return Row(
      children: <Widget>[
        // Buscador de personal
        SizedBox(
          width: 500,
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Buscar Personal',
              hintText: 'Escribe el nombre del personal...',
              prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 20),
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
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              isDense: true,
            ),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textPrimaryLight,
            ),
            onChanged: (String value) {
              final CuadranteFilter newFilter = widget.state.filter.copyWith(
                searchQuery: value,
              );
              context.read<CuadranteBloc>().add(CuadranteFilterChanged(newFilter));
            },
          ),
        ),

        const SizedBox(width: AppSizes.spacing),

        // Switch: Solo personal con turnos activos (compacto)
        InkWell(
          onTap: () {
            final CuadranteFilter newFilter = widget.state.filter.copyWith(
              soloConTurnos: !widget.state.filter.soloConTurnos,
            );
            context.read<CuadranteBloc>().add(CuadranteFilterChanged(newFilter));
          },
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: widget.state.filter.soloConTurnos ? AppColors.success.withValues(alpha: 0.1) : AppColors.gray50,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(
                color: widget.state.filter.soloConTurnos ? AppColors.success : AppColors.gray300,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: widget.state.filter.soloConTurnos ? AppColors.success : AppColors.textSecondaryLight,
                ),
                const SizedBox(width: 6),
                Text(
                  'Solo con turnos',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: widget.state.filter.soloConTurnos ? AppColors.success : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  height: 20,
                  child: Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: widget.state.filter.soloConTurnos,
                      onChanged: (bool value) {
                        final CuadranteFilter newFilter = widget.state.filter.copyWith(
                          soloConTurnos: value,
                        );
                        context.read<CuadranteBloc>().add(CuadranteFilterChanged(newFilter));
                      },
                      activeTrackColor: AppColors.success,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: AppSizes.spacing),

        // Filtro por Contrato
        SizedBox(
          width: 320,
          child: _isLoadingFilters
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : _buildContratoDropdown(),
        ),

        const SizedBox(width: AppSizes.spacing),

        // Filtro por Dotación
        SizedBox(
          width: 320,
          child: _isLoadingFilters
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : _buildDotacionDropdown(),
        ),
      ],
    );
  }

  Widget _buildEstadisticaChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: AppSizes.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondaryLight,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getSemanaTexto() {
    final DateFormat formatter = DateFormat('d MMM', 'es_ES');
    return '${formatter.format(widget.state.primerDiaSemana)} - ${formatter.format(widget.state.ultimoDiaSemana)}';
  }

  /// Muestra el diálogo para copiar la semana actual a otra fecha
  Future<void> _mostrarDialogoCopiarSemana(BuildContext context) async {
    final CopiarSemanaResult? resultado = await showDialog<CopiarSemanaResult>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CopiarSemanaDialog(
          semanaActual: widget.state.primerDiaSemana,
          personalConTurnos: widget.state.personalConTurnos,
        );
      },
    );

    if (resultado != null && context.mounted) {
      final DateTime semanaDestino = DateTime.parse(resultado.semanaDestino);

      // Disparar evento para copiar la semana
      context.read<CuadranteBloc>().add(
            CuadranteCopiarSemanaRequested(
              semanaOrigen: widget.state.primerDiaSemana,
              semanaDestino: semanaDestino,
              idPersonal: resultado.idPersonal,
            ),
          );
    }
  }

  /// Construye el dropdown de contratos validando duplicados y valor actual
  Widget _buildContratoDropdown() {
    // Eliminar duplicados usando un Set por ID
    final Map<String, ContratoEntity> contratosMap = <String, ContratoEntity>{};
    for (final ContratoEntity contrato in _contratos) {
      contratosMap[contrato.id] = contrato;
    }
    final List<ContratoEntity> contratosSinDuplicados = contratosMap.values.toList();

    // Verificar si el valor actual existe en la lista
    final String? currentValue = widget.state.filter.contratoId;
    final bool valueExists = currentValue == null ||
        contratosSinDuplicados.any((ContratoEntity c) => c.id == currentValue);

    return AppDropdown<String>(
      value: valueExists ? currentValue : null,
      label: 'Contrato',
      hint: 'Todos los contratos',
      prefixIcon: Icons.description,
      width: 320,
      items: contratosSinDuplicados.map((ContratoEntity contrato) {
        final String label = contrato.tipoContrato != null && contrato.tipoContrato!.isNotEmpty
            ? '${contrato.codigo} - ${contrato.tipoContrato}'
            : contrato.codigo;
        return AppDropdownItem<String>(
          value: contrato.id,
          label: label,
          icon: Icons.description,
        );
      }).toList(),
      onChanged: (String? contratoId) {
        final CuadranteFilter newFilter = widget.state.filter.copyWith(
          contratoId: contratoId,
        );
        context.read<CuadranteBloc>().add(CuadranteFilterChanged(newFilter));
      },
    );
  }

  /// Construye el dropdown de dotaciones validando duplicados y valor actual
  Widget _buildDotacionDropdown() {
    // Eliminar duplicados usando un Set por ID
    final Map<String, DotacionEntity> dotacionesMap = <String, DotacionEntity>{};
    for (final DotacionEntity dotacion in _dotaciones) {
      dotacionesMap[dotacion.id] = dotacion;
    }
    final List<DotacionEntity> dotacionesSinDuplicados = dotacionesMap.values.toList();

    // Verificar si el valor actual existe en la lista
    final String? currentValue = widget.state.filter.dotacionId;
    final bool valueExists = currentValue == null ||
        dotacionesSinDuplicados.any((DotacionEntity d) => d.id == currentValue);

    return AppDropdown<String>(
      value: valueExists ? currentValue : null,
      label: 'Dotación',
      hint: 'Todas las dotaciones',
      prefixIcon: Icons.local_hospital,
      width: 320,
      items: dotacionesSinDuplicados.map((DotacionEntity dotacion) {
        return AppDropdownItem<String>(
          value: dotacion.id,
          label: dotacion.nombre,
          icon: Icons.local_hospital,
        );
      }).toList(),
      onChanged: (String? dotacionId) {
        final CuadranteFilter newFilter = widget.state.filter.copyWith(
          dotacionId: dotacionId,
        );
        context.read<CuadranteBloc>().add(CuadranteFilterChanged(newFilter));
      },
    );
  }

  /// Muestra el diálogo para generar cuadrante automáticamente
  Future<void> _mostrarDialogoGeneracionAutomatica(BuildContext context) async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return GeneracionAutomaticaDialog(
          fechaInicioSugerida: widget.state.primerDiaSemana,
          fechaFinSugerida: widget.state.ultimoDiaSemana,
        );
      },
    );

    // Si se confirmó la generación, refrescar cuadrante
    if (result == true && context.mounted) {
      context.read<CuadranteBloc>().add(const CuadranteRefreshRequested());
    }
  }
}
