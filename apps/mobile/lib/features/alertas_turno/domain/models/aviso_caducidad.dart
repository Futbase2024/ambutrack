import 'package:equatable/equatable.dart';

/// De dónde viene la caducidad
enum OrigenAviso {
  vehiculo('Vehículo'),
  personal('Tu documentación'),
  material('Material de la ambulancia');

  const OrigenAviso(this.label);

  final String label;
}

/// Gravedad de la caducidad
enum NivelCaducidad { caducado, proximo }

/// Algo caducado o a punto de caducar (solo informa, nunca bloquea)
class AvisoCaducidad extends Equatable {
  const AvisoCaducidad({
    required this.origen,
    required this.nivel,
    required this.titulo,
    this.fecha,
    this.detalle,
  });

  final OrigenAviso origen;
  final NivelCaducidad nivel;
  final String titulo;
  final DateTime? fecha;

  /// Ej: "x2 · Lote L123"
  final String? detalle;

  bool get caducado => nivel == NivelCaducidad.caducado;

  @override
  List<Object?> get props => <Object?>[origen, nivel, titulo, fecha, detalle];
}
