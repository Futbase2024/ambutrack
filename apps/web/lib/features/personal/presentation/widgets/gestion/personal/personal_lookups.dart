import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/personal/data/services/tablas_maestras_service.dart';
import 'package:ambutrack_web/features/personal/domain/entities/categoria_personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/empresa_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/puesto_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/tipo_contrato_entity.dart';
import 'package:flutter/foundation.dart';

/// Nombres de las tablas maestras relacionadas con el personal (id → texto)
class PersonalLookups {
  const PersonalLookups({
    this.categorias = const <String, String>{},
    this.provincias = const <String, String>{},
    this.puestos = const <String, String>{},
    this.tiposContrato = const <String, String>{},
    this.empresas = const <String, String>{},
    this.bases = const <String, String>{},
    this.dotaciones = const <String, String>{},
    this.vehiculos = const <String, String>{},
    this.contratosCliente = const <String, String>{},
  });

  final Map<String, String> categorias;
  final Map<String, String> provincias;
  final Map<String, String> puestos;
  final Map<String, String> tiposContrato;
  final Map<String, String> empresas;
  final Map<String, String> bases;
  final Map<String, String> dotaciones;
  final Map<String, String> vehiculos;
  final Map<String, String> contratosCliente;

  /// Carga las tablas maestras (con la caché de [TablasMaestrasService])
  static Future<PersonalLookups> load() async {
    final TablasMaestrasService s = TablasMaestrasService();
    try {
      final List<Object> r = await Future.wait(<Future<Object>>[
        s.getCategorias(), s.getProvincias(), s.getPuestos(), s.getContratos(), s.getEmpresas(),
        s.getBases(), s.getDotaciones(), s.getVehiculos(), s.getContratosCliente(),
      ]);
      return PersonalLookups(
        categorias: <String, String>{
          for (final CategoriaPersonalEntity c in r[0] as List<CategoriaPersonalEntity>) c.id: c.categoria,
        },
        provincias: <String, String>{
          for (final ProvinciaEntity p in r[1] as List<ProvinciaEntity>) p.id: p.nombre,
        },
        puestos: <String, String>{for (final PuestoEntity p in r[2] as List<PuestoEntity>) p.id: p.nombre},
        tiposContrato: <String, String>{
          for (final TipoContratoEntity c in r[3] as List<TipoContratoEntity>) c.id: c.nombre,
        },
        empresas: <String, String>{for (final EmpresaEntity e in r[4] as List<EmpresaEntity>) e.id: e.nombre},
        bases: <String, String>{for (final BaseCentroEntity b in r[5] as List<BaseCentroEntity>) b.id: b.nombre},
        dotaciones: <String, String>{
          for (final DotacionEntity d in r[6] as List<DotacionEntity>) d.id: d.nombre,
        },
        vehiculos: <String, String>{
          for (final VehiculoEntity v in r[7] as List<VehiculoEntity>) v.id: v.matricula,
        },
        contratosCliente: <String, String>{
          for (final ContratoEntity c in r[8] as List<ContratoEntity>) c.id: c.codigo,
        },
      );
    } catch (e) {
      debugPrint('❌ PersonalLookups: error al cargar tablas maestras: $e');
      return const PersonalLookups();
    }
  }
}
