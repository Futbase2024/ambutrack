import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/features/contratos/domain/repositories/contrato_repository.dart';
import 'package:ambutrack_web/features/cuadrante/bases/domain/repositories/bases_repository.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/domain/repositories/centro_hospitalario_repository.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/domain/repositories/tipo_vehiculo_repository.dart';
import 'package:flutter/foundation.dart';

/// Nombres de los catálogos relacionados con las dotaciones (solo lectura).
///
/// Reutiliza los mismos repositorios que el formulario de dotación para
/// mostrar nombres en lugar de IDs en la rejilla y la ficha.
class DotacionesCatalogos {
  const DotacionesCatalogos({
    this.hospitales = const <String, String>{},
    this.bases = const <String, String>{},
    this.contratos = const <String, String>{},
    this.tiposVehiculo = const <String, String>{},
  });

  final Map<String, String> hospitales;
  final Map<String, String> bases;
  final Map<String, String> contratos;
  final Map<String, String> tiposVehiculo;

  /// Nombre del destino de la dotación (hospital, base o contrato)
  String? destinoNombre(DotacionEntity d) {
    if (d.hospitalId != null) {
      return hospitales[d.hospitalId];
    }
    if (d.baseId != null) {
      return bases[d.baseId];
    }
    if (d.contratoId != null) {
      return contratos[d.contratoId];
    }
    return null;
  }

  String? tipoVehiculoNombre(DotacionEntity d) => tiposVehiculo[d.tipoVehiculoId];

  /// Carga los catálogos; si alguno falla se devuelve vacío (solo afecta a la vista)
  static Future<DotacionesCatalogos> cargar() async {
    try {
      final List<CentroHospitalarioEntity> hospitales =
          await getIt<CentroHospitalarioRepository>().getAll();
      final List<BaseCentroEntity> bases = await getIt<BasesRepository>().getAll();
      final List<ContratoEntity> contratos = await getIt<ContratoRepository>().getAll();
      final List<TipoVehiculoEntity> tipos = await getIt<TipoVehiculoRepository>().getAll();
      return DotacionesCatalogos(
        hospitales: <String, String>{
          for (final CentroHospitalarioEntity h in hospitales) h.id: h.nombre,
        },
        bases: <String, String>{for (final BaseCentroEntity b in bases) b.id: b.nombre},
        contratos: <String, String>{for (final ContratoEntity c in contratos) c.id: c.codigo},
        tiposVehiculo: <String, String>{for (final TipoVehiculoEntity t in tipos) t.id: t.nombre},
      );
    } catch (e) {
      debugPrint('⚠️ DotacionesCatalogos: no se pudieron cargar los catálogos - $e');
      return const DotacionesCatalogos();
    }
  }
}
