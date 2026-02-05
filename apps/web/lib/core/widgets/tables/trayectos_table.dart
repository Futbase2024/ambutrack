import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/menus/action_menu.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modelo de datos para un trayecto
class TrayectoTableData {
  const TrayectoTableData({
    required this.id,
    required this.fecha,
    required this.estado,
    required this.tipo,
    required this.hora,
    this.horaRecogida,
    this.horaLlegada,
    this.vehiculo,
    this.conductor,
  });

  final String id;
  final DateTime fecha;
  final String estado; // 'pendiente', 'en_curso', 'completado', 'cancelado', 'anulado', 'finalizado'
  final String tipo; // 'IDA', 'VUELTA'
  final String hora;
  final String? horaRecogida;
  final String? horaLlegada;
  final String? vehiculo;
  final String? conductor;

  /// Helper para obtener color del estado
  Color get estadoColor {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return AppColors.warning;
      case 'en_curso':
        return AppColors.info;
      case 'completado':
      case 'finalizado':
        return AppColors.success;
      case 'cancelado':
      case 'anulado':
        return AppColors.error;
      default:
        return AppColors.textSecondaryLight;
    }
  }

  /// Helper para obtener icono del estado
  IconData get estadoIcon {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Icons.schedule;
      case 'en_curso':
        return Icons.directions_run;
      case 'completado':
      case 'finalizado':
        return Icons.check_circle;
      case 'cancelado':
      case 'anulado':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  /// Helper para obtener color del tipo
  Color get tipoColor {
    switch (tipo.toUpperCase()) {
      case 'IDA':
        return AppColors.success;
      case 'VUELTA':
        return AppColors.error;
      default:
        return AppColors.textSecondaryLight;
    }
  }
}

/// Tabla reutilizable de trayectos con diseño profesional
///
/// Uso:
/// ```dart
/// TrayectosTable(
///   trayectos: trayectos,
///   onEdit: (trayecto) => print('Editar ${trayecto.id}'),
///   onDelete: (trayecto) => print('Eliminar ${trayecto.id}'),
///   onView: (trayecto) => print('Ver ${trayecto.id}'),
/// )
/// ```
class TrayectosTable extends StatefulWidget {
  const TrayectosTable({
    required this.trayectos,
    this.onEdit,
    this.onDelete,
    this.onView,
    this.onCancel,
    this.onAnular,
    this.onRecuperar,
    this.onAnalizar,
    this.onAssign,
    this.sortable = true,
    this.selectable = false,
    this.onSelectionChanged,
    this.emptyMessage = 'No hay trayectos registrados',
    super.key,
  });

  final List<TrayectoTableData> trayectos;
  final void Function(TrayectoTableData)? onEdit;
  final void Function(TrayectoTableData)? onDelete;
  final void Function(TrayectoTableData)? onView;
  final void Function(TrayectoTableData)? onCancel;
  final void Function(TrayectoTableData)? onAnular;
  final void Function(TrayectoTableData)? onRecuperar;
  final void Function(TrayectoTableData)? onAnalizar;
  final void Function(TrayectoTableData)? onAssign;
  final bool sortable;
  final bool selectable;
  final void Function(List<TrayectoTableData>)? onSelectionChanged;
  final String emptyMessage;

  @override
  State<TrayectosTable> createState() => _TrayectosTableState();
}

