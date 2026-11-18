import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/averia_orden_reparacion.dart';
import 'package:flutter_test/flutter_test.dart';

IncidenciaVehiculoEntity _averia({
  EstadoIncidencia estado = EstadoIncidencia.reportada,
  PrioridadIncidencia prioridad = PrioridadIncidencia.alta,
  String? taller,
}) {
  return IncidenciaVehiculoEntity(
    id: 'inc-1',
    vehiculoId: 'veh-1',
    reportadoPor: 'user-1',
    reportadoPorNombre: 'JUAN PÉREZ',
    fechaReporte: DateTime(2026, 11, 3),
    tipo: TipoIncidencia.values.first,
    prioridad: prioridad,
    estado: estado,
    titulo: 'Fallo en el motor',
    descripcion: 'Ruido al arrancar',
    kilometrajeReporte: 150000.4,
    tallerResponsable: taller,
    empresaId: 'emp-1',
    createdAt: DateTime(2026, 11, 3),
  );
}

OrdenReparacionEntity _orden({String? tallerNombre}) => OrdenReparacionEntity(
      id: 'ord-1',
      empresaId: 'emp-1',
      vehiculoId: 'veh-1',
      incidenciaId: 'inc-1',
      tallerNombre: tallerNombre,
      fechaEntrada: DateTime(2026, 11, 2),
      createdAt: DateTime(2026, 11, 2),
    );

TallerEntity _taller(String id, String nombre) => TallerEntity(
      id: id,
      empresaId: 'emp-1',
      nombre: nombre,
      createdAt: DateTime(2026),
    );

void main() {
  group('prioridadOrdenDesdeAveria', () {
    test('mapea todas las prioridades', () {
      expect(prioridadOrdenDesdeAveria(PrioridadIncidencia.baja), PrioridadOrdenReparacion.baja);
      expect(prioridadOrdenDesdeAveria(PrioridadIncidencia.media), PrioridadOrdenReparacion.normal);
      expect(prioridadOrdenDesdeAveria(PrioridadIncidencia.alta), PrioridadOrdenReparacion.alta);
      expect(prioridadOrdenDesdeAveria(PrioridadIncidencia.critica), PrioridadOrdenReparacion.urgente);
    });
  });

  group('plantillaOrdenDesdeAveria', () {
    test('vincula la avería y copia vehículo, km, diagnóstico y prioridad', () {
      final OrdenReparacionEntity p = plantillaOrdenDesdeAveria(_averia(), <TallerEntity>[]);
      expect(p.incidenciaId, 'inc-1');
      expect(p.vehiculoId, 'veh-1');
      expect(p.kilometrajeEntrada, 150000);
      expect(p.diagnostico, 'Fallo en el motor\n\nRuido al arrancar');
      expect(p.prioridad, PrioridadOrdenReparacion.alta);
      expect(p.tallerId, isNull);
    });

    test('resuelve el taller del catálogo por nombre', () {
      final OrdenReparacionEntity p = plantillaOrdenDesdeAveria(
        _averia(taller: 'TALLER GARCÍA'),
        <TallerEntity>[_taller('t-1', 'OTRO'), _taller('t-2', 'TALLER GARCÍA')],
      );
      expect(p.tallerId, 't-2');
    });
  });

  group('averiaTrasCrearOrden', () {
    test('una avería pendiente pasa a En reparación con el taller de la orden', () {
      final IncidenciaVehiculoEntity r = averiaTrasCrearOrden(_averia(), _orden(tallerNombre: 'TALLER GARCÍA'));
      expect(r.estado, EstadoIncidencia.enReparacion);
      expect(r.tallerResponsable, 'TALLER GARCÍA');
    });

    test('no retrocede el estado de una avería ya resuelta', () {
      final IncidenciaVehiculoEntity r =
          averiaTrasCrearOrden(_averia(estado: EstadoIncidencia.resuelta), _orden());
      expect(r.estado, EstadoIncidencia.resuelta);
    });

    test('conserva el taller de la avería si la orden no tiene', () {
      final IncidenciaVehiculoEntity r = averiaTrasCrearOrden(_averia(taller: 'PREVIO'), _orden());
      expect(r.tallerResponsable, 'PREVIO');
    });
  });
}
