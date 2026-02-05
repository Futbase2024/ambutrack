/// Roles de usuario en AmbuTrack
///
/// Define los 10 roles disponibles en el sistema con sus descripciones.
/// Cada rol tiene permisos específicos para acceder a módulos de la aplicación.
enum UserRole {
  /// Acceso total al sistema
  /// - Todos los módulos disponibles
  /// - Puede gestionar usuarios y roles
  admin('admin', 'Administrador', 'Acceso total al sistema'),

  /// Gestión de RRHH, turnos, ausencias y vacaciones
  /// - Módulos: personal, turnos, ausencias, vacaciones, cuadrantes, reportes_personal
  jefePersonal('jefe_personal', 'Jefe de Personal', 'Gestión RRHH y turnos'),

  /// Operaciones, servicios y vehículos
  /// - Módulos: servicios, vehiculos, cuadrantes, dotaciones, bases, operaciones
  jefeTrafic('jefe_trafico', 'Jefe de Tráfico', 'Operaciones y servicios'),

  /// Supervisión operativa e incidencias
  /// - Módulos: servicios, cuadrantes, incidencias, operaciones, comunicaciones
  coordinador('coordinador', 'Coordinador', 'Supervisión operativa'),

  /// Gestión documental y contratos
  /// - Módulos: contratos, documentacion, personal, vehiculos, calendario
  administrativo('administrativo', 'Administrativo', 'Gestión documental'),

  /// Acceso a datos propios (conductor)
  /// - Módulos: mis_turnos, mis_servicios, mis_ausencias
  conductor('conductor', 'Conductor', 'Acceso a datos propios'),

  /// Acceso a datos propios (sanitario)
  /// - Módulos: mis_turnos, mis_servicios, mis_ausencias
  sanitario('sanitario', 'Sanitario', 'Acceso a datos propios'),

  /// Gestión de flota (rol heredado)
  /// - Módulos: vehiculos, mantenimiento, itv
  gestor('gestor', 'Gestor de Flota', 'Gestión de vehículos'),

  /// Mantenimiento (rol heredado)
  /// - Módulos: mantenimiento, talleres, repuestos
  tecnico('tecnico', 'Técnico', 'Mantenimiento de vehículos'),

  /// Solo lectura (rol heredado)
  /// - Módulos: Consulta sin modificación
  operador('operador', 'Operador', 'Solo lectura');

  const UserRole(this.value, this.label, this.description);

  /// Valor del rol (usado en base de datos)
  final String value;

  /// Etiqueta del rol (UI)
  final String label;

  /// Descripción del rol
  final String description;

  /// Crea un UserRole desde un string
  static UserRole fromString(String? value) {
    if (value == null || value.isEmpty) {
      return UserRole.operador; // Rol por defecto
    }

    return UserRole.values.firstWhere(
      (UserRole role) => role.value == value.toLowerCase(),
      orElse: () => UserRole.operador,
    );
  }

  /// Verifica si el rol es de administración
  bool get isAdmin => this == UserRole.admin;

  /// Verifica si el rol es de gestión (admin, jefe_personal, jefe_trafico)
  bool get isManager =>
      this == UserRole.admin ||
      this == UserRole.jefePersonal ||
      this == UserRole.jefeTrafic;

  /// Verifica si el rol es operativo (conductor, sanitario)
  bool get isOperative => this == UserRole.conductor || this == UserRole.sanitario;

  /// Verifica si el rol es de solo lectura
  bool get isReadOnly => this == UserRole.operador;

  @override
  String toString() => value;
}
