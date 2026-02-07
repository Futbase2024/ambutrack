import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/stock_equipamiento/stock_equipamiento_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/stock_equipamiento/stock_equipamiento_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/stock_equipamiento/stock_equipamiento_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Header para la página de Stock de Equipamiento de Vehículos
class StockEquipamientoHeader extends StatelessWidget {
  const StockEquipamientoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StockEquipamientoBloc, StockEquipamientoState>(
      builder: (BuildContext context, StockEquipamientoState state) {
        final double width = MediaQuery.of(context).size.width;
        final bool isDesktop = width >= 1024;

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingLarge,
            vertical: AppSizes.paddingSmall,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            border: Border.all(color: AppColors.gray200),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.gray900.withValues(alpha: 0.05),
                blurRadius: AppSizes.shadowMedium,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isDesktop
              ? _DesktopLayout(state: state)
              : _MobileLayout(state: state),
        );
      },
    );
  }
}

/// Layout desktop
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.state});

  final StockEquipamientoState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const _TitleSection(),
        const SizedBox(width: AppSizes.spacingLarge),
        Expanded(child: _StatsSection(state: state)),
        const SizedBox(width: AppSizes.spacingLarge),
        _RefreshButton(state: state),
      ],
    );
  }
}

/// Layout mobile
class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.state});

  final StockEquipamientoState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Expanded(child: _TitleSection()),
            const SizedBox(width: AppSizes.spacing),
            _RefreshButton(state: state),
          ],
        ),
        const SizedBox(height: AppSizes.spacing),
        _StatsSection(state: state),
      ],
    );
  }
}

/// Sección de título
class _TitleSection extends StatelessWidget {
  const _TitleSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingSmall),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: const Icon(
            Icons.medical_services,
            color: AppColors.primary,
            size: AppSizes.iconMedium,
          ),
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Stock de Equipamiento',
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMedium,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            Text(
              'Resumen de equipamiento por vehículo',
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontXs,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Sección de estadísticas
class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.state});

  final StockEquipamientoState state;

  @override
  Widget build(BuildContext context) {
    final List<_StatData> stats = _buildStats();

    return Row(
      children: stats
          .map(
            (_StatData s) => Expanded(
              child: _MiniStatCard(
                value: s.value,
                icon: s.icon,
                color: s.color,
              ),
            ),
          )
          .expand(
            (Widget w) => <Widget>[w, const SizedBox(width: AppSizes.spacingSmall)],
          )
          .toList()
        ..removeLast(),
    );
  }

  List<_StatData> _buildStats() {
    if (state is StockEquipamientoLoading || state is StockEquipamientoInitial) {
      return const <_StatData>[
        _StatData(value: '-', icon: Icons.directions_car, color: AppColors.primary),
        _StatData(value: '-', icon: Icons.check_circle, color: AppColors.success),
        _StatData(value: '-', icon: Icons.warning, color: AppColors.warning),
        _StatData(value: '-', icon: Icons.error, color: AppColors.error),
      ];
    }

    if (state is StockEquipamientoLoaded) {
      final StockEquipamientoLoaded loaded = state as StockEquipamientoLoaded;
      return <_StatData>[
        _StatData(
          value: loaded.totalVehiculos.toString(),
          icon: Icons.directions_car,
          color: AppColors.primary,
        ),
        _StatData(
          value: loaded.vehiculosOk.toString(),
          icon: Icons.check_circle,
          color: AppColors.success,
        ),
        _StatData(
          value: loaded.vehiculosAtencion.toString(),
          icon: Icons.warning,
          color: AppColors.warning,
        ),
        _StatData(
          value: loaded.vehiculosCritico.toString(),
          icon: Icons.error,
          color: AppColors.error,
        ),
      ];
    }

    return const <_StatData>[
      _StatData(value: '!', icon: Icons.error, color: AppColors.error),
    ];
  }
}

/// Datos de estadística
class _StatData {
  const _StatData({
    required this.value,
    required this.icon,
    required this.color,
  });

  final String value;
  final IconData icon;
  final Color color;
}

/// Mini tarjeta de estadística
class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.value,
    required this.icon,
    required this.color,
  });

  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: AppSizes.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: color, size: AppSizes.iconLarge),
          const SizedBox(width: AppSizes.spacingXs),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontMedium,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón de refrescar
class _RefreshButton extends StatelessWidget {
  const _RefreshButton({required this.state});

  final StockEquipamientoState state;

  @override
  Widget build(BuildContext context) {
    final bool isLoading = state is StockEquipamientoLoading ||
        (state is StockEquipamientoLoaded &&
            (state as StockEquipamientoLoaded).isRefreshing);

    return AppButton(
      onPressed: isLoading
          ? null
          : () {
              context
                  .read<StockEquipamientoBloc>()
                  .add(const StockEquipamientoRefreshRequested());
            },
      icon: Icons.refresh,
      label: 'Actualizar',
      variant: AppButtonVariant.secondary,
    );
  }
}

/// Barra de búsqueda para filtrar vehículos
class StockEquipamientoSearchBar extends StatefulWidget {
  const StockEquipamientoSearchBar({
    required this.onSearchChanged,
    super.key,
  });

  final void Function(String) onSearchChanged;

  @override
  State<StockEquipamientoSearchBar> createState() =>
      _StockEquipamientoSearchBarState();
}

class _StockEquipamientoSearchBarState
    extends State<StockEquipamientoSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: _controller,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Buscar por matrícula, marca o modelo...',
          prefixIcon: const Icon(
            Icons.search,
            size: 20,
            color: AppColors.textSecondaryLight,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    size: 18,
                    color: AppColors.textSecondaryLight,
                  ),
                  onPressed: () {
                    _controller.clear();
                    widget.onSearchChanged('');
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            borderSide: const BorderSide(color: AppColors.gray300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            borderSide: const BorderSide(color: AppColors.gray300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMedium,
            vertical: AppSizes.paddingSmall,
          ),
          isDense: true,
        ),
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimaryLight,
        ),
      ),
    );
  }
}
