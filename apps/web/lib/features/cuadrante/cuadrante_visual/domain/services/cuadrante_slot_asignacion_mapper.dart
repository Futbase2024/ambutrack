import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/domain/entities/cuadrante_slot_entity.dart';

/// Traduce entre slots del cuadrante visual y asignaciones persistidas.
///
/// La tabla `asignaciones_vehiculos_turnos` no tiene columnas propias para el
/// número de unidad ni para el personal, así que esos datos se guardan en la
/// columna `metadata` (jsonb) con las claves definidas aquí.
class CuadranteSlotAsignacionMapper {
  const CuadranteSlotAsignacionMapper._();

  static const String keyNumeroUnidad = 'numero_unidad';
  static const String keyPersonalId = 'personal_id';
  static const String keyPersonalNombre = 'personal_nombre';
  static const String keyRolPersonal = 'rol_personal';

  /// Construye los slots de una dotación a partir de sus asignaciones.
  ///
  /// Las asignaciones con `numero_unidad` en metadata ocupan su unidad; las
  /// antiguas (sin ese dato) rellenan las unidades libres en orden.
  static List<CuadranteSlotEntity> construirSlots({
    required String dotacionId,
    required int cantidadUnidades,
    required DateTime fecha,
    required List<AsignacionVehiculoTurnoEntity> asignaciones,
    Map<String, String> matriculasPorVehiculo = const <String, String>{},
    Map<String, String> nombresPorPersonal = const <String, String>{},
  }) {
    final List<AsignacionVehiculoTurnoEntity> deDotacion = asignaciones
        .where((AsignacionVehiculoTurnoEntity a) => a.dotacionId == dotacionId)
        .toList();

    final Map<int, AsignacionVehiculoTurnoEntity> porUnidad =
        <int, AsignacionVehiculoTurnoEntity>{};
    final List<AsignacionVehiculoTurnoEntity> sinUnidad = <AsignacionVehiculoTurnoEntity>[];

    for (final AsignacionVehiculoTurnoEntity a in deDotacion) {
      final int? unidad = numeroUnidad(a);
      if (unidad != null && unidad >= 1 && unidad <= cantidadUnidades && !porUnidad.containsKey(unidad)) {
        porUnidad[unidad] = a;
      } else {
        sinUnidad.add(a);
      }
    }

    for (int i = 1; i <= cantidadUnidades && sinUnidad.isNotEmpty; i++) {
      if (!porUnidad.containsKey(i)) {
        porUnidad[i] = sinUnidad.removeAt(0);
      }
    }

    return <CuadranteSlotEntity>[
      for (int i = 1; i <= cantidadUnidades; i++)
        _slotDesdeAsignacion(
          dotacionId: dotacionId,
          fecha: fecha,
          numeroUnidad: i,
          asignacion: porUnidad[i],
          matriculasPorVehiculo: matriculasPorVehiculo,
          nombresPorPersonal: nombresPorPersonal,
        ),
    ];
  }

  /// Número de unidad guardado en metadata (null si no existe o no es válido)
  static int? numeroUnidad(AsignacionVehiculoTurnoEntity asignacion) {
    final Object? valor = asignacion.metadata?[keyNumeroUnidad];
    if (valor is int) {
      return valor;
    }
    if (valor is num) {
      return valor.toInt();
    }
    if (valor is String) {
      return int.tryParse(valor);
    }
    return null;
  }

  /// Metadata a persistir para un slot, conservando claves ajenas previas
  static Map<String, dynamic> metadataDesdeSlot(
    CuadranteSlotEntity slot, {
    Map<String, dynamic>? metadataPrevia,
  }) {
    final Map<String, dynamic> metadata = <String, dynamic>{
      ...?metadataPrevia,
      keyNumeroUnidad: slot.numeroUnidad,
    };
    final bool tienePersonal = slot.personalId != null && slot.personalId!.isNotEmpty;
    if (tienePersonal) {
      metadata[keyPersonalId] = slot.personalId;
      metadata[keyPersonalNombre] = slot.personalNombre;
      metadata[keyRolPersonal] = slot.rolPersonal;
    } else {
      metadata
        ..remove(keyPersonalId)
        ..remove(keyPersonalNombre)
        ..remove(keyRolPersonal);
    }
    return metadata;
  }

  static CuadranteSlotEntity _slotDesdeAsignacion({
    required String dotacionId,
    required DateTime fecha,
    required int numeroUnidad,
    required AsignacionVehiculoTurnoEntity? asignacion,
    required Map<String, String> matriculasPorVehiculo,
    required Map<String, String> nombresPorPersonal,
  }) {
    final Map<String, dynamic> metadata = asignacion?.metadata ?? const <String, dynamic>{};
    final String? personalId = _texto(metadata[keyPersonalId]);
    final String? personalNombre =
        _texto(metadata[keyPersonalNombre]) ?? (personalId == null ? null : nombresPorPersonal[personalId]);

    return CuadranteSlotEntity(
      dotacionId: dotacionId,
      fecha: fecha,
      numeroUnidad: numeroUnidad,
      asignacionId: asignacion?.id,
      vehiculoId: asignacion?.vehiculoId,
      vehiculoMatricula: asignacion == null ? null : matriculasPorVehiculo[asignacion.vehiculoId],
      personalId: personalId,
      personalNombre: personalNombre,
      rolPersonal: _texto(metadata[keyRolPersonal]),
      notas: asignacion?.observaciones,
    );
  }

  static String? _texto(Object? valor) {
    if (valor is String && valor.isNotEmpty) {
      return valor;
    }
    return null;
  }
}