class _TrayectosTableState extends State<TrayectosTable> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  final Set<String> _selectedIds = <String>{};

  List<TrayectoTableData> get _sortedTrayectos {
    final List<TrayectoTableData> sorted = List<TrayectoTableData>.from(widget.trayectos);

    if (_sortColumnIndex != null) {
      sorted.sort((TrayectoTableData a, TrayectoTableData b) {
        int comparison = 0;

        switch (_sortColumnIndex) {
          case 0: // Fecha
            comparison = a.fecha.compareTo(b.fecha);
          case 1: // Estado
            comparison = a.estado.compareTo(b.estado);
          case 2: // Tipo (Ida/Vuelta)
            comparison = a.tipo.compareTo(b.tipo);
          case 3: // Hora
            comparison = a.hora.compareTo(b.hora);
          case 4: // H.Rec
            comparison = (a.horaRecogida ?? '').compareTo(b.horaRecogida ?? '');
          case 5: // H.Lleg
            comparison = (a.horaLlegada ?? '').compareTo(b.horaLlegada ?? '');
          case 6: // Vehículo
            comparison = (a.vehiculo ?? '').compareTo(b.vehiculo ?? '');
          case 7: // Conductor
            comparison = (a.conductor ?? '').compareTo(b.conductor ?? '');
        }

        return _sortAscending ? comparison : -comparison;
      });
    }

    return sorted;
  }

  void _onSort(int columnIndex, bool ascending) {
    if (widget.sortable) {
      setState(() {
        _sortColumnIndex = columnIndex;
        _sortAscending = ascending;
      });
    }
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }

      if (widget.onSelectionChanged != null) {
        final List<TrayectoTableData> selected = widget.trayectos
            .where((TrayectoTableData t) => _selectedIds.contains(t.id))
            .toList();
        widget.onSelectionChanged!(selected);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trayectos.isEmpty) {
      return _buildEmptyState();
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.gray200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 32,
          ),
          child: DataTable(
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            headingRowHeight: 48,
            dataRowMinHeight: 56,
            dataRowMaxHeight: 56,
            columnSpacing: 24,
            horizontalMargin: 16,
            dividerThickness: 1,
            headingRowColor: WidgetStateProperty.all(AppColors.surfaceLight),
            columns: <DataColumn>[
              _buildColumn('Fecha ↑', 0, flex: 2),
              _buildColumn('Estado', 1, flex: 2),
              _buildColumn('Ida/Vuelta', 2, flex: 2),
              _buildColumn('Hora', 3),
              _buildColumn('H.Rec', 4),
              _buildColumn('H.Lleg', 5),
              _buildColumn('Vehículo', 6, flex: 2),
              _buildColumn('Conductor', 7, flex: 2),
              const DataColumn(
                label: Expanded(
                  child: Center(
                    child: Text(
                      'Acciones',
                      style: TextStyle(
                        fontSize: AppSizes.fontSmall,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            rows: _sortedTrayectos.map((TrayectoTableData trayecto) {
              final bool isSelected = _selectedIds.contains(trayecto.id);

              return DataRow(
                selected: isSelected,
                onSelectChanged: widget.selectable
                    ? (_) => _toggleSelection(trayecto.id)
                    : null,
                color: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary.withValues(alpha: 0.05);
                    }
                    return null;
                  },
                ),
                cells: <DataCell>[
                  // Fecha
                  DataCell(
                    Text(
                      _formatDate(trayecto.fecha),
                      style: GoogleFonts.inter(
                        fontSize: AppSizes.fontSmall,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ),

                  // Estado
                  DataCell(_buildEstadoBadge(trayecto)),

                  // Ida/Vuelta
                  DataCell(_buildTipoBadge(trayecto)),

                  // Hora
                  DataCell(
                    Text(
                      trayecto.hora,
                      style: GoogleFonts.inter(
                        fontSize: AppSizes.fontSmall,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ),

                  // H.Rec
                  DataCell(
                    Text(
                      trayecto.horaRecogida ?? '-',
                      style: GoogleFonts.inter(
                        fontSize: AppSizes.fontSmall,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),

                  // H.Lleg
                  DataCell(
                    Text(
                      trayecto.horaLlegada ?? '-',
                      style: GoogleFonts.inter(
                        fontSize: AppSizes.fontSmall,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),

                  // Vehículo
                  DataCell(
                    Text(
                      trayecto.vehiculo ?? '-',
                      style: GoogleFonts.inter(
                        fontSize: AppSizes.fontSmall,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),

                  // Conductor
                  DataCell(
                    Text(
                      trayecto.conductor ?? '-',
                      style: GoogleFonts.inter(
                        fontSize: AppSizes.fontSmall,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),

                  // Acciones
                  DataCell(
                    Center(child: _buildActionsMenu(trayecto)),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  DataColumn _buildColumn(String label, int columnIndex, {int flex = 1}) {
    return DataColumn(
      label: Expanded(
        flex: flex,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontSmall,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
      onSort: widget.sortable ? _onSort : null,
    );
  }

  Widget _buildEstadoBadge(TrayectoTableData trayecto) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: trayecto.estadoColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(
              color: trayecto.estadoColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                trayecto.estadoIcon,
                size: 14,
                color: trayecto.estadoColor,
              ),
              const SizedBox(width: 4),
              Text(
                trayecto.estado,
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontSmall,
                  fontWeight: FontWeight.w600,
                  color: trayecto.estadoColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipoBadge(TrayectoTableData trayecto) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: trayecto.tipoColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Text(
            trayecto.tipo,
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontSmall,
              fontWeight: FontWeight.w600,
              color: trayecto.tipoColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionsMenu(TrayectoTableData trayecto) {
    final List<ActionMenuItem> items = <ActionMenuItem>[];
    final String estadoLower = trayecto.estado.toLowerCase();

    // Determinar si está cancelado, anulado o finalizado
    final bool estaCancelado = estadoLower == 'cancelado';
    final bool estaAnulado = estadoLower == 'anulado';
    final bool estaFinalizado = estadoLower == 'finalizado';

    // Estado inactivo: cancelado o anulado
    final bool estaInactivo = estaCancelado || estaAnulado;

    // Estado activo: NO está cancelado, anulado ni finalizado
    final bool estaActivo = !estaCancelado && !estaAnulado && !estaFinalizado;

    // Lógica según estado:
    // - Si está activo (no cancelado, no anulado, no finalizado):
    //   → Editar, Cancelar, Anular, Analizar
    // - Si está cancelado o anulado:
    //   → Editar, Recuperar, Analizar

    // Editar (siempre disponible)
    if (widget.onEdit != null) {
      items.add(
        const ActionMenuItem(
          value: 'edit',
          label: 'Editar',
          icon: Icons.edit_outlined,
          iconColor: AppColors.secondaryLight,
        ),
      );
    }

    if (estaInactivo) {
      // Está cancelado o anulado → Mostrar Recuperar
      if (widget.onRecuperar != null) {
        items.add(
          const ActionMenuItem(
            value: 'recuperar',
            label: 'Recuperar',
            icon: Icons.restore_outlined,
            iconColor: AppColors.success,
            description: 'Recuperar trayecto',
          ),
        );
      }
    } else if (estaActivo) {
      // Está activo → Mostrar Cancelar y Anular
      if (widget.onCancel != null) {
        items.add(
          const ActionMenuItem(
            value: 'cancelar',
            label: 'Cancelar',
            icon: Icons.cancel_outlined,
            iconColor: AppColors.warning,
            description: 'Cancelar este trayecto',
          ),
        );
      }

      if (widget.onAnular != null) {
        items.add(
          const ActionMenuItem(
            value: 'anular',
            label: 'Anular',
            icon: Icons.block_outlined,
            isDanger: true,
            description: 'Anular este trayecto',
          ),
        );
      }
    }

    // Analizar (siempre disponible)
    if (widget.onAnalizar != null) {
      items.add(
        const ActionMenuItem(
          value: 'analizar',
          label: 'Analizar',
          icon: Icons.analytics_outlined,
          iconColor: AppColors.info,
          description: 'Analizar trayecto',
        ),
      );
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return ActionMenu(
      items: items,
      onSelected: (String value) {
        switch (value) {
          case 'edit':
            widget.onEdit?.call(trayecto);
          case 'cancelar':
            widget.onCancel?.call(trayecto);
          case 'anular':
            widget.onAnular?.call(trayecto);
          case 'recuperar':
            widget.onRecuperar?.call(trayecto);
          case 'analizar':
            widget.onAnalizar?.call(trayecto);
        }
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl * 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.alt_route,
            size: 64,
            color: AppColors.textSecondaryLight.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSizes.spacing),
          Text(
            widget.emptyMessage,
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontMedium,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
