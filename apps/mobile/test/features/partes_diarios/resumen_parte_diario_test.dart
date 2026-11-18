import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_mobile/features/partes_diarios/domain/resumen_parte_diario.dart';
import 'package:flutter_test/flutter_test.dart';

RegistroHorarioEntity _fichaje(String tipo, DateTime fecha) => RegistroHorarioEntity(
      id: '$tipo-${fecha.toIso8601String()}',
      createdAt: fecha,
      updatedAt: fecha,
      personalId: 'p1',
      tipo: tipo,
      fechaHora: fecha,
    );

TrasladoEntity _traslado(String estado, {double? kmTotales, double? kmInicio, double? kmFin}) => TrasladoEntity(
      id: estado,
      estado: estado,
      kmTotales: kmTotales,
      kmInicio: kmInicio,
      kmFin: kmFin,
    );

void main() {
  final DateTime dia = DateTime(2026, 11, 18);

  test('suma los tramos entrada-salida', () {
    final ResumenParteDiario r = ResumenParteDiario.calcular(
      fichajes: <RegistroHorarioEntity>[
        _fichaje('salida', dia.add(const Duration(hours: 14))),
        _fichaje('entrada', dia.add(const Duration(hours: 8))),
        _fichaje('entrada', dia.add(const Duration(hours: 15))),
        _fichaje('salida', dia.add(const Duration(hours: 16, minutes: 30))),
      ],
      traslados: const <TrasladoEntity>[],
      ahora: dia.add(const Duration(hours: 20)),
    );
    expect(r.tiempoTrabajado, const Duration(hours: 7, minutes: 30));
    expect(r.jornadaAbierta, isFalse);
  });

  test('una entrada sin salida cuenta hasta ahora y marca la jornada abierta', () {
    final ResumenParteDiario r = ResumenParteDiario.calcular(
      fichajes: <RegistroHorarioEntity>[_fichaje('entrada', dia.add(const Duration(hours: 8)))],
      traslados: const <TrasladoEntity>[],
      ahora: dia.add(const Duration(hours: 10, minutes: 15)),
    );
    expect(r.tiempoTrabajado, const Duration(hours: 2, minutes: 15));
    expect(r.jornadaAbierta, isTrue);
  });

  test('clasifica los servicios y suma los km', () {
    final ResumenParteDiario r = ResumenParteDiario.calcular(
      fichajes: const <RegistroHorarioEntity>[],
      traslados: <TrasladoEntity>[
        _traslado('finalizado', kmTotales: 12),
        _traslado('finalizado', kmInicio: 100, kmFin: 130),
        _traslado('cancelado'),
        _traslado('no_realizado'),
        _traslado('en_transito'),
      ],
      ahora: dia,
    );
    expect(r.realizados, 2);
    expect(r.noRealizados, 2);
    expect(r.pendientes, 1);
    expect(r.totalServicios, 5);
    expect(r.kmTotales, 42);
  });

  test('formatDuracion', () {
    expect(formatDuracion(const Duration(hours: 7, minutes: 5)), '7 h 05 min');
  });
}
