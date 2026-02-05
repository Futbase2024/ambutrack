import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:flutter/material.dart';

/// Barra de filtros para ITV y Revisiones
class ItvRevisionesFilters extends StatefulWidget {
  const ItvRevisionesFilters({
    required this.onFilterChanged,
    super.key,
  });

  final void Function(ItvRevisionesFilterData) onFilterChanged;

  @override
  State<ItvRevisionesFilters> createState() => _ItvRevisionesFiltersState();
}

class _ItvRevisionesFiltersState extends State<ItvRevisionesFilters> {
  final TextEditingController _searchController = TextEditingController();
  TipoItvRevision? _selectedTipo;
  ResultadoItvRevision? _selectedResultado;
  EstadoItvRevision? _selectedEstado;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    widget.onFilterChanged(
      ItvRevisionesFilterData(
        searchText: _searchController.text.trim(),
        tipo: _selectedTipo,
        resultado: _selectedResultado,
        estado: _selectedEstado,
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedTipo = null;
      _selectedResultado = null;
      _selectedEstado = null;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.spacing,
      runSpacing: AppSizes.spacing,
      alignment: WrapAlignment.end,
      children: <Widget>[
        // Búsqueda por texto
        SizedBox(
          width: 250,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Buscar',
              hintText: 'Vehículo, taller...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: AppSizes.paddingSmall,
              ),
            ),
            onSubmitted: (String value) {
              _applyFilters();
            },
            onChanged: (String value) {
              setState(() {});
            },
          ),
        ),

        // Filtro por tipo
        AppDropdown<TipoItvRevision?>(
          value: _selectedTipo,
          width: 180,
          label: 'Tipo',
          items: const <AppDropdownItem<TipoItvRevision?>>[
            AppDropdownItem<TipoItvRevision?>(
              value: null,
              label: 'Todos',
              icon: Icons.filter_list,
            ),
            AppDropdownItem<TipoItvRevision?>(
              value: TipoItvRevision.itv,
              label: 'ITV',
              icon: Icons.fact_check,
              iconColor: AppColors.info,
            ),
            AppDropdownItem<TipoItvRevision?>(
              value: TipoItvRevision.revisionTecnica,
              label: 'Revisión Técnica',
              icon: Icons.build_circle,
              iconColor: AppColors.secondary,
            ),
            AppDropdownItem<TipoItvRevision?>(
              value: TipoItvRevision.inspeccionAnual,
              label: 'Inspección Anual',
              icon: Icons.calendar_today,
              iconColor: AppColors.warning,
            ),
            AppDropdownItem<TipoItvRevision?>(
              value: TipoItvRevision.inspeccionEspecial,
              label: 'Inspección Especial',
              icon: Icons.star,
              iconColor: AppColors.primary,
            ),
          ],
          onChanged: (TipoItvRevision? value) {
            setState(() {
              _selectedTipo = value;
            });
            _applyFilters();
          },
        ),

        // Filtro por resultado
        AppDropdown<ResultadoItvRevision?>(
          value: _selectedResultado,
          width: 180,
          label: 'Resultado',
          items: const <AppDropdownItem<ResultadoItvRevision?>>[
            AppDropdownItem<ResultadoItvRevision?>(
              value: null,
              label: 'Todos',
              icon: Icons.filter_list,
            ),
            AppDropdownItem<ResultadoItvRevision?>(
              value: ResultadoItvRevision.favorable,
              label: 'Favorable',
              icon: Icons.check_circle,
              iconColor: AppColors.success,
            ),
            AppDropdownItem<ResultadoItvRevision?>(
              value: ResultadoItvRevision.desfavorable,
              label: 'Desfavorable',
              icon: Icons.warning,
              iconColor: AppColors.warning,
            ),
            AppDropdownItem<ResultadoItvRevision?>(
              value: ResultadoItvRevision.negativo,
              label: 'Negativo',
              icon: Icons.cancel,
              iconColor: AppColors.error,
            ),
            AppDropdownItem<ResultadoItvRevision?>(
              value: ResultadoItvRevision.pendiente,
              label: 'Pendiente',
              icon: Icons.schedule,
              iconColor: AppColors.gray600,
            ),
          ],
          onChanged: (ResultadoItvRevision? value) {
            setState(() {
              _selectedResultado = value;
            });
            _applyFilters();
          },
        ),

