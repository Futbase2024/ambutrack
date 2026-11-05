import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/mantenimiento/domain/repositories/mantenimiento_repository.dart';
import 'package:ambutrack_web/features/taller/domain/repositories/orden_reparacion_repository.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/alerta_mantenimiento.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/alertas_mantenimiento_calculator.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/alertas_mantenimiento_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/alertas_mantenimiento_state.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/vehiculo_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC que calcula las alertas de mantenimiento a partir de vehículos,
/// órdenes de reparación, repuestos y mantenimientos programados
@injectable
class AlertasMantenimientoBloc extends Bloc<AlertasMantenimientoEvent, AlertasMantenimientoState> {
  AlertasMantenimientoBloc(this._vehiculos, this._ordenes, this._mantenimientos)
      : super(const AlertasMantenimientoInitial()) {
    on<AlertasMantenimientoLoadRequested>(_onLoadRequested);
  }

  final VehiculoRepository _vehiculos;
  final OrdenReparacionRepository _ordenes;
  final MantenimientoRepository _mantenimientos;

  /// Ejecuta [load] y devuelve null (registrando la fuente) si falla
  Future<T?> _safe<T>(String fuente, List<String> errores, Future<T> Function() load) async {
    try {
      return await load();
    } catch (e) {
      debugPrint('⚠️ AlertasMantenimientoBloc: No se pudo cargar $fuente: $e');
      errores.add(fuente);
      return null;
    }
  }

  Future<List<MantenimientoEntity>> _loadMantenimientos() async {
    final List<Either<Exception, List<MantenimientoEntity>>> results =
        await Future.wait(<Future<Either<Exception, List<MantenimientoEntity>>>>[
      _mantenimientos.getVencidos(),
      _mantenimientos.getProximos(AlertasMantenimientoCalculator.diasProximo),
    ]);
    final Map<String, MantenimientoEntity> porId = <String, MantenimientoEntity>{};
    for (final Either<Exception, List<MantenimientoEntity>> r in results) {
      final List<MantenimientoEntity> lista = r.fold((Exception e) => throw e, (List<MantenimientoEntity> l) => l);
      for (final MantenimientoEntity m in lista) {
        porId[m.id] = m;
      }
    }
    return porId.values.toList();
  }

  Future<void> _onLoadRequested(
    AlertasMantenimientoLoadRequested event,
    Emitter<AlertasMantenimientoState> emit,
  ) async {
    debugPrint('🔔 AlertasMantenimientoBloc: Calculando alertas');
    emit(const AlertasMantenimientoLoading());
    final List<String> errores = <String>[];
    final List<Object?> r = await Future.wait<Object?>(<Future<Object?>>[
      _safe('vehículos', errores, _vehiculos.getAll),
      _safe('órdenes de reparación', errores, _ordenes.getAll),
      _safe('repuestos', errores, _ordenes.getAllRepuestos),
      _safe('mantenimientos', errores, _loadMantenimientos),
    ]);
    if (errores.length == r.length) {
      emit(const AlertasMantenimientoError(message: 'No se pudo cargar ninguna fuente de datos.'));
      return;
    }
    final List<VehiculoEntity> vehiculos = r[0] as List<VehiculoEntity>? ?? <VehiculoEntity>[];
    final List<OrdenReparacionEntity> ordenes = r[1] as List<OrdenReparacionEntity>? ?? <OrdenReparacionEntity>[];
    final List<RepuestoOrdenEntity> repuestos = r[2] as List<RepuestoOrdenEntity>? ?? <RepuestoOrdenEntity>[];
    final List<MantenimientoEntity> mants = r[3] as List<MantenimientoEntity>? ?? <MantenimientoEntity>[];

    final AlertasMantenimientoCalculator calc = AlertasMantenimientoCalculator();
    final List<AlertaMantenimiento> alertas = <AlertaMantenimiento>[
      ...calc.vehiculos(vehiculos),
      ...calc.ordenes(ordenes),
      ...calc.repuestos(repuestos, <String, OrdenReparacionEntity>{
        for (final OrdenReparacionEntity o in ordenes) o.id: o,
      }),
      ...calc.mantenimientos(mants, <String, String>{
        for (final VehiculoEntity v in vehiculos) v.id: v.matricula,
      }),
    ]..sort((AlertaMantenimiento a, AlertaMantenimiento b) {
        final int bySeveridad = a.severidad.index.compareTo(b.severidad.index);
        return bySeveridad != 0 ? bySeveridad : a.urgencia.compareTo(b.urgencia);
      });
    debugPrint('✅ AlertasMantenimientoBloc: ${alertas.length} alertas (errores: $errores)');
    emit(AlertasMantenimientoLoaded(alertas: alertas, fuentesConError: errores));
  }
}
