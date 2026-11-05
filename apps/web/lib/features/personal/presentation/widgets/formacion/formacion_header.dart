import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/formacion/formacion_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/formacion/formacion_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/formacion/formacion_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/formacion/formacion_personal_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class FormacionHeader extends StatelessWidget {
  const FormacionHeader({
    super.key,
    required this.usuariosNombres,
    required this.certificacionesNombres,
    required this.cursosNombres,
    this.extra,
  });

  final Map<String, String> usuariosNombres;
  final Map<String, String> certificacionesNombres;
  final Map<String, String> cursosNombres;
  final Widget? extra;

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
      child: Column(
        children: <Widget>[
          if (isDesktop)
            _DesktopBody(
              usuariosNombres: usuariosNombres,
              certificacionesNombres: certificacionesNombres,
              cursosNombres: cursosNombres,
            )
          else if (isTablet)
            _TabletBody(
              usuariosNombres: usuariosNombres,
              certificacionesNombres: certificacionesNombres,
              cursosNombres: cursosNombres,
            )
          else
            _MobileBody(
              usuariosNombres: usuariosNombres,
              certificacionesNombres: certificacionesNombres,
              cursosNombres: cursosNombres,
            ),
          if (extra != null) ...<Widget>[
            const SizedBox(height: AppSizes.spacing),
            extra!,
          ],
        ],
      ),
    );
  }
}

class _DesktopBody extends StatelessWidget {
  const _DesktopBody({
    required this.usuariosNombres,
    required this.certificacionesNombres,
    required this.cursosNombres,
  });

  final Map<String, String> usuariosNombres;
  final Map<String, String> certificacionesNombres;
  final Map<String, String> cursosNombres;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const _TitleSection(),
        const SizedBox(width: AppSizes.spacingLarge),
        const Expanded(child: _StatsCards()),
        const SizedBox(width: AppSizes.spacingLarge),
        _ActionButtons(
          usuariosNombres: usuariosNombres,
          certificacionesNombres: certificacionesNombres,
          cursosNombres: cursosNombres,
        ),
      ],
    );
  }
}

class _TabletBody extends StatelessWidget {
  const _TabletBody({
    required this.usuariosNombres,
    required this.certificacionesNombres,
    required this.cursosNombres,
  });

  final Map<String, String> usuariosNombres;
  final Map<String, String> certificacionesNombres;
  final Map<String, String> cursosNombres;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Expanded(child: _TitleSection()),
            const SizedBox(width: AppSizes.spacing),
            _ActionButtons(
              usuariosNombres: usuariosNombres,
              certificacionesNombres: certificacionesNombres,
              cursosNombres: cursosNombres,
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing),
        const _StatsCards(),
      ],
    );
  }
}

class _MobileBody extends StatelessWidget {
  const _MobileBody({
    required this.usuariosNombres,
    required this.certificacionesNombres,
    required this.cursosNombres,
  });

  final Map<String, String> usuariosNombres;
  final Map<String, String> certificacionesNombres;
  final Map<String, String> cursosNombres;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _TitleSection(),
        const SizedBox(height: AppSizes.spacing),
        const _StatsCards(),
        const SizedBox(height: AppSizes.spacing),
        _ActionButtons(
          usuariosNombres: usuariosNombres,
          certificacionesNombres: certificacionesNombres,
          cursosNombres: cursosNombres,
          isMobile: true,
        ),
      ],
    );
  }
}

