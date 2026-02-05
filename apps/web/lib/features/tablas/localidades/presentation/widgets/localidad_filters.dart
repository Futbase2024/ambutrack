import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:flutter/material.dart';

/// Widget de filtros para la lista de localidades
class LocalidadFilters extends StatefulWidget {
  const LocalidadFilters({
    required this.onFiltersChanged,
    super.key,
  });

  final void Function(LocalidadFilterData) onFiltersChanged;

  @override
  State<LocalidadFilters> createState() => _LocalidadFiltersState();
}

class _LocalidadFiltersState extends State<LocalidadFilters> {
  String? _selectedProvinciaId;
  List<ProvinciaEntity> _provincias = <ProvinciaEntity>[];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProvincias();
  }

  Future<void> _loadProvincias() async {
    setState(() => _isLoading = true);

    try {
      final ProvinciaDataSource dataSource = getIt<ProvinciaDataSource>();
      final List<ProvinciaEntity> provincias = await dataSource.getAll();

      if (mounted) {
        setState(() {
          _provincias = provincias;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar provincias para filtros: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _notifyFilters() {
    widget.onFiltersChanged(
      LocalidadFilterData(
        provinciaId: _selectedProvinciaId,
      ),
    );
  }

  void _limpiarFiltros() {
    setState(() {
      _selectedProvinciaId = null;
    });
    _notifyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasActiveFilters = _selectedProvinciaId != null;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: <Widget>[
        // Filtro por provincia
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
              value: _selectedProvinciaId,
              label: 'Provincia',
              hint: 'Todas',
              prefixIcon: Icons.map,
              items: <AppDropdownItem<String>>[
                const AppDropdownItem<String>(
                  value: '',
                  label: 'Todas las provincias',
                ),
                ..._provincias.map(
                  (ProvinciaEntity provincia) => AppDropdownItem<String>(
                    value: provincia.id,
                    label: provincia.nombre,
                  ),
                ),
              ],
              onChanged: (String? value) {
                setState(() {
                  _selectedProvinciaId = value?.isEmpty == true ? null : value;
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

/// Datos de filtrado para localidades
class LocalidadFilterData {
  const LocalidadFilterData({
    this.provinciaId,
  });

  final String? provinciaId;

  bool get hasActiveFilters => provinciaId != null;

  List<LocalidadEntity> apply(List<LocalidadEntity> localidades) {
    List<LocalidadEntity> result = localidades;

    // Filtrar por provincia
    if (provinciaId != null) {
      result = result.where((LocalidadEntity l) => l.provinciaId == provinciaId).toList();
    }

    return result;
  }
}
