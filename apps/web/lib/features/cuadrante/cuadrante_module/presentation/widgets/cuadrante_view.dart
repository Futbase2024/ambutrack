import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion_frame/gestion_frame.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/cuadrante_view_mode.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_bloc.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_event.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_state.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/cuadrante_calendario_view.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/cuadrante_disponibilidad_view.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/cuadrante_filter_bar.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/cuadrante_header.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/cuadrante_tabla_view.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/turnos_bloc.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/turnos_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Vista principal del cuadrante
class CuadranteView extends StatefulWidget {
  const CuadranteView({super.key});

  @override
  State<CuadranteView> createState() => _CuadranteViewState();
}

class _CuadranteViewState extends State<CuadranteView> {
  @override
  void initState() {
    super.initState();
    // Cargar cuadrante al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CuadranteBloc>().add(const CuadranteLoadRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        BlocListener<CuadranteBloc, CuadranteState>(
          listener: (BuildContext context, CuadranteState state) {
            // Mostrar diálogo cuando se copia una semana exitosamente
            if (state is CuadranteCopiaExitosa && mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  showResultDialog(
                    context: context,
                    title: 'Semana Copiada',
                    message: state.message,
                    type: ResultType.success,
                  );
                }
              });
            }
          },
        ),
        BlocListener<TurnosBloc, TurnosState>(
          listener: (BuildContext context, TurnosState state) {
            if (!mounted) {
              return;
            }

            // Escuchar cambios de turnos y actualizar cuadrante de forma granular
            // NOTA: Los ResultDialog se muestran desde turno_form_dialog.dart
            // Aquí solo actualizamos el cuadrante
            if (state is TurnoCreated) {
              context.read<CuadranteBloc>().add(CuadranteTurnoCreated(state.turno));
            } else if (state is TurnoUpdated) {
              context.read<CuadranteBloc>().add(CuadranteTurnoUpdated(state.turno));
            } else if (state is TurnoDeleted) {
              context.read<CuadranteBloc>().add(CuadranteTurnoDeleted(state.turnoId));
            }
          },
        ),
      ],
      child: BlocBuilder<CuadranteBloc, CuadranteState>(
        builder: (BuildContext context, CuadranteState state) {
          if (state is CuadranteLoading) {
            return const GestionFrame(content: _LoadingView());
          }

          if (state is CuadranteError) {
            return GestionFrame(content: _ErrorView(message: state.message));
          }

          if (state is CuadranteLoaded) {
            return GestionFrame(
              toolbar: CuadranteHeader(state: state),
              filterBar: CuadranteFilterBar(state: state),
              content: _CuadranteModeContent(state: state),
              statusBar: CuadranteStatusBar(state: state),
            );
          }

          // Estado inicial - mostrar loading
          return const GestionFrame(content: _LoadingView());
        },
      ),
    );
  }
}

/// Contenido según el modo de vista seleccionado
class _CuadranteModeContent extends StatelessWidget {
  const _CuadranteModeContent({required this.state});

  final CuadranteLoaded state;

  @override
  Widget build(BuildContext context) {
    switch (state.viewMode) {
      case CuadranteViewMode.tabla:
        return CuadranteTablaView(state: state);
      case CuadranteViewMode.disponibilidad:
        return CuadranteDisponibilidadView(state: state);
      case CuadranteViewMode.calendario:
        return CuadranteCalendarioView(state: state);
    }
  }
}

/// Vista de carga
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: AppLoadingIndicator(
        message: 'Cargando cuadrante...',
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
    return Center(
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
          const SizedBox(height: AppSizes.spacing),
          ElevatedButton.icon(
            onPressed: () {
              context.read<CuadranteBloc>().add(const CuadranteRefreshRequested());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

