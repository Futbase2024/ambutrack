import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart' hide MovimientoStockEntity;
// ignore: implementation_imports
import 'package:ambutrack_core_datasource/src/datasources/almacen/entities/movimiento_stock_entity.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/almacen_gestion_common.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/movimiento_gestion_columns.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/movimiento_lookups.dart';
import 'package:flutter/material.dart';

/// Identificador abreviado (8 primeros caracteres) o null
String? _idCorto(String? id) => id == null || id.length <= 8 ? id : '${id.substring(0, 8)}…';

/// Nombre resuelto o, si aún no se conoce, el identificador abreviado
String? _nombreOId(String? nombre, String? id) => nombre == null || nombre == id ? _idCorto(id) : nombre;

/// Ficha lateral (solo lectura) del movimiento de stock seleccionado
class MovimientoDetailPanel extends StatelessWidget {
  const MovimientoDetailPanel({required this.movimiento, required this.producto, super.key});

  final MovimientoStockEntity? movimiento;
  final ProductoEntity? producto;

  @override
  Widget build(BuildContext context) {
    final MovimientoStockEntity? m = movimiento;
    if (m == null) {
      return const GestionDetailEmpty(message: 'Selecciona un movimiento para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(m.id),
      title: producto?.nombre ?? 'Movimiento de stock',
      badges: <Widget>[
        GestionDotLabel(label: m.tipo.label, color: movimientoTipoColor(m.tipo)),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(
          label: 'General',
          child: _MovimientoGeneralTab(movimiento: m, producto: producto),
        ),
      ],
    );
  }
}

class _MovimientoGeneralTab extends StatefulWidget {
  const _MovimientoGeneralTab({required this.movimiento, required this.producto});

  final MovimientoStockEntity movimiento;
  final ProductoEntity? producto;

  @override
  State<_MovimientoGeneralTab> createState() => _MovimientoGeneralTabState();
}

class _MovimientoGeneralTabState extends State<_MovimientoGeneralTab> {
  MovimientoNombres _nombres = const MovimientoNombres();

  @override
  void initState() {
    super.initState();
    _resolver();
  }

  @override
  void didUpdateWidget(covariant _MovimientoGeneralTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.movimiento.id != widget.movimiento.id) {
      _nombres = const MovimientoNombres();
      _resolver();
    }
  }

  Future<void> _resolver() async {
    final String id = widget.movimiento.id;
    final MovimientoNombres nombres = await MovimientoLookups.resolve(widget.movimiento);
    if (mounted && widget.movimiento.id == id) {
      setState(() => _nombres = nombres);
    }
  }

  @override
  Widget build(BuildContext context) {
    final MovimientoStockEntity m = widget.movimiento;
    final ProductoEntity? p = widget.producto;
    final MovimientoNombres n = _nombres;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Movimiento'),
        GestionDetailField(label: 'Tipo', value: m.tipo.label),
        GestionDetailField(label: 'Fecha', value: movimientoFechaHora(m.createdAt)),
        GestionDetailField(
          label: 'Cantidad',
          child: Text(
            movimientoCantidadConSigno(m),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: movimientoCantidadColor(m.tipo),
            ),
          ),
        ),
        GestionDetailField(
          label: 'Stock anterior',
          value: m.cantidadAnterior == null ? null : almacenCantidad(m.cantidadAnterior!),
        ),
        GestionDetailField(
          label: 'Stock nuevo',
          value: m.cantidadNueva == null ? null : almacenCantidad(m.cantidadNueva!),
        ),
        const GestionDetailSection(title: 'Producto'),
        GestionDetailField(label: 'Nombre', value: p?.nombre),
        GestionDetailField(label: 'Código', value: p?.codigo),
        GestionDetailField(label: 'Categoría', value: p?.categoria?.label),
        GestionDetailField(label: 'Unidad', value: p?.unidadMedida),
        const GestionDetailSection(title: 'Trazabilidad'),
        GestionDetailField(label: 'Lote', value: m.lote),
        GestionDetailField(label: 'Nº serie', value: m.numeroSerie),
        GestionDetailField(label: 'Referencia', value: m.referencia),
        GestionDetailField(label: 'Servicio', value: _nombreOId(n.servicio, m.idServicio)),
        const GestionDetailSection(title: 'Almacenes'),
        GestionDetailField(label: 'Origen', value: _nombreOId(n.almacenOrigen, m.idAlmacenOrigen)),
        GestionDetailField(label: 'Destino', value: _nombreOId(n.almacenDestino, m.idAlmacenDestino)),
        const GestionDetailSection(title: 'Motivo'),
        AlmacenDetailText(m.motivo),
        const GestionDetailSection(title: 'Observaciones'),
        AlmacenDetailText(m.observaciones),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Usuario', value: _nombreOId(n.usuario, m.usuarioId)),
      ],
    );
  }
}
