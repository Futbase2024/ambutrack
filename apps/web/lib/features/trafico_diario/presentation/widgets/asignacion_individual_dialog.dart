import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/models/conductor_con_vehiculo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Diálogo para asignar conductor a un traslado individual desde el menú contextual
class AsignacionIndividualDialog extends StatelessWidget {
  const AsignacionIndividualDialog({
    required this.idTraslado,
    required this.pacienteNombre,
    required this.conductores,
    required this.onAsignar,
    super.key,
  });

  /// ID del traslado a asignar
  final String idTraslado;

  /// Nombre del paciente para mostrar contexto
  final String pacienteNombre;

  /// Lista de conductores disponibles
  final List<ConductorConVehiculo> conductores;

  /// Callback cuando se selecciona un conductor
  final void Function(String idTraslado, ConductorConVehiculo conductor) onAsignar;

  /// Muestra el diálogo de asignación individual
  static Future<void> show({
    required BuildContext context,
    required String idTraslado,
    required String pacienteNombre,
    required List<ConductorConVehiculo> conductores,
    required void Function(String idTraslado, ConductorConVehiculo conductor) onAsignar,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AsignacionIndividualDialog(
          idTraslado: idTraslado,
          pacienteNombre: pacienteNombre,
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
        child: _AsignacionIndividualContent(
          idTraslado: idTraslado,
          pacienteNombre: pacienteNombre,
          conductores: conductores,
          onAsignar: onAsignar,
        ),
      ),
    );
  }
}

/// Contenido del diálogo de asignación individual
class _AsignacionIndividualContent extends StatefulWidget {
  const _AsignacionIndividualContent({
    required this.idTraslado,
    required this.pacienteNombre,
    required this.conductores,
    required this.onAsignar,
  });

  final String idTraslado;
  final String pacienteNombre;
  final List<ConductorConVehiculo> conductores;
  final void Function(String idTraslado, ConductorConVehiculo conductor) onAsignar;

  @override
  State<_AsignacionIndividualContent> createState() => _AsignacionIndividualContentState();
}

class _AsignacionIndividualContentState extends State<_AsignacionIndividualContent> {
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
                conductor.nombreConductor.toLowerCase().contains(query) ||
                conductor.matriculaVehiculo.toLowerCase().contains(query))
            .toList()
          ..sort((ConductorConVehiculo a, ConductorConVehiculo b) =>
              a.nombreConductor.compareTo(b.nombreConductor));
      }
    });
  }

  void _asignarConductor() {
    if (_conductorSeleccionado != null) {
      widget.onAsignar(widget.idTraslado, _conductorSeleccionado!);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Header con título y botón cerrar
        _buildHeader(),
        const SizedBox(height: 16),

        // Info del traslado
        _buildInfoTraslado(),
        const SizedBox(height: 20),

        // Campo de búsqueda
        _buildSearchField(),
        const SizedBox(height: 16),

        // Lista de conductores
        _buildListaConductores(),
        const SizedBox(height: 24),

        // Botones de acción
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.person_add,
            color: AppColors.primary,
            size: 24,
          ),
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
    );
  }

  Widget _buildInfoTraslado() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.local_hospital,
            color: AppColors.info,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Traslado para:',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.pacienteNombre.isNotEmpty
                      ? widget.pacienteNombre.toUpperCase()
                      : 'SIN PACIENTE ASIGNADO',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Buscar por nombre o matrícula...',
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
    );
  }

  Widget _buildListaConductores() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 350),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray300),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: _conductoresFiltrados.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              shrinkWrap: true,
              itemCount: _conductoresFiltrados.length,
              separatorBuilder: (BuildContext _, int __) => const Divider(height: 1),
              itemBuilder: (BuildContext context, int index) {
                final ConductorConVehiculo conductor = _conductoresFiltrados[index];
                final bool seleccionado = _conductorSeleccionado == conductor;

                return _buildConductorTile(conductor, seleccionado);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.textSecondaryLight.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No se encontraron conductores',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondaryLight,
              ),
            ),
            if (_searchController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Prueba con otro término de búsqueda',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight.withValues(alpha: 0.7),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConductorTile(ConductorConVehiculo conductor, bool seleccionado) {
    return ListTile(
      selected: seleccionado,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
      leading: CircleAvatar(
        backgroundColor: seleccionado ? AppColors.primary : AppColors.gray300,
        foregroundColor: Colors.white,
        child: Text(
          conductor.nombreConductor.substring(0, 1).toUpperCase(),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        conductor.nombreConductor.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: seleccionado ? FontWeight.w600 : FontWeight.w400,
          color: seleccionado ? AppColors.primary : AppColors.textPrimaryLight,
        ),
      ),
      subtitle: Row(
        children: <Widget>[
          Icon(
            Icons.directions_car,
            size: 14,
            color: seleccionado ? AppColors.primary : AppColors.textSecondaryLight,
          ),
          const SizedBox(width: 4),
          Text(
            conductor.matriculaVehiculo,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: seleccionado ? AppColors.primary : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
      trailing: seleccionado
          ? const Icon(
              Icons.check_circle,
              color: AppColors.primary,
              size: 24,
            )
          : const Icon(
              Icons.radio_button_unchecked,
              color: AppColors.gray400,
              size: 24,
            ),
      onTap: () {
        setState(() {
          _conductorSeleccionado = conductor;
        });
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
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
        ElevatedButton.icon(
          onPressed: _conductorSeleccionado != null ? _asignarConductor : null,
          icon: const Icon(Icons.check, size: 18),
          label: Text(
            'Asignar Conductor',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}
