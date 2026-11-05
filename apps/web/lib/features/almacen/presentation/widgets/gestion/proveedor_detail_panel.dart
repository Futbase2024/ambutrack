import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/almacen_gestion_common.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/producto_gestion_columns.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Ficha lateral del proveedor del almacén seleccionado
class ProveedorDetailPanel extends StatelessWidget {
  const ProveedorDetailPanel({
    required this.proveedor,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final ProveedorEntity? proveedor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ProveedorEntity? p = proveedor;
    if (p == null) {
      return const GestionDetailEmpty(message: 'Selecciona un proveedor para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(p.id),
      title: p.nombreComercial,
      badges: <Widget>[AlmacenEstadoDot(activo: p.activo)],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _ProveedorGeneralTab(proveedor: p)),
        GestionDetailTab(label: 'Productos', child: _ProveedorProductosTab(proveedorId: p.id)),
      ],
      actions: <Widget>[
        AlmacenDetailEditButton(onPressed: onEdit),
        AlmacenDetailDeleteButton(onPressed: onDelete),
      ],
    );
  }
}

class _ProveedorGeneralTab extends StatelessWidget {
  const _ProveedorGeneralTab({required this.proveedor});

  final ProveedorEntity proveedor;

  @override
  Widget build(BuildContext context) {
    final ProveedorEntity p = proveedor;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Identificación'),
        GestionDetailField(label: 'Código', value: p.codigo),
        GestionDetailField(label: 'Razón social', value: p.razonSocial),
        GestionDetailField(label: 'CIF/NIF', value: p.cifNif),
        const GestionDetailSection(title: 'Contacto'),
        GestionDetailField(label: 'Persona', value: p.personaContacto),
        GestionDetailField(
          label: 'Teléfono',
          value: p.telefono == null ? null : GestionFormatters.telefono(p.telefono),
        ),
        GestionDetailField(label: 'Email', value: p.email),
        GestionDetailField(label: 'Web', value: p.web),
        const GestionDetailSection(title: 'Dirección'),
        GestionDetailField(label: 'Dirección', value: p.direccion),
        GestionDetailField(label: 'C. Postal', value: p.codigoPostal),
        GestionDetailField(label: 'Ciudad', value: p.ciudad),
        GestionDetailField(label: 'Provincia', value: p.provincia),
        GestionDetailField(label: 'País', value: p.pais),
        const GestionDetailSection(title: 'Condiciones comerciales'),
        GestionDetailField(label: 'Cond. de pago', value: p.condicionesPago),
        GestionDetailField(label: 'Descuento', value: '${almacenCantidad(p.descuentoGeneral)} %'),
        const GestionDetailSection(title: 'Observaciones'),
        AlmacenDetailText(p.observaciones),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(
          label: 'Fecha alta',
          value: p.fechaAlta == null ? null : GestionFormatters.fecha(p.fechaAlta),
        ),
        GestionDetailField(label: 'Creado', value: GestionFormatters.fecha(p.createdAt)),
        GestionDetailField(label: 'Modificado', value: GestionFormatters.fecha(p.updatedAt)),
      ],
    );
  }
}

/// Pestaña "Productos": productos que tienen a este proveedor como habitual
class _ProveedorProductosTab extends StatelessWidget {
  const _ProveedorProductosTab({required this.proveedorId});

  final String proveedorId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductoBloc, ProductoState>(
      builder: (BuildContext context, ProductoState state) {
        if (state is! ProductoLoaded) {
          return const Center(
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        final List<ProductoEntity> productos = state.productos
            .where((ProductoEntity p) => p.proveedorHabitualId == proveedorId)
            .toList()
          ..sort((ProductoEntity a, ProductoEntity b) => a.nombre.compareTo(b.nombre));
        return GestionDetailBody(
          children: <Widget>[
            GestionDetailSection(title: 'Proveedor habitual de ${productos.length} productos'),
            if (productos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Ningún producto tiene a este proveedor como habitual',
                  style: TextStyle(fontSize: 12.5, color: AppColors.gray500),
                ),
              )
            else
              ...productos.map((ProductoEntity p) => _ProductoMiniRow(producto: p)),
          ],
        );
      },
    );
  }
}

class _ProductoMiniRow extends StatelessWidget {
  const _ProductoMiniRow({required this.producto});

  final ProductoEntity producto;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              producto.nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gray800),
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: ProductoCategoriaDot(categoria: producto.categoria),
          ),
        ],
      ),
    );
  }
}
