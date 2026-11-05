import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/averia_gestion_columns.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:flutter/material.dart';

/// Ficha lateral de la avería seleccionada
class AveriaDetailPanel extends StatelessWidget {
  const AveriaDetailPanel({
    required this.incidencia,
    required this.vehiculos,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final IncidenciaVehiculoEntity? incidencia;
  final Map<String, VehiculoEntity> vehiculos;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final IncidenciaVehiculoEntity? i = incidencia;
    if (i == null) {
      return const GestionDetailEmpty(message: 'Selecciona una avería para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(i.id),
      title: i.titulo,
      badges: <Widget>[
        GestionDotLabel(label: i.estado.nombre, color: averiaEstadoColor(i.estado)),
        GestionDotLabel(
          label: 'Prioridad ${i.prioridad.nombre.toLowerCase()}',
          color: averiaPrioridadColor(i.prioridad),
        ),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(
          label: 'General',
          child: _AveriaGeneralTab(incidencia: i, vehiculo: vehiculos[i.vehiculoId]),
        ),
        GestionDetailTab(label: 'Resolución', child: _AveriaResolucionTab(incidencia: i)),
      ],
      actions: <Widget>[
        FlotaPanelButton.edit(onPressed: onEdit),
        FlotaPanelButton.delete(onPressed: onDelete),
      ],
    );
  }
}

class _AveriaGeneralTab extends StatelessWidget {
  const _AveriaGeneralTab({required this.incidencia, required this.vehiculo});

  final IncidenciaVehiculoEntity incidencia;
  final VehiculoEntity? vehiculo;

  @override
  Widget build(BuildContext context) {
    final IncidenciaVehiculoEntity i = incidencia;
    final VehiculoEntity? v = vehiculo;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Incidencia'),
        GestionDetailField(label: 'Tipo', value: i.tipo.nombre),
        GestionDetailField(
          label: 'Prioridad',
          child: GestionDotLabel(label: i.prioridad.nombre, color: averiaPrioridadColor(i.prioridad)),
        ),
        GestionDetailField(
          label: 'Estado',
          child: GestionDotLabel(label: i.estado.nombre, color: averiaEstadoColor(i.estado)),
        ),
        GestionDetailField(label: 'Fecha reporte', value: GestionFormatters.fecha(i.fechaReporte)),
        GestionDetailField(label: 'Reportado por', value: i.reportadoPorNombre),
        const GestionDetailSection(title: 'Vehículo'),
        GestionDetailField(label: 'Matrícula', value: v?.matricula ?? i.vehiculoId),
        GestionDetailField(label: 'Marca/Modelo', value: v == null ? null : '${v.marca} ${v.modelo}'),
        GestionDetailField(
          label: 'Km reporte',
          value: i.kilometrajeReporte == null ? null : flotaKm(i.kilometrajeReporte),
        ),
        GestionDetailField(label: 'Ubicación', value: i.ubicacionReporte),
        GestionDetailField(label: 'Fotos', value: '${i.fotosUrls?.length ?? 0}'),
        const GestionDetailSection(title: 'Descripción'),
        FlotaNotes(i.descripcion),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(i.createdAt)),
        GestionDetailField(
          label: 'Modificado',
          value: i.updatedAt == null ? null : GestionFormatters.fecha(i.updatedAt),
        ),
      ],
    );
  }
}

class _AveriaResolucionTab extends StatelessWidget {
  const _AveriaResolucionTab({required this.incidencia});

  final IncidenciaVehiculoEntity incidencia;

  @override
  Widget build(BuildContext context) {
    final IncidenciaVehiculoEntity i = incidencia;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Asignación'),
        GestionDetailField(label: 'Asignado a', value: i.asignadoA),
        GestionDetailField(
          label: 'Fecha asignación',
          value: i.fechaAsignacion == null ? null : GestionFormatters.fecha(i.fechaAsignacion),
        ),
        GestionDetailField(label: 'Taller', value: i.tallerResponsable),
        const GestionDetailSection(title: 'Resolución'),
        GestionDetailField(
          label: 'Fecha resolución',
          value: i.fechaResolucion == null ? null : GestionFormatters.fecha(i.fechaResolucion),
        ),
        GestionDetailField(
          label: 'Coste',
          value: i.costoReparacion == null ? null : flotaMoneda(i.costoReparacion),
        ),
        const GestionDetailSection(title: 'Solución aplicada'),
        FlotaNotes(i.solucionAplicada),
      ],
    );
  }
}
