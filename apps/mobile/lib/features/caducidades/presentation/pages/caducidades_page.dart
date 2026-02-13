import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dialogs/professional_result_dialog.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../checklist_ambulancia/data/services/vehiculo_cache_service.dart';
import '../../../checklist_ambulancia/domain/repositories/checklist_repository.dart';
import '../bloc/caducidades_bloc.dart';
import '../bloc/caducidades_event.dart';
import '../bloc/caducidades_state.dart';
import '../widgets/caducidad_card.dart';
import '../widgets/caducidades_empty_state.dart';
import '../widgets/caducidades_stats_header.dart';
import '../widgets/dialogs/solicitud_reposicion_dialog.dart';
import '../widgets/dialogs/registrar_incidencia_dialog.dart';
import 'detalle_caducidad_page.dart';

/// Página de Control de Caducidades
///
/// Muestra los items con caducidad del vehículo asignado al usuario
class CaducidadesPage extends StatefulWidget {
  const CaducidadesPage({super.key});

  @override
  State<CaducidadesPage> createState() => _CaducidadesPageState();
}

class _CaducidadesPageState extends State<CaducidadesPage> {
  String? _vehiculoId;
  bool _cargandoVehiculo = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  /// Carga el vehículo asignado al usuario
  Future<void> _cargarDatos() async {
    setState(() {
      _cargandoVehiculo = true;
    });

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.personal != null) {
      final personal = authState.personal!;
      final personalId = personal.id;

      // Intentar obtener vehículo desde caché primero
      final cache = VehiculoCacheService.instance;
      String? vehiculoId = cache.getVehiculoAsignado(personalId);

      // Si no está en caché, consultar al repository
      if (vehiculoId == null) {
        try {
          final repository = getIt<ChecklistRepository>();
          vehiculoId = await repository.getVehiculoAsignadoHoy(personalId);

          // Guardar en caché
          if (vehiculoId != null) {
            cache.setVehiculoAsignado(personalId, vehiculoId);
          }
        } catch (e) {
          debugPrint('❌ Error al obtener vehículo asignado: $e');
        }
      }

      setState(() {
        _vehiculoId = vehiculoId;
        _cargandoVehiculo = false;
      });
    } else {
      setState(() {
        _cargandoVehiculo = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargandoVehiculo) {
      return Scaffold(
        backgroundColor: AppColors.gray50,
        appBar: AppBar(
          title: const Text('Control de Caducidades'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Buscando vehículo asignado...',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_vehiculoId == null) {
      return Scaffold(
        backgroundColor: AppColors.gray50,
        appBar: AppBar(
          title: const Text('Control de Caducidades'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const SafeArea(
          child: _SinVehiculoAsignadoView(),
        ),
      );
    }

    return BlocProvider(
      create: (context) => getIt<CaducidadesBloc>()
        ..add(CaducidadesEvent.started(vehiculoId: _vehiculoId!)),
      child: _CaducidadesPageContent(vehiculoId: _vehiculoId!),
    );
  }
}

class _CaducidadesPageContent extends StatelessWidget {
  const _CaducidadesPageContent({required this.vehiculoId});

  final String vehiculoId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Control de Caducidades'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CaducidadesBloc>().add(
                    const CaducidadesEvent.refrescar(),
                  );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<CaducidadesBloc, CaducidadesState>(
          listener: (context, state) {
            state.maybeWhen(
              accionExitosa: (mensaje, vehiculoId) {
                showProfessionalResultDialog(
                  context,
                  title: 'Éxito',
                  message: mensaje,
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.success,
                  onClose: () {
                    // Recargar datos después de acción exitosa
                    if (vehiculoId != null) {
                      context.read<CaducidadesBloc>().add(
                            CaducidadesEvent.cargarCaducidades(
                              vehiculoId: vehiculoId,
                            ),
                          );
                    }
                  },
                );
              },
              error: (mensaje, vehiculoId) {
                showProfessionalResultDialog(
                  context,
                  title: 'Error',
                  message: mensaje,
                  icon: Icons.error_outline,
                  iconColor: AppColors.error,
                );
              },
              orElse: () {},
            );
          },
          builder: (context, state) {
            return state.when(
              initial: () => const _LoadingView(),
              loading: () => const _LoadingView(),
              loaded: (
                items,
                alertas,
                vehiculoId,
                filtroActual,
                total,
                ok,
                proximos,
                criticos,
                caducados,
                isRefreshing,
              ) {
                return _LoadedView(
                  items: items,
                  totalItems: total,
                  itemsOk: ok,
                  itemsProximos: proximos,
                  itemsCriticos: criticos,
                  itemsCaducados: caducados,
                  filtroActual: filtroActual,
                  isRefreshing: isRefreshing,
                  vehiculoId: vehiculoId,
                );
              },
              procesando: (mensaje) => _ProcesamdoView(mensaje: mensaje),
              accionExitosa: (mensaje, vehiculoId) => const _LoadingView(),
              error: (mensaje, vehiculoId) => _ErrorView(
                mensaje: mensaje,
                vehiculoId: vehiculoId,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Vista cuando está cargando
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

/// Vista cuando está procesando una acción
class _ProcesamdoView extends StatelessWidget {
  const _ProcesamdoView({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            mensaje,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Vista cuando hay datos cargados
class _LoadedView extends StatelessWidget {
  const _LoadedView({
    required this.items,
    required this.totalItems,
    required this.itemsOk,
    required this.itemsProximos,
    required this.itemsCriticos,
    required this.itemsCaducados,
    required this.filtroActual,
    required this.isRefreshing,
    required this.vehiculoId,
  });

  final List items;
  final int totalItems;
  final int itemsOk;
  final int itemsProximos;
  final int itemsCriticos;
  final int itemsCaducados;
  final String? filtroActual;
  final bool isRefreshing;
  final String vehiculoId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header con estadísticas y filtros
        CaducidadesStatsHeader(
          totalItems: totalItems,
          itemsOk: itemsOk,
          itemsProximos: itemsProximos,
          itemsCriticos: itemsCriticos,
          itemsCaducados: itemsCaducados,
          filtroActual: filtroActual,
          onFiltroChanged: (filtro) {
            context.read<CaducidadesBloc>().add(
                  CaducidadesEvent.filtrarPorEstado(filtro: filtro),
                );
          },
        ),

        // Lista de items
        Expanded(
          child: items.isEmpty
              ? CaducidadesEmptyState(
                  mensaje: filtroActual != null
                      ? 'No hay items en este estado'
                      : 'No hay items con caducidad',
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    context.read<CaducidadesBloc>().add(
                          const CaducidadesEvent.refrescar(),
                        );
                  },
                  child: ListView.builder(
                    itemCount: items.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return CaducidadCard(
                        item: item,
                        onTap: () {
                          // Capturar el BLoC antes de navegar
                          final caducidadesBloc = context.read<CaducidadesBloc>();

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BlocProvider.value(
                                value: caducidadesBloc,
                                child: DetalleCaducidadPage(
                                  item: item,
                                  vehiculoId: vehiculoId,
                                ),
                              ),
                            ),
                          );
                        },
                        onSolicitarReposicion: () async {
                          await _mostrarDialogoSolicitudReposicion(
                            context,
                            item,
                            vehiculoId,
                          );
                        },
                        onRegistrarIncidencia: () async {
                          await _mostrarDialogoRegistrarIncidencia(
                            context,
                            item,
                            vehiculoId,
                          );
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

/// Vista de error
class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.mensaje,
    this.vehiculoId,
  });

  final String mensaje;
  final String? vehiculoId;

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
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: 24),
            const Text(
              'Error al cargar caducidades',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              mensaje,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (vehiculoId != null) {
                  context.read<CaducidadesBloc>().add(
                        CaducidadesEvent.cargarCaducidades(
                          vehiculoId: vehiculoId!,
                        ),
                      );
                }
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
      ),
    );
  }
}

/// Vista sin vehículo asignado
class _SinVehiculoAsignadoView extends StatelessWidget {
  const _SinVehiculoAsignadoView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 80,
              color: AppColors.gray400,
            ),
            const SizedBox(height: 24),
            const Text(
              'Sin vehículo asignado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'No tienes un vehículo asignado para hoy. Contacta con tu coordinador.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ===== Funciones auxiliares para diálogos =====

/// Muestra diálogo para solicitar reposición de un item
Future<void> _mostrarDialogoSolicitudReposicion(
  BuildContext context,
  dynamic item,
  String vehiculoId,
) async {
  final authState = context.read<AuthBloc>().state;
  if (authState is! AuthAuthenticated) return;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => SolicitudReposicionDialog(
      productoNombre: item.productoNombre ?? 'Sin nombre',
      cantidadActual: item.cantidadActual ?? 0,
      onSolicitar: (cantidad, motivo) async {
        // Disparar evento en el BLoC
        context.read<CaducidadesBloc>().add(
              CaducidadesEvent.solicitarReposicion(
                vehiculoId: vehiculoId,
                productoId: item.productoId ?? '',
                productoNombre: item.productoNombre ?? 'Sin nombre',
                cantidadSolicitada: cantidad,
                motivo: motivo,
                usuarioId: authState.user.id,
              ),
            );
      },
    ),
  );

  if (result == true) {
    debugPrint('✅ Solicitud de reposición enviada');
  }
}

/// Muestra diálogo para registrar incidencia de caducidad
Future<void> _mostrarDialogoRegistrarIncidencia(
  BuildContext context,
  dynamic item,
  String vehiculoId,
) async {
  final authState = context.read<AuthBloc>().state;
  if (authState is! AuthAuthenticated || authState.personal == null) return;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => RegistrarIncidenciaDialog(
      productoNombre: item.productoNombre ?? 'Sin nombre',
      onRegistrar: (titulo, descripcion) async {
        // Disparar evento en el BLoC
        context.read<CaducidadesBloc>().add(
              CaducidadesEvent.registrarIncidencia(
                vehiculoId: vehiculoId,
                titulo: titulo,
                descripcion: descripcion,
                reportadoPor: authState.user.id,
                reportadoPorNombre: authState.personal!.nombreCompleto,
                empresaId: authState.personal!.empresaId ?? '',
              ),
            );
      },
    ),
  );

  if (result == true) {
    debugPrint('✅ Incidencia registrada');
  }
}
