import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/models/conductor_con_vehiculo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Diálogo para asignación masiva de conductor a múltiples traslados
class AsignacionMasivaDialog extends StatelessWidget {
  const AsignacionMasivaDialog({
    required this.cantidadSeleccionados,
    required this.conductores,
    required this.onAsignar,
    super.key,
  });

  final int cantidadSeleccionados;
  final List<ConductorConVehiculo> conductores;
  final ValueChanged<ConductorConVehiculo?> onAsignar;

  static Future<void> show({
    required BuildContext context,
    required int cantidadSeleccionados,
    required List<ConductorConVehiculo> conductores,
    required ValueChanged<ConductorConVehiculo?> onAsignar,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AsignacionMasivaDialog(
          cantidadSeleccionados: cantidadSeleccionados,
          conductores: conductores,
          onAsignar: onAsignar,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: _AsignacionMasivaContent(
          cantidadSeleccionados: cantidadSeleccionados,
          conductores: conductores,
          onAsignar: onAsignar,
        ),
      ),
    );
  }
}

/// Contenido del diálogo de asignación masiva
class _AsignacionMasivaContent extends StatefulWidget {
  const _AsignacionMasivaContent({
    required this.cantidadSeleccionados,
    required this.conductores,
    required this.onAsignar,
  });

  final int cantidadSeleccionados;
  final List<ConductorConVehiculo> conductores;
  final ValueChanged<ConductorConVehiculo?> onAsignar;

  @override
  State<_AsignacionMasivaContent> createState() => _AsignacionMasivaContentState();
}

class _AsignacionMasivaContentState extends State<_AsignacionMasivaContent> {
  ConductorConVehiculo? _conductorSeleccionado;
  final TextEditingController _searchController = TextEditingController();
  late List<ConductorConVehiculo> _conductoresFiltrados;

  @override
  void initState() {
    super.initState();
    _conductoresFiltrados = List<ConductorConVehiculo>.from(widget.conductores)
      ..sort((ConductorConVehiculo a, ConductorConVehiculo b) =>
          a.nombreConductor.compareTo(b.nombreConductor));
    _searchController.addListener(_filtrarConductores);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_filtrarConductores)
      ..dispose();
    super.dispose();
  }

  void _filtrarConductores() {
    setState(() {
      final String query = _searchController.text.toLowerCase();
      if (query.isEmpty) {
        _conductoresFiltrados = List<ConductorConVehiculo>.from(widget.conductores)
          ..sort((ConductorConVehiculo a, ConductorConVehiculo b) =>
              a.nombreConductor.compareTo(b.nombreConductor));
      } else {
        _conductoresFiltrados = widget.conductores
            .where((ConductorConVehiculo conductor) =>
                conductor.nombreConductor.toLowerCase().contains(query))
            .toList()
          ..sort((ConductorConVehiculo a, ConductorConVehiculo b) =>
              a.nombreConductor.compareTo(b.nombreConductor));
      }
    });
  }

  void _asignarConductor() {
    widget.onAsignar(_conductorSeleccionado);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Título
        Row(
          children: <Widget>[
            const Icon(
              Icons.person_add,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Asignar Conductor',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
              color: AppColors.textSecondaryLight,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Info de traslados seleccionados
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Se asignará el mismo conductor a ${widget.cantidadSeleccionados} traslados seleccionados',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Campo de búsqueda
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar conductor...',
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: _searchController.clear,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          style: GoogleFonts.inter(fontSize: 14),
        ),
        const SizedBox(height: 16),

        // Lista de conductores
        Container(
          constraints: const BoxConstraints(maxHeight: 400),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gray300),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: _conductoresFiltrados.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No se encontraron conductores',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: _conductoresFiltrados.length,
                  separatorBuilder: (BuildContext _, int __) => const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    final ConductorConVehiculo conductor = _conductoresFiltrados[index];
                    final bool seleccionado = _conductorSeleccionado == conductor;

                    return ListTile(
                      selected: seleccionado,
                      selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
                      leading: CircleAvatar(
                        backgroundColor: seleccionado
                            ? AppColors.primary
                            : AppColors.gray300,
                        foregroundColor: Colors.white,
                        child: Text(
                          conductor.nombreConductor.substring(0, 1).toUpperCase(),
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        conductor.nombreConductor,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: seleccionado ? FontWeight.w600 : FontWeight.w400,
                          color: seleccionado
                              ? AppColors.primary
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      subtitle: Text(
                        'Vehículo: ${conductor.matriculaVehiculo}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      trailing: seleccionado
                          ? const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: 24,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _conductorSeleccionado = conductor;
                        });
                      },
                    );
                  },
                ),
        ),
        const SizedBox(height: 24),

        // Botones de acción
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _conductorSeleccionado != null ? _asignarConductor : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                elevation: 0,
              ),
              child: Text(
                'Asignar Conductor',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
