import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/services/vehiculo_cache_service.dart';
import '../../domain/repositories/checklist_repository.dart';
import '../bloc/checklist_bloc.dart';
import '../bloc/checklist_event.dart';
import '../bloc/checklist_state.dart';
import '../widgets/checklist_card.dart';
import '../widgets/empty_checklist_view.dart';
import '../widgets/seleccion_vehiculo_dialog.dart';
import '../widgets/sin_vehiculo_asignado_view.dart';

/// Página de Checklist de Ambulancia
///
/// Muestra el historial de checklists realizados
/// y permite crear nuevos checklists
class ChecklistAmbulanciaPage extends StatelessWidget {
  const ChecklistAmbulanciaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChecklistBloc(
        repository: getIt(),
      ),
      child: const _ChecklistAmbulanciaPageContent(),
    );
  }
}

class _ChecklistAmbulanciaPageContent extends StatefulWidget {
  const _ChecklistAmbulanciaPageContent();

  @override
  State<_ChecklistAmbulanciaPageContent> createState() =>
      _ChecklistAmbulanciaPageContentState();
}

class _ChecklistAmbulanciaPageContentState
    extends State<_ChecklistAmbulanciaPageContent> {
  String? _vehiculoId;
  bool _cargandoVehiculo = true;
  String? _empresaId;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  /// Carga los datos iniciales
  Future<void> _cargarDatos() async {
    setState(() {
      _cargandoVehiculo = true;
    });

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.personal != null) {
      final personal = authState.personal!;
      final personalId = personal.id;

      // Guardar empresaId para uso posterior
      _empresaId = personal.empresaId;

      // Intentar obtener vehículo desde caché primero
      final cache = VehiculoCacheService.instance;
      String? vehiculoId = cache.getVehiculoAsignado(personalId);

      // Si no está en caché, consultar al repository
      if (vehiculoId == null) {
        try {
          final repository = getIt<ChecklistRepository>();
          vehiculoId = await repository.getVehiculoAsignadoHoy(personalId);

          // Guardar en caché
          cache.setVehiculoAsignado(personalId, vehiculoId);
        } catch (e) {
          debugPrint('❌ Error al obtener vehículo asignado: $e');
        }
      }

      setState(() {
        _vehiculoId = vehiculoId;
        _cargandoVehiculo = false;
      });

      // Cargar historial si tiene vehículo asignado
      if (_vehiculoId != null && mounted) {
        context.read<ChecklistBloc>().add(
              ChecklistEvent.cargarHistorial(vehiculoId: _vehiculoId!),
            );
      }
    } else {
      setState(() {
        _cargandoVehiculo = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Checklist de Ambulancia'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _cargandoVehiculo
            ? const Center(
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
              )
            : _vehiculoId == null
                ? SinVehiculoAsignadoView(
                    mostrarBotonSeleccion: true,
                    onSeleccionarManual: () => _mostrarSeleccionVehiculo(context),
                  )
                : BlocBuilder<ChecklistBloc, ChecklistState>(
                    builder: (context, state) {
                      return state.when(
                        initial: () => const Center(
                          child: Text('Inicializando...'),
                        ),
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        historialCargado: (checklists, vehiculoId) {
                          if (checklists.isEmpty) {
                            return EmptyChecklistView(
                              onCrearChecklist: () =>
                                  _navegarANuevoChecklist(context),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: () async {
                              context.read<ChecklistBloc>().add(
                                    const ChecklistEvent.refrescarHistorial(),
                                  );
                              // Esperar un poco para que se complete
                              await Future.delayed(
                                const Duration(milliseconds: 500),
                              );
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: checklists.length,
                              itemBuilder: (context, index) {
                                final checklist = checklists[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: ChecklistCard(
                                    checklist: checklist,
                                    onTap: () => _navegarADetalle(
                                      context,
                                      checklist.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        creandoChecklist: (vehiculoId, tipo, items, resultados, obs) {
                          // Este estado se maneja en la página de nuevo checklist
                          return const SizedBox.shrink();
                        },
                        guardando: () => const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Guardando checklist...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.gray700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        checklistGuardado: (checklist) {
                          // Este estado se maneja en el listener
                          return const SizedBox.shrink();
                        },
                        viendoDetalle: (checklist) {
                          // Este estado se maneja en la página de detalle
                          return const SizedBox.shrink();
                        },
                        error: (mensaje, vehiculoId) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
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
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.gray900,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  mensaje,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppColors.gray600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    if (vehiculoId != null) {
                                      context.read<ChecklistBloc>().add(
                                            ChecklistEvent.cargarHistorial(
                                              vehiculoId: vehiculoId,
                                            ),
                                          );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                  ),
                                  child: const Text('Reintentar'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: _vehiculoId != null
          ? FloatingActionButton.extended(
              onPressed: () => _navegarANuevoChecklist(context),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Nuevo Checklist'),
            )
          : null,
    );
  }

  /// Muestra diálogo de selección manual de vehículo
  Future<void> _mostrarSeleccionVehiculo(BuildContext context) async {
    if (_empresaId == null || _empresaId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Usuario sin empresa asignada'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final repository = getIt<ChecklistRepository>();
      final vehiculos = await repository.getTodosVehiculos(_empresaId!);

      // Cerrar loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (vehiculos.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No hay vehículos disponibles'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      // Mostrar diálogo de selección
      if (context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => SeleccionVehiculoDialog(
            vehiculos: vehiculos,
            onVehiculoSeleccionado: (vehiculo) {
              // Actualizar vehículo seleccionado
              setState(() {
                _vehiculoId = vehiculo.id;
              });

              // Cargar historial
              context.read<ChecklistBloc>().add(
                    ChecklistEvent.cargarHistorial(vehiculoId: vehiculo.id),
                  );

              debugPrint(
                '✅ Vehículo seleccionado manualmente: ${vehiculo.matricula}',
              );
            },
          ),
        );
      }
    } catch (e) {
      // Cerrar loading si está abierto
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      debugPrint('❌ Error al cargar vehículos: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar vehículos: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Navega a la página de nuevo checklist
  Future<void> _navegarANuevoChecklist(BuildContext context) async {
    if (_vehiculoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes un vehículo asignado'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Navegar y esperar el resultado
    final result = await context.push<bool>(
      '/checklist-ambulancia/nuevo?vehiculoId=$_vehiculoId',
    );

    // Si el resultado es true, significa que se guardó el checklist exitosamente
    if (result == true && context.mounted) {
      debugPrint('✅ [ChecklistAmbulancia] Checklist guardado, recargando historial...');

      // Recargar historial
      if (_vehiculoId != null) {
        context.read<ChecklistBloc>().add(
              ChecklistEvent.cargarHistorial(vehiculoId: _vehiculoId!),
            );
      }

      // Mostrar diálogo de éxito
      _mostrarDialogoExito(context);
    }
  }

  /// Navega a la página de detalle de checklist
  Future<void> _navegarADetalle(BuildContext context, String checklistId) async {
    // Navegar a la página de detalle
    await context.push('/checklist-ambulancia/$checklistId');

    // Al volver, recargar el historial para asegurar que el estado es correcto
    if (context.mounted && _vehiculoId != null) {
      debugPrint('🔄 [ChecklistAmbulancia] Volviendo de detalle, recargando historial...');
      context.read<ChecklistBloc>().add(
            ChecklistEvent.cargarHistorial(vehiculoId: _vehiculoId!),
          );
    }
  }

  /// Muestra diálogo de éxito al guardar checklist
  Future<void> _mostrarDialogoExito(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              const Text(
                'Checklist Guardado',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'El checklist se ha guardado correctamente.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.gray700,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
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
  }
}
