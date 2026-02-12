import 'package:ambutrack_desktop/core/theme/app_colors.dart';
import 'package:ambutrack_desktop/core/theme/app_sizes.dart';
import 'package:ambutrack_desktop/core/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ===============================
/// MODELOS
/// ===============================

class HeaderStat {
  const HeaderStat({
    required this.value,
    required this.icon,
    this.color,
  });

  final String value;
  final IconData icon;
  final Color? color;
}

class PageHeaderConfig {

  const PageHeaderConfig({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.stats,
    required this.onAdd,
    this.addButtonLabel = 'Agregar',
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final List<HeaderStat> stats;
  final VoidCallback onAdd;
  final String addButtonLabel;
}

/// ===============================
/// HEADER REUTILIZABLE
/// ===============================

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.config,
  });

  final PageHeaderConfig config;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1024;
    final bool isTablet = width >= 600 && width < 1024;

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
          ? _DesktopLayout(config)
          : isTablet
              ? _TabletLayout(config)
              : _MobileLayout(config),
    );
  }
}

/// ===============================
/// LAYOUTS
/// ===============================

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout(this.config);
  final PageHeaderConfig config;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _TitleSection(config),
        const SizedBox(width: AppSizes.spacingLarge),
        Expanded(child: _StatsSection(config.stats)),
        const SizedBox(width: AppSizes.spacingLarge),
        _AddButton(config),
      ],
    );
  }
}

class _TabletLayout extends StatelessWidget {
  const _TabletLayout(this.config);
  final PageHeaderConfig config;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: _TitleSection(config)),
            const SizedBox(width: AppSizes.spacing),
            _AddButton(config),
          ],
        ),
        const SizedBox(height: AppSizes.spacing),
        _StatsSection(config.stats),
      ],
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout(this.config);
  final PageHeaderConfig config;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _TitleSection(config),
        const SizedBox(height: AppSizes.spacing),
        _StatsSection(config.stats),
        const SizedBox(height: AppSizes.spacing),
        SizedBox(
          width: double.infinity,
          child: _AddButton(config),
        ),
      ],
    );
  }
}

/// ===============================
/// SECCIONES
/// ===============================

class _TitleSection extends StatelessWidget {
  const _TitleSection(this.config);
  final PageHeaderConfig config;

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
          child: Icon(
            config.icon,
            color: AppColors.primary,
            size: AppSizes.iconMedium,
          ),
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              config.title,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMedium,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            Text(
              config.subtitle,
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

class _StatsSection extends StatelessWidget {
  const _StatsSection(this.stats);
  final List<HeaderStat> stats;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    final List<Expanded> widgets = stats
        .map(
          (HeaderStat s) => Expanded(
            child: _MiniStatCard(
              value: s.value,
              icon: s.icon,
              color: s.color ?? AppColors.primary,
              backgroundColor: (s.color ?? AppColors.primary).withValues(alpha: 0.1),
            ),
          ),
        )
        .toList();

    if (widgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return isMobile
        ? Column(
            children: <Widget>[
              Row(children: widgets.take(2).toList()),
              const SizedBox(height: AppSizes.spacingSmall),
              Row(children: widgets.skip(2).toList()),
            ],
          )
        : Row(
            children: widgets
                .expand((Expanded w) => <Widget>[w, const SizedBox(width: AppSizes.spacingSmall)])
                .toList()
              ..removeLast(),
          );
  }
}

/// ===============================
/// BOTÓN
/// ===============================

class _AddButton extends StatelessWidget {
  const _AddButton(this.config);
  final PageHeaderConfig config;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      onPressed: config.onAdd,
      icon: Icons.add,
      label: config.addButtonLabel,
    );
  }
}

/// ===============================
/// MINI STAT CARD
/// ===============================

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.value,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final String value;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: AppSizes.spacingXs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
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
