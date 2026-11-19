import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/widgets/gestion/bases_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral de la base seleccionada
class BasesDetailPanel extends StatelessWidget {
  const BasesDetailPanel({
    required this.base,
    required this.onEdit,
    required this.onToggleActivo,
    super.key,
  });

  final BaseCentroEntity? base;
  final VoidCallback onEdit;
  final VoidCallback onToggleActivo;

  @override
  Widget build(BuildContext context) {
    final BaseCentroEntity? b = base;
    if (b == null) {
      return const GestionDetailEmpty(message: 'Selecciona una base para ver su ficha');
    }
    final Color toggleColor = b.activo ? AppColors.error : AppColors.success;
    return GestionDetailPanel(
      key: ValueKey<String>(b.id),
      title: b.nombre,
      badges: <Widget>[
        if (b.tipo?.trim().isNotEmpty ?? false) BaseTipoDot(tipo: b.tipo),
        BaseEstadoDot(activo: b.activo),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _BaseGeneralTab(base: b)),
      ],
      actions: <Widget>[
        OutlinedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('Editar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(0, 34),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onToggleActivo,
          icon: Icon(b.activo ? Icons.block : Icons.check_circle_outline, size: 16),
          label: Text(b.activo ? 'Desactivar' : 'Activar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: toggleColor,
            side: BorderSide(color: toggleColor.withValues(alpha: 0.4)),
            minimumSize: const Size(0, 34),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _BaseGeneralTab extends StatelessWidget {
  const _BaseGeneralTab({required this.base});

  final BaseCentroEntity base;

  @override
  Widget build(BuildContext context) {
    final BaseCentroEntity b = base;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Identificación'),
        GestionDetailField(label: 'Código', value: b.codigo),
        GestionDetailField(label: 'Nombre', value: b.nombre),
        GestionDetailField(label: 'Tipo', value: b.tipo),
        GestionDetailField(label: 'Estado', child: BaseEstadoDot(activo: b.activo)),
        const GestionDetailSection(title: 'Ubicación'),
        GestionDetailField(label: 'Dirección', value: b.direccion),
        GestionDetailField(label: 'Población', value: b.poblacionNombre),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(b.createdAt)),
        GestionDetailField(label: 'Modificado', value: GestionFormatters.fecha(b.updatedAt)),
      ],
    );
  }
}
