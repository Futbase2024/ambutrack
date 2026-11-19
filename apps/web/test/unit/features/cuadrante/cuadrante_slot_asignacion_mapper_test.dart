import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/domain/entities/cuadrante_slot_entity.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/domain/services/cuadrante_slot_asignacion_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

AsignacionVehiculoTurnoEntity _asig(String id, {String dotacion = 'd1', Map<String, dynamic>? metadata}) {
  return AsignacionVehiculoTurnoEntity(
    id: id,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    fecha: DateTime(2026, 11, 18),
    vehiculoId: 'veh-$id',
    dotacionId: dotacion,
    metadata: metadata,
  );
}

void main() {
  final DateTime fecha = DateTime(2026, 11, 18);

  test('respeta numero_unidad y rellena unidades libres con asignaciones antiguas', () {
    final List<CuadranteSlotEntity> slots = CuadranteSlotAsignacionMapper.construirSlots(
      dotacionId: 'd1',
      cantidadUnidades: 3,
      fecha: fecha,
      asignaciones: <AsignacionVehiculoTurnoEntity>[
        _asig('a', metadata: <String, dynamic>{'numero_unidad': 3, 'personal_id': 'p1', 'rol_personal': 'tes'}),
        _asig('b'),
        _asig('c', dotacion: 'otra'),
      ],
      matriculasPorVehiculo: <String, String>{'veh-a': '1234ABC'},
      nombresPorPersonal: <String, String>{'p1': 'ANA LÓPEZ'},
    );

    expect(slots.map((CuadranteSlotEntity s) => s.asignacionId), <String?>['b', null, 'a']);
    expect(slots[2].vehiculoMatricula, '1234ABC');
    expect(slots[2].personalId, 'p1');
    expect(slots[2].personalNombre, 'ANA LÓPEZ');
    expect(slots[2].rolPersonal, 'tes');
  });

  test('metadataDesdeSlot guarda unidad y personal, y lo limpia si no hay personal', () {
    final CuadranteSlotEntity conPersonal = CuadranteSlotEntity(
      dotacionId: 'd1',
      fecha: fecha,
      numeroUnidad: 2,
      personalId: 'p1',
      personalNombre: 'ANA LÓPEZ',
      rolPersonal: 'conductor',
    );
    expect(CuadranteSlotAsignacionMapper.metadataDesdeSlot(conPersonal), <String, dynamic>{
      'numero_unidad': 2,
      'personal_id': 'p1',
      'personal_nombre': 'ANA LÓPEZ',
      'rol_personal': 'conductor',
    });

    final CuadranteSlotEntity sinPersonal = CuadranteSlotEntity(dotacionId: 'd1', fecha: fecha, numeroUnidad: 1);
    expect(
      CuadranteSlotAsignacionMapper.metadataDesdeSlot(
        sinPersonal,
        metadataPrevia: <String, dynamic>{'personal_id': 'viejo', 'otro': true},
      ),
      <String, dynamic>{'otro': true, 'numero_unidad': 1},
    );
  });
}
