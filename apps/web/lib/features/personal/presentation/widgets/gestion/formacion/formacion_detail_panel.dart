import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/common/personal_gestion_common.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/formacion/formacion_catalogos.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/formacion/formacion_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del registro de formación seleccionado
class FormacionDetailPanel extends StatelessWidget {
  const FormacionDetailPanel({
    required this.item,
    required this.catalogos,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final FormacionPersonalEntity? item;
  final FormacionCatalogos catalogos;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final FormacionPersonalEntity? f = item;
    if (f == null) {
      return const GestionDetailEmpty(message: 'Selecciona un registro de formación para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(f.id),
      title: catalogos.formacion(f),
      badges: <Widget>[
        GestionDotLabel(label: catalogos.personal(f), color: AppColors.formacion),
        FormacionEstadoDot(estado: f.estado),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _FormacionGeneralTab(item: f, catalogos: catalogos)),
      ],
      actions: <Widget>[
        GestionDetailEditButton(onPressed: onEdit),
        GestionDetailDeleteButton(onPressed: onDelete),
      ],
    );
  }
}

class _FormacionGeneralTab extends StatelessWidget {
  const _FormacionGeneralTab({required this.item, required this.catalogos});

  final FormacionPersonalEntity item;
  final FormacionCatalogos catalogos;

  @override
  Widget build(BuildContext context) {
    final FormacionPersonalEntity f = item;
    final int diasRestantes = f.fechaExpiracion.difference(DateTime.now()).inDays;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Formación'),
        GestionDetailField(label: 'Empleado', value: catalogos.personal(f)),
        GestionDetailField(label: 'Tipo', value: formacionTipoLabel(f)),
        GestionDetailField(label: 'Nombre', value: catalogos.formacion(f)),
        GestionDetailField(label: 'Horas', value: '${f.horasAcumuladas} h'),
        const GestionDetailSection(title: 'Vigencia'),
        GestionDetailField(label: 'Inicio', value: GestionFormatters.fecha(f.fechaInicio)),
        GestionDetailField(label: 'Fin', value: GestionFormatters.fecha(f.fechaFin)),
        GestionDetailField(label: 'Expiración', value: GestionFormatters.fecha(f.fechaExpiracion)),
        GestionDetailField(
          label: 'Días restantes',
          value: diasRestantes >= 0 ? '$diasRestantes' : 'Expirada hace ${-diasRestantes} días',
        ),
        GestionDetailField(label: 'Estado', child: FormacionEstadoDot(estado: f.estado)),
        const GestionDetailSection(title: 'Documentación'),
        GestionDetailField(label: 'Certificado', value: f.certificadoUrl),
        const GestionDetailSection(title: 'Observaciones'),
        GestionDetailNotes(text: f.observaciones),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(
          label: 'Alta',
          value: f.createdAt == null ? null : GestionFormatters.fecha(f.createdAt),
        ),
        GestionDetailField(
          label: 'Modificado',
          value: f.updatedAt == null ? null : GestionFormatters.fecha(f.updatedAt),
        ),
      ],
    );
  }
}
