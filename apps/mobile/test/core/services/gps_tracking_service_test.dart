import 'package:ambutrack_mobile/core/services/gps_tracking_service.dart';
import 'package:ambutrack_mobile/features/registro_horario/presentation/bloc/registro_horario_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('debeEnviarGps', () {
    test('envía solo con jornada fichada, app abierta, sesión y vehículo', () {
      expect(debeEnviarGps(fichado: true, enPrimerPlano: true, autenticado: true, sinVehiculo: false), isTrue);
    });

    test('no envía si falta cualquier condición', () {
      expect(debeEnviarGps(fichado: false, enPrimerPlano: true, autenticado: true, sinVehiculo: false), isFalse);
      expect(debeEnviarGps(fichado: true, enPrimerPlano: false, autenticado: true, sinVehiculo: false), isFalse);
      expect(debeEnviarGps(fichado: true, enPrimerPlano: true, autenticado: false, sinVehiculo: false), isFalse);
      expect(debeEnviarGps(fichado: true, enPrimerPlano: true, autenticado: true, sinVehiculo: true), isFalse);
    });
  });

  group('estadoFichajeDe', () {
    test('lee el fichaje de los estados cargados', () {
      expect(
        estadoFichajeDe(const RegistroHorarioLoaded(historial: [], estadoActual: EstadoFichaje.dentro)),
        EstadoFichaje.dentro,
      );
      expect(
        estadoFichajeDe(const RegistroHorarioLoaded(historial: [], estadoActual: EstadoFichaje.fuera)),
        EstadoFichaje.fuera,
      );
    });

    test('devuelve null en estados sin información de fichaje', () {
      expect(estadoFichajeDe(const RegistroHorarioInitial()), isNull);
    });
  });

  group('esErrorSinVehiculo', () {
    test('detecta el error del servidor por código o mensaje', () {
      expect(esErrorSinVehiculo(Exception('PostgrestException(code: P0002)')), isTrue);
      expect(
        esErrorSinVehiculo(Exception('No tienes un vehículo asignado en tu turno de hoy')),
        isTrue,
      );
      expect(esErrorSinVehiculo(Exception('timeout')), isFalse);
    });
  });
}
