/// Día programado con horarios específicos
/// Se usa cuando hay un rango de fechas definido (modo expandido)
class DiaProgramado {

  DiaProgramado({
    required this.fecha,
    required this.diaSemana,
    required this.horaRecogida,
    required this.horaCita,
    this.horaVuelta,
    this.habilitado = true,
  });
  /// Fecha específica del día programado
  final DateTime fecha;

  /// Día de la semana (0-6, donde 0=Domingo)
  final int diaSemana;

  /// Hora de recogida del paciente (formato "HH:mm")
  final String horaRecogida;

  /// Hora de cita en el centro médico (formato "HH:mm")
  final String horaCita;

  /// Hora de vuelta/retorno (formato "HH:mm")
  /// Puede ser null si el servicio no incluye vuelta
  final String? horaVuelta;

  /// Indica si el día está habilitado
  /// false = el usuario lo eliminó (ej: festivo)
  final bool habilitado;

  /// Obtiene el nombre del día de la semana en español
  String get nombreDiaSemana {
    const List<String> nombres = <String>[
      'Domingo',
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
    ];
    return nombres[diaSemana];
  }

  /// Obtiene el nombre corto del día de la semana
  String get nombreDiaSemanaCorto {
    const List<String> nombres = <String>['D', 'L', 'M', 'X', 'J', 'V', 'S'];
    return nombres[diaSemana];
  }

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
  DiaProgramado copyWith({
    DateTime? fecha,
    int? diaSemana,
    String? horaRecogida,
    String? horaCita,
    String? horaVuelta,
    bool? habilitado,
  }) {
    return DiaProgramado(
      fecha: fecha ?? this.fecha,
      diaSemana: diaSemana ?? this.diaSemana,
      horaRecogida: horaRecogida ?? this.horaRecogida,
      horaCita: horaCita ?? this.horaCita,
      horaVuelta: horaVuelta ?? this.horaVuelta,
      habilitado: habilitado ?? this.habilitado,
    );
  }

  @override
  String toString() {
    return 'DiaProgramado('
        'fecha: ${fecha.toIso8601String()}, '
        'diaSemana: $diaSemana, '
        'horaRecogida: $horaRecogida, '
        'horaCita: $horaCita, '
        'horaVuelta: $horaVuelta, '
        'habilitado: $habilitado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is DiaProgramado &&
        other.fecha == fecha &&

        other.diaSemana == diaSemana &&
        other.horaRecogida == horaRecogida &&
        other.horaCita == horaCita &&
        other.horaVuelta == horaVuelta &&
        other.habilitado == habilitado;
  }

  @override
  int get hashCode {
    return Object.hash(
      fecha,
      diaSemana,
      horaRecogida,
      horaCita,
      horaVuelta,
      habilitado,
    );
  }
}
