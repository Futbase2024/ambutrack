import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Header del dashboard con título y botones de acción
///
/// Incluye:
/// - Título "Panel de Control" con descripción
/// - Botones de acción: Importar, Exportar, Filtrar, Nuevo Servicio
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    this.onImport,
    this.onExport,
    this.onFilter,
    this.onNewService,
  });

  final VoidCallback? onImport;
  final VoidCallback? onExport;
  final VoidCallback? onFilter;
  final VoidCallback? onNewService;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isWide = constraints.maxWidth > 768;

        if (isWide) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const _TitleSection(),
              _ActionButtons(
                onImport: onImport,
                onExport: onExport,
                onFilter: onFilter,
                onNewService: onNewService,
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _TitleSection(),
            const SizedBox(height: 16),
            _ActionButtons(
              onImport: onImport,
              onExport: onExport,
              onFilter: onFilter,
              onNewService: onNewService,
            ),
          ],
        );
      },
    );
  }
}

/// Sección de título y descripción
class _TitleSection extends StatelessWidget {
  const _TitleSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Panel de Control',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Resumen general de las operaciones y estado del sistema.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.gray500,
          ),
        ),
      ],
    );
  }
}

/// Botones de acción
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    this.onImport,
    this.onExport,
    this.onFilter,
    this.onNewService,
  });

  final VoidCallback? onImport;
  final VoidCallback? onExport;
  final VoidCallback? onFilter;
  final VoidCallback? onNewService;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        _SecondaryButton(
          label: 'Importar',
          icon: Icons.upload_outlined,
          onPressed: onImport,
        ),
        _SecondaryButton(
          label: 'Exportar',
          icon: Icons.download_outlined,
          onPressed: onExport,
        ),
        _SecondaryButton(
          label: 'Filtrar',
          icon: Icons.filter_list_outlined,
          onPressed: onFilter,
        ),
        _PrimaryButton(
          label: 'Nuevo Servicio',
          icon: Icons.add_circle_outline,
          onPressed: onNewService,
        ),
      ],
    );
  }
}

/// Botón secundario con borde
class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.icon,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.gray700,
        backgroundColor: Colors.white,
        side: const BorderSide(color: AppColors.gray200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

/// Botón primario con gradiente
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
