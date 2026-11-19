import 'dart:typed_data';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Datos recogidos en el asistente "Iniciar turno" (además de turno y vehículo)
class DatosInicioTurno extends Equatable {
  const DatosInicioTurno({
    required this.rol,
    required this.kmInicial,
    required this.combustible,
    required this.checklist,
    required this.declaracionAptitud,
    this.companeroId,
    this.companeroNombre,
    this.fotoKmBytes,
    this.fotoKmExtension = 'jpeg',
    this.baseId,
    this.distanciaBaseM,
    this.fueraDeBase = false,
    this.motivoFueraBase,
    this.avisos = const <String>[],
    this.modoDispositivo,
  });

  final RolDotacion rol;
  final String? companeroId;
  final String? companeroNombre;
  final int kmInicial;
  final NivelCombustible combustible;
  final Uint8List? fotoKmBytes;
  final String fotoKmExtension;
  final List<ChecklistInicioItem> checklist;
  final bool declaracionAptitud;
  final String? baseId;
  final int? distanciaBaseM;
  final bool fueraDeBase;
  final String? motivoFueraBase;
  final List<String> avisos;
  final String? modoDispositivo;

  @override
  List<Object?> get props => <Object?>[
        rol,
        companeroId,
        companeroNombre,
        kmInicial,
        combustible,
        fotoKmBytes,
        fotoKmExtension,
        checklist,
        declaracionAptitud,
        baseId,
        distanciaBaseM,
        fueraDeBase,
        motivoFueraBase,
        avisos,
        modoDispositivo,
      ];
}
