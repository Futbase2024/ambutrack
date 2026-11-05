import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/features/cuadrante/bases/domain/repositories/bases_repository.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/domain/repositories/dotaciones_repository.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/domain/repositories/centro_hospitalario_repository.dart';
import 'package:ambutrack_web/features/turnos/domain/repositories/plantilla_turno_repository.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/vehiculo_repository.dart';
import 'package:flutter/foundation.dart';

/// Nombres de los catálogos relacionados con las asignaciones (solo lectura).
///
/// Permite mostrar matrícula / nombre en lugar de IDs. Si un catálogo no se
/// puede cargar se muestra el ID original, como hacía la tabla anterior.
class AsignacionesCatalogos {
  const AsignacionesCatalogos({
    this.vehiculos = const <String, String>{},
    this.dotaciones = const <String, String>{},
    this.plantillas = const <String, String>{},
    this.hospitales = const <String, String>{},
    this.bases = const <String, String>{},
  });

  final Map<String, String> vehiculos;
  final Map<String, String> dotaciones;
  final Map<String, String> plantillas;
  final Map<String, String> hospitales;
  final Map<String, String> bases;

  String vehiculo(AsignacionVehiculoTurnoEntity a) => vehiculos[a.vehiculoId] ?? a.vehiculoId;

  String dotacion(AsignacionVehiculoTurnoEntity a) => dotaciones[a.dotacionId] ?? a.dotacionId;

  String? turno(AsignacionVehiculoTurnoEntity a) {
    final String? id = a.plantillaTurnoId;
    return id == null ? null : (plantillas[id] ?? id);
  }

  /// Nombre del destino (hospital o base)
  String? destino(AsignacionVehiculoTurnoEntity a) {
    if (a.hospitalId != null) {
      return hospitales[a.hospitalId] ?? a.hospitalId;
    }
    if (a.baseId != null) {
      return bases[a.baseId] ?? a.baseId;
    }
    return null;
  }

  static Future<Map<String, String>> _safe(String nombre, Future<Map<String, String>> Function() load) async {
    try {
      return await load();
    } catch (e) {
      debugPrint('⚠️ AsignacionesCatalogos: no se pudo cargar $nombre - $e');
      return const <String, String>{};
    }
  }

  static Future<AsignacionesCatalogos> cargar() async {
    final Map<String, String> vehiculos = await _safe('vehículos', () async {
      final List<VehiculoEntity> l = await getIt<VehiculoRepository>().getAll();
      return <String, String>{for (final VehiculoEntity v in l) v.id: v.matricula};
    });
    final Map<String, String> dotaciones = await _safe('dotaciones', () async {
      final List<DotacionEntity> l = await getIt<DotacionesRepository>().getAll();
      return <String, String>{for (final DotacionEntity d in l) d.id: d.nombre};
    });
    final Map<String, String> plantillas = await _safe('plantillas', () async {
      final List<PlantillaTurnoEntity> l = await getIt<PlantillaTurnoRepository>().getAll();
      return <String, String>{for (final PlantillaTurnoEntity p in l) p.id: p.nombre};
    });
    final Map<String, String> hospitales = await _safe('hospitales', () async {
      final List<CentroHospitalarioEntity> l = await getIt<CentroHospitalarioRepository>().getAll();
      return <String, String>{for (final CentroHospitalarioEntity h in l) h.id: h.nombre};
    });
    final Map<String, String> bases = await _safe('bases', () async {
      final List<BaseCentroEntity> l = await getIt<BasesRepository>().getAll();
      return <String, String>{for (final BaseCentroEntity b in l) b.id: b.nombre};
    });
    return AsignacionesCatalogos(
      vehiculos: vehiculos,
      dotaciones: dotaciones,
      plantillas: plantillas,
      hospitales: hospitales,
      bases: bases,
    );
  }
}
