import 'package:flutter/material.dart';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

import '../../../../core/theme/app_colors.dart';

/// Diálogo para seleccionar vehículo manualmente
///
/// Permite a usuarios admin o coordinador seleccionar cualquier vehículo
/// para realizar un checklist
class SeleccionVehiculoDialog extends StatefulWidget {
  const SeleccionVehiculoDialog({
    super.key,
    required this.vehiculos,
    required this.onVehiculoSeleccionado,
  });

  /// Lista de vehículos disponibles
  final List<VehiculoEntity> vehiculos;

  /// Callback cuando se selecciona un vehículo
  final void Function(VehiculoEntity vehiculo) onVehiculoSeleccionado;

  @override
  State<SeleccionVehiculoDialog> createState() =>
      _SeleccionVehiculoDialogState();
}

class _SeleccionVehiculoDialogState extends State<SeleccionVehiculoDialog> {
  final _searchController = TextEditingController();
  List<VehiculoEntity> _vehiculosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _vehiculosFiltrados = widget.vehiculos;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filtra los vehículos según el texto de búsqueda
  void _filtrarVehiculos(String query) {
    if (query.isEmpty) {
      setState(() {
        _vehiculosFiltrados = widget.vehiculos;
      });
      return;
    }

    final queryLower = query.toLowerCase();
    setState(() {
      _vehiculosFiltrados = widget.vehiculos.where((vehiculo) {
        final matricula = vehiculo.matricula.toLowerCase();
        final modelo = vehiculo.modelo.toLowerCase();
        return matricula.contains(queryLower) || modelo.contains(queryLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_shipping,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Seleccionar Vehículo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray900,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    color: AppColors.gray600,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Campo de búsqueda
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por matrícula o modelo...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: _filtrarVehiculos,
              ),
            ),

            // Lista de vehículos
            Expanded(
              child: _vehiculosFiltrados.isEmpty
                  ? const _EmptySearchView()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _vehiculosFiltrados.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final vehiculo = _vehiculosFiltrados[index];
                        return _VehiculoListTile(
                          vehiculo: vehiculo,
                          onTap: () {
                            widget.onVehiculoSeleccionado(vehiculo);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${_vehiculosFiltrados.length} vehículo(s) disponible(s)',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.gray600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Item de la lista de vehículos
class _VehiculoListTile extends StatelessWidget {
  const _VehiculoListTile({
    required this.vehiculo,
    required this.onTap,
  });

  final VehiculoEntity vehiculo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            // Icono del vehículo
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_shipping,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Información del vehículo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehiculo.matricula,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vehiculo.modelo,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),

            // Flecha
            const Icon(
              Icons.chevron_right,
              color: AppColors.gray400,
            ),
          ],
        ),
      ),
    );
  }
}

/// Vista vacía cuando no hay resultados de búsqueda
class _EmptySearchView extends StatelessWidget {
  const _EmptySearchView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.gray400,
            ),
            SizedBox(height: 16),
            Text(
              'No se encontraron vehículos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Intenta con otra búsqueda',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
