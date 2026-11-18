import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../registro_horario/domain/repositories/registro_horario_repository.dart';
import '../../../servicios/domain/repositories/traslados_repository.dart';
import '../../domain/resumen_parte_diario.dart';

/// Estado del parte diario de un día concreto
sealed class ParteDiarioState extends Equatable {
  const ParteDiarioState(this.dia);

  final DateTime dia;

  @override
  List<Object?> get props => <Object?>[dia];
}

final class ParteDiarioLoading extends ParteDiarioState {
  const ParteDiarioLoading(super.dia);
}

final class ParteDiarioLoaded extends ParteDiarioState {
  const ParteDiarioLoaded({
    required DateTime dia,
    required this.fichajes,
    required this.traslados,
    required this.resumen,
  }) : super(dia);

  final List<RegistroHorarioEntity> fichajes;
  final List<TrasladoEntity> traslados;
  final ResumenParteDiario resumen;

  @override
  List<Object?> get props => <Object?>[dia, fichajes, traslados, resumen];
}

final class ParteDiarioError extends ParteDiarioState {
  const ParteDiarioError(super.dia, this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[dia, message];
}

/// Carga los fichajes y servicios del trabajador para el día elegido
class ParteDiarioCubit extends Cubit<ParteDiarioState> {
  ParteDiarioCubit({
    required TrasladosRepository trasladosRepository,
    required RegistroHorarioRepository registroRepository,
    required String personalId,
    DateTime Function()? reloj,
  })  : _traslados = trasladosRepository,
        _registros = registroRepository,
        _personalId = personalId,
        _reloj = reloj ?? DateTime.now,
        super(ParteDiarioLoading(_soloFecha((reloj ?? DateTime.now)())));

  final TrasladosRepository _traslados;
  final RegistroHorarioRepository _registros;
  final String _personalId;
  final DateTime Function() _reloj;

  static DateTime _soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);

  /// No se puede navegar más allá de hoy
  bool get puedeAvanzar => state.dia.isBefore(_soloFecha(_reloj()));

  Future<void> cargar([DateTime? dia]) async {
    final DateTime fecha = _soloFecha(dia ?? state.dia);
    emit(ParteDiarioLoading(fecha));
    try {
      final DateTime finDia = fecha.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
      final List<Object> res = await Future.wait<Object>(<Future<Object>>[
        _registros.obtenerPorRangoFechas(_personalId, fecha, finDia),
        _traslados.getByRangoFechas(fechaInicio: fecha, fechaFin: fecha, idConductor: _personalId),
      ]);
      final List<RegistroHorarioEntity> fichajes = res[0] as List<RegistroHorarioEntity>;
      final List<TrasladoEntity> traslados = List<TrasladoEntity>.of(res[1] as List<TrasladoEntity>)
        ..sort((TrasladoEntity a, TrasladoEntity b) =>
            (a.horaProgramada ?? fecha).compareTo(b.horaProgramada ?? fecha));
      emit(ParteDiarioLoaded(
        dia: fecha,
        fichajes: fichajes,
        traslados: traslados,
        resumen: ResumenParteDiario.calcular(fichajes: fichajes, traslados: traslados, ahora: _reloj()),
      ));
    } catch (e) {
      debugPrint('❌ [ParteDiario] Error al cargar el parte: $e');
      emit(ParteDiarioError(fecha, 'No se pudo cargar el parte del día'));
    }
  }

  Future<void> diaAnterior() => cargar(state.dia.subtract(const Duration(days: 1)));

  Future<void> diaSiguiente() async {
    if (puedeAvanzar) {
      await cargar(state.dia.add(const Duration(days: 1)));
    }
  }
}
