import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ambutrack_core/ambutrack_core.dart';
import '../../../../core/realtime/connection_status_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart' show AuthAuthenticated;
import '../../data/repositories/traslados_repository_impl.dart';
import '../bloc/traslados_bloc.dart';
import '../bloc/traslados_event.dart';
import '../bloc/traslados_state.dart';
import '../widgets/traslado_card_container.dart';

/// Página principal de servicios/traslados
class ServiciosPage extends StatelessWidget {
  const ServiciosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final repository = TrasladosRepositoryImpl();
        final bloc = TrasladosBloc(repository);

        // Obtener ID del conductor desde AuthBloc
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated && authState.personal != null) {
          final idConductor = authState.personal!.id;
          // Iniciar Event Ledger: Realtime sin polling
          bloc.add(IniciarStreamEventos(idConductor));
        }

        return bloc;
      },
      child: const _ServiciosPageContent(),
    );
  }
}

class _ServiciosPageContent extends StatefulWidget {
  const _ServiciosPageContent();

  @override
  State<_ServiciosPageContent> createState() => _ServiciosPageContentState();
}

class _ServiciosPageContentState extends State<_ServiciosPageContent> {
  // Flags para evitar mostrar múltiples diálogos simultáneamente
  bool _mostrandoDialogoAsignacion = false;
  bool _mostrandoDialogoDesasignacion = false;

