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

/// Palabras clave de categorías de personal que van en ambulancia
const List<String> _categoriasOperativas = <String>[
  'tecnico',
  'tes',
  'conductor',
  'enfermer',
  'medic',
  'sanitari',
  'ambulancia',
];

/// Minúsculas y sin tildes, para comparar categorías escritas a mano
String _normalizar(String texto) {
  const Map<String, String> tildes = <String, String>{'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u'};
  return texto.trim().toLowerCase().split('').map((String c) => tildes[c] ?? c).join();
}

/// true si la categoría de la ficha de personal es de puesto en ambulancia
bool categoriaOperativa(String? categoria) {
  final List<String> palabras = _normalizar(categoria ?? '').split(RegExp(r'[^a-z]+'));
  return palabras.any((String p) => _categoriasOperativas.any(p.startsWith));
}

/// true si el usuario ficha entrada sin vehículo, km, checklist ni material.
///
/// Manda la categoría de la ficha de personal: un TES/conductor/sanitario pasa
/// por el asistente completo aunque su rol de usuario sea de oficina (ej. admin).
bool rolFichaSinVehiculo(String? rol, {String? categoria}) {
  if (categoriaOperativa(categoria)) {
    return false;
  }
  return _rolesSinVehiculo.contains(rol?.trim().toLowerCase());
}

/// Roles que pueden gestionar incidencias de vehículo (cambiar estado, anotar solución)
const Set<String> _rolesGestionIncidencias = <String>{
  'admin',
  'administrador',
  'jefe_mantenimiento',
  'jefe_trafico',
};

bool rolGestionaIncidencias(String? rol) => _rolesGestionIncidencias.contains(rol?.trim().toLowerCase());
