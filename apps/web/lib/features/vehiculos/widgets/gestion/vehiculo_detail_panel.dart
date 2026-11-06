import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_gestion_columns.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_related_tabs.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_stock_tab.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del vehículo seleccionado
class VehiculoDetailPanel extends StatelessWidget {
  const VehiculoDetailPanel({
    required this.vehiculo,
    required this.onEdit,
    required this.onDelete,
    required this.onStock,
    super.key,
  });

  final VehiculoEntity? vehiculo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onStock;

  @override
  Widget build(BuildContext context) {
    final VehiculoEntity? v = vehiculo;
    if (v == null) {
      return const GestionDetailEmpty(message: 'Selecciona un vehículo para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(v.id),
      title: '${v.matricula} · ${v.marca} ${v.modelo}',
      badges: <Widget>[
        VehiculoEstadoDot(estado: v.estado),
        GestionDotLabel(label: GestionFormatters.texto(v.tipoVehiculo), color: vehiculoTipoColor),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _VehiculoGeneralTab(vehiculo: v)),
        GestionDetailTab(label: 'ITV', child: VehiculoItvTab(vehiculoId: v.id)),
        GestionDetailTab(label: 'Documentos', child: VehiculoDocumentosTab(vehiculoId: v.id)),
        GestionDetailTab(label: 'Reparaciones', child: VehiculoReparacionesTab(vehiculoId: v.id)),
        GestionDetailTab(
          label: 'Equipamiento',
          child: VehiculoStockTab(vehiculoId: v.id, onOpenStock: onStock),
        ),
      ],
      actions: <Widget>[
        FlotaPanelButton.edit(onPressed: onEdit),
        FlotaPanelButton.delete(onPressed: onDelete),
      ],
    );
  }
}

class _VehiculoGeneralTab extends StatelessWidget {
  const _VehiculoGeneralTab({required this.vehiculo});

  final VehiculoEntity vehiculo;

  @override
  Widget build(BuildContext context) {
    final VehiculoEntity v = vehiculo;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Identificación'),
        GestionDetailField(label: 'Matrícula', value: v.matricula),
        GestionDetailField(label: 'Nº interno', value: v.numeroInterno),
        GestionDetailField(label: 'Alias', value: v.alias),
        GestionDetailField(label: 'Bastidor', value: v.numeroBastidor),
        const GestionDetailSection(title: 'Vehículo'),
        GestionDetailField(label: 'Marca', value: v.marca),
        GestionDetailField(label: 'Modelo', value: v.modelo),
        GestionDetailField(label: 'Año', value: '${v.anioFabricacion}'),
        GestionDetailField(label: 'Tipo', value: v.tipoVehiculo),
        GestionDetailField(label: 'Categoría', value: v.categoria),
        GestionDetailField(label: 'Clasificación', value: v.clasificacion),
        GestionDetailField(label: 'Pasajeros', value: v.capacidadPasajeros?.toString()),
        GestionDetailField(label: 'Camillas', value: v.capacidadCamilla?.toString()),
        const GestionDetailSection(title: 'Uso'),
        GestionDetailField(label: 'Km actual', value: _opt(flotaKm(v.kmActual))),
        GestionDetailField(label: 'Ubicación', value: v.ubicacionActual),
        GestionDetailField(label: 'Adquisición', value: _fecha(v.fechaAdquisicion)),
        const GestionDetailSection(title: 'Vencimientos'),
        GestionDetailField(label: 'Próxima ITV', child: VehiculoFechaVencimiento(fecha: v.proximaItv)),
        GestionDetailField(
          label: 'Seguro',
          child: VehiculoFechaVencimiento(fecha: v.fechaVencimientoSeguro),
        ),
        GestionDetailField(label: 'Homologación', value: v.homologacionSanitaria),
        GestionDetailField(
          label: 'Venc. homolog.',
          child: VehiculoFechaVencimiento(fecha: v.fechaVencimientoHomologacion),
        ),
        const GestionDetailSection(title: 'Mantenimiento'),
        GestionDetailField(label: 'Último', value: _fecha(v.ultimoMantenimiento)),
        GestionDetailField(label: 'Próximo', value: _fecha(v.proximoMantenimiento)),
        GestionDetailField(label: 'Km próximo', value: _opt(flotaKm(v.kmProximoMantenimiento))),
        ..._equipamiento(v.equipamiento),
        const GestionDetailSection(title: 'Observaciones'),
        FlotaNotes(v.observaciones),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(v.createdAt)),
        GestionDetailField(label: 'Modificado', value: GestionFormatters.fecha(v.updatedAt)),
      ],
    );
  }

  static String? _fecha(DateTime? f) => f == null ? null : GestionFormatters.fecha(f);

  static String? _opt(String s) => s == GestionFormatters.vacio ? null : s;

  static List<Widget> _equipamiento(Map<String, dynamic>? equipamiento) {
    if (equipamiento == null || equipamiento.isEmpty) {
      return const <Widget>[];
    }
    return <Widget>[
      const GestionDetailSection(title: 'Equipamiento'),
      for (final MapEntry<String, dynamic> e in equipamiento.entries)
        GestionDetailField(label: e.key, value: e.value?.toString()),
    ];
  }
}
