import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/widgets/historial/registro_historial_tab.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/widgets/gestion/itv_gestion_columns.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral de la ITV/Revisión seleccionada
class ItvDetailPanel extends StatelessWidget {
  const ItvDetailPanel({
    required this.item,
    required this.todos,
    required this.vehiculos,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final ItvRevisionEntity? item;

  /// Todas las ITV/Revisiones (para el historial del vehículo)
  final List<ItvRevisionEntity> todos;
  final Map<String, VehiculoEntity> vehiculos;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ItvRevisionEntity? i = item;
    if (i == null) {
      return const GestionDetailEmpty(message: 'Selecciona una ITV/Revisión para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(i.id),
      title: '${i.tipo.displayName} · ${itvMatricula(i, vehiculos)}',
      badges: <Widget>[
        GestionDotLabel(label: i.resultado.displayName, color: itvResultadoColor(i.resultado)),
        GestionDotLabel(label: i.estado.displayName, color: itvEstadoColor(i.estado)),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(
          label: 'General',
          child: _ItvGeneralTab(item: i, vehiculo: vehiculos[i.vehiculoId]),
        ),
        GestionDetailTab(label: 'Historial vehículo', child: _ItvHistorialTab(item: i, todos: todos)),
        GestionDetailTab(label: 'Cambios', child: RegistroHistorialTab(tabla: 'titv_revisiones', registroId: i.id)),
      ],
      actions: <Widget>[
        FlotaPanelButton.edit(onPressed: onEdit),
        FlotaPanelButton.delete(onPressed: onDelete),
      ],
    );
  }
}

class _ItvGeneralTab extends StatelessWidget {
  const _ItvGeneralTab({required this.item, required this.vehiculo});

  final ItvRevisionEntity item;
  final VehiculoEntity? vehiculo;

  @override
  Widget build(BuildContext context) {
    final ItvRevisionEntity i = item;
    final VehiculoEntity? v = vehiculo;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Inspección'),
        GestionDetailField(
          label: 'Tipo',
          child: GestionDotLabel(label: i.tipo.displayName, color: itvTipoColor(i.tipo)),
        ),
        GestionDetailField(label: 'Fecha', value: GestionFormatters.fecha(i.fecha)),
        GestionDetailField(label: 'Vencimiento', child: VehiculoFechaVencimiento(fecha: i.fechaVencimiento)),
        GestionDetailField(
          label: 'Resultado',
          child: GestionDotLabel(label: i.resultado.displayName, color: itvResultadoColor(i.resultado)),
        ),
        GestionDetailField(
          label: 'Estado',
          child: GestionDotLabel(label: i.estado.displayName, color: itvEstadoColor(i.estado)),
        ),
        GestionDetailField(label: 'Nº documento', value: i.numeroDocumento),
        const GestionDetailSection(title: 'Vehículo'),
        GestionDetailField(label: 'Matrícula', value: v?.matricula),
        GestionDetailField(label: 'Marca/Modelo', value: v == null ? null : '${v.marca} ${v.modelo}'),
        GestionDetailField(label: 'Tipo', value: v?.tipoVehiculo),
        GestionDetailField(label: 'Km revisión', value: flotaKm(i.kmVehiculo)),
        const GestionDetailSection(title: 'Taller y coste'),
        GestionDetailField(label: 'Taller', value: i.taller),
        GestionDetailField(label: 'Coste total', value: GestionFormatters.moneda(i.costoTotal)),
        const GestionDetailSection(title: 'Observaciones'),
        FlotaNotes(i.observaciones),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(i.createdAt)),
        GestionDetailField(label: 'Modificado', value: GestionFormatters.fecha(i.updatedAt)),
      ],
    );
  }
}

class _ItvHistorialTab extends StatelessWidget {
  const _ItvHistorialTab({required this.item, required this.todos});

  final ItvRevisionEntity item;
  final List<ItvRevisionEntity> todos;

  @override
  Widget build(BuildContext context) {
    final List<ItvRevisionEntity> historial = todos
        .where((ItvRevisionEntity i) => i.vehiculoId == item.vehiculoId)
        .toList()
      ..sort((ItvRevisionEntity a, ItvRevisionEntity b) => b.fecha.compareTo(a.fecha));
    final double coste =
        historial.fold<double>(0, (double s, ItvRevisionEntity i) => s + i.costoTotal);
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Resumen'),
        GestionDetailField(label: 'Registros', value: '${historial.length}'),
        GestionDetailField(label: 'Coste total', value: GestionFormatters.moneda(coste)),
        const GestionDetailSection(title: 'Inspecciones del vehículo'),
        ...historial.map(
          (ItvRevisionEntity i) => FlotaMiniRow(
            leading: GestionFormatters.fecha(i.fecha),
            leadingWidth: 82,
            middle: GestionDotLabel(
              label: '${i.tipo.displayName} · ${i.resultado.displayName}',
              color: itvResultadoColor(i.resultado),
              fontSize: 11.5,
            ),
            trailing: i.id == item.id ? 'Actual' : i.estado.displayName,
          ),
        ),
      ],
    );
  }
}
