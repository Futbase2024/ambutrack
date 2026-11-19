import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/proveedor_taller_gestion_columns.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/taller_gestion_columns.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/taller_gestion_common.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del proveedor de taller seleccionado
class ProveedorTallerDetailPanel extends StatelessWidget {
  const ProveedorTallerDetailPanel({
    required this.proveedor,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final ProveedorTallerEntity? proveedor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ProveedorTallerEntity? p = proveedor;
    if (p == null) {
      return const GestionDetailEmpty(
        message: 'Selecciona un proveedor para ver su ficha',
      );
    }
    return GestionDetailPanel(
      key: ValueKey<String>(p.id),
      title: p.nombre,
      badges: <Widget>[
        GestionDotLabel(label: p.tipo.displayName, color: proveedorTallerTipoColor(p.tipo)),
        TallerEstadoDot(activo: p.activo),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _ProveedorGeneralTab(proveedor: p)),
      ],
      actions: <Widget>[
        TallerDetailEditButton(onPressed: onEdit),
        TallerDetailDeleteButton(onPressed: onDelete),
      ],
    );
  }
}

class _ProveedorGeneralTab extends StatelessWidget {
  const _ProveedorGeneralTab({required this.proveedor});

  final ProveedorTallerEntity proveedor;

  @override
  Widget build(BuildContext context) {
    final ProveedorTallerEntity p = proveedor;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Identificación'),
        GestionDetailField(label: 'NIF', value: p.nif),
        GestionDetailField(label: 'Tipo', value: p.tipo.displayName),
        const GestionDetailSection(title: 'Contacto'),
        GestionDetailField(label: 'Persona', value: p.contactoNombre),
        GestionDetailField(
          label: 'Teléfono',
          value: p.telefono == null ? null : GestionFormatters.telefono(p.telefono),
        ),
        GestionDetailField(label: 'Email', value: p.email),
        const GestionDetailSection(title: 'Dirección'),
        GestionDetailField(label: 'Dirección', value: p.direccion),
        GestionDetailField(label: 'C. Postal', value: p.codigoPostal),
        GestionDetailField(label: 'Ciudad', value: p.ciudad),
        GestionDetailField(label: 'Provincia', value: p.provincia),
        const GestionDetailSection(title: 'Facturación'),
        GestionDetailField(label: 'Forma de pago', value: p.formaPago),
        GestionDetailField(label: 'Cuenta bancaria', value: p.cuentaBancaria),
        const GestionDetailSection(title: 'Observaciones'),
        TallerDetailText(p.observaciones),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(p.createdAt)),
        GestionDetailField(
          label: 'Modificado',
          value: p.updatedAt == null ? null : GestionFormatters.fecha(p.updatedAt),
        ),
      ],
    );
  }
}
