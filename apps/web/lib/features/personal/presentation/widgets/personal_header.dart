import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/personal_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Header de la página de personal con estadísticas integradas
class PersonalHeader extends StatelessWidget {
  const PersonalHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 1024;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;

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
          ? const _DesktopLayout()
          : isTablet
              ? const _TabletLayout()
              : const _MobileLayout(),
    );
  }
}

/// Layout para desktop: Título | Stats | Botón (horizontal)
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _TitleSection(),
        const SizedBox(width: AppSizes.spacingLarge),
        Expanded(child: _StatsCards()),
        const SizedBox(width: AppSizes.spacingLarge),
        _AddButton(),
      ],
    );
  }
}

/// Layout para tablet: Título + Botón arriba, Stats abajo
class _TabletLayout extends StatelessWidget {
  const _TabletLayout();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: _TitleSection()),
            const SizedBox(width: AppSizes.spacing),
            _AddButton(),
          ],
        ),
        const SizedBox(height: AppSizes.spacing),
        _StatsCards(),
      ],
    );
  }
}

/// Layout para móvil: Todo en columna
class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _TitleSection(),
        const SizedBox(height: AppSizes.spacing),
        _StatsCards(),
        const SizedBox(height: AppSizes.spacing),
        SizedBox(
          width: double.infinity,
          child: _AddButton(),
        ),
      ],
    );
  }
}

/// Sección de título
class _TitleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingSmall),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: const Icon(
            Icons.people,
            color: AppColors.primary,
            size: AppSizes.iconMedium,
          ),
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Gestión de Personal',
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMedium,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            Text(
              'Administra tu equipo médico y personal de emergencias',
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

/// Cards de estadísticas
class _StatsCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PersonalBloc, PersonalState>(
      builder: (BuildContext context, PersonalState state) {
        String total = '-';
        String enServicio = '-';
        String disponibles = '-';
        String ausentes = '-';

        if (state is PersonalLoaded) {
          total = state.total.toString();
          enServicio = state.enServicio.toString();
          disponibles = state.disponibles.toString();
          ausentes = state.ausentes.toString();
        }

        final double screenWidth = MediaQuery.of(context).size.width;
        final bool isMobile = screenWidth < 600;

        return isMobile
            ? Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _MiniStatCard(                          
                          value: total,
                          icon: Icons.people,
                          color: AppColors.primary,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingSmall),
                      Expanded(
                        child: _MiniStatCard(
                          value: disponibles,
                          icon: Icons.check_circle,
                          color: AppColors.primary,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _MiniStatCard(
                          value: enServicio,
                          icon: Icons.work,
                          color: AppColors.primary,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingSmall),
                      Expanded(
                        child: _MiniStatCard(
                          value: ausentes,
                          icon: Icons.local_hospital,
                          color: AppColors.primary,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: <Widget>[
                  Expanded(
                    child: _MiniStatCard(
                      value: total,
                      icon: Icons.people,
                      color: AppColors.primary,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: _MiniStatCard(
                      value: enServicio,
                      icon: Icons.work,
                      color: AppColors.primary,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: _MiniStatCard(
                      value: disponibles,
                      icon: Icons.check_circle,
                      color: AppColors.primary,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: _MiniStatCard(
                      value: ausentes,
                      icon: Icons.local_hospital,
                      color: AppColors.primary,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              );
      },
    );
  }
}

/// Botón añadir personal
class _AddButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppButton(
      onPressed: () async {
        debugPrint('🚀 Abriendo formulario de nuevo personal...');
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return BlocProvider<PersonalBloc>.value(
              value: context.read<PersonalBloc>(),
              child: const PersonalFormDialog(),
            );
          },
        );
        debugPrint('Formulario cerrado');
      },
      icon: Icons.add,
      label: 'Agregar Personal',
    );
  }
}

/// Mini card de estadística para el header
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
        mainAxisSize: MainAxisSize.min,
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