        // Filtro por estado
        AppDropdown<EstadoItvRevision?>(
          value: _selectedEstado,
          width: 180,
          label: 'Estado',
          items: const <AppDropdownItem<EstadoItvRevision?>>[
            AppDropdownItem<EstadoItvRevision?>(
              value: null,
              label: 'Todos',
              icon: Icons.filter_list,
            ),
            AppDropdownItem<EstadoItvRevision?>(
              value: EstadoItvRevision.pendiente,
              label: 'Pendiente',
              icon: Icons.schedule,
              iconColor: AppColors.info,
            ),
            AppDropdownItem<EstadoItvRevision?>(
              value: EstadoItvRevision.realizada,
              label: 'Realizada',
              icon: Icons.check_circle,
              iconColor: AppColors.success,
            ),
            AppDropdownItem<EstadoItvRevision?>(
              value: EstadoItvRevision.vencida,
              label: 'Vencida',
              icon: Icons.error,
              iconColor: AppColors.error,
            ),
            AppDropdownItem<EstadoItvRevision?>(
              value: EstadoItvRevision.cancelada,
              label: 'Cancelada',
              icon: Icons.cancel,
              iconColor: AppColors.gray600,
            ),
          ],
          onChanged: (EstadoItvRevision? value) {
            setState(() {
              _selectedEstado = value;
            });
            _applyFilters();
          },
        ),

        // Botón aplicar filtros
        AppButton(
          onPressed: _applyFilters,
          icon: Icons.filter_alt,
          label: 'Filtrar',
        ),

        // Botón limpiar filtros (solo visible si hay filtros activos)
        if (_searchController.text.isNotEmpty ||
            _selectedTipo != null ||
            _selectedResultado != null ||
            _selectedEstado != null)
          AppButton(
            onPressed: _clearFilters,
            icon: Icons.clear_all,
            label: 'Limpiar',
            variant: AppButtonVariant.text,
          ),
      ],
    );
  }
}

/// Datos de filtro para ITV y Revisiones
class ItvRevisionesFilterData {
  const ItvRevisionesFilterData({
    this.searchText,
    this.tipo,
    this.resultado,
    this.estado,
  });

  final String? searchText;
  final TipoItvRevision? tipo;
  final ResultadoItvRevision? resultado;
  final EstadoItvRevision? estado;

  /// Filtra una lista de ITV/Revisiones según los criterios
  List<ItvRevisionEntity> apply(List<ItvRevisionEntity> itvRevisiones) {
    return itvRevisiones.where((ItvRevisionEntity itvRevision) {
      // Filtro por búsqueda de texto
      if (searchText != null && searchText!.isNotEmpty) {
        final String search = searchText!.toLowerCase();
        final bool matchesVehiculo = itvRevision.vehiculoId.toLowerCase().contains(search);
        final bool matchesObservaciones = itvRevision.observaciones?.toLowerCase().contains(search) ?? false;
        final bool matchesTaller = itvRevision.taller?.toLowerCase().contains(search) ?? false;

        if (!matchesVehiculo && !matchesObservaciones && !matchesTaller) {
          return false;
        }
      }

      // Filtro por tipo
      if (tipo != null && itvRevision.tipo != tipo) {
        return false;
      }

      // Filtro por resultado
      if (resultado != null && itvRevision.resultado != resultado) {
        return false;
      }

      // Filtro por estado
      if (estado != null && itvRevision.estado != estado) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Verifica si hay algún filtro activo
  bool get hasActiveFilters {
    return (searchText != null && searchText!.isNotEmpty) ||
        tipo != null ||
        resultado != null ||
        estado != null;
  }
}
