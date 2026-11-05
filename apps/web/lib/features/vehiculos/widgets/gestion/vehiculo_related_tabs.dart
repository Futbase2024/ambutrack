import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_bloc.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_state.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/widgets/gestion/itv_gestion_columns.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_state.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_ui_helpers.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/bloc/documentacion_vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/bloc/documentacion_vehiculos_state.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/widgets/gestion/documentacion_gestion_columns.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const int _maxUltimas = 15;

/// Pestaña "ITV" de la ficha del vehículo: inspecciones y revisiones
class VehiculoItvTab extends StatelessWidget {
  const VehiculoItvTab({required this.vehiculoId, super.key});

  final String vehiculoId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItvRevisionBloc, ItvRevisionState>(
      builder: (BuildContext context, ItvRevisionState state) {
        if (state is ItvRevisionError) {
          return FlotaEmptyNote(state.message);
        }
        if (state is! ItvRevisionLoaded) {
          return const FlotaTabLoading();
        }
        final List<ItvRevisionEntity> items = state.itvRevisiones
            .where((ItvRevisionEntity i) => i.vehiculoId == vehiculoId)
            .toList()
          ..sort((ItvRevisionEntity a, ItvRevisionEntity b) => b.fecha.compareTo(a.fecha));
        final ItvRevisionEntity? ultima = items.isEmpty ? null : items.first;
        return GestionDetailBody(
          children: <Widget>[
            const GestionDetailSection(title: 'Resumen'),
            GestionDetailField(label: 'Registros', value: '${items.length}'),
            GestionDetailField(label: 'Última', value: _fecha(ultima?.fecha)),
            GestionDetailField(label: 'Resultado', value: ultima?.resultado.displayName),
            GestionDetailField(label: 'Vence', value: _fecha(ultima?.fechaVencimiento)),
            GestionDetailSection(title: _titulo('Historial', items.length)),
            if (items.isEmpty)
              const FlotaEmptyNote('Este vehículo no tiene ITV ni revisiones registradas')
            else
              ...items.take(_maxUltimas).map(
                    (ItvRevisionEntity i) => FlotaMiniRow(
                      leading: GestionFormatters.fecha(i.fecha),
                      leadingWidth: 82,
                      middle: GestionDotLabel(
                        label: '${i.tipo.displayName} · ${i.resultado.displayName}',
                        color: itvResultadoColor(i.resultado),
                        fontSize: 11.5,
                      ),
                      trailing: i.estado.displayName,
                    ),
                  ),
          ],
        );
      },
    );
  }
}

/// Pestaña "Documentos" de la ficha del vehículo: seguros, permisos, etc.
class VehiculoDocumentosTab extends StatelessWidget {
  const VehiculoDocumentosTab({required this.vehiculoId, super.key});

  final String vehiculoId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentacionVehiculosBloc, DocumentacionVehiculosState>(
      builder: (BuildContext context, DocumentacionVehiculosState state) {
        if (state is DocumentacionVehiculosError) {
          return FlotaEmptyNote(state.message);
        }
        if (state is! DocumentacionVehiculosLoaded) {
          return const FlotaTabLoading();
        }
        final List<DocumentacionVehiculoEntity> docs = state.documentos
            .where((DocumentacionVehiculoEntity d) => d.vehiculoId == vehiculoId)
            .toList()
          ..sort((DocumentacionVehiculoEntity a, DocumentacionVehiculoEntity b) =>
              a.fechaVencimiento.compareTo(b.fechaVencimiento));
        int count(String e) => docs.where((DocumentacionVehiculoEntity d) => d.estado == e).length;
        return GestionDetailBody(
          children: <Widget>[
            const GestionDetailSection(title: 'Resumen'),
            GestionDetailField(label: 'Documentos', value: '${docs.length}'),
            GestionDetailField(label: 'Vigentes', value: '${count('vigente')}'),
            GestionDetailField(label: 'Próx. a vencer', value: '${count('proxima_vencer')}'),
            GestionDetailField(label: 'Vencidos', value: '${count('vencida') + count('vencido')}'),
            const GestionDetailSection(title: 'Documentos'),
            if (docs.isEmpty)
              const FlotaEmptyNote('Este vehículo no tiene documentación registrada')
            else
              ...docs.map(
                (DocumentacionVehiculoEntity d) => FlotaMiniRow(
                  leading: docTipoLabel(d),
                  leadingWidth: 120,
                  middle: GestionDotLabel(
                    label: docEstadoLabel(d.estado),
                    color: docEstadoColor(d.estado),
                    fontSize: 11.5,
                  ),
                  trailing: GestionFormatters.fecha(d.fechaVencimiento),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Pestaña "Reparaciones" de la ficha del vehículo: órdenes de reparación de taller
class VehiculoReparacionesTab extends StatelessWidget {
  const VehiculoReparacionesTab({required this.vehiculoId, super.key});

  final String vehiculoId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdenReparacionBloc, OrdenReparacionState>(
      builder: (BuildContext context, OrdenReparacionState state) {
        if (state is OrdenReparacionError) {
          return FlotaEmptyNote(state.message);
        }
        if (state is! OrdenReparacionLoaded) {
          return const FlotaTabLoading();
        }
        final List<OrdenReparacionEntity> ordenes = state.ordenes
            .where((OrdenReparacionEntity o) => o.vehiculoId == vehiculoId)
            .toList()
          ..sort((OrdenReparacionEntity a, OrdenReparacionEntity b) =>
              b.fechaEntrada.compareTo(a.fechaEntrada));
        final List<OrdenReparacionEntity> validas = ordenes
            .where((OrdenReparacionEntity o) => o.estado != EstadoOrdenReparacion.anulada)
            .toList();
        final double importe =
            validas.fold<double>(0, (double s, OrdenReparacionEntity o) => s + o.costoTotal);
        return GestionDetailBody(
          children: <Widget>[
            const GestionDetailSection(title: 'Actividad'),
            GestionDetailField(
              label: 'Abiertas',
              value: '${ordenes.where((OrdenReparacionEntity o) => o.estado.isActiva).length}',
            ),
            GestionDetailField(label: 'Total histórico', value: '${ordenes.length}'),
            GestionDetailField(label: 'Importe total', value: GestionFormatters.moneda(importe)),
            GestionDetailField(
              label: 'Última entrada',
              value: ordenes.isEmpty ? null : GestionFormatters.fecha(ordenes.first.fechaEntrada),
            ),
            GestionDetailSection(title: _titulo('Órdenes', ordenes.length)),
            if (ordenes.isEmpty)
              const FlotaEmptyNote('Este vehículo no tiene órdenes de reparación')
            else
              ...ordenes.take(_maxUltimas).map(
                    (OrdenReparacionEntity o) => FlotaMiniRow(
                      leading: o.numeroOrden.isEmpty ? GestionFormatters.vacio : o.numeroOrden,
                      middle: GestionDotLabel(
                        label: o.estado.displayName,
                        color: estadoOrdenColor(o.estado),
                        fontSize: 11.5,
                      ),
                      trailing: GestionFormatters.fecha(o.fechaEntrada),
                    ),
                  ),
          ],
        );
      },
    );
  }
}

String? _fecha(DateTime? f) => f == null ? null : GestionFormatters.fecha(f);

String _titulo(String base, int total) =>
    total > _maxUltimas ? 'Últimos $_maxUltimas de $total' : base;
