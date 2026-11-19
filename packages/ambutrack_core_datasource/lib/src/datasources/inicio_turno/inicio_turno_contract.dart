import 'dart:typed_data';

import 'entities/inicio_turno_entity.dart';

/// Contrato del datasource de entrada en turno
abstract class InicioTurnoDataSource {
  /// Registra los datos de la entrada en turno
  Future<InicioTurnoEntity> create(InicioTurnoEntity entity);

  /// Puntos activos del checklist corto de inicio de turno (ordenados)
  Future<List<String>> getPlantillaChecklist();

  /// Personas con la jornada abierta en el vehículo
  Future<List<OcupanteVehiculoEntity>> getOcupacionVehiculo(String vehiculoId);

  /// Coordenadas de la base (null si no existe o no tiene coordenadas)
  Future<UbicacionBaseEntity?> getUbicacionBase(String baseId);

  /// Sube la foto del cuentakilómetros y devuelve su ruta en storage
  Future<String> subirFotoKm({required Uint8List bytes, required String extension});

  /// URL firmada temporal para ver una foto del cuentakilómetros
  Future<String> getUrlFotoKm(String ruta);

  /// Rol (`usuarios.rol`) del usuario autenticado
  Future<String?> getRolUsuarioActual();

  /// Inicios de turno pendientes de validar por coordinación
  Future<List<InicioTurnoEntity>> getPendientesValidacion();

  /// Inicios de turno en un rango de fechas (más recientes primero)
  Future<List<InicioTurnoEntity>> getByRango({required DateTime desde, required DateTime hasta});

  /// Aprueba o rechaza un inicio de turno pendiente
  Future<InicioTurnoEntity> validar({
    required String id,
    required bool aprobado,
    String? motivoRechazo,
  });

  /// Inicios de turno de una persona en un rango (más antiguos primero)
  Future<List<InicioTurnoEntity>> getByPersonal({
    required String personalId,
    required DateTime desde,
    required DateTime hasta,
  });

  /// Último inicio de turno de la persona que aún no tiene fin de turno
  Future<InicioTurnoEntity?> getAbiertoPorPersonal(String personalId);

  /// Cierra el turno: km final (obligatorio) y P-10 entregados (opcional)
  ///
  /// RPC `fn_registrar_fin_turno`: valida que el registro sea del usuario y km final ≥ inicial.
  Future<void> registrarFinTurno({
    required String inicioTurnoId,
    required int kmFinal,
    String? fotoKmFinalUrl,
    String? numerosP10,
  });
}
