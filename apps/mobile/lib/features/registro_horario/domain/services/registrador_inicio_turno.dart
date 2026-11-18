import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/datos_inicio_turno.dart';
import '../repositories/turno_actual_repository.dart';

/// Guarda los datos de la entrada en turno tras fichar la entrada
///
/// Un fallo aquí no deshace el fichaje: se devuelve un aviso para el usuario.
class RegistradorInicioTurno {
  const RegistradorInicioTurno(this._repository);

  final TurnoActualRepository _repository;

  /// Devuelve el texto a añadir al mensaje de éxito ('' si no hay nada que avisar)
  Future<String> registrar({
    required TPersonalEntity personal,
    required TurnoEntity turno,
    required VehiculoEntity vehiculo,
    required String registroEntradaId,
    required DatosInicioTurno datos,
    required double latitud,
    required double longitud,
  }) async {
    try {
      final String? fotoKm = await _subirFoto(datos);
      final InicioTurnoEntity inicio = await _repository.registrarInicioTurno(
        InicioTurnoEntity(
          id: const Uuid().v4(),
          personalId: personal.id,
          registroEntradaId: registroEntradaId,
          turnoId: turno.id,
          personalNombre: '${personal.nombre} ${personal.apellidos}'.trim().toUpperCase(),
          vehiculoId: vehiculo.id,
          vehiculoMatricula: vehiculo.matricula,
          baseId: datos.baseId,
          rol: datos.rol,
          companeroId: datos.companeroId,
          companeroNombre: datos.companeroNombre?.toUpperCase(),
          kmInicial: datos.kmInicial,
          combustible: datos.combustible,
          fotoKmUrl: fotoKm,
          checklistItems: datos.checklist,
          declaracionAptitud: datos.declaracionAptitud,
          latitud: latitud,
          longitud: longitud,
          distanciaBaseM: datos.distanciaBaseM,
          fueraDeBase: datos.fueraDeBase,
          motivoFueraBase: datos.motivoFueraBase,
          avisos: datos.avisos,
          modoDispositivo: datos.modoDispositivo,
        ),
      );
      if (inicio.estadoValidacion == EstadoValidacionInicio.pendiente) {
        return '\n\nHas iniciado el turno fuera de tu base: coordinación debe validarlo.';
      }
      return '';
    } catch (e) {
      debugPrint('❌ [RegistradorInicioTurno] Error: $e');
      return '\n\nEl fichaje se ha guardado, pero no los datos del vehículo (km, checklist). '
          'Avisa a coordinación.';
    }
  }

  Future<String?> _subirFoto(DatosInicioTurno datos) async {
    final Uint8List? bytes = datos.fotoKmBytes;
    if (bytes == null) {
      return null;
    }
    try {
      return await _repository.subirFotoKm(bytes: bytes, extension: datos.fotoKmExtension);
    } catch (e) {
      debugPrint('⚠️ [RegistradorInicioTurno] Foto no subida: $e');
      return null;
    }
  }
}
