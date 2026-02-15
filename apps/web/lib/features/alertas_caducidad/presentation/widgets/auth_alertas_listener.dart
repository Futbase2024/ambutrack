import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/bloc/alertas_caducidad_bloc.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/bloc/alertas_caducidad_event.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/bloc/alertas_caducidad_state.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/widgets/alertas_dialogo_inicial.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Listener global que muestra el diálogo de alertas críticas después del login.
///
/// Escucha los cambios de autenticación y carga las alertas críticas
/// cuando el usuario se loguea exitosamente.
class AuthAlertasListener extends StatefulWidget {
  const AuthAlertasListener({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<AuthAlertasListener> createState() => _AuthAlertasListenerState();
}

class _AuthAlertasListenerState extends State<AuthAlertasListener> {
  bool _hasLoadedAlertas = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🔔🔔🔔 AuthAlertasListener: initState() llamado - Widget CREADO');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('🔔🔔 AuthAlertasListener: didChangeDependencies() llamado');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔔 AuthAlertasListener: build() llamado, _hasLoadedAlertas=$_hasLoadedAlertas');

    try {
      // Verificar que podemos leer el AuthBloc
      final AuthState authState = context.read<AuthBloc>().state;
      debugPrint('🔔 AuthAlertasListener: AuthBloc leído correctamente, estado=$authState');
    } catch (e) {
      debugPrint('❌ AuthAlertasListener: Error leyendo AuthBloc: $e');
    }

    try {
      // Verificar que podemos leer el AlertasCaducidadBloc
      context.read<AlertasCaducidadBloc>();
      debugPrint('🔔 AuthAlertasListener: AlertasCaducidadBloc leído correctamente');
    } catch (e) {
      debugPrint('❌ AuthAlertasListener: Error leyendo AlertasCaducidadBloc: $e');
    }

    // Verificar estado inicial y cargar alertas si está autenticado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🔔 AuthAlertasListener: PostFrameCallback ejecutado');

      final AuthState authState = context.read<AuthBloc>().state;
      debugPrint('🔔 AuthAlertasListener: PostFrameCallback, AuthState=$authState');

      if (authState is AuthAuthenticated && !_hasLoadedAlertas) {
        _hasLoadedAlertas = true;
        final String usuarioId = authState.user.uid;

        debugPrint('🔔 AuthAlertasListener: Usuario autenticado, cargando alertas críticas...');

        context.read<AlertasCaducidadBloc>().add(
          AlertasCaducidadEvent.loadAlertasCriticas(usuarioId: usuarioId),
        );
      } else {
        debugPrint('🔔 AuthAlertasListener: No se cargan alertas - Authenticated=${authState is AuthAuthenticated}, _hasLoadedAlertas=$_hasLoadedAlertas');
      }
    });

    return BlocListener<AuthBloc, AuthState>(
      listener: (BuildContext context, AuthState authState) {
        debugPrint('🔔 AuthAlertasListener: BlocListener llamado, AuthState=$authState, _hasLoadedAlertas=$_hasLoadedAlertas');

        // También escuchar cambios de estado (por si se loguea después)
        if (authState is AuthAuthenticated && !_hasLoadedAlertas) {
          _hasLoadedAlertas = true;
          final String usuarioId = authState.user.uid;

          debugPrint('🔔 AuthAlertasListener: AuthStateChanged, cargando alertas críticas...');

          context.read<AlertasCaducidadBloc>().add(
            AlertasCaducidadEvent.loadAlertasCriticas(usuarioId: usuarioId),
          );
        }
      },
      child: BlocListener<AlertasCaducidadBloc, AlertasCaducidadState>(
        listener: (BuildContext context, AlertasCaducidadState alertasState) {
          alertasState.maybeWhen(
            loaded: (List<AlertaCaducidadEntity> alertas, _, _, _, _) {
              debugPrint('🔔 AuthAlertasListener: ${alertas.length} alertas cargadas');
              // Filtrar solo alertas críticas
              if (alertas.any((AlertaCaducidadEntity a) => a.esCritica == true)) {
                debugPrint('🔔 AuthAlertasListener: Hay alertas críticas, mostrando diálogo...');
                // Mostrar diálogo de alertas críticas
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final AuthState authState = context.read<AuthBloc>().state;
                  if (authState is AuthAuthenticated) {
                    _mostrarDialogoCriticas(context, alertas, authState.user.uid);
                  }
                });
              } else {
                debugPrint('🔔 AuthAlertasListener: No hay alertas críticas para mostrar');
              }
            },
            orElse: () {},
          );
        },
        child: widget.child,
      ),
    );
  }

  void _mostrarDialogoCriticas(
    BuildContext context,
    List<AlertaCaducidadEntity> alertas,
    String usuarioId,
  ) {
    // Verificar que el contexto aún sea válido antes de mostrar el diálogo
    if (!context.mounted) {
      return;
    }

    // Filtrar solo alertas críticas
    final List<AlertaCaducidadEntity> criticas = alertas.where((AlertaCaducidadEntity a) => a.esCritica == true).toList();

    if (criticas.isEmpty) {
      return;
    }

    // Usar Navigator.push con MaterialPageRoute para heredar localizaciones
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext dialogContext) => AlertasDialogoInicial(
          usuarioId: usuarioId,
        ),
      ),
    );
  }
}
