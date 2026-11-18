import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dialogs/professional_result_dialog.dart';
import '../../../../core/widgets/menu/app_menu.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/registro_horario_bloc.dart';
import '../bloc/registro_horario_event.dart';
import '../bloc/registro_horario_state.dart';
import '../widgets/boton_registro_circular_widget.dart';
import '../widgets/cambiar_vehiculo_dialog.dart';
import '../widgets/historial_fichajes_widget.dart';
import '../widgets/inicio_turno/iniciar_turno_sheet.dart';
import '../widgets/info_turno_grupo.dart';
import '../widgets/turno_estado_card.dart';
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Reloj, estado y jornada en curso
                      TurnoEstadoCard(
                        estadoActual: state.estadoActual,
                        ultimoRegistro: state.ultimoRegistro,
                      ),
                      const SizedBox(height: 28),

                      // 2. Botón circular con huella dactilar
                      Center(
                        child: BotonRegistroCircularWidget(
                          estadoActual: state.estadoActual,
                          onFichar: (lat, lon, precision, observaciones) {
                            _onFichar(context, state.estadoActual, lat, lon,
                                precision, observaciones);
                          },
                        ),
                      ),
                      const SizedBox(height: 28),

                      // 3. Información del turno
                      const AppMenuSeccion('Mi turno'),
                      InfoTurnoGrupo(
                        vehiculo: state.vehiculo,
                        companero: state.companero,
                        ultimoRegistro: state.ultimoRegistro,
                        proximoTurno: state.proximoTurno,
                        onCambiarVehiculo: _puedeCambiarVehiculo(state)
                            ? () => _mostrarDialogoCambioVehiculo(
                                  context,
                                  state.vehiculo!,
                                )
                            : null,
                        onVerUbicacion: _tieneUbicacion(state.ultimoRegistro)
                            ? () => _mostrarMapaUbicacion(
                                  context,
                                  state.ultimoRegistro!,
                                )
                            : null,
                      ),
                      const SizedBox(height: 28),

                      // 4. Historial
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
  ///
  /// La entrada abre la hoja "Iniciar turno" para confirmar o elegir
  /// turno y vehículo antes de fichar.
  Future<void> _onFichar(
    BuildContext context,
    EstadoFichaje estadoActual,
    double lat,
    double lon,
    double precision,
    String? observaciones,
  ) async {
    if (estadoActual == EstadoFichaje.fuera) {
      final AuthState authState = context.read<AuthBloc>().state;
      final String? idPersonal = authState is AuthAuthenticated ? authState.personal?.id : null;
      if (idPersonal == null) {
        return;
      }
      final RegistroHorarioBloc bloc = context.read<RegistroHorarioBloc>();
      final InicioTurnoSeleccion? seleccion = await showIniciarTurnoSheet(context, idPersonal: idPersonal);
      if (seleccion == null) {
        return;
      }
      bloc.add(
        FicharEntrada(
          latitud: lat,
          longitud: lon,
          precisionGps: precision,
          seleccion: seleccion,
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

  /// Solo se puede cambiar de vehículo estando en turno con uno asignado
  bool _puedeCambiarVehiculo(RegistroHorarioLoadedWithContext state) {
    return state.estadoActual == EstadoFichaje.dentro && state.vehiculo != null;
  }

  bool _tieneUbicacion(RegistroHorarioEntity? registro) {
    return registro != null && registro.latitud != null && registro.longitud != null;
  }

  /// Muestra el mapa con la ubicación del fichaje
  void _mostrarMapaUbicacion(BuildContext context, RegistroHorarioEntity registro) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => UbicacionFichajeDialog(registro: registro),
    );
  }

  /// Muestra el diálogo para cambiar de vehículo
  void _mostrarDialogoCambioVehiculo(
    BuildContext context,
    VehiculoEntity vehiculoActual,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CambiarVehiculoDialog(
        vehiculoActual: vehiculoActual,
      ),
    );
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
