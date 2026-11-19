import '../entities/inicio_turno_entity.dart';

double? _double(dynamic value) => value == null ? null : (value as num).toDouble();

int? _int(dynamic value) => value == null ? null : (value as num).round();

DateTime? _date(dynamic value) => value == null ? null : DateTime.parse(value as String);

/// Model: serialización JSON de la tabla `inicios_turno`
class InicioTurnoSupabaseModel {
  const InicioTurnoSupabaseModel._();

  static InicioTurnoEntity fromJson(Map<String, dynamic> json) {
    return InicioTurnoEntity(
      id: json['id'] as String,
      personalId: json['personal_id'] as String,
      empresaId: json['empresa_id'] as String?,
      registroEntradaId: json['registro_entrada_id'] as String?,
      turnoId: json['turno_id'] as String?,
      personalNombre: json['personal_nombre'] as String?,
      vehiculoId: json['vehiculo_id'] as String?,
      vehiculoMatricula: json['vehiculo_matricula'] as String?,
      baseId: json['base_id'] as String?,
      rol: RolDotacion.fromString(json['rol'] as String?),
      companeroId: json['companero_id'] as String?,
      companeroNombre: json['companero_nombre'] as String?,
      kmInicial: _int(json['km_inicial']),
      combustible: NivelCombustible.fromString(json['combustible'] as String?),
      fotoKmUrl: json['foto_km_url'] as String?,
      checklistItems: _items(json['checklist_items']),
      declaracionAptitud: json['declaracion_aptitud'] as bool? ?? false,
      latitud: _double(json['latitud']),
      longitud: _double(json['longitud']),
      distanciaBaseM: _int(json['distancia_base_m']),
      fueraDeBase: json['fuera_de_base'] as bool? ?? false,
      motivoFueraBase: json['motivo_fuera_base'] as String?,
      avisos: (json['avisos'] as List<dynamic>? ?? const <dynamic>[]).map((dynamic a) => '$a').toList(),
      estadoValidacion: EstadoValidacionInicio.fromString(json['estado_validacion'] as String?),
      validadoPor: json['validado_por'] as String?,
      validadoAt: _date(json['validado_at']),
      motivoRechazo: json['motivo_rechazo'] as String?,
      modoDispositivo: json['modo_dispositivo'] as String?,
      createdAt: _date(json['created_at']),
      kmFinal: _int(json['km_final']),
      fotoKmFinalUrl: json['foto_km_final_url'] as String?,
      numerosP10: json['numeros_p10'] as String?,
      finTurnoAt: _date(json['fin_turno_at']),
    );
  }

  /// JSON de inserción (los campos de validación los gestiona la BD)
  static Map<String, dynamic> toInsertJson(InicioTurnoEntity e) {
    return <String, dynamic>{
      'id': e.id,
      'personal_id': e.personalId,
      'registro_entrada_id': e.registroEntradaId,
      'turno_id': e.turnoId,
      'personal_nombre': e.personalNombre,
      'vehiculo_id': e.vehiculoId,
      'vehiculo_matricula': e.vehiculoMatricula,
      'base_id': e.baseId,
      'rol': e.rol?.value,
      'companero_id': e.companeroId,
      'companero_nombre': e.companeroNombre,
      'km_inicial': e.kmInicial,
      'combustible': e.combustible?.value,
      'foto_km_url': e.fotoKmUrl,
      'checklist_items': e.checklistItems
          .map((ChecklistInicioItem i) => <String, dynamic>{
                'nombre': i.nombre,
                'correcto': i.correcto,
                'observacion': i.observacion,
              })
          .toList(),
      'checklist_ok': e.checklistOk,
      'declaracion_aptitud': e.declaracionAptitud,
      'latitud': e.latitud,
      'longitud': e.longitud,
      'distancia_base_m': e.distanciaBaseM,
      'fuera_de_base': e.fueraDeBase,
      'motivo_fuera_base': e.motivoFueraBase,
      'avisos': e.avisos,
      'modo_dispositivo': e.modoDispositivo,
    };
  }

  static List<ChecklistInicioItem> _items(dynamic value) {
    if (value is! List) {
      return const <ChecklistInicioItem>[];
    }
    return value.whereType<Map<String, dynamic>>().map((Map<String, dynamic> m) {
      return ChecklistInicioItem(
        nombre: m['nombre'] as String? ?? '',
        correcto: m['correcto'] as bool? ?? false,
        observacion: m['observacion'] as String?,
      );
    }).toList();
  }
}
