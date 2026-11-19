import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_pdf/ambutrack_pdf.dart';
import 'package:flutter_test/flutter_test.dart';

const String _yo = 'p-1';
final DateTime _dia = DateTime(2026, 11, 19);

RegistroHorarioEntity _fichaje(String id, String tipo, int h, int m) => RegistroHorarioEntity(
      id: id,
      createdAt: _dia,
      updatedAt: _dia,
      personalId: _yo,
      tipo: tipo,
      fechaHora: DateTime(2026, 11, 19, h, m),
    );

PacienteEntity _paciente({String? mutua}) => PacienteEntity(
      id: 'pac',
      nombre: 'juan',
      primerApellido: 'pérez',
      segundoApellido: 'garcía',
      tipoDocumento: 'DNI',
      documento: '1',
      sexo: 'HOMBRE',
      fechaNacimiento: DateTime(1950),
      mutuaAseguradora: mutua,
      domicilioDireccion: 'c/ real 1',
    );

TrasladoEntity _traslado(String id, EstadoTraslado estado, int h, {String? conductor, String? vehiculo, String? mutua}) =>
    TrasladoEntity(
      id: id,
      estado: estado.value,
      idPersonalConductor: conductor,
      idVehiculo: vehiculo,
      paciente: _paciente(mutua: mutua),
      tipoTraslado: 'ida',
      tipoOrigen: 'domicilio_paciente',
      tipoDestino: 'otro_domicilio',
      destino: 'hospital puerta del mar',
      fecha: _dia,
      fechaEnOrigen: DateTime(2026, 11, 19, h),
      fechaFinalizado: DateTime(2026, 11, 19, h, 45),
    );

InicioTurnoEntity _inicio(String id, String vehiculo, int h, {int? kmFinal}) => InicioTurnoEntity(
      id: id,
      personalId: _yo,
      personalNombre: 'Ana López',
      registroEntradaId: 'e-$id',
      vehiculoId: vehiculo,
      vehiculoMatricula: '1234abc',
      kmInicial: 1000,
      kmFinal: kmFinal,
      checklistItems: const <ChecklistInicioItem>[
        ChecklistInicioItem(nombre: 'Luces', correcto: true),
        ChecklistInicioItem(nombre: 'Oxígeno', correcto: false, observacion: 'Bala baja'),
      ],
      createdAt: DateTime(2026, 11, 19, h),
    );

List<ParteDiarioData> _construir({
  required List<InicioTurnoEntity> inicios,
  required List<RegistroHorarioEntity> fichajes,
  required List<TrasladoEntity> traslados,
  String? soloInicioId,
}) {
  return ParteDiarioBuilder.construirDia(
    personalId: _yo,
    personalNombre: 'Ana López',
    dia: _dia,
    empresa: const EmpresaParte(nombre: 'Test'),
    inicios: inicios,
    fichajes: fichajes,
    traslados: traslados,
    soloInicioId: soloInicioId,
  );
}

