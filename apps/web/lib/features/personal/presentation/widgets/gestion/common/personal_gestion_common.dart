import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Devuelve la página [page] de [rows] con [pageSize] elementos
List<T> gestionPageOf<T>(List<T> rows, int page, int pageSize) {
  final int start = (page * pageSize).clamp(0, rows.length);
  final int end = (start + pageSize).clamp(0, rows.length);
  return rows.sublist(start, end);
}

/// Texto de celda que pinta el marcador de vacío en gris claro
class GestionCellText extends StatelessWidget {
  const GestionCellText(this.value, {this.bold = false, super.key});

  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final bool empty = value == GestionFormatters.vacio;
    return Text(
      value,
      style: TextStyle(
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        color: empty ? AppColors.gray300 : null,
      ),
    );
  }
}

/// Indicador de estado activo/inactivo (genérico para catálogos)
class CatalogoEstadoDot extends StatelessWidget {
  const CatalogoEstadoDot({
    required this.activo,
    this.activoLabel = 'Activo',
    this.inactivoLabel = 'Inactivo',
    super.key,
  });

  final bool activo;
  final String activoLabel;
  final String inactivoLabel;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(
      label: activo ? activoLabel : inactivoLabel,
      color: activo ? AppColors.success : AppColors.inactive,
    );
  }
}

/// Botón "Editar" de la ficha lateral
class GestionDetailEditButton extends StatelessWidget {
  const GestionDetailEditButton({required this.onPressed, this.label = 'Editar', super.key});

  final VoidCallback onPressed;
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
class GestionDetailDeleteButton extends StatelessWidget {
  const GestionDetailDeleteButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

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

/// Bloque de texto libre (observaciones, descripción) de la ficha
class GestionDetailNotes extends StatelessWidget {
  const GestionDetailNotes({required this.text, super.key});

  final String? text;

  @override
  Widget build(BuildContext context) {
    final bool hasText = text?.trim().isNotEmpty ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        GestionFormatters.texto(text),
        style: TextStyle(
          fontSize: 12.5,
          height: 1.4,
          color: hasText ? AppColors.gray800 : AppColors.gray300,
        ),
      ),
    );
  }
}

/// Mensaje informativo dentro de una pestaña de la ficha
class GestionDetailMessage extends StatelessWidget {
  const GestionDetailMessage(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message,
        style: const TextStyle(fontSize: 12.5, color: AppColors.gray500),
      ),
    );
  }
}

/// Indicador de carga pequeño para pestañas de la ficha
class GestionDetailLoading extends StatelessWidget {
  const GestionDetailLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

/// Error de carga inicial (sin datos en caché)
class GestionLoadError extends StatelessWidget {
  const GestionLoadError({
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
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, color: AppColors.gray600),
          ),
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

/// Contenido central de una pantalla de gestión: carga inicial, error o rejilla.
///
/// Mientras se recarga con datos en caché se muestra una barra de progreso
/// fina sobre la rejilla para evitar parpadeos.
class GestionGridContent<T> extends StatelessWidget {
  const GestionGridContent({
    required this.hasData,
    required this.isLoading,
    required this.columns,
    required this.rows,
    required this.rowId,
    required this.firstRowNumber,
    required this.selectedId,
    required this.sort,
    required this.onSelect,
    required this.onActivate,
    required this.onSort,
    required this.onRetry,
    required this.emptyMessage,
    required this.errorTitle,
    this.errorMessage,
    super.key,
  });

  final bool hasData;
  final bool isLoading;

  /// Error de carga cuando todavía no hay datos
  final String? errorMessage;
  final String errorTitle;
  final List<GestionColumn<T>> columns;
  final List<T> rows;
  final String Function(T item) rowId;
  final int firstRowNumber;
  final String? selectedId;
  final GestionSort sort;
  final ValueChanged<T> onSelect;
  final ValueChanged<T>? onActivate;
  final ValueChanged<GestionSort> onSort;
  final VoidCallback onRetry;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (!hasData && errorMessage != null) {
      return GestionLoadError(title: errorTitle, message: errorMessage!, onRetry: onRetry);
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

/// Barra de herramientas estándar: Nuevo / Editar / Eliminar + Actualizar / Imprimir
/// y, opcionalmente, un grupo de acciones adicionales.
class GestionStandardToolbar extends StatelessWidget {
  const GestionStandardToolbar({
    required this.title,
    required this.icon,
    required this.hasSelection,
    required this.onNew,
    required this.onEdit,
    required this.onDelete,
    required this.onRefresh,
    required this.onPrint,
    this.newLabel = 'Nuevo',
    this.extraActions = const <GestionToolbarAction>[],
    super.key,
  });

  final String title;
  final IconData icon;
  final bool hasSelection;
  final String newLabel;
  final VoidCallback? onNew;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final VoidCallback onRefresh;
  final VoidCallback? onPrint;
  final List<GestionToolbarAction> extraActions;

  @override
  Widget build(BuildContext context) {
    return GestionToolbar(
      title: title,
      icon: icon,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.add, label: newLabel, primary: true, onPressed: onNew),
          GestionToolbarAction(
            icon: Icons.edit_outlined,
            label: 'Editar',
            tooltip: 'Editar el registro seleccionado (doble clic / Intro)',
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

/// Resumen "N registros" / "X de N registros"
String gestionResumenRegistros(int total, int filtrados) =>
    filtrados == total ? '$total registros' : '$filtrados de $total registros';
