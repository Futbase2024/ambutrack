import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/widgets/historial/registro_historial_tab.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/common/personal_gestion_common.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/personal/personal_formacion_tab.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/personal/personal_general_tab.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/personal/personal_gestion_columns.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/personal/personal_lookups.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/personal/personal_related_tabs.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del empleado seleccionado
class PersonalDetailPanel extends StatelessWidget {
  const PersonalDetailPanel({
    required this.persona,
    required this.lookups,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final PersonalEntity? persona;
  final PersonalLookups lookups;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final PersonalEntity? p = persona;
    if (p == null) {
      return const GestionDetailEmpty(message: 'Selecciona un empleado para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(p.id),
      title: p.nombreCompleto,
      badges: <Widget>[
        if (p.categoria?.trim().isNotEmpty ?? false) PersonalCategoriaDot(categoria: p.categoria),
        PersonalServicioDot(servicio: p.categoriaServicio),
        PersonalEstadoDot(activo: p.activo),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: PersonalGeneralTab(persona: p, lookups: lookups)),
        GestionDetailTab(
          label: 'Formación',
          child: PersonalFormacionTab(personalId: p.usuarioId ?? p.id),
        ),
        GestionDetailTab(label: 'Equipamiento', child: PersonalEquipamientoTab(personalId: p.id)),
        GestionDetailTab(label: 'Vestuario', child: PersonalVestuarioTab(personalId: p.id)),
        GestionDetailTab(label: 'Cambios', child: RegistroHistorialTab(tabla: 'tpersonal', registroId: p.id)),
      ],
      actions: <Widget>[
        GestionDetailEditButton(onPressed: onEdit),
        GestionDetailDeleteButton(onPressed: onDelete),
      ],
    );
  }
}
