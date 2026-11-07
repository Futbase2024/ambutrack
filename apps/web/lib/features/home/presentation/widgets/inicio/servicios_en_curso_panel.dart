import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/home/presentation/widgets/inicio/inicio_panel.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslado_gestion_helpers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Panel "Servicios en curso" del dashboard: rejilla de los traslados activos
class ServiciosEnCursoPanel extends StatefulWidget {
  const ServiciosEnCursoPanel({required this.servicios, super.key});

  final List<TrasladoEntity> servicios;

  @override
  State<ServiciosEnCursoPanel> createState() => _ServiciosEnCursoPanelState();
}

class _ServiciosEnCursoPanelState extends State<ServiciosEnCursoPanel> {
  GestionSort _sort = const GestionSort(columnIndex: 0);
  String? _selectedId;

  /// Nombre del paciente sin pasar por el getter de la entidad (que escribe trazas)
  static String _paciente(TrasladoEntity t) {
    final PacienteEntity? p = t.paciente;
    if (p == null) {
      return GestionFormatters.vacio;
    }
    final String nombre = <String?>[p.nombre, p.primerApellido, p.segundoApellido]
        .where((String? s) => s != null && s.isNotEmpty)
        .join(' ');
    return nombre.isEmpty ? GestionFormatters.vacio : nombre;
  }

  static List<GestionColumn<TrasladoEntity>> get _columns => <GestionColumn<TrasladoEntity>>[
        GestionColumn<TrasladoEntity>(
          label: 'Hora',
          width: 70,
          sortValue: (TrasladoEntity t) => t.horaProgramada?.millisecondsSinceEpoch ?? 0,
          cell: (TrasladoEntity t) => Text(TrasladoGestion.hora(t.horaProgramada)),
        ),
        GestionColumn<TrasladoEntity>(
          label: 'Código',
          width: 110,
          sortValue: (TrasladoEntity t) => t.codigo ?? '',
          cell: (TrasladoEntity t) => Text(
            GestionFormatters.texto(t.codigo),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        GestionColumn<TrasladoEntity>(
          label: 'Paciente',
          flex: 2,
          minWidth: 150,
          sortValue: (TrasladoEntity t) => _paciente(t).toLowerCase(),
          cell: (TrasladoEntity t) => Text(_paciente(t), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        GestionColumn<TrasladoEntity>(
          label: 'Vehículo',
          width: 100,
          sortValue: (TrasladoEntity t) => t.matriculaVehiculo ?? '',
          cell: (TrasladoEntity t) => Text(GestionFormatters.texto(t.matriculaVehiculo)),
        ),
        GestionColumn<TrasladoEntity>(
          label: 'Estado',
          width: 150,
          sortValue: (TrasladoEntity t) => TrasladoGestion.estadoLabel(t.estado),
          cell: (TrasladoEntity t) => GestionDotLabel(
            label: TrasladoGestion.estadoLabel(t.estado),
            color: TrasladoGestion.estadoColor(t.estado),
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final List<GestionColumn<TrasladoEntity>> columns = _columns;
    return InicioPanel(
      title: 'Servicios en curso (${widget.servicios.length})',
      icon: Icons.local_hospital_outlined,
      trailing: TextButton(
        onPressed: () => context.go('/servicios/planificar'),
        style: TextButton.styleFrom(foregroundColor: AppColors.primary, textStyle: const TextStyle(fontSize: 12.5)),
        child: const Text('Ver planificación'),
      ),
      child: GestionGrid<TrasladoEntity>(
        columns: columns,
        rows: _sort.apply(widget.servicios, columns),
        rowId: (TrasladoEntity t) => t.id,
        selectedId: _selectedId,
        onSelect: (TrasladoEntity t) => setState(() => _selectedId = t.id),
        sort: _sort,
        onSort: (GestionSort s) => setState(() => _sort = s),
        emptyMessage: 'No hay servicios en curso ahora mismo',
      ),
    );
  }
}
