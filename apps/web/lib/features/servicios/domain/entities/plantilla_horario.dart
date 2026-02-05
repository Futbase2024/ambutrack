/// Plantilla de horario para servicios sin fecha de finalización
/// Define un patrón de horarios que se repetirá indefinidamente
class PlantillaHorario {

  PlantillaHorario({
    this.diaSemana,
    this.diaMes,
    required this.etiqueta,
    required this.horaRecogida,
    required this.horaCita,
    this.horaVuelta,
  });
  /// Día de la semana (0-6, donde 0=Domingo)
  /// Solo se usa para recurrencia semanal
  final int? diaSemana;

  /// Día del mes (1-31)
  /// Solo se usa para recurrencia mensual
  final int? diaMes;

  /// Etiqueta descriptiva del día
  /// Ejemplos: "Todos los días", "Lunes", "Día 15", etc.
  final String etiqueta;

  /// Hora de recogida del paciente (formato "HH:mm")
  final String horaRecogida;

  /// Hora de cita en el centro médico (formato "HH:mm")
  final String horaCita;

  /// Hora de vuelta/retorno (formato "HH:mm")
  /// Puede ser null si el servicio no incluye vuelta
  final String? horaVuelta;

  /// Valida que los horarios sean correctos
  String? validar() {
    // Validar formato de horas
    if (!_esHoraValida(horaRecogida)) {
      return 'Hora de recogida inválida';
    }
    if (!_esHoraValida(horaCita)) {
      return 'Hora de cita inválida';
    }
    if (horaVuelta != null && !_esHoraValida(horaVuelta!)) {
      return 'Hora de vuelta inválida';
    }

    // Validar que recogida < cita
    if (_compararHoras(horaRecogida, horaCita) >= 0) {
      return 'La hora de recogida debe ser anterior a la hora de cita';
    }

    // Validar que cita < vuelta (si existe)
    if (horaVuelta != null && _compararHoras(horaCita, horaVuelta!) >= 0) {
      return 'La hora de vuelta debe ser posterior a la hora de cita';
    }

    return null; // Sin errores
  }

  /// Valida el formato HH:mm
  bool _esHoraValida(String hora) {
    final RegExp regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(hora);
  }

  /// Compara dos horas en formato HH:mm
  /// Retorna: -1 si h1 < h2, 0 si h1 == h2, 1 si h1 > h2
  int _compararHoras(String h1, String h2) {
    final List<String> parts1 = h1.split(':');
    final List<String> parts2 = h2.split(':');

    final int minutos1 = int.parse(parts1[0]) * 60 + int.parse(parts1[1]);
    final int minutos2 = int.parse(parts2[0]) * 60 + int.parse(parts2[1]);

    return minutos1.compareTo(minutos2);
  }

  /// Crea una copia con campos modificados
  PlantillaHorario copyWith({
    int? diaSemana,
    int? diaMes,
    String? etiqueta,
    String? horaRecogida,
    String? horaCita,
    String? horaVuelta,
  }) {
    return PlantillaHorario(
      diaSemana: diaSemana ?? this.diaSemana,
      diaMes: diaMes ?? this.diaMes,
      etiqueta: etiqueta ?? this.etiqueta,
      horaRecogida: horaRecogida ?? this.horaRecogida,
      horaCita: horaCita ?? this.horaCita,
      horaVuelta: horaVuelta ?? this.horaVuelta,
    );
  }

  @override
  String toString() {
    return 'PlantillaHorario('
        'etiqueta: $etiqueta, '
        'horaRecogida: $horaRecogida, '
        'horaCita: $horaCita, '
        'horaVuelta: $horaVuelta)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is PlantillaHorario &&
        other.diaSemana == diaSemana &&

        other.diaMes == diaMes &&
        other.etiqueta == etiqueta &&
        other.horaRecogida == horaRecogida &&
        other.horaCita == horaCita &&
        other.horaVuelta == horaVuelta;
  }

  @override
  int get hashCode {
    return Object.hash(
      diaSemana,
      diaMes,
      etiqueta,
      horaRecogida,
      horaCita,
      horaVuelta,
    );
  }
}
