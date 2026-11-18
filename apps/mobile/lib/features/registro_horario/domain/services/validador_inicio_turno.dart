import 'dart:math' as math;

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Gravedad de un aviso al iniciar turno
enum NivelAviso {
  /// Impide iniciar el turno
  bloqueo,

  /// Se informa pero se puede continuar
  aviso,
}

/// Aviso o bloqueo detectado al iniciar turno
class AvisoInicioTurno extends Equatable {
  const AvisoInicioTurno(this.nivel, this.mensaje);

  const AvisoInicioTurno.bloqueo(this.mensaje) : nivel = NivelAviso.bloqueo;

  const AvisoInicioTurno.aviso(this.mensaje) : nivel = NivelAviso.aviso;

  final NivelAviso nivel;
  final String mensaje;

  bool get bloquea => nivel == NivelAviso.bloqueo;

  @override
  List<Object?> get props => <Object?>[nivel, mensaje];
}

/// Reglas de negocio de la entrada en turno (lógica pura, sin I/O)
class ValidadorInicioTurno {
  const ValidadorInicioTurno._();

  /// Días de antelación para avisar de caducidades del vehículo
  static const int diasAvisoVehiculo = 15;

  /// Radio de la geocerca de la base
  static const int radioBaseMetros = 200;

  static final DateFormat _fecha = DateFormat('dd/MM/yyyy');

  /// ITV, seguro y homologación del vehículo
  static List<AvisoInicioTurno> documentacionVehiculo(VehiculoEntity v, DateTime ahora) {
    return <AvisoInicioTurno>[
      ?_caducidad('La ITV', v.proximaItv, ahora),
      ?_caducidad('El seguro', v.fechaVencimientoSeguro, ahora),
      ?_caducidad('La homologación sanitaria', v.fechaVencimientoHomologacion, ahora),
    ];
  }

  /// Documentación del trabajador: el carnet caducado bloquea solo al conductor
  static List<AvisoInicioTurno> documentacionPersonal(
    List<DocumentoPersonalEntity> documentos, {
    required bool esConductor,
    required DateTime ahora,
  }) {
    final List<AvisoInicioTurno> avisos = <AvisoInicioTurno>[];
    for (final DocumentoPersonalEntity d in documentos) {
      final EstadoDocumentoPersonal estado = EstadoDocumentoPersonal.calcular(d.fechaCaducidad, ahora);
      final String nombre = d.nombre?.isNotEmpty ?? false ? d.nombre! : d.tipo.label;
      final bool esCarnet = d.tipo == TipoDocumentoPersonal.carnetConducir;
      if (estado == EstadoDocumentoPersonal.caducado) {
        avisos.add(esCarnet && esConductor
            ? AvisoInicioTurno.bloqueo('Tu $nombre está caducado: no puedes ir de conductor')
            : AvisoInicioTurno.aviso('Tu documento "$nombre" está caducado'));
      } else if (estado == EstadoDocumentoPersonal.proximoACaducar && d.fechaCaducidad != null) {
        avisos.add(AvisoInicioTurno.aviso('Tu documento "$nombre" caduca el ${_fecha.format(d.fechaCaducidad!)}'));
      }
    }
    return avisos;
  }

  /// Los km introducidos no pueden ser menores que los últimos registrados
  static AvisoInicioTurno? kilometraje(int? km, double? kmActual) {
    if (km == null || kmActual == null || kmActual <= 0) {
      return null;
    }
    if (km < kmActual) {
      return AvisoInicioTurno.bloqueo(
        'Los km ($km) son menores que los últimos registrados (${kmActual.round()})',
      );
    }
    if (km - kmActual > 2000) {
      return AvisoInicioTurno.aviso('Hay más de 2.000 km desde el último registro: revisa la cifra');
    }
    return null;
  }

  /// Distancia en metros entre dos coordenadas (fórmula de Haversine)
  static int distanciaMetros(double lat1, double lon1, double lat2, double lon2) {
    const double radioTierra = 6371000;
    final double dLat = _rad(lat2 - lat1);
    final double dLon = _rad(lon2 - lon1);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) * math.cos(_rad(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);
    return (radioTierra * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))).round();
  }

  static double _rad(double grados) => grados * math.pi / 180;

  static AvisoInicioTurno? _caducidad(String que, DateTime fecha, DateTime ahora) {
    final DateTime hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final DateTime dia = DateTime(fecha.year, fecha.month, fecha.day);
    if (dia.isBefore(hoy)) {
      return AvisoInicioTurno.bloqueo('$que del vehículo caducó el ${_fecha.format(fecha)}');
    }
    if (dia.difference(hoy).inDays <= diasAvisoVehiculo) {
      return AvisoInicioTurno.aviso('$que del vehículo caduca el ${_fecha.format(fecha)}');
    }
    return null;
  }
}
