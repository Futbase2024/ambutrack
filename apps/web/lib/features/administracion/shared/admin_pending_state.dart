import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Punto de una lista de la pantalla de "pendiente"
class AdminPendingItem {
  const AdminPendingItem({required this.icon, required this.title, required this.detail});

  final IconData icon;
  final String title;
  final String detail;
}

/// Estado vacío profesional para funcionalidades pendientes de implementar
class AdminPendingState extends StatelessWidget {
  const AdminPendingState({
    required this.icon,
    required this.title,
    required this.message,
    required this.planPath,
    this.items = const <AdminPendingItem>[],
    this.itemsTitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;

  /// Ruta del documento con la propuesta (docs/plans/...)
  final String planPath;
  final String? itemsTitle;
  final List<AdminPendingItem> items;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: AppColors.info),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray900),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, height: 1.4, color: AppColors.gray700),
              ),
              if (items.isNotEmpty) ...<Widget>[
                const SizedBox(height: 24),
                _PendingItemsCard(title: itemsTitle, items: items),
              ],
              const SizedBox(height: 16),
              _PlanReference(path: planPath),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingItemsCard extends StatelessWidget {
  const _PendingItemsCard({required this.title, required this.items});

  final String? title;
  final List<AdminPendingItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title != null) ...<Widget>[
            Text(
              title!.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: 10),
          ],
          for (final AdminPendingItem item in items) _PendingItemRow(item: item),
        ],
      ),
    );
  }
}

class _PendingItemRow extends StatelessWidget {
  const _PendingItemRow({required this.item});

  final AdminPendingItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(item.icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray900),
                ),
                const SizedBox(height: 2),
                Text(
                  item.detail,
                  style: const TextStyle(fontSize: 12.5, height: 1.35, color: AppColors.gray600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanReference extends StatelessWidget {
  const _PlanReference({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.description_outlined, size: 16, color: AppColors.gray500),
        const SizedBox(width: 6),
        Flexible(
          child: SelectableText(
            'Propuesta técnica: $path',
            style: const TextStyle(fontSize: 12.5, color: AppColors.gray500),
          ),
        ),
      ],
    );
  }
}
