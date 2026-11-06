import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/widgets/gestion/mantenimiento_gestion_columns.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del mantenimiento seleccionado
class MantenimientoDetailPanel extends StatelessWidget {
  const MantenimientoDetailPanel({
    required this.item,
    required this.todos,
    required this.vehiculos,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final MantenimientoEntity? item;

  /// Todos los mantenimientos (para el historial del vehículo)
  final List<MantenimientoEntity> todos;
  final Map<String, VehiculoEntity> vehiculos;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final MantenimientoEntity? m = item;
    if (m == null) {
      return const GestionDetailEmpty(message: 'Selecciona un mantenimiento para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(m.id),
      title: '${m.tipoMantenimiento.displayName} · ${mantMatricula(m, vehiculos)}',
      badges: <Widget>[
        GestionDotLabel(label: m.estado.displayName, color: mantEstadoColor(m.estado)),
        if (mantVencido(m)) const GestionDotLabel(label: 'Vencido', color: AppColors.error),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(
          label: 'General',
          child: _MantGeneralTab(item: m, vehiculo: vehiculos[m.vehiculoId]),
        ),
        GestionDetailTab(label: 'Historial vehículo', child: _MantHistorialTab(item: m, todos: todos)),
      ],
      actions: <Widget>[
        FlotaPanelButton.edit(onPressed: onEdit),
        FlotaPanelButton.delete(onPressed: onDelete),
      ],
    );
  }
}

class _MantGeneralTab extends StatelessWidget {
  const _MantGeneralTab({required this.item, required this.vehiculo});

  final MantenimientoEntity item;
  final VehiculoEntity? vehiculo;

  @override
  Widget build(BuildContext context) {
    final MantenimientoEntity m = item;
    final VehiculoEntity? v = vehiculo;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Mantenimiento'),
        GestionDetailField(
          label: 'Tipo',
          child: GestionDotLabel(
            label: m.tipoMantenimiento.displayName,
            color: mantTipoColor(m.tipoMantenimiento),
          ),
        ),
        GestionDetailField(label: 'Fecha', value: GestionFormatters.fecha(m.fecha)),
        GestionDetailField(label: 'Programada', value: GestionFormatters.fecha(m.fechaProgramada)),
        GestionDetailField(label: 'Inicio', value: GestionFormatters.fecha(m.fechaInicio)),
        GestionDetailField(label: 'Fin', value: GestionFormatters.fecha(m.fechaFin)),
        GestionDetailField(label: 'Nº orden', value: m.numeroOrden),
        const GestionDetailSection(title: 'Vehículo'),
        GestionDetailField(label: 'Matrícula', value: v?.matricula),
        GestionDetailField(label: 'Marca/Modelo', value: v == null ? null : '${v.marca} ${v.modelo}'),
        GestionDetailField(label: 'Km', value: flotaKm(m.kmVehiculo)),
        const GestionDetailSection(title: 'Trabajo'),
        GestionDetailField(label: 'Descripción', value: m.descripcion),
        GestionDetailField(label: 'Taller', value: m.taller),
        GestionDetailField(label: 'Mecánico', value: m.mecanicoResponsable),
        GestionDetailField(label: 'Inoperativo', value: flotaDecimal(m.tiempoInoperativoHoras, sufijo: ' h')),
        const GestionDetailSection(title: 'Trabajos realizados'),
        FlotaNotes(m.trabajosRealizados),
        const GestionDetailSection(title: 'Costes'),
        GestionDetailField(label: 'Mano de obra', value: flotaMoneda(m.costoManoObra)),
        GestionDetailField(label: 'Repuestos', value: flotaMoneda(m.costoRepuestos)),
        GestionDetailField(label: 'Total', value: GestionFormatters.moneda(m.costoTotal)),
        const GestionDetailSection(title: 'Próximo mantenimiento'),
        GestionDetailField(label: 'Km sugerido', value: flotaKm(m.proximoKmSugerido)),
        GestionDetailField(label: 'Fecha sugerida', value: GestionFormatters.fecha(m.proximaFechaSugerida)),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(m.createdAt)),
        GestionDetailField(label: 'Modificado', value: GestionFormatters.fecha(m.updatedAt)),
      ],
    );
  }
}

class _MantHistorialTab extends StatelessWidget {
  const _MantHistorialTab({required this.item, required this.todos});

  final MantenimientoEntity item;
  final List<MantenimientoEntity> todos;

  @override
  Widget build(BuildContext context) {
    final List<MantenimientoEntity> historial = todos
        .where((MantenimientoEntity m) => m.vehiculoId == item.vehiculoId)
        .toList()
      ..sort((MantenimientoEntity a, MantenimientoEntity b) => mantFechaRef(b).compareTo(mantFechaRef(a)));
    final double coste = historial.fold<double>(0, (double s, MantenimientoEntity m) => s + m.costoTotal);
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Resumen'),
        GestionDetailField(label: 'Registros', value: '${historial.length}'),
        GestionDetailField(label: 'Coste total', value: GestionFormatters.moneda(coste)),
        const GestionDetailSection(title: 'Mantenimientos del vehículo'),
        ...historial.map(
          (MantenimientoEntity m) => FlotaMiniRow(
            leading: GestionFormatters.fecha(mantFechaRef(m)),
            leadingWidth: 82,
            middle: GestionDotLabel(
              label: '${m.tipoMantenimiento.displayName} · ${m.estado.displayName}',
              color: mantEstadoColor(m.estado),
              fontSize: 11.5,
            ),
            trailing: m.id == item.id ? 'Actual' : GestionFormatters.moneda(m.costoTotal),
          ),
        ),
      ],
    );
  }
}
