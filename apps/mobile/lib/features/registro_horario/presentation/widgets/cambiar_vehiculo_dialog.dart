import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../bloc/registro_horario_bloc.dart';
import '../bloc/registro_horario_event.dart';

/// Diálogo para cambiar de vehículo durante el turno
///
/// Muestra lista de vehículos disponibles y solicita ubicación GPS
/// antes de realizar el cambio.
class CambiarVehiculoDialog extends StatefulWidget {
  const CambiarVehiculoDialog({
    required this.vehiculoActual,
    super.key,
  });

  final VehiculoEntity vehiculoActual;

  @override
  State<CambiarVehiculoDialog> createState() => _CambiarVehiculoDialogState();
}

class _CambiarVehiculoDialogState extends State<CambiarVehiculoDialog> {
  bool _isLoading = true;
  bool _isChanging = false;
  List<VehiculoEntity> _vehiculos = [];
  VehiculoEntity? _vehiculoSeleccionado;
  Position? _posicion;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Cargar vehículos disponibles
      final vehiculoDs = VehiculoDataSourceFactory.createSupabase();
      final todosVehiculos = await vehiculoDs.getAll();

      // Filtrar vehículo actual
      _vehiculos = todosVehiculos
          .where((v) => v.id != widget.vehiculoActual.id)
          .toList();

      // Obtener ubicación GPS
      _posicion = await _obtenerUbicacion();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<Position?> _obtenerUbicacion() async {
    try {
      // Verificar permisos
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Permisos de ubicación no otorgados');
      }

      // Obtener ubicación actual
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      debugPrint('❌ Error al obtener ubicación: $e');
      return null;
    }
  }

  Future<void> _confirmarCambio() async {
    if (_vehiculoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un vehículo'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_posicion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener la ubicación GPS'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isChanging = true;
    });

    // Disparar evento de cambio de vehículo
    if (mounted) {
      context.read<RegistroHorarioBloc>().add(
            CambiarVehiculo(
              nuevoVehiculoId: _vehiculoSeleccionado!.id,
              latitud: _posicion!.latitude,
              longitud: _posicion!.longitude,
              precisionGps: _posicion!.accuracy,
            ),
          );

      // Cerrar diálogo
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.swap_horiz,
                    size: 24,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cambiar Vehículo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray900,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Cierra turno actual y abre con nuevo vehículo',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Vehículo actual
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_shipping,
                    size: 20,
                    color: AppColors.gray600,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Actual:',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.gray600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.vehiculoActual.matricula,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.gray900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (widget.vehiculoActual.modelo.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '(${widget.vehiculoActual.modelo})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.gray500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Lista de vehículos o loading
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar vehículos',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_vehiculos.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: AppColors.info,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No hay vehículos disponibles',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _vehiculos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final vehiculo = _vehiculos[index];
                    final isSelected = _vehiculoSeleccionado?.id == vehiculo.id;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _vehiculoSeleccionado = vehiculo;
                        });
                      },
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusSmall),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.gray300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusSmall),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_shipping,
                              size: 20,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.gray600,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vehiculo.matricula,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.gray900,
                                    ),
                                  ),
                                  if (vehiculo.modelo.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      vehiculo.modelo,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.gray600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isChanging
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.gray400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isChanging ? null : _confirmarCambio,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isChanging
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Cambiar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
