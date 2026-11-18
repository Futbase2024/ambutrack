import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

import '../../domain/models/datos_inicio_turno.dart';
import '../../domain/services/validador_inicio_turno.dart';
import '../bloc/registro_horario_event.dart';
import 'inicio_turno_state.dart';

/// Reglas del asistente "Iniciar turno" calculadas a partir del estado
extension InicioTurnoReglas on InicioTurnoState {
  /// Personas con la jornada abierta en el vehículo (sin contarme a mí ni al compañero)
  List<OcupanteVehiculoEntity> get ocupantesAjenos => ocupantes
      .where((OcupanteVehiculoEntity o) => o.personalId != personal?.id && o.personalId != companero?.id)
      .toList();

  List<AvisoInicioTurno> get avisosVehiculo {
    final VehiculoEntity? v = vehiculoSeleccionado;
    if (v == null) {
      return const <AvisoInicioTurno>[];
    }
    return <AvisoInicioTurno>[
      ...ValidadorInicioTurno.documentacionVehiculo(v, DateTime.now()),
      for (final OcupanteVehiculoEntity o in ocupantesAjenos)
        AvisoInicioTurno.aviso(
          '${v.matricula} ya está en servicio con ${o.personalNombre ?? 'otro técnico'}. '
          'Si es tu compañero, añádelo en el siguiente paso.',
        ),
    ];
  }

  List<AvisoInicioTurno> get avisosPersonal => ValidadorInicioTurno.documentacionPersonal(
        documentos,
        esConductor: rol == RolDotacion.conductor,
        ahora: DateTime.now(),
      );

  AvisoInicioTurno? get avisoKm => ValidadorInicioTurno.kilometraje(km, vehiculoSeleccionado?.kmActual);

  /// Distancia a la base en metros (null si no hay GPS o la base no tiene coordenadas)
  int? get distanciaBase {
    final UbicacionBaseEntity? base = ubicacionBase;
    final double? lat = latitud;
    final double? lon = longitud;
    if (base == null || lat == null || lon == null || (lat == 0 && lon == 0)) {
      return null;
    }
    return ValidadorInicioTurno.distanciaMetros(lat, lon, base.latitud, base.longitud);
  }

  bool get fueraDeBase => (distanciaBase ?? 0) > ValidadorInicioTurno.radioBaseMetros;

  /// Fuera de base solo se permite si nadie más está ya en servicio con el vehículo
  AvisoInicioTurno? get avisoFueraBase {
    if (!fueraDeBase) {
      return null;
    }
    if (ocupantesAjenos.isNotEmpty) {
      return const AvisoInicioTurno.bloqueo(
        'Estás fuera de tu base y el vehículo ya está en servicio con otra persona. Contacta con coordinación.',
      );
    }
    return AvisoInicioTurno.aviso(
      'Estás a $distanciaBase m de ${ubicacionBase?.nombre ?? 'tu base'}. '
      'Indica el motivo: coordinación tendrá que validar el inicio.',
    );
  }

  bool get _checklistCompleto {
    for (int i = 0; i < checklistNombres.length; i++) {
      final bool? r = respuestas[i];
      if (r == null || (!r && (observaciones[i]?.trim().isEmpty ?? true))) {
        return false;
      }
    }
    return true;
  }

  bool _sinBloqueos(Iterable<AvisoInicioTurno> avisos) => !avisos.any((AvisoInicioTurno a) => a.bloquea);

  /// Se puede pasar del paso actual al siguiente (o confirmar en el último)
  bool get puedeAvanzar {
    switch (paso) {
      case PasoInicioTurno.turno:
        return turno != null || plantillaSeleccionada != null;
      case PasoInicioTurno.vehiculo:
        return vehiculoSeleccionado != null && !cargandoOcupacion && _sinBloqueos(avisosVehiculo);
      case PasoInicioTurno.dotacion:
        return rol != null && _sinBloqueos(avisosPersonal);
      case PasoInicioTurno.estado:
        return km != null && combustible != null && !(avisoKm?.bloquea ?? false);
      case PasoInicioTurno.checklist:
        return _checklistCompleto;
      case PasoInicioTurno.resumen:
        final AvisoInicioTurno? fuera = avisoFueraBase;
        return declaracion && !(fuera?.bloquea ?? false) && (!fueraDeBase || motivoFueraBase.trim().isNotEmpty);
    }
  }

  /// Resultado final del asistente
  InicioTurnoSeleccion toSeleccion({required String modoDispositivo}) {
    final List<ChecklistInicioItem> checklist = <ChecklistInicioItem>[
      for (int i = 0; i < checklistNombres.length; i++)
        ChecklistInicioItem(
          nombre: checklistNombres[i],
          correcto: respuestas[i] ?? false,
          observacion: observaciones[i]?.trim().isEmpty ?? true ? null : observaciones[i]!.trim(),
        ),
    ];
    final List<String> avisos = <String>[
      ...avisosVehiculo.map((AvisoInicioTurno a) => a.mensaje),
      ...avisosPersonal.map((AvisoInicioTurno a) => a.mensaje),
      ?avisoKm?.mensaje,
    ];
    final TPersonalEntity? c = companero;
    return InicioTurnoSeleccion(
      turno: turno,
      vehiculo: vehiculoSeleccionado!,
      plantilla: plantillaSeleccionada,
      datos: DatosInicioTurno(
        rol: rol!,
        companeroId: c?.id,
        companeroNombre: c == null ? null : '${c.nombre} ${c.apellidos}'.trim(),
        kmInicial: km!,
        combustible: combustible!,
        fotoKmBytes: fotoKm,
        checklist: checklist,
        declaracionAptitud: declaracion,
        baseId: ubicacionBase?.id ?? turno?.idBase ?? personal?.baseId,
        distanciaBaseM: distanciaBase,
        fueraDeBase: fueraDeBase,
        motivoFueraBase: fueraDeBase ? motivoFueraBase.trim() : null,
        avisos: avisos,
        modoDispositivo: modoDispositivo,
      ),
    );
  }
}
