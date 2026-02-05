import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/domain/entities/cuadrante_slot_entity.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/domain/entities/personal_drag_data.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/domain/entities/vehiculo_drag_data.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/presentation/bloc/cuadrante_visual_bloc.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/presentation/bloc/cuadrante_visual_event.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/presentation/bloc/cuadrante_visual_state.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/presentation/widgets/cuadrante_slot_widget.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/presentation/widgets/draggable_personal_card.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/presentation/widgets/draggable_vehiculo_card.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Página principal del cuadrante visual con drag & drop
class CuadranteVisualPage extends StatelessWidget {
  const CuadranteVisualPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<CuadranteVisualBloc>(
        create: (BuildContext _) => getIt<CuadranteVisualBloc>()
          ..add(CuadranteLoadRequested(DateTime.now())),
        child: const _CuadranteVisualView(),
      ),
    );
  }
}

class _CuadranteVisualView extends StatefulWidget {
  const _CuadranteVisualView();

  @override
  State<_CuadranteVisualView> createState() => _CuadranteVisualViewState();
}

class _CuadranteVisualViewState extends State<_CuadranteVisualView> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return BlocListener<CuadranteVisualBloc, CuadranteVisualState>(
      listener: (BuildContext context, CuadranteVisualState state) {
        if (state is CuadranteVisualSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ Cuadrante guardado: ${state.savedCount} asignaciones',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is CuadranteVisualError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<CuadranteVisualBloc, CuadranteVisualState>(
        builder: (BuildContext context, CuadranteVisualState state) {
          if (state is CuadranteVisualLoading) {
            return const _LoadingView();
          }

          if (state is CuadranteVisualError) {
            return _ErrorView(message: state.message);
          }

          if (state is CuadranteVisualLoaded) {
            return _buildLoadedView(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadedView(
      BuildContext context, CuadranteVisualLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Header: Título, fecha, y acciones
        _buildHeader(context, state),
        const SizedBox(height: AppSizes.spacing),

        // Layout principal: 3 columnas (Personal | Cuadrante | Vehículos)
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Columna izquierda: Personal disponible
              _buildPersonalPanel(state),

              const SizedBox(width: AppSizes.spacing),

              // Columna central: Cuadrante (slots)
              Expanded(
                child: _buildCuadrantePanel(context, state),
              ),

              const SizedBox(width: AppSizes.spacing),

              // Columna derecha: Vehículos disponibles
              _buildVehiculosPanel(state),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, CuadranteVisualLoaded state) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: <Widget>[
          // Título
          Expanded(
            child: Text(
              'Cuadrante Visual',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),

          // Selector de fecha
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );

              if (picked != null && picked != _selectedDate) {
                setState(() => _selectedDate = picked);
                if (context.mounted) {
                  context
                      .read<CuadranteVisualBloc>()
                      .add(CuadranteLoadRequested(picked));
                }
              }
            },
          ),
          const SizedBox(width: AppSizes.spacingSmall),

          Text(
            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryLight,
            ),
          ),

          const SizedBox(width: AppSizes.spacing),

          // Indicador de cambios sin guardar
          if (state.hasUnsavedChanges)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha:  0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                border: Border.all(color: AppColors.warning),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.warning_outlined,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Cambios sin guardar',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(width: AppSizes.spacing),

          // Botón Limpiar
          OutlinedButton.icon(
            onPressed: () {
              context
                  .read<CuadranteVisualBloc>()
                  .add(const CuadranteClearRequested());
            },
            icon: const Icon(Icons.clear_all, size: 18),
            label: const Text('Limpiar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
          ),

          const SizedBox(width: AppSizes.spacingSmall),

          // Botón Guardar
          ElevatedButton.icon(
            onPressed: state.hasUnsavedChanges
                ? () {
                    context
                        .read<CuadranteVisualBloc>()
                        .add(const CuadranteSaveRequested());
                  }
                : null,
            icon: const Icon(Icons.save, size: 18),
            label: const Text('Guardar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalPanel(CuadranteVisualLoaded state) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Personal Disponible',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacing),

          // Lista de personal activo
          Expanded(
            child: state.personalList.isEmpty
                ? Center(
                    child: Text(
                      'No hay personal activo',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: state.personalList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final PersonalEntity personal = state.personalList[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.spacingSmall),
                        child: DraggablePersonalCard(
                          personalId: personal.id,
                          nombre: '${personal.nombre} ${personal.apellidos}',
                          rol: personal.categoria?.toLowerCase() ?? 'sin-rol',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuadrantePanel(
      BuildContext context, CuadranteVisualLoaded state) {
    // Agrupar slots por dotación
    final Map<String, List<CuadranteSlotEntity>> slotsByDotacion = <String, List<CuadranteSlotEntity>>{};

    for (final CuadranteSlotEntity slot in state.slots) {
      if (!slotsByDotacion.containsKey(slot.dotacionId)) {
        slotsByDotacion[slot.dotacionId] = <CuadranteSlotEntity>[];
      }
      slotsByDotacion[slot.dotacionId]!.add(slot);
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Cuadrante del Día',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacing),

          Expanded(
            child: ListView.builder(
              itemCount: state.dotaciones.length,
              itemBuilder: (BuildContext context, int index) {
                final DotacionEntity dotacion = state.dotaciones[index];
                final List<CuadranteSlotEntity> slots = slotsByDotacion[dotacion.id] ?? <CuadranteSlotEntity>[];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Nombre de la dotación
                    Text(
                      dotacion.nombre,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingSmall),

                    // Slots de la dotación
                    Wrap(
                      spacing: AppSizes.spacingSmall,
                      runSpacing: AppSizes.spacingSmall,
                      children: slots.map<Widget>((CuadranteSlotEntity slot) {
                        return CuadranteSlotWidget(
                          slot: slot,
                          onPersonalDropped: (PersonalDragData personalData) {
                            context.read<CuadranteVisualBloc>().add(
                                  CuadrantePersonalAssigned(
                                    dotacionId: slot.dotacionId,
                                    numeroUnidad: slot.numeroUnidad,
                                    personalData: personalData,
                                  ),
                                );
                          },
                          onVehiculoDropped: (VehiculoDragData vehiculoData) {
                            context.read<CuadranteVisualBloc>().add(
                                  CuadranteVehiculoAssigned(
                                    dotacionId: slot.dotacionId,
                                    numeroUnidad: slot.numeroUnidad,
                                    vehiculoData: vehiculoData,
                                  ),
                                );
                          },
                          onRemovePersonal: () {
                            context.read<CuadranteVisualBloc>().add(
                                  CuadrantePersonalRemoved(
                                    dotacionId: slot.dotacionId,
                                    numeroUnidad: slot.numeroUnidad,
                                  ),
                                );
                          },
                          onRemoveVehiculo: () {
                            context.read<CuadranteVisualBloc>().add(
                                  CuadranteVehiculoRemoved(
                                    dotacionId: slot.dotacionId,
                                    numeroUnidad: slot.numeroUnidad,
                                  ),
                                );
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppSizes.spacing),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiculosPanel(CuadranteVisualLoaded state) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Vehículos Disponibles',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacing),

          // Lista de vehículos activos
          Expanded(
            child: state.vehiculosList.isEmpty
                ? Center(
                    child: Text(
                      'No hay vehículos activos',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: state.vehiculosList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final VehiculoEntity vehiculo = state.vehiculosList[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.spacingSmall),
                        child: DraggableVehiculoCard(
                          vehiculoId: vehiculo.id,
                          matricula: vehiculo.matricula,
                          tipo: vehiculo.tipoVehiculo,
                          modelo: vehiculo.modelo,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Vista de carga
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingMassive),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      constraints: const BoxConstraints(minHeight: 400),
      child: const Center(
        child: AppLoadingIndicator(
          message: 'Cargando cuadrante...',
        ),
      ),
    );
  }
}

/// Vista de error
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.error),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: AppSizes.spacing),
          Text(
            'Error al cargar cuadrante',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
