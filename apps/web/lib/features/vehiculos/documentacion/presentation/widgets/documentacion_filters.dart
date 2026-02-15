import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Filtros para la lista de Documentación de Vehículos
class DocumentacionFilters {
  const DocumentacionFilters({
    this.tipoDocumentoId,
    this.estado,
    this.vehiculoId,
    this.proximosVencer = false,
    this.vencidos = false,
  });

  final String? tipoDocumentoId;
  final String? estado;
  final String? vehiculoId;
  final bool proximosVencer;
  final bool vencidos;

  DocumentacionFilters copyWith({
    String? tipoDocumentoId,
    String? estado,
    String? vehiculoId,
    bool? proximosVencer,
    bool? vencidos,
  }) {
    return DocumentacionFilters(
      tipoDocumentoId: tipoDocumentoId ?? this.tipoDocumentoId,
      estado: estado ?? this.estado,
      vehiculoId: vehiculoId ?? this.vehiculoId,
      proximosVencer: proximosVencer ?? this.proximosVencer,
      vencidos: vencidos ?? this.vencidos,
    );
  }

  bool get hasFilters =>
      tipoDocumentoId != null ||
      estado != null ||
      vehiculoId != null ||
      proximosVencer ||
      vencidos;

  DocumentacionFilters clear() {
    return const DocumentacionFilters();
  }
}

/// Widget de filtros para Documentación de Vehículos
class DocumentacionFiltersWidget extends StatelessWidget {
  const DocumentacionFiltersWidget({
    super.key,
    required this.filters,
    required this.onFiltersChanged,
    this.vehiculoId,
  });

  final DocumentacionFilters filters;
  final ValueChanged<DocumentacionFilters> onFiltersChanged;
  final String? vehiculoId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.gray200),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.filter_list,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Filtros',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const Spacer(),
              if (filters.hasFilters)
                TextButton.icon(
                  onPressed: () => onFiltersChanged(filters.clear()),
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Limpiar'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    textStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Wrap(
            spacing: AppSizes.paddingMedium,
            runSpacing: AppSizes.paddingMedium,
            children: <Widget>[
              _buildTipoDropdown(),
              _buildEstadoDropdown(),
              _buildProximosVencerFilter(),
              _buildVencidosFilter(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipoDropdown() {
    return SizedBox(
      width: 200,
      child: AppDropdown<String>(
        value: filters.tipoDocumentoId,
        label: 'Tipo de Documento',
        hint: 'Todos',
        prefixIcon: Icons.description_outlined,
        items: const <AppDropdownItem<String>>[
          AppDropdownItem<String>(
            value: 'seguro_rc',
            label: 'Seguro RC',
            icon: Icons.security,
          ),
          AppDropdownItem<String>(
            value: 'seguro_todo_riesgo',
            label: 'Seguro Todo Riesgo',
            icon: Icons.security,
          ),
          AppDropdownItem<String>(
            value: 'itv',
            label: 'ITV',
            icon: Icons.verified,
          ),
          AppDropdownItem<String>(
            value: 'permiso_municipal',
            label: 'Permiso Municipal',
            icon: Icons.admin_panel_settings,
          ),
          AppDropdownItem<String>(
            value: 'tarjeta_transporte',
            label: 'Tarjeta de Transporte',
            icon: Icons.badge,
          ),
        ],
        onChanged: (String? value) {
          onFiltersChanged(
            filters.copyWith(tipoDocumentoId: value),
          );
        },
      ),
    );
  }

  Widget _buildEstadoDropdown() {
    return SizedBox(
      width: 180,
      child: AppDropdown<String>(
        value: filters.estado,
        label: 'Estado',
        hint: 'Todos',
        prefixIcon: Icons.playlist_add_check_circle,
        items: const <AppDropdownItem<String>>[
          AppDropdownItem<String>(
            value: 'vigente',
            label: 'Vigente',
            icon: Icons.check_circle,
            iconColor: AppColors.success,
          ),
          AppDropdownItem<String>(
            value: 'proxima_vencer',
            label: 'Próxima a Vencer',
            icon: Icons.warning,
            iconColor: AppColors.warning,
          ),
          AppDropdownItem<String>(
            value: 'vencida',
            label: 'Vencida',
            icon: Icons.cancel,
            iconColor: AppColors.error,
          ),
        ],
        onChanged: (String? value) {
          onFiltersChanged(
            filters.copyWith(estado: value),
          );
        },
      ),
    );
  }

  Widget _buildProximosVencerFilter() {
    return FilterChip(
      label: const Text('Próximos a vencer'),
      labelStyle: GoogleFonts.inter(
        fontSize: AppSizes.fontSmall,
        fontWeight: FontWeight.w600,
      ),
      avatar: filters.proximosVencer
          ? const Icon(Icons.warning_amber, size: 18, color: Colors.white)
          : const Icon(Icons.warning_amber_outlined, size: 18),
      selected: filters.proximosVencer,
      onSelected: (bool selected) {
        onFiltersChanged(
          filters.copyWith(
            proximosVencer: selected,
            vencidos: selected ? false : filters.vencidos,
          ),
        );
      },
      selectedColor: AppColors.warning,
      checkmarkColor: Colors.white,
      backgroundColor: AppColors.gray100,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        side: BorderSide(
          color: filters.proximosVencer
              ? AppColors.warning
              : AppColors.gray300,
        ),
      ),
    );
  }

  Widget _buildVencidosFilter() {
    return FilterChip(
      label: const Text('Vencidos'),
      labelStyle: GoogleFonts.inter(
        fontSize: AppSizes.fontSmall,
        fontWeight: FontWeight.w600,
      ),
      avatar: filters.vencidos
          ? const Icon(Icons.cancel, size: 18, color: Colors.white)
          : const Icon(Icons.cancel_outlined, size: 18),
      selected: filters.vencidos,
      onSelected: (bool selected) {
        onFiltersChanged(
          filters.copyWith(
            vencidos: selected,
            proximosVencer: selected ? false : filters.proximosVencer,
          ),
        );
      },
      selectedColor: AppColors.error,
      checkmarkColor: Colors.white,
      backgroundColor: AppColors.gray100,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        side: BorderSide(
          color: filters.vencidos ? AppColors.error : AppColors.gray300,
        ),
      ),
    );
  }
}