  // Flag para evitar múltiples cambios de estado simultáneos
  bool _cambiandoEstado = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Mis Servicios'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        // El AppBar automáticamente muestra el botón back si hay navegación previa
        automaticallyImplyLeading: true,
        actions: [
          // Botón de histórico
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              context.push('/servicios/historico');
            },
            tooltip: 'Histórico de servicios',
          ),
          // Indicador de estado de conexión Realtime
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: ConnectionStatusIndicator(
                connectionManager: context.read<TrasladosBloc>().connectionManager,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header con contador
            _buildHeader(context),

            // Lista de traslados
            Expanded(
              child: BlocConsumer<TrasladosBloc, TrasladosState>(
                listenWhen: (previous, current) {
                  // Solo escuchar eventos específicos (no TrasladosLoaded)
                  return current is TrasladoAsignado ||
                         current is TrasladoDesasignado ||
                         current is TrasladosError;
                },
                buildWhen: (previous, current) {
                  debugPrint('🔍 [ServiciosPage] buildWhen:');
                  debugPrint('   - Previous: ${previous.runtimeType}');
                  debugPrint('   - Current: ${current.runtimeType}');

                  // IGNORAR estados transitorios - no deben reconstruir el ListView
                  if (current is CambiandoEstadoTraslado ||
                      current is EstadoCambiadoSuccess ||
                      current is TrasladoAsignado ||
                      current is TrasladoDesasignado) {
                    debugPrint('   ❌ IGNORANDO estado transitorio - NO reconstruir ListView');
                    return false; // Los listeners manejan estos estados
                  }

                  // Reconstruir solo cuando cambia a Loading o Error
                  if (current is TrasladosLoading || current is TrasladosError) {
                    debugPrint('   ✅ Loading/Error - SÍ reconstruir ListView');
                    return true;
                  }

                  // Para TrasladosLoaded, comparar el número de traslados FILTRADOS (activos del día)
                  if (current is TrasladosLoaded && previous is TrasladosLoaded) {
                    final trasladosPreviosFiltrados = _filtrarTraslados(previous.traslados);
                    final trasladosActualesFiltrados = _filtrarTraslados(current.traslados);

                    final cambioNumeroFiltrados = trasladosActualesFiltrados.length != trasladosPreviosFiltrados.length;

                    debugPrint('   - Traslados FILTRADOS: ${trasladosPreviosFiltrados.length} → ${trasladosActualesFiltrados.length}');
                    debugPrint('   - Traslados TOTALES: ${previous.traslados.length} → ${current.traslados.length}');

                    if (cambioNumeroFiltrados) {
                      debugPrint('   ✅ Cambió número de traslados FILTRADOS - SÍ reconstruir ListView');
                    } else {
                      debugPrint('   ❌ Solo cambió un traslado individual - NO reconstruir ListView');
                    }
                    return cambioNumeroFiltrados;
                  }

                  // Si es la primera carga REAL (desde Initial o Loading)
                  if (current is TrasladosLoaded) {
                    // Reconstruir si venimos de un estado inicial
                    if (previous is TrasladosInitial || previous is TrasladosLoading) {
                      debugPrint('   ✅ Primera carga REAL - SÍ reconstruir ListView');
                      return true;
                    }
                    // IMPORTANTE: Reconstruir si venimos de EstadoCambiadoSuccess
                    // porque el traslado puede haber cambiado a un estado no activo (finalizado, cancelado)
                    // y debe desaparecer de la lista filtrada
                    if (previous is EstadoCambiadoSuccess) {
                      debugPrint('   ✅ Viene desde EstadoCambiadoSuccess - SÍ reconstruir ListView (puede haber desaparecido de filtros)');
                      return true;
                    }
                    // IMPORTANTE: Reconstruir si venimos de TrasladoAsignado o TrasladoDesasignado
                    // porque estos estados indican que la lista de traslados cambió (se agregó o eliminó un traslado)
                    if (previous is TrasladoAsignado || previous is TrasladoDesasignado) {
                      debugPrint('   ✅ Viene desde ${previous.runtimeType} - SÍ reconstruir ListView (cambió la lista de traslados)');
                      return true;
                    }
                    // Si venimos de otros estados transitorios, NO reconstruir
                    debugPrint('   ❌ Transición desde ${previous.runtimeType} - NO reconstruir ListView');
                    return false;
                  }

                  // Por defecto NO reconstruir
                  debugPrint('   ❌ Por defecto - NO reconstruir ListView');
                  return false;
                },
                listener: (context, state) {
                  if (state is TrasladosError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  } else if (state is TrasladoAsignado && !_mostrandoDialogoAsignacion) {
                    // Mostrar diálogo solo si no hay uno activo
                    _mostrandoDialogoAsignacion = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _mostrarDialogoAsignacion(context, state.traslado, state.esReasignacion);
                      }
                    });
                  } else if (state is TrasladoDesasignado && !_mostrandoDialogoDesasignacion) {
                    // Mostrar diálogo solo si no hay uno activo
                    _mostrandoDialogoDesasignacion = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _mostrarDialogoDesasignacion(context, state.traslado);
                      }
                    });
                  }
                },
                builder: (context, state) {
                  if (state is TrasladosLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is TrasladosLoaded) {
                    final traslados = _filtrarTraslados(state.traslados);

                    if (traslados.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<TrasladosBloc>().add(const RefrescarTraslados());
                        await Future.delayed(const Duration(seconds: 1));
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: traslados.length,
                        itemBuilder: (context, index) {
                          final traslado = traslados[index];
                          // Usar TrasladoCardContainer para optimizar rebuilds
                          // Solo se reconstruirá esta tarjeta cuando ELLA cambie
                          return TrasladoCardContainer(
                            trasladoId: traslado.id,
                            onTap: () async {
                              // Capturar BLoC antes del await para evitar usar context después del gap asíncrono
                              final bloc = context.read<TrasladosBloc>();

                              // Navegar y esperar a que regrese
                              await context.push('/servicios/${traslado.id}');

                              // Al volver, refrescar la lista
                              if (mounted) {
                                debugPrint('🔄 [ServiciosPage] Regresando del detalle, refrescando lista...');
                                bloc.add(const RefrescarTraslados());
                              }
                            },
                            onCambiarEstado: (nuevoEstado) {
                              _cambiarEstadoDesdeCard(traslado, nuevoEstado);
                            },
                          );
                        },
                      ),
                    );
                  }

                  // Estado inicial
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_shipping,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Título y contador
          Expanded(
            child: BlocBuilder<TrasladosBloc, TrasladosState>(
              builder: (context, state) {
                int totalHoy = 0;
                int activosHoy = 0;

                if (state is TrasladosLoaded) {
                  // Filtrar solo los del día actual
                  final ahora = DateTime.now();
                  final hoy = DateTime(ahora.year, ahora.month, ahora.day);

                  final trasladosHoy = state.traslados.where((t) {
                    final fechaTraslado = DateTime(
                      t.fecha.year,
                      t.fecha.month,
                      t.fecha.day,
                    );
                    return fechaTraslado.isAtSameMomentAs(hoy);
                  }).toList();

                  totalHoy = trasladosHoy.length;
                  activosHoy = trasladosHoy
                      .where((t) => t.estado.isActivo)
                      .length;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mis Servicios',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hoy: $activosHoy activos de $totalHoy totales',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Botón de actualizar
          IconButton(
            onPressed: () {
              context.read<TrasladosBloc>().add(const RefrescarTraslados());
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay traslados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No tienes traslados asignados para hoy',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<TrasladoEntity> _filtrarTraslados(List<TrasladoEntity> traslados) {
    // 1. Filtrar solo traslados del día actual Y que estén activos
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);

    var trasladosFiltrados = traslados.where((t) {
      final fechaTraslado = DateTime(t.fecha.year, t.fecha.month, t.fecha.day);
      // Filtrar por fecha Y por estado activo (excluye finalizados, cancelados, no realizados)
      return fechaTraslado.isAtSameMomentAs(hoy) && t.estado.isActivo;
    }).toList();

    // 2. Ordenar por hora programada (ascendente)
    trasladosFiltrados.sort((a, b) {
      return a.horaProgramada.compareTo(b.horaProgramada);
    });

    return trasladosFiltrados;
  }

  Future<void> _mostrarDialogoAsignacion(
    BuildContext context,
    TrasladoEntity traslado,
    bool esReasignacion,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de éxito
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 20),

              // Título
              Text(
                esReasignacion ? 'Traslado Reasignado' : 'Nuevo Traslado Asignado',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Detalles del traslado asignado
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Paciente
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            traslado.pacienteNombre ?? 'No especificado',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gray900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Hora programada (GRANDE)
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_outlined,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${DateFormat('dd/MM/yyyy').format(traslado.fecha)} - ${traslado.horaProgramada.substring(0, 5)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Origen
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ORIGEN',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gray600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                traslado.origenCompleto,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gray900,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Destino
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DESTINO',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gray600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                traslado.destinoCompleto,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gray900,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Botón único
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Aceptar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Resetear flag cuando el diálogo se cierra
    if (mounted) {
      setState(() {
        _mostrandoDialogoAsignacion = false;
      });
    }
  }

  /// Cambia el estado de un traslado desde la tarjeta
  Future<void> _cambiarEstadoDesdeCard(TrasladoEntity traslado, EstadoTraslado nuevoEstado) async {
    if (_cambiandoEstado) {
      debugPrint('⚠️  [ServiciosPage] Ya hay un cambio de estado en proceso');
      return;
    }

    // Obtener el traslado más reciente del estado para evitar usar datos desactualizados
    final estadoActual = context.read<TrasladosBloc>().state;
    if (estadoActual is! TrasladosLoaded) {
      debugPrint('⚠️  [ServiciosPage] No se puede cambiar estado sin traslados cargados');
      return;
    }

    final trasladoActualizado = estadoActual.getTrasladoById(traslado.id);
    if (trasladoActualizado == null) {
      debugPrint('⚠️  [ServiciosPage] Traslado no encontrado en el estado actual');
      return;
    }

    // Mostrar diálogo de confirmación
    final confirmar = await _mostrarDialogoConfirmacion(context, nuevoEstado);
    if (confirmar != true) return;

    setState(() {
      _cambiandoEstado = true;
    });

    // Mostrar diálogo de loading
    if (!mounted) return;
    _mostrarDialogoLoading(context, nuevoEstado);

    try {
      // Obtener ID de usuario desde AuthBloc
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated || authState.personal == null) {
        throw Exception('Usuario no autenticado');
      }

      final idUsuario = authState.personal!.id;

      // Obtener ubicación actual
      UbicacionEntity? ubicacion;
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
        ubicacion = UbicacionEntity(
          latitud: position.latitude,
          longitud: position.longitude,
          precision: position.accuracy,
          timestamp: DateTime.now(),
        );
      } catch (e) {
        debugPrint('⚠️  No se pudo obtener ubicación: $e');
      }

      // Cambiar estado usando el traslado actualizado
      if (mounted) {
        context.read<TrasladosBloc>().add(
              CambiarEstadoTraslado(
                idTraslado: trasladoActualizado.id,
                nuevoEstado: nuevoEstado,
                idUsuario: idUsuario,
                ubicacion: ubicacion,
              ),
            );
      }

      // Cerrar diálogo de loading después de un breve delay
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar loading dialog
      }

      // ✅ NO mostrar SnackBar - El feedback visual ya se proporciona mediante:
      // 1. El diálogo de loading (que muestra "Cambiando a [estado]")
      // 2. El badge de estado actualizado en la tarjeta
      // 3. El botón de acción actualizado en la tarjeta
    } catch (e) {
      // Cerrar diálogo de loading
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar estado: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _cambiandoEstado = false;
        });
      }
    }
  }

  void _mostrarDialogoLoading(BuildContext context, EstadoTraslado nuevoEstado) {
    final color = _getColorFromHex(nuevoEstado.colorHex);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Spinner con color del estado
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: 24),

                // Título
                Text(
                  'Cambiando a ${nuevoEstado.label}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Descripción
                const Text(
                  'Obteniendo ubicación y actualizando estado...',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.gray600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _mostrarDialogoConfirmacion(BuildContext context, EstadoTraslado nuevoEstado) {
    final color = _getColorFromHex(nuevoEstado.colorHex);

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono del estado
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconForEstado(nuevoEstado),
                  size: 48,
                  color: color,
                ),
              ),
              const SizedBox(height: 20),

              // Título
              const Text(
                'Confirmar cambio de estado',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Descripción
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.gray700,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: '¿Confirmas que deseas cambiar el estado a '),
                    TextSpan(
                      text: nuevoEstado.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    const TextSpan(text: '?'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.gray300, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Confirmar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForEstado(EstadoTraslado estado) {
    switch (estado) {
      case EstadoTraslado.enviado:
        return Icons.send_outlined;
      case EstadoTraslado.recibido:
        return Icons.check_circle_outline;
      case EstadoTraslado.enOrigen:
        return Icons.location_on;
      case EstadoTraslado.saliendoOrigen:
        return Icons.drive_eta;
      case EstadoTraslado.enTransito:
        return Icons.local_shipping_outlined;
      case EstadoTraslado.enDestino:
        return Icons.place;
      case EstadoTraslado.finalizado:
        return Icons.check_circle;
      default:
        return Icons.arrow_forward;
    }
  }

  Color _getColorFromHex(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  Future<void> _mostrarDialogoDesasignacion(BuildContext context, TrasladoEntity traslado) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de advertencia
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(height: 20),

              // Título
              const Text(
                'Traslado Desasignado',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Descripción
              const Text(
                'Este traslado ha sido desasignado desde la web.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.gray700,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              // Detalles del traslado desasignado
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Paciente
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            traslado.pacienteNombre ?? 'No especificado',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gray900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Hora programada (GRANDE)
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_outlined,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${DateFormat('dd/MM/yyyy').format(traslado.fecha)} - ${traslado.horaProgramada.substring(0, 5)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Origen
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ORIGEN',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gray600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                traslado.origenCompleto,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gray900,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Destino
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DESTINO',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gray600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                traslado.destinoCompleto,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gray900,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Botón
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Entendido',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Resetear flag cuando el diálogo se cierra
    if (mounted) {
      setState(() {
        _mostrandoDialogoDesasignacion = false;
      });
    }
  }
}
