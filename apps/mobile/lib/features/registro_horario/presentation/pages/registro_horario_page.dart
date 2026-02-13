import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/widgets/dialogs/professional_result_dialog.dart';
import '../bloc/registro_horario_bloc.dart';
import '../bloc/registro_horario_event.dart';
import '../bloc/registro_horario_state.dart';
import '../widgets/boton_registro_circular_widget.dart';
import '../widgets/estado_registro_badge.dart';
import '../widgets/historial_fichajes_widget.dart';
import '../widgets/reloj_digital_widget.dart';
import '../widgets/seccion_tarjetas_info_widget.dart';
import '../widgets/ubicacion_fichaje_dialog.dart';

/// Página de Registro Horario con diseño profesional
///
/// Permite al personal fichar entrada/salida con geolocalización.
/// Incluye reloj en tiempo real, información contextual y diseño moderno.
class RegistroHorarioPage extends StatefulWidget {
  const RegistroHorarioPage({super.key});

  @override
  State<RegistroHorarioPage> createState() => _RegistroHorarioPageState();
}

class _RegistroHorarioPageState extends State<RegistroHorarioPage> {
  @override
  void initState() {
    super.initState();
    // Cargar contexto completo (registros + información contextual)
    context.read<RegistroHorarioBloc>().add(const ObtenerContextoTurno());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Registro Horario'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
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
            // Usar diálogos profesionales (NO SnackBar)
            if (state is RegistroHorarioSuccess) {
              showProfessionalResultDialog(
                context,
                title: 'Registro Exitoso',
                message: state.mensaje,
                icon: Icons.check_circle_outline,
                iconColor: AppColors.success,
              );
            } else if (state is RegistroHorarioError) {
              showProfessionalResultDialog(
                context,
                title: 'Error al Registrar',
                message: state.mensaje,
                icon: Icons.error_outline,
                iconColor: AppColors.error,
              );
            }
          },
          builder: (context, state) {
            // Estado inicial (cargando)
            if (state is RegistroHorarioInitial) {
              return const _LoadingView();
            }

            // Estado de fichando
            if (state is RegistroHorarioFichando) {
              return const _FichandoView();
            }

            // Estado cargado con contexto
            if (state is RegistroHorarioLoadedWithContext) {
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  context
                      .read<RegistroHorarioBloc>()
                      .add(const ObtenerContextoTurno());
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // 1. Reloj digital grande
                      const RelojDigitalWidget(),
                      const SizedBox(height: 12),

                      // 2. Badge de estado
                      EstadoRegistroBadge(estadoActual: state.estadoActual),
                      const SizedBox(height: 24),

                      // 3. Botón circular con huella dactilar
                      BotonRegistroCircularWidget(
                        estadoActual: state.estadoActual,
                        onFichar: (lat, lon, precision, observaciones) {
                          _onFichar(context, state.estadoActual, lat, lon,
                              precision, observaciones);
                        },
                      ),
                      const SizedBox(height: 16),

                      // 3.1. Botón de ubicación del último fichaje
                      if (state.ultimoRegistro != null &&
                          state.ultimoRegistro!.latitud != null &&
                          state.ultimoRegistro!.longitud != null)
                        _BotonUbicacionFichaje(
                          registro: state.ultimoRegistro!,
                        ),
                      const SizedBox(height: 16),

                      // 4. Tarjetas informativas
                      SeccionTarjetasInfoWidget(
                        vehiculo: state.vehiculo,
                        companero: state.companero,
                        ultimoRegistro: state.ultimoRegistro,
                        proximoTurno: state.proximoTurno,
                      ),
                      const SizedBox(height: 24),

                      // 5. Historial (widget existente - sin cambios)
                      HistorialFichajesWidget(historial: state.historial),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            }

            // Estado cargado simple (backward compatibility)
            if (state is RegistroHorarioLoaded) {
              // Mostrar versión simplificada sin contexto
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Cargando información contextual...',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Estado de error
            if (state is RegistroHorarioError) {
              return _ErrorView(
                mensaje: state.mensaje,
                onReintentar: () {
                  context
                      .read<RegistroHorarioBloc>()
                      .add(const ObtenerContextoTurno());
                },
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

  /// Maneja el evento de fichar (entrada o salida)
  void _onFichar(
    BuildContext context,
    EstadoFichaje estadoActual,
    double lat,
    double lon,
    double precision,
    String? observaciones,
  ) {
    if (estadoActual == EstadoFichaje.fuera) {
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
  }
}

/// Vista de carga inicial
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

/// Vista mientras se está fichando
class _FichandoView extends StatelessWidget {
  const _FichandoView();

  @override
  Widget build(BuildContext context) {
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
}

/// Botón para ver la ubicación del último fichaje en un mapa
class _BotonUbicacionFichaje extends StatelessWidget {
  const _BotonUbicacionFichaje({
    required this.registro,
  });

  final RegistroHorarioEntity registro;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _mostrarMapaUbicacion(context),
      icon: Icon(
        Icons.location_on,
        size: 18,
        color: _getTipoColor(),
      ),
      label: Text(
        'Ver ubicación del ${registro.tipo.toLowerCase()}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _getTipoColor(),
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        side: BorderSide(color: _getTipoColor(), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
      ),
    );
  }

  /// Muestra el diálogo con el mapa
  void _mostrarMapaUbicacion(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => UbicacionFichajeDialog(registro: registro),
    );
  }

  /// Obtiene el color según el tipo de fichaje
  Color _getTipoColor() {
    return registro.tipo.toLowerCase() == 'entrada'
        ? AppColors.success
        : AppColors.error;
  }
}

/// Vista de error con opción de reintentar
class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.mensaje,
    required this.onReintentar,
  });

  final String mensaje;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.gray800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
