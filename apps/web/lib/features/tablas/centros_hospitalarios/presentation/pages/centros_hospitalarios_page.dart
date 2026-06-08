import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/bloc/centro_hospitalario_bloc.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/bloc/centro_hospitalario_event.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/bloc/centro_hospitalario_state.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/widgets/centro_hospitalario_form_dialog.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/widgets/centro_hospitalario_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Página de gestión de centros hospitalarios
class CentrosHospitalariosPage extends StatelessWidget {
  const CentrosHospitalariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<CentroHospitalarioBloc>(
        create: (BuildContext context) =>
            getIt<CentroHospitalarioBloc>()..add(const CentroHospitalarioLoadAllRequested()),
        child: const _CentrosHospitalariosView(),
      ),
    );
  }
}

/// Vista principal de centros hospitalarios
class _CentrosHospitalariosView extends StatefulWidget {
  const _CentrosHospitalariosView();

  @override
  State<_CentrosHospitalariosView> createState() => _CentrosHospitalariosViewState();
}

class _CentrosHospitalariosViewState extends State<_CentrosHospitalariosView> {
  String _searchQuery = '';
  String _statusFilter = '';
  int? _sortColumnIndex = 0;
  bool _sortAscending = true;
  int _currentPage = 0;
  static const int _itemsPerPage = 25;

  List<CentroHospitalarioEntity> _filterCentros(List<CentroHospitalarioEntity> centros) {
    List<CentroHospitalarioEntity> result = centros;

    if (_statusFilter.isNotEmpty) {
      final bool isActivo = _statusFilter == 'activo';
      result = result.where((CentroHospitalarioEntity c) => c.activo == isActivo).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final String query = _searchQuery.toLowerCase();
      result = result.where((CentroHospitalarioEntity centro) {
        return centro.nombre.toLowerCase().contains(query) ||
            (centro.localidadNombre?.toLowerCase().contains(query) ?? false) ||
            (centro.provinciaNombre?.toLowerCase().contains(query) ?? false) ||
            (centro.tipoCentro?.toLowerCase().contains(query) ?? false) ||
            (centro.direccion?.toLowerCase().contains(query) ?? false) ||
            (centro.telefono?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return result;
  }

  List<CentroHospitalarioEntity> _sortCentros(List<CentroHospitalarioEntity> centros) {
    if (_sortColumnIndex == null) {
      return centros;
    }

    final List<CentroHospitalarioEntity> sorted = List<CentroHospitalarioEntity>.from(centros)
      ..sort((CentroHospitalarioEntity a, CentroHospitalarioEntity b) {
        int comparison = 0;

        switch (_sortColumnIndex) {
          case 0:
            comparison = a.nombre.compareTo(b.nombre);
          case 1:
            comparison = (a.tipoCentro ?? '').compareTo(b.tipoCentro ?? '');
          case 2:
            comparison = (a.localidadNombre ?? '').compareTo(b.localidadNombre ?? '');
          case 3:
            comparison = (a.telefono ?? '').compareTo(b.telefono ?? '');
          case 4:
            comparison = a.activo == b.activo ? 0 : (a.activo ? -1 : 1);
          default:
            comparison = 0;
        }

        return _sortAscending ? comparison : -comparison;
      });

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: BlocBuilder<CentroHospitalarioBloc, CentroHospitalarioState>(
        builder: (BuildContext context, CentroHospitalarioState state) {
          if (state is CentroHospitalarioLoading) {
            return _buildLoadingState();
          }

          if (state is CentroHospitalarioError) {
            return _buildErrorState(state.message);
          }

          if (state is CentroHospitalarioLoaded) {
            return _buildLoadedState(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: AppLoadingIndicator(message: 'Cargando centros hospitalarios...'),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        margin: const EdgeInsets.all(AppSizes.paddingXl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          border: Border.all(color: AppColors.error),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: AppSizes.spacing),
            Text(
              'Error al cargar centros hospitalarios',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.error),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            Text(message, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryLight)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, CentroHospitalarioLoaded state) {
    final int totalCentros = state.centros.length;
    final int centrosActivos = state.centros.where((CentroHospitalarioEntity c) => c.activo).length;
    final int centrosInactivos = totalCentros - centrosActivos;

    List<CentroHospitalarioEntity> filtrados = _filterCentros(state.centros);
    filtrados = _sortCentros(filtrados);

    final int totalItems = filtrados.length;
    final int totalPages = (totalItems / _itemsPerPage).ceil().clamp(1, 999);
    final int startIndex = _currentPage * _itemsPerPage;
    final int endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
    final List<CentroHospitalarioEntity> centrosPaginados = totalItems > 0
        ? filtrados.sublist(startIndex, endIndex)
        : <CentroHospitalarioEntity>[];

    final bool hasFilters = _searchQuery.isNotEmpty || _statusFilter.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingXl,
        AppSizes.paddingXl,
        AppSizes.paddingXl,
        AppSizes.paddingLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _PageHeaderSection(
            totalCentros: totalCentros,
            centrosActivos: centrosActivos,
            centrosInactivos: centrosInactivos,
            onAdd: () => _showCreateDialog(context),
            extra: CentroHospitalarioFilterBar(
              searchQuery: _searchQuery,
              statusFilter: _statusFilter,
              onSearchChanged: (String query) {
                setState(() {
                  _searchQuery = query;
                  _currentPage = 0;
                });
              },
              onStatusChanged: (String status) {
                setState(() {
                  _statusFilter = status;
                  _currentPage = 0;
                });
              },
              onClear: () {
                setState(() {
                  _searchQuery = '';
                  _statusFilter = '';
                  _currentPage = 0;
                });
              },
              totalCentros: totalCentros,
              filteredCentros: filtrados.length,
            ),
          ),
          const SizedBox(height: AppSizes.spacing),
          Expanded(
            child: CentroHospitalarioTable(
              centros: centrosPaginados,
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              onSort: (int columnIndex, bool ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                });
              },
              currentPage: _currentPage,
              totalPages: totalPages,
              totalItems: totalItems,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              hasFilters: hasFilters,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) =>
          BlocProvider<CentroHospitalarioBloc>.value(
        value: context.read<CentroHospitalarioBloc>(),
        child: const CentroHospitalarioFormDialog(),
      ),
    );
  }
}

/// Sección de header con título, KPIs y botón de acción
class _PageHeaderSection extends StatelessWidget {
  const _PageHeaderSection({
    required this.totalCentros,
    required this.centrosActivos,
    required this.centrosInactivos,
    required this.onAdd,
    this.extra,
  });

  final int totalCentros;
  final int centrosActivos;
  final int centrosInactivos;
  final VoidCallback onAdd;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Gestión de Centros Hospitalarios',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingXs),
                  Text(
                    'Administra hospitales, centros de salud y clínicas',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.spacingXl),
            Expanded(
              flex: 3,
              child: _CompactKpiBar(
                totalCentros: totalCentros,
                centrosActivos: centrosActivos,
                centrosInactivos: centrosInactivos,
              ),
            ),
            const SizedBox(width: AppSizes.spacing),
            _GradientButton(
              icon: Icons.add_circle,
              label: 'Nuevo Centro',
              onPressed: onAdd,
            ),
          ],
        ),
        if (extra != null) ...<Widget>[
          const SizedBox(height: AppSizes.spacing),
          extra!,
        ],
      ],
    );
  }
}

/// Barra de KPIs compactos
class _CompactKpiBar extends StatelessWidget {
  const _CompactKpiBar({
    required this.totalCentros,
    required this.centrosActivos,
    required this.centrosInactivos,
  });

