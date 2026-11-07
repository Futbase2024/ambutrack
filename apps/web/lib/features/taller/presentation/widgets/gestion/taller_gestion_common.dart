import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Devuelve la página [page] de [rows] con tamaño [pageSize]
List<T> tallerPageOf<T>(List<T> rows, int page, int pageSize) {
  final int start = (page * pageSize).clamp(0, rows.length);
  final int end = (start + pageSize).clamp(0, rows.length);
  return rows.sublist(start, end);
}

/// Texto "N registros" / "X de N registros" para la barra de estado
String tallerRegistrosLabel(int total, int filtrados) =>
    filtrados == total ? '$total registros' : '$filtrados de $total registros';

/// Barra de herramientas CRUD estándar de las pantallas del taller
class TallerCrudToolbar extends StatelessWidget {
  const TallerCrudToolbar({
    required this.title,
    required this.icon,
    required this.entityLabel,
    required this.hasSelection,
    required this.onNew,
    required this.onEdit,
    required this.onDelete,
    required this.onRefresh,
    required this.onPrint,
    this.extraActions = const <GestionToolbarAction>[],
    super.key,
  });

  final String title;
  final IconData icon;

  /// Nombre de la entidad en singular con artículo (ej. "el proveedor")
  final String entityLabel;
  final bool hasSelection;
  final VoidCallback onNew;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;
  final VoidCallback? onPrint;

  /// Acciones específicas de la pantalla (grupo adicional)
  final List<GestionToolbarAction> extraActions;

  @override
  Widget build(BuildContext context) {
    return GestionToolbar(
      title: title,
      icon: icon,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.add, label: 'Nuevo', primary: true, onPressed: onNew),
          GestionToolbarAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            tooltip: 'Editar $entityLabel seleccionado (doble clic / Intro)',
            onPressed: hasSelection ? onEdit : null,
          ),
          GestionToolbarAction(
            icon: Icons.delete_outline,
            label: 'Eliminar',
            destructive: true,
            onPressed: hasSelection ? onDelete : null,
          ),
        ],
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.refresh, label: 'Actualizar', onPressed: onRefresh),
          GestionToolbarAction(
            icon: Icons.print_outlined,
            label: 'Imprimir',
            tooltip: 'Imprimir o guardar como PDF el listado filtrado',
            onPressed: onPrint,
          ),
        ],
        if (extraActions.isNotEmpty) extraActions,
      ],
    );
  }
}

/// Contenido central genérico: carga inicial, error o rejilla con progreso
class TallerGestionGridContent<T> extends StatelessWidget {
  const TallerGestionGridContent({
    required this.hasData,
    required this.isLoading,
    required this.errorTitle,
    required this.columns,
    required this.rows,
    required this.rowId,
    required this.firstRowNumber,
    required this.selectedId,
    required this.sort,
    required this.emptyMessage,
    required this.onSelect,
    required this.onActivate,
    required this.onSort,
    required this.onRetry,
    this.errorMessage,
    super.key,
  });

  final bool hasData;
  final bool isLoading;
  final String errorTitle;

  /// Mensaje de error de la carga inicial (sin datos en caché)
  final String? errorMessage;
  final List<GestionColumn<T>> columns;
  final List<T> rows;
  final String Function(T item) rowId;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final String emptyMessage;
  final ValueChanged<T> onSelect;
  final ValueChanged<T> onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final String? error = errorMessage;
    if (!hasData && error != null) {
      return TallerGestionLoadError(title: errorTitle, message: error, onRetry: onRetry);
    }
    if (!hasData) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        GestionGrid<T>(
          columns: columns,
          rows: rows,
          rowId: rowId,
          selectedId: selectedId,
          onSelect: onSelect,
          onActivate: onActivate,
          sort: sort,
          onSort: onSort,
          firstRowNumber: firstRowNumber,
          emptyMessage: emptyMessage,
        ),
        if (isLoading)
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }
}

/// Vista de error de la carga inicial con botón de reintento
class TallerGestionLoadError extends StatelessWidget {
  const TallerGestionLoadError({
    required this.title,
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.error_outline, size: 40, color: AppColors.error),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.error),
          ),
          const SizedBox(height: 4),
          Text(message, style: const TextStyle(fontSize: 12.5, color: AppColors.gray600)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

/// Botón "Editar" de la ficha lateral
class TallerDetailEditButton extends StatelessWidget {
  const TallerDetailEditButton({required this.onPressed, this.label = 'Editar', super.key});

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.edit_outlined, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(0, 34),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Botón "Eliminar" de la ficha lateral
class TallerDetailDeleteButton extends StatelessWidget {
  const TallerDetailDeleteButton({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.delete_outline, size: 16),
      label: const Text('Eliminar'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
        minimumSize: const Size(0, 34),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Bloque de texto largo (observaciones, diagnóstico...) de la ficha
class TallerDetailText extends StatelessWidget {
  const TallerDetailText(this.value, {super.key});

  final String? value;

  @override
  Widget build(BuildContext context) {
    final bool empty = value?.trim().isEmpty ?? true;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        GestionFormatters.texto(value),
        style: TextStyle(
          fontSize: 12.5,
          height: 1.4,
          color: empty ? AppColors.gray300 : AppColors.gray800,
        ),
      ),
    );
  }
}
