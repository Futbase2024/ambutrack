import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../caducidades/presentation/bloc/caducidades_bloc.dart';
import '../../../caducidades/presentation/bloc/caducidades_event.dart';
import '../../../caducidades/presentation/bloc/caducidades_state.dart';
import '../../../checklist_ambulancia/data/services/vehiculo_cache_service.dart';
import '../../../checklist_ambulancia/domain/repositories/checklist_repository.dart';
import '../../data/services/alertas_caducidad_cache_service.dart';
import 'dialogs/alertas_caducidad_dialog.dart';

/// Sección de alertas de caducidad en el home
///
/// Muestra items próximos a caducar y críticos agrupados por categoría
class AlertasCaducidadHomeSection extends StatefulWidget {
  const AlertasCaducidadHomeSection({super.key});

  @override
  State<AlertasCaducidadHomeSection> createState() =>
      _AlertasCaducidadHomeSectionState();
}

class _AlertasCaducidadHomeSectionState
    extends State<AlertasCaducidadHomeSection> {
  String? _vehiculoId;
  bool _cargandoVehiculo = true;
  bool _fueronRevisadasHoy = false;

  @override
  void initState() {
    super.initState();
    _cargarVehiculo();
  }

  Future<void> _cargarVehiculo() async {
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

      if (mounted) {
        // Verificar si las alertas ya fueron revisadas hoy
        final cache = AlertasCaducidadCacheService.instance;
        final revisadasHoy = vehiculoId != null ? cache.fueronRevisadasHoy(vehiculoId) : false;

        setState(() {
          _vehiculoId = vehiculoId;
          _fueronRevisadasHoy = revisadasHoy;
          _cargandoVehiculo = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _cargandoVehiculo = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // No mostrar si está cargando, no hay vehículo asignado, o ya fueron revisadas hoy
    if (_cargandoVehiculo || _vehiculoId == null || _fueronRevisadasHoy) {
      return const SizedBox.shrink();
    }

    return BlocProvider(
      create: (context) => getIt<CaducidadesBloc>()
        ..add(CaducidadesEvent.started(vehiculoId: _vehiculoId!)),
      child: _AlertasCaducidadContent(vehiculoId: _vehiculoId!),
    );
  }
}

class _AlertasCaducidadContent extends StatefulWidget {
  const _AlertasCaducidadContent({required this.vehiculoId});

  final String vehiculoId;

  @override
  State<_AlertasCaducidadContent> createState() => _AlertasCaducidadContentState();
}

class _AlertasCaducidadContentState extends State<_AlertasCaducidadContent> {
  bool _dialogoMostrado = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CaducidadesBloc, CaducidadesState>(
      builder: (context, state) {
        return state.maybeWhen(
          loaded: (
            items,
            alertas,
            vehiculoIdEstado,
            filtroActual,
            totalItems,
            itemsOk,
            itemsProximos,
            itemsCriticos,
            itemsCaducados,
            isRefreshing,
          ) {
            // Debug: Ver qué items recibimos
            debugPrint('🏠 AlertasCaducidadHomeSection: Recibidos ${items.length} items');
            for (final item in items) {
              debugPrint('   - ${item.productoNombre}: estado="${item.estadoCaducidad}"');
            }

            // Filtrar solo items próximos y críticos
            // Calcular estado si viene null
            final itemsAlerta = items.where((item) {
              final estadoCalculado = _calcularEstadoCaducidad(item);
              return estadoCalculado == 'proximo' || estadoCalculado == 'critico';
            }).toList();

            debugPrint('🏠 AlertasCaducidadHomeSection: ${itemsAlerta.length} items después de filtrar');

            // No mostrar nada si no hay alertas
            if (itemsAlerta.isEmpty) {
              return const SizedBox.shrink();
            }

            // Mostrar diálogo automáticamente si no se ha mostrado aún
            if (!_dialogoMostrado) {
              _dialogoMostrado = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  showDialog<void>(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) => AlertasCaducidadDialog(
                      items: itemsAlerta,
                      vehiculoId: widget.vehiculoId,
                    ),
                  );
                }
              });
            }

            // Retornar widget invisible ya que mostramos el diálogo
            return const SizedBox.shrink();
          },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }

  /// Calcula el estado de caducidad si viene null
  String _calcularEstadoCaducidad(StockVehiculoEntity item) {
    // Si ya tiene estado definido, usarlo
    if (item.estadoCaducidad != null && item.estadoCaducidad != 'null') {
      return item.estadoCaducidad!;
    }

    // Si no tiene fecha de caducidad, no tiene estado
    if (item.fechaCaducidad == null) {
      return 'sin_caducidad';
    }

    // Calcular días restantes
    final diasRestantes = item.fechaCaducidad!.difference(DateTime.now()).inDays;

    // Clasificar según días restantes
    if (diasRestantes < 0) {
      return 'caducado';
    } else if (diasRestantes <= 7) {
      return 'critico';
    } else if (diasRestantes <= 30) {
      return 'proximo';
    } else {
      return 'ok';
    }
  }
}
