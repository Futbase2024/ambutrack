import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/registro_horario_bloc.dart';
import '../bloc/registro_horario_event.dart';
import '../bloc/registro_horario_state.dart';
import '../widgets/boton_fichaje_widget.dart';
import '../widgets/estado_actual_widget.dart';
import '../widgets/historial_fichajes_widget.dart';

/// Página de Registro Horario
///
/// Permite al personal fichar entrada/salida con geolocalización.
class RegistroHorarioPage extends StatelessWidget {
  const RegistroHorarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<RegistroHorarioBloc>()
        ..add(const CargarRegistrosHorario()),
      child: const _RegistroHorarioView(),
    );
  }
}

class _RegistroHorarioView extends StatelessWidget {
  const _RegistroHorarioView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Registro Horario'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<RegistroHorarioBloc, RegistroHorarioState>(
          listener: (context, state) {
        // Mostrar SnackBar en caso de success o error
        if (state is RegistroHorarioSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.mensaje),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is RegistroHorarioError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.mensaje),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        // Estado inicial (cargando)
        if (state is RegistroHorarioInitial) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Estado de fichando
        if (state is RegistroHorarioFichando) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Registrando fichaje...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        // Estado cargado (normal)
        if (state is RegistroHorarioLoaded) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<RegistroHorarioBloc>().add(const RefrescarHistorial());
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Estado Actual
                  EstadoActualWidget(
                    estadoActual: state.estadoActual,
                    ultimoRegistro: state.ultimoRegistro,
                  ),
                  const SizedBox(height: 16),

                  // Botón de Fichaje
                  BotonFichajeWidget(
                    estadoActual: state.estadoActual,
                    onFichar: (lat, lon, precision, observaciones) {
                      if (state.estadoActual == EstadoFichaje.fuera) {
                        context.read<RegistroHorarioBloc>().add(
                              FicharEntrada(
                                latitud: lat,
                                longitud: lon,
                                precisionGps: precision,
                                observaciones: observaciones,
                              ),
                            );
                      } else {
                        context.read<RegistroHorarioBloc>().add(
                              FicharSalida(
                                latitud: lat,
                                longitud: lon,
                                precisionGps: precision,
                                observaciones: observaciones,
                              ),
                            );
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Historial
                  HistorialFichajesWidget(
                    historial: state.historial,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        }

        // Estado de error
        if (state is RegistroHorarioError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    state.mensaje,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context
                        .read<RegistroHorarioBloc>()
                        .add(const CargarRegistrosHorario());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

          // Estado desconocido
          return const Center(
            child: Text('Estado desconocido'),
          );
        },
      ),
      ),
    );
  }
}
