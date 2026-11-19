import 'dart:async';
import 'dart:math' as math;

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_bloc.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_event.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_state.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_state.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/bloc/documentacion_vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/bloc/documentacion_vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/bloc/documentacion_vehiculos_state.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/domain/repositories/equipamiento_vehiculo_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Todos los datos de un vehículo necesarios para su ficha exportable
class VehiculoFichaData {
  const VehiculoFichaData({
    required this.vehiculo,
    required this.itv,
    required this.documentos,
    required this.ordenes,
    required this.dotacion,
  });

  final VehiculoEntity vehiculo;
  final List<ItvRevisionEntity> itv;
  final List<DocumentacionVehiculoEntity> documentos;
  final List<OrdenReparacionEntity> ordenes;
  final List<StockVehiculoEntity> dotacion;
}

/// Reúne ITV, documentación, reparaciones y dotación de uno o varios vehículos.
///
/// ITV, documentos y órdenes salen de los BLoCs de la pantalla (ya en memoria);
/// la dotación se pide al repositorio, varias peticiones en paralelo.
class VehiculoFichaLoader {
  VehiculoFichaLoader.of(BuildContext context)
      : _itvBloc = context.read<ItvRevisionBloc>(),
        _docBloc = context.read<DocumentacionVehiculosBloc>(),
        _ordenBloc = context.read<OrdenReparacionBloc>();

  final ItvRevisionBloc _itvBloc;
  final DocumentacionVehiculosBloc _docBloc;
  final OrdenReparacionBloc _ordenBloc;

  static const Duration _timeout = Duration(seconds: 30);
  static const int _paralelo = 6;

  Future<List<VehiculoFichaData>> cargar(
    List<VehiculoEntity> vehiculos, {
    ValueChanged<double>? onProgress,
  }) async {
    debugPrint('📦 VehiculoFichaLoader: cargando ${vehiculos.length} ficha(s)');
    final List<Object> listas = await Future.wait(<Future<Object>>[
      _itv(),
      _documentos(),
      _ordenes(),
    ]);
    final List<ItvRevisionEntity> itv = listas[0] as List<ItvRevisionEntity>;
    final List<DocumentacionVehiculoEntity> docs = listas[1] as List<DocumentacionVehiculoEntity>;
    final List<OrdenReparacionEntity> ordenes = listas[2] as List<OrdenReparacionEntity>;
    final Map<String, List<StockVehiculoEntity>> dotaciones = await _dotaciones(vehiculos, onProgress);

    return vehiculos.map((VehiculoEntity v) {
      return VehiculoFichaData(
        vehiculo: v,
        itv: itv.where((ItvRevisionEntity i) => i.vehiculoId == v.id).toList()
          ..sort((ItvRevisionEntity a, ItvRevisionEntity b) => b.fecha.compareTo(a.fecha)),
        documentos: docs.where((DocumentacionVehiculoEntity d) => d.vehiculoId == v.id).toList()
          ..sort((DocumentacionVehiculoEntity a, DocumentacionVehiculoEntity b) =>
              a.fechaVencimiento.compareTo(b.fechaVencimiento)),
        ordenes: ordenes.where((OrdenReparacionEntity o) => o.vehiculoId == v.id).toList()
          ..sort((OrdenReparacionEntity a, OrdenReparacionEntity b) => b.fechaEntrada.compareTo(a.fechaEntrada)),
        dotacion: dotaciones[v.id] ?? const <StockVehiculoEntity>[],
      );
    }).toList();
  }

  Future<List<ItvRevisionEntity>> _itv() {
    return _esperar<ItvRevisionState, List<ItvRevisionEntity>>(
      _itvBloc,
      (ItvRevisionState s) => switch (s) {
        ItvRevisionLoaded() => s.itvRevisiones,
        ItvRevisionError() => throw Exception('ITV: ${s.message}'),
        _ => null,
      },
      () => _itvBloc.add(const ItvRevisionLoadRequested()),
    );
  }

  Future<List<DocumentacionVehiculoEntity>> _documentos() {
    return _esperar<DocumentacionVehiculosState, List<DocumentacionVehiculoEntity>>(
      _docBloc,
      (DocumentacionVehiculosState s) => switch (s) {
        DocumentacionVehiculosLoaded() => s.documentos,
        DocumentacionVehiculosError() => throw Exception('Documentación: ${s.message}'),
        _ => null,
      },
      () => _docBloc.add(const DocumentacionVehiculosLoadRequested()),
    );
  }

  Future<List<OrdenReparacionEntity>> _ordenes() {
    return _esperar<OrdenReparacionState, List<OrdenReparacionEntity>>(
      _ordenBloc,
      (OrdenReparacionState s) => switch (s) {
        OrdenReparacionLoaded() => s.ordenes,
        OrdenReparacionError() => throw Exception('Reparaciones: ${s.message}'),
        _ => null,
      },
      () => _ordenBloc.add(const OrdenReparacionLoadRequested(silent: true)),
    );
  }

  /// Devuelve el dato del estado actual o espera al primer estado cargado
  static Future<T> _esperar<S, T>(BlocBase<S> bloc, T? Function(S) extraer, VoidCallback cargar) async {
    final T? actual = extraer(bloc.state);
    if (actual != null) {
      return actual;
    }
    cargar();
    final S listo = await bloc.stream.firstWhere((S s) => extraer(s) != null).timeout(_timeout);
    return extraer(listo) as T;
  }

  Future<Map<String, List<StockVehiculoEntity>>> _dotaciones(
    List<VehiculoEntity> vehiculos,
    ValueChanged<double>? onProgress,
  ) async {
    final EquipamientoVehiculoRepository repo = getIt<EquipamientoVehiculoRepository>();
    final Map<String, List<StockVehiculoEntity>> result = <String, List<StockVehiculoEntity>>{};
    for (int i = 0; i < vehiculos.length; i += _paralelo) {
      final List<VehiculoEntity> lote = vehiculos.sublist(i, math.min(i + _paralelo, vehiculos.length));
      await Future.wait(
        lote.map((VehiculoEntity v) async => result[v.id] = await repo.getDotacion(v.id)),
      );
      onProgress?.call(result.length / vehiculos.length);
    }
    return result;
  }
}