class _TitleSection extends StatelessWidget {
  const _TitleSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingSmall),
          decoration: BoxDecoration(
            color: AppColors.formacion.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: const Icon(
            Icons.school,
            color: AppColors.formacion,
            size: AppSizes.iconMedium,
          ),
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Formación y Certificaciones',
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMedium,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            Text(
              'Gestiona la formación profesional de tu equipo',
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

class _StatsCards extends StatelessWidget {
  const _StatsCards();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormacionBloc, FormacionState>(
      builder: (BuildContext context, FormacionState state) {
        String total = '-';
        String vigentes = '-';
        String proximas = '-';
        String vencidas = '-';

        if (state is FormacionLoaded) {
          final List<FormacionPersonalEntity> items = state.items;
          total = items.length.toString();
          vigentes = items.where((FormacionPersonalEntity f) => f.estado == 'vigente').length.toString();
          proximas = items.where((FormacionPersonalEntity f) => f.estado == 'proxima_vencer').length.toString();
          vencidas = items.where((FormacionPersonalEntity f) => f.estado == 'vencida').length.toString();
        }

        final double screenWidth = MediaQuery.of(context).size.width;
        final bool isMobile = screenWidth < 600;

        if (isMobile) {
          return Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(child: _MiniStatCard(value: total, label: 'Total', icon: Icons.school, color: AppColors.formacion)),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(child: _MiniStatCard(value: vigentes, label: 'Vigentes', icon: Icons.check_circle, color: AppColors.success)),
                ],
              ),
              const SizedBox(height: AppSizes.spacingSmall),
              Row(
                children: <Widget>[
                  Expanded(child: _MiniStatCard(value: proximas, label: 'Próximas', icon: Icons.warning, color: AppColors.warning)),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(child: _MiniStatCard(value: vencidas, label: 'Vencidas', icon: Icons.error, color: AppColors.emergency)),
                ],
              ),
            ],
          );
        }

        return Row(
          children: <Widget>[
            Expanded(child: _MiniStatCard(value: total, label: 'Total', icon: Icons.school, color: AppColors.formacion)),
            const SizedBox(width: AppSizes.spacingSmall),
            Expanded(child: _MiniStatCard(value: vigentes, label: 'Vigentes', icon: Icons.check_circle, color: AppColors.success)),
            const SizedBox(width: AppSizes.spacingSmall),
            Expanded(child: _MiniStatCard(value: proximas, label: 'Próximas', icon: Icons.warning, color: AppColors.warning)),
            const SizedBox(width: AppSizes.spacingSmall),
            Expanded(child: _MiniStatCard(value: vencidas, label: 'Vencidas', icon: Icons.error, color: AppColors.emergency)),
          ],
        );
      },
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
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
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: color, size: AppSizes.iconLarge),
          const SizedBox(width: AppSizes.spacingXs),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontMedium,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontXs,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.usuariosNombres,
    required this.certificacionesNombres,
    required this.cursosNombres,
    this.isMobile = false,
  });

  final Map<String, String> usuariosNombres;
  final Map<String, String> certificacionesNombres;
  final Map<String, String> cursosNombres;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: AppButton(
              onPressed: () => _showFormacionDialog(context),
              icon: Icons.add,
              label: 'Asignar Formación',
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              onPressed: () => Navigator.of(context).pushNamed('/personal/formacion/certificaciones'),
              icon: Icons.verified,
              label: 'Certificaciones',
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              onPressed: () => Navigator.of(context).pushNamed('/personal/formacion/cursos'),
              icon: Icons.menu_book,
              label: 'Cursos',
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AppButton(
          onPressed: () => _showFormacionDialog(context),
          icon: Icons.add,
          label: 'Asignar Formación',
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        AppButton(
          onPressed: () => Navigator.of(context).pushNamed('/personal/formacion/certificaciones'),
          icon: Icons.verified,
          label: 'Certificaciones',
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        AppButton(
          onPressed: () => Navigator.of(context).pushNamed('/personal/formacion/cursos'),
          icon: Icons.menu_book,
          label: 'Cursos',
        ),
      ],
    );
  }

  Future<void> _showFormacionDialog(BuildContext context) async {
    final FormacionBloc bloc = context.read<FormacionBloc>();
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BlocProvider<FormacionBloc>.value(
          value: bloc,
          child: const FormacionPersonalFormDialog(),
        );
      },
    );
    if (result == true && context.mounted) {
      bloc.add(const FormacionLoadRequested());
    }
  }
}
