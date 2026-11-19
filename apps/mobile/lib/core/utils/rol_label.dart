/// Traduce el código de rol de la tabla `usuarios` a un nombre de puesto legible.
///
/// Devuelve null si el rol viene vacío; los roles desconocidos se formatean
/// sustituyendo guiones bajos por espacios y capitalizando cada palabra.
String? rolLabel(String? rol) {
  final String? codigo = rol?.trim().toLowerCase();
  if (codigo == null || codigo.isEmpty) {
    return null;
  }
  return switch (codigo) {
    'tecnico' || 'tes' => 'Técnico en Emergencias Sanitarias',
    'conductor' => 'Conductor de Ambulancia',
    'admin' || 'administrador' => 'Administrador',
    'enfermero' => 'Enfermero/a',
    'medico' => 'Médico/a',
    'jefe_mantenimiento' => 'Jefe de Mantenimiento',
    'jefe_trafico' => 'Jefe de Tráfico',
    'jefe_personal' => 'Jefe de Personal',
    'coordinador' => 'Coordinador/a',
    'operador' => 'Operador/a',
    _ => codigo
        .split('_')
        .where((String parte) => parte.isNotEmpty)
        .map((String parte) => '${parte[0].toUpperCase()}${parte.substring(1)}')
        .join(' '),
  };
}

/// Roles de oficina/jefatura que inician turno sin vehículo (fichaje simple)
const Set<String> _rolesSinVehiculo = <String>{
  'admin',
  'administrador',
  'jefe_mantenimiento',
  'jefe_personal',
  'jefe_trafico',
  'coordinador',
  'operador',
};

/// true si el rol ficha entrada sin vehículo, km, checklist ni material
bool rolFichaSinVehiculo(String? rol) => _rolesSinVehiculo.contains(rol?.trim().toLowerCase());

/// Roles que pueden gestionar incidencias de vehículo (cambiar estado, anotar solución)
const Set<String> _rolesGestionIncidencias = <String>{
  'admin',
  'administrador',
  'jefe_mantenimiento',
  'jefe_trafico',
};

bool rolGestionaIncidencias(String? rol) => _rolesGestionIncidencias.contains(rol?.trim().toLowerCase());