void main() {
  group('ParteDiarioBuilder', () {
    test('un turno: cabecera, km, servicios e incidencias', () {
      final List<ParteDiarioData> partes = _construir(
        inicios: <InicioTurnoEntity>[_inicio('1', 'v-1', 8, kmFinal: 1180)],
        fichajes: <RegistroHorarioEntity>[_fichaje('e-1', 'entrada', 8, 0), _fichaje('s-1', 'salida', 15, 30)],
        traslados: <TrasladoEntity>[
          _traslado('t1', EstadoTraslado.finalizado, 9, conductor: _yo, mutua: 'mapfre'),
          _traslado('t2', EstadoTraslado.finalizado, 11, vehiculo: 'v-1'),
          _traslado('t3', EstadoTraslado.noRealizado, 12, conductor: _yo),
          _traslado('t4', EstadoTraslado.finalizado, 13, conductor: 'otro', vehiculo: 'v-9'),
        ],
      );

      expect(partes, hasLength(1));
      final ParteDiarioData p = partes.single;
      expect(p.tecnico, 'ANA LÓPEZ');
      expect(p.matricula, '1234ABC');
      expect(p.horaEntrada, '08:00');
      expect(p.horaSalida, '15:30');
      expect(p.kmEntrada, '1000');
      expect(p.kmSalida, '1180');
      expect(p.kmRecorridos, '180');
      expect(p.numServicios, '2');
      expect(p.servicios, hasLength(2));
      expect(p.servicios.first.paciente, 'JUAN PÉREZ GARCÍA');
      expect(p.servicios.first.entidad, 'MAPFRE');
      expect(p.servicios.last.entidad, 'SAS');
      expect(p.servicios.first.domicilio, 'C/ REAL 1');
      expect(p.incidencias.single, contains('JUAN PÉREZ GARCÍA'));
      expect(p.revisadoControles, isTrue);
      expect(p.checklist, hasLength(2));
      expect(p.otrasIncidencias.single, 'OXÍGENO: Bala baja');
    });

    test('dos inicios con distinta ambulancia generan dos partes', () {
      final List<ParteDiarioData> partes = _construir(
        inicios: <InicioTurnoEntity>[_inicio('2', 'v-2', 15), _inicio('1', 'v-1', 7)],
        fichajes: <RegistroHorarioEntity>[
          _fichaje('e-1', 'entrada', 7, 0),
          _fichaje('s-1', 'salida', 14, 0),
          _fichaje('e-2', 'entrada', 15, 0),
          _fichaje('s-2', 'salida', 22, 0),
        ],
        traslados: <TrasladoEntity>[
          _traslado('t1', EstadoTraslado.finalizado, 9, conductor: _yo),
          _traslado('t2', EstadoTraslado.finalizado, 17, conductor: _yo),
          _traslado('t3', EstadoTraslado.finalizado, 18, conductor: _yo),
        ],
      );

      expect(partes, hasLength(2));
      expect(partes[0].horaEntrada, '07:00');
      expect(partes[0].horaSalida, '14:00');
      expect(partes[0].servicios, hasLength(1));
      expect(partes[1].horaEntrada, '15:00');
      expect(partes[1].servicios, hasLength(2));
      expect(partes[1].kmSalida, isEmpty);
    });

    test('inicios seguidos con la misma ambulancia se juntan en un parte', () {
      final List<ParteDiarioData> partes = _construir(
        inicios: <InicioTurnoEntity>[_inicio('1', 'v-1', 7), _inicio('2', 'v-1', 8, kmFinal: 1250)],
        fichajes: <RegistroHorarioEntity>[_fichaje('e-1', 'entrada', 7, 0)],
        traslados: <TrasladoEntity>[
          _traslado('t1', EstadoTraslado.finalizado, 6, conductor: _yo),
          _traslado('t2', EstadoTraslado.finalizado, 10, conductor: _yo),
        ],
      );

      expect(partes, hasLength(1));
      expect(partes.single.servicios, hasLength(2));
      expect(partes.single.kmEntrada, '1000');
      expect(partes.single.kmSalida, '1250');
      expect(partes.single.kmRecorridos, '250');
    });

    test('soloInicioId devuelve solo el parte de ese inicio', () {
      final List<ParteDiarioData> partes = _construir(
        inicios: <InicioTurnoEntity>[_inicio('1', 'v-1', 7), _inicio('2', 'v-2', 15)],
        fichajes: const <RegistroHorarioEntity>[],
        traslados: <TrasladoEntity>[_traslado('t2', EstadoTraslado.finalizado, 17, conductor: _yo)],
        soloInicioId: '2',
      );

      expect(partes, hasLength(1));
      expect(partes.single.servicios, hasLength(1));
    });

    test('sin inicio de turno: un parte sin revisión de vehículo', () {
      final List<ParteDiarioData> partes = _construir(
        inicios: const <InicioTurnoEntity>[],
        fichajes: <RegistroHorarioEntity>[_fichaje('e', 'entrada', 8, 0)],
        traslados: <TrasladoEntity>[_traslado('t1', EstadoTraslado.finalizado, 9, conductor: _yo)],
      );

      expect(partes, hasLength(1));
      expect(partes.single.tecnico, 'ANA LÓPEZ');
      expect(partes.single.tieneRevision, isFalse);
      expect(partes.single.servicios, hasLength(1));
    });
  });

  test('genera un PDF con más de 17 servicios', () async {
    final List<ParteDiarioData> partes = _construir(
      inicios: <InicioTurnoEntity>[_inicio('1', 'v-1', 6)],
      fichajes: <RegistroHorarioEntity>[_fichaje('e-1', 'entrada', 6, 0)],
      traslados: <TrasladoEntity>[
        for (int i = 0; i < 20; i++) _traslado('t$i', EstadoTraslado.finalizado, 7, conductor: _yo),
      ],
    );
    final List<int> bytes = await ParteDiarioPdf.generar(partes);
    expect(bytes.length, greaterThan(1000));
  });
}
