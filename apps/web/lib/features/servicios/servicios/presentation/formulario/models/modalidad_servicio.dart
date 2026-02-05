/// Modalidades de servicio disponibles
enum ModalidadServicio {
  /// Servicio único (un solo día)
  unico, // 'unico' en DB

  /// Servicio diario (todos los días)
  diario, // 'diario' en DB

  /// Servicio semanal (días específicos de la semana)
  semanal, // 'semanal' en DB

  /// Servicio semanas alternas (semana sí, semana no)
  semanasAlternas, // 'semanas_alternas' en DB

  /// Servicio días alternos (cada X días)
  diasAlternos, // 'dias_alternos' en DB

  /// Servicio mensual (días específicos del mes)
  mensual, // 'mensual' en DB

  /// Servicio en fechas específicas
  especifico, // 'especifico' en DB - fechas específicas
}
