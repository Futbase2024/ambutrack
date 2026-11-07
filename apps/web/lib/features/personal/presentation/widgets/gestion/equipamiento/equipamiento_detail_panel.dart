import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/common/personal_gestion_common.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/equipamiento/equipamiento_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del equipamiento seleccionado
class EquipamientoDetailPanel extends StatelessWidget {
  const EquipamientoDetailPanel({
    required this.item,
    required this.personalNombre,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final EquipamientoPersonalEntity? item;
  final String? personalNombre;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final EquipamientoPersonalEntity? e = item;
    if (e == null) {
      return const GestionDetailEmpty(message: 'Selecciona un equipamiento para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(e.id),
      title: e.nombreEquipamiento,
      badges: <Widget>[
        EquipamientoTipoDot(tipo: e.tipoEquipamiento),
        EquipamientoEstadoDot(asignado: e.estaAsignado),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(
          label: 'General',
          child: _EquipamientoGeneralTab(item: e, personalNombre: personalNombre),
        ),
      ],
      actions: <Widget>[
        GestionDetailEditButton(onPressed: onEdit),
        GestionDetailDeleteButton(onPressed: onDelete),
      ],
    );
  }
}

class _EquipamientoGeneralTab extends StatelessWidget {
  const _EquipamientoGeneralTab({required this.item, required this.personalNombre});

  final EquipamientoPersonalEntity item;
  final String? personalNombre;

  @override
  Widget build(BuildContext context) {
    final EquipamientoPersonalEntity e = item;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Equipamiento'),
        GestionDetailField(label: 'Nombre', value: e.nombreEquipamiento),
        GestionDetailField(label: 'Tipo', child: EquipamientoTipoDot(tipo: e.tipoEquipamiento)),
        GestionDetailField(label: 'Nº serie', value: e.numeroSerie),
        GestionDetailField(label: 'Talla', value: e.talla),
        GestionDetailField(
          label: 'Conservación',
          value: e.estado == null ? null : equipamientoConservacion(e.estado),
        ),
        const GestionDetailSection(title: 'Asignación'),
        GestionDetailField(label: 'Personal', value: personalNombre),
        GestionDetailField(label: 'F. asignación', value: GestionFormatters.fecha(e.fechaAsignacion)),
        GestionDetailField(
          label: 'F. devolución',
          value: e.fechaDevolucion == null ? null : GestionFormatters.fecha(e.fechaDevolucion),
        ),
        GestionDetailField(label: 'Estado', child: EquipamientoEstadoDot(asignado: e.estaAsignado)),
        GestionDetailField(label: 'Activo', value: e.activo ? 'Sí' : 'No'),
        const GestionDetailSection(title: 'Documentación'),
        GestionDetailField(label: 'Documento', value: e.documentoUrl),
        const GestionDetailSection(title: 'Observaciones'),
        GestionDetailNotes(text: e.observaciones),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(
          label: 'Alta',
          value: e.createdAt == null ? null : GestionFormatters.fecha(e.createdAt),
        ),
        GestionDetailField(
          label: 'Modificado',
          value: e.updatedAt == null ? null : GestionFormatters.fecha(e.updatedAt),
        ),
      ],
    );
  }
}
