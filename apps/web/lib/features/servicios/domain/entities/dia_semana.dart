/// Enum para los días de la semana con información completa
enum DiaSemana {
  /// Lunes
  lunes(1, 'Lunes', 'L'),

  /// Martes
  martes(2, 'Martes', 'M'),

  /// Miércoles
  miercoles(3, 'Miércoles', 'X'),

  /// Jueves
  jueves(4, 'Jueves', 'J'),

  /// Viernes
  viernes(5, 'Viernes', 'V'),

  /// Sábado
  sabado(6, 'Sábado', 'S'),

  /// Domingo
  domingo(7, 'Domingo', 'D');

  /// Valor numérico del día (1=Lunes, 7=Domingo)
  final int valor;

  /// Nombre completo del día
  final String nombre;

  /// Abreviatura de una letra
  final String abreviatura;

  // ignore: sort_constructors_first
  const DiaSemana(this.valor, this.nombre, this.abreviatura);

  /// Obtener DiaSemana desde un valor numérico
  static DiaSemana fromValor(int valor) {
    return DiaSemana.values.firstWhere(
      (DiaSemana d) => d.valor == valor,
      orElse: () => DiaSemana.lunes,
    );
  }

  /// Obtener DiaSemana desde DateTime
  static DiaSemana fromDateTime(DateTime date) {
    // DateTime.weekday: 1=Monday, 7=Sunday
    return fromValor(date.weekday);
  }
}