  final int totalCentros;
  final int centrosActivos;
  final int centrosInactivos;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _CompactKpiCard(
            value: totalCentros.toString(),
            label: 'Total',
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFF1E3FAE), Color(0xFF3B82F6)],
            ),
            icon: Icons.local_hospital,
          ),
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        Expanded(
          child: _CompactKpiCard(
            value: centrosActivos.toString(),
            label: 'Activos',
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFF059669), Color(0xFF34D399)],
            ),
            icon: Icons.check_circle,
          ),
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        Expanded(
          child: _CompactKpiCard(
            value: centrosInactivos.toString(),
            label: 'Inactivos',
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFFD97706), Color(0xFFFBBF24)],
            ),
            icon: Icons.pause_circle_outline,
          ),
        ),
      ],
    );
  }
}

/// KPI card compacto
class _CompactKpiCard extends StatelessWidget {
  const _CompactKpiCard({
    required this.value,
    required this.label,
    required this.gradient,
    required this.icon,
  });

  final String value;
  final String label;
  final LinearGradient gradient;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingSmall + 4,
          vertical: AppSizes.paddingSmall,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.9)),
            const SizedBox(width: AppSizes.spacingXs + 2),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón con gradiente estilo Stitch
class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF1E3FAE), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.padding,
              vertical: AppSizes.paddingSmall + 4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: AppSizes.spacingXs + 4),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
