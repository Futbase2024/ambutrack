import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/widgets/gestion/mantenimiento_gestion_columns.dart';
import 'package:flutter_test/flutter_test.dart';

MantenimientoEntity _mant({
  String id = 'm1',
  DateTime? fecha,
  DateTime? programada,
  EstadoMantenimiento estado = EstadoMantenimiento.programado,
  TipoMantenimiento tipo = TipoMantenimiento.basico,
  String descripcion = 'Cambio de aceite',
  String? taller,
}) {
  return MantenimientoEntity(
    id: id,
    vehiculoId: 'v1',
    fecha: fecha ?? DateTime.now(),
    kmVehiculo: 1000,
    tipoMantenimiento: tipo,
    descripcion: descripcion,
    taller: taller,
    costoTotal: 0,
    estado: estado,
    fechaProgramada: programada,
    empresaId: 'e1',
    createdAt: DateTime(2026),
  );
}

void main() {
  final DateTime hoy = DateTime.now();

  group('mantVencido', () {
    test('programado con fecha pasada está vencido', () {
      expect(mantVencido(_mant(programada: hoy.subtract(const Duration(days: 3)))), isTrue);
    });

    test('programado para hoy o el futuro no está vencido', () {
      expect(mantVencido(_mant(programada: hoy)), isFalse);
      expect(mantVencido(_mant(programada: hoy.add(const Duration(days: 3)))), isFalse);
    });

    test('completado nunca está vencido', () {
      final MantenimientoEntity m = _mant(
        programada: hoy.subtract(const Duration(days: 30)),
        estado: EstadoMantenimiento.completado,
      );
      expect(mantVencido(m), isFalse);
      expect(mantEstadoLabel(m), EstadoMantenimiento.completado.displayName);
    });

    test('la etiqueta muestra "Vencido"', () {
      expect(mantEstadoLabel(_mant(programada: hoy.subtract(const Duration(days: 1)))), 'Vencido');
    });
  });

  test('la fecha de referencia es la programada si existe', () {
    final DateTime programada = DateTime(2026, 5, 10);
    expect(mantFechaRef(_mant(fecha: DateTime(2026), programada: programada)), programada);
    expect(mantFechaRef(_mant(fecha: DateTime(2026, 2, 2))), DateTime(2026, 2, 2));
  });

  group('filtrarMantenimientos', () {
    final List<MantenimientoEntity> items = <MantenimientoEntity>[
      _mant(taller: 'TALLER NORTE'),
      _mant(id: 'm2', tipo: TipoMantenimiento.urgente, descripcion: 'Frenos', estado: EstadoMantenimiento.enProceso),
    ];

    test('busca en descripción y taller', () {
      expect(
        filtrarMantenimientos(
          items,
          vehiculos: const <String, VehiculoEntity>{},
          query: 'norte',
          tipo: null,
          estado: null,
        ).length,
        1,
      );
      expect(
        filtrarMantenimientos(
          items,
          vehiculos: const <String, VehiculoEntity>{},
          query: 'frenos',
          tipo: null,
          estado: null,
        ).single.id,
        'm2',
      );
    });

    test('filtra por tipo y estado', () {
      expect(
        filtrarMantenimientos(
          items,
          vehiculos: const <String, VehiculoEntity>{},
          query: '',
          tipo: TipoMantenimiento.urgente,
          estado: null,
        ).single.id,
        'm2',
      );
      expect(
        filtrarMantenimientos(
          items,
          vehiculos: const <String, VehiculoEntity>{},
          query: '',
          tipo: null,
          estado: EstadoMantenimiento.programado,
        ).single.id,
        'm1',
      );
    });
  });
}
