import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:flutter/material.dart';

/// Widget de filtros para la lista de provincias
class ProvinciaFilters extends StatefulWidget {
  const ProvinciaFilters({
    required this.onFiltersChanged,
    super.key,
  });

  final void Function(ProvinciaFilterData) onFiltersChanged;

  @override
  State<ProvinciaFilters> createState() => _ProvinciaFiltersState();
}

class _ProvinciaFiltersState extends State<ProvinciaFilters> {
  String? _selectedComunidadId;
  List<ComunidadAutonomaEntity> _comunidades = <ComunidadAutonomaEntity>[];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadComunidades();
  }

  Future<void> _loadComunidades() async {
    setState(() => _isLoading = true);

    try {
      final ComunidadAutonomaDataSource dataSource = getIt<ComunidadAutonomaDataSource>();
      final List<ComunidadAutonomaEntity> comunidades = await dataSource.getAll();

      if (mounted) {
        setState(() {
          _comunidades = comunidades;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar comunidades para filtros: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _notifyFilters() {
    widget.onFiltersChanged(
      ProvinciaFilterData(
        comunidadId: _selectedComunidadId,
      ),
    );
  }

  void _limpiarFiltros() {
    setState(() {
      _selectedComunidadId = null;
    });
    _notifyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasActiveFilters = _selectedComunidadId != null;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: <Widget>[
        // Filtro por comunidad autónoma
        if (_isLoading)
          const SizedBox(
            width: 250,
            height: 56,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else
          SizedBox(
            width: 250,
            child: AppDropdown<String>(
              value: _selectedComunidadId,
              label: 'Comunidad Autónoma',
              hint: 'Todas',
              prefixIcon: Icons.map,
              items: <AppDropdownItem<String>>[
                const AppDropdownItem<String>(
                  value: '',
                  label: 'Todas las comunidades',
                ),
                ..._comunidades.map(
                  (ComunidadAutonomaEntity comunidad) => AppDropdownItem<String>(
                    value: comunidad.id,
                    label: comunidad.nombre,
                  ),
                ),
              ],
              onChanged: (String? value) {
                setState(() {
                  _selectedComunidadId = value?.isEmpty == true ? null : value;
                });
                _notifyFilters();
              },
            ),
          ),

        // Botón limpiar filtros
        if (hasActiveFilters)
          SizedBox(
            height: 56,
            child: AppButton(
              onPressed: _limpiarFiltros,
              label: 'Limpiar filtros',
              variant: AppButtonVariant.text,
            ),
          ),
      ],
    );
  }
}

/// Datos de filtrado para provincias
class ProvinciaFilterData {
  const ProvinciaFilterData({
    this.comunidadId,
  });

  final String? comunidadId;

  bool get hasActiveFilters => comunidadId != null;

  List<ProvinciaEntity> apply(List<ProvinciaEntity> provincias) {
    List<ProvinciaEntity> result = provincias;

    // Filtrar por comunidad autónoma
    if (comunidadId != null) {
      result = result.where((ProvinciaEntity p) => p.comunidadId == comunidadId).toList();
    }

    return result;
  }
}
