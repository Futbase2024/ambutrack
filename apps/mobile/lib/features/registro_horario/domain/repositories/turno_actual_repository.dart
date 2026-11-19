import 'dart:typed_data';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Contrato para resolver el turno en curso del trabajador al fichar
///
/// Agrupa las consultas necesarias para iniciar turno desde la app:
/// turno vigente del cuadrante, vehículos operativos y plantillas.
abstract class TurnoActualRepository {
  /// Turno del cuadrante que contiene el momento actual (o null)
  Future<TurnoEntity?> obtenerTurnoVigente(String idPersonal);

  /// Turnos de otros trabajadores en el mismo vehículo ahora mismo
  Future<List<TurnoEntity>> obtenerCompaneros({
    required String idVehiculo,
    required String idPersonalExcluido,
  });

  /// Próximo turno planificado a partir de mañana
  Future<TurnoEntity?> obtenerProximoTurno(String idPersonal);

  /// Crea un turno (desde la app: origen app, sin validar)
  Future<TurnoEntity> crearTurno(TurnoEntity turno);

  /// Actualiza un turno (ej: cambio de vehículo)
  Future<TurnoEntity> actualizarTurno(TurnoEntity turno);

  /// Vehículo por ID
  Future<VehiculoEntity?> obtenerVehiculo(String id);

  /// Vehículos en estado activo (operativos)
  Future<List<VehiculoEntity>> obtenerVehiculosOperativos();

  /// Plantillas de turno activas (Mañana, Tarde, Noche, 12h, 24h...)
  Future<List<PlantillaTurnoEntity>> obtenerPlantillas();

  /// Puntos del checklist corto de inicio de turno
  Future<List<String>> obtenerPlantillaChecklist();

  /// Personas con la jornada abierta en el vehículo
  Future<List<OcupanteVehiculoEntity>> obtenerOcupacionVehiculo(String idVehiculo);

  /// Coordenadas de la base (para la geocerca)
  Future<UbicacionBaseEntity?> obtenerUbicacionBase(String idBase);

  /// Documentación del trabajador (carnet, certificados...)
  Future<List<DocumentoPersonalEntity>> obtenerDocumentosPersonal(String idPersonal);

  /// Material (stock) del vehículo, para avisar de caducidades
  Future<List<StockVehiculoEntity>> obtenerMaterialVehiculo(String idVehiculo);

  /// Personal activo (para elegir compañero)
  Future<List<TPersonalEntity>> obtenerPersonalActivo();

  /// Sube la foto del cuentakilómetros y devuelve su ruta
  Future<String> subirFotoKm({required Uint8List bytes, required String extension});

  /// Registra los datos de la entrada en turno
  Future<InicioTurnoEntity> registrarInicioTurno(InicioTurnoEntity inicio);

  /// Último inicio de turno del trabajador aún sin cerrar (o null)
  Future<InicioTurnoEntity?> obtenerInicioAbierto(String idPersonal);

  /// Cierra el turno: km final (obligatorio) y P-10 entregados (opcional)
  Future<void> registrarFinTurno({
    required String idInicioTurno,
    required int kmFinal,
    String? numerosP10,
  });
}
