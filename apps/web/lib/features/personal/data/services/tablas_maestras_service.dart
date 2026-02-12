import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/personal/domain/entities/categoria_personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/empresa_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/poblacion_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/puesto_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/tipo_contrato_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio para cargar tablas maestras relacionadas con Personal
/// Implementa caché en memoria para reducir llamadas a Supabase
/// SINGLETON para evitar múltiples instancias
class TablasMaestrasService {
  TablasMaestrasService._();

  // ignore: sort_unnamed_constructors_first
  factory TablasMaestrasService() => _instance;

  // Singleton
  static final TablasMaestrasService _instance = TablasMaestrasService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Caché en memoria
  static List<ProvinciaEntity>? _cachedProvincias;
  static List<PuestoEntity>? _cachedPuestos;
  static List<TipoContratoEntity>? _cachedContratos;
  static List<EmpresaEntity>? _cachedEmpresas;
  static List<CategoriaPersonalEntity>? _cachedCategorias;
  static final Map<String, List<PoblacionEntity>> _cachedPoblaciones = <String, List<PoblacionEntity>>{};

  static DateTime? _lastFetchProvincias;
  static DateTime? _lastFetchPuestos;
  static DateTime? _lastFetchContratos;
  static DateTime? _lastFetchEmpresas;
  static DateTime? _lastFetchCategorias;

  // Duración del caché (24 horas para tablas maestras que casi no cambian)
  static const Duration _cacheDuration = Duration(hours: 24);

  /// Obtiene todas las provincias (con caché de 24h)
  Future<List<ProvinciaEntity>> getProvincias() async {
    // Verificar caché
    if (_cachedProvincias != null &&
        _lastFetchProvincias != null &&
        DateTime.now().difference(_lastFetchProvincias!) < _cacheDuration) {
      debugPrint('⚡ TablasMaestrasService: Usando caché de provincias (${_cachedProvincias!.length} items)');
      return _cachedProvincias!;
    }

    try {
      debugPrint('🔍 TablasMaestrasService: Cargando provincias desde Supabase...');
      final dynamic response = await _supabase.from('tprovincias').select();

      if (response is List) {
        final List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(response);
        debugPrint('✅ Provincias cargadas: ${dataList.length}');

        if (dataList.isEmpty) {
          debugPrint('⚠️ La tabla tprovincias está vacía o hay un problema de permisos RLS');
        }

        final List<ProvinciaEntity> provincias = dataList
            .map((Map<String, dynamic> json) => ProvinciaSupabaseModel.fromJson(json).toEntity())
            .toList()
          ..sort((ProvinciaEntity a, ProvinciaEntity b) => a.nombre.compareTo(b.nombre));

        // Actualizar caché
        _cachedProvincias = provincias;
        _lastFetchProvincias = DateTime.now();

        return provincias;
      }

      debugPrint('❌ Response no es una lista: $response');
      return <ProvinciaEntity>[];
    } catch (e, stackTrace) {
      debugPrint('❌ Error al obtener provincias: $e');
      debugPrint('❌ StackTrace: $stackTrace');
      return <ProvinciaEntity>[];
    }
  }

  /// Obtiene todas las poblaciones (con caché por provincia)
  Future<List<PoblacionEntity>> getPoblaciones({String? provinciaId}) async {
    if (provinciaId == null) {
      return <PoblacionEntity>[];
    }

    // Verificar caché para esta provincia
    if (_cachedPoblaciones.containsKey(provinciaId)) {
      debugPrint('⚡ TablasMaestrasService: Usando caché de poblaciones para provincia $provinciaId');
      return _cachedPoblaciones[provinciaId]!;
    }

    try {
      debugPrint('🔍 TablasMaestrasService: Cargando poblaciones de provincia $provinciaId desde Supabase...');
      final List<Map<String, dynamic>> response = await _supabase
          .from('tpoblaciones')
          .select()
          .eq('provincia_id', provinciaId)
          .order('nombre');

      debugPrint('✅ Poblaciones cargadas: ${response.length}');

      final List<PoblacionEntity> poblaciones = response.map(PoblacionEntity.fromMap).toList();

      // Actualizar caché
      _cachedPoblaciones[provinciaId] = poblaciones;

      return poblaciones;
    } catch (e) {
      debugPrint('❌ Error al obtener poblaciones: $e');
      return <PoblacionEntity>[];
    }
  }

  /// Obtiene todos los puestos de trabajo (con caché de 24h)
  Future<List<PuestoEntity>> getPuestos() async {
    // Verificar caché
    if (_cachedPuestos != null &&
        _lastFetchPuestos != null &&
        DateTime.now().difference(_lastFetchPuestos!) < _cacheDuration) {
      debugPrint('⚡ TablasMaestrasService: Usando caché de puestos (${_cachedPuestos!.length} items)');
      return _cachedPuestos!;
    }

    try {
      debugPrint('🔍 TablasMaestrasService: Cargando puestos desde Supabase...');
      final List<Map<String, dynamic>> response =
          await _supabase.from('tpuestos').select().order('nombre');

      final List<PuestoEntity> puestos = response.map(PuestoEntity.fromMap).toList();

      // Actualizar caché
      _cachedPuestos = puestos;
      _lastFetchPuestos = DateTime.now();

      return puestos;
    } catch (e) {
      debugPrint('❌ Error al obtener puestos: $e');
      return <PuestoEntity>[];
    }
  }

  /// Obtiene todos los tipos de contrato laboral (con caché de 24h)
  Future<List<TipoContratoEntity>> getContratos() async {
    // Verificar caché
    if (_cachedContratos != null &&
        _lastFetchContratos != null &&
        DateTime.now().difference(_lastFetchContratos!) < _cacheDuration) {
      debugPrint('⚡ TablasMaestrasService: Usando caché de tipos de contrato (${_cachedContratos!.length} items)');
      return _cachedContratos!;
    }

    try {
      debugPrint('🔍 TablasMaestrasService: Cargando tipos de contrato desde Supabase...');
      final List<Map<String, dynamic>> response =
          await _supabase.from('tcontratos').select().order('nombre');

      final List<TipoContratoEntity> contratos = response
          .map(TipoContratoEntity.fromMap)
          .toList();

      // Actualizar caché
      _cachedContratos = contratos;
      _lastFetchContratos = DateTime.now();

      return contratos;
    } catch (e) {
      debugPrint('❌ Error al obtener tipos de contrato: $e');
      return <TipoContratoEntity>[];
    }
  }

  /// Obtiene todas las empresas (con caché de 24h)
  Future<List<EmpresaEntity>> getEmpresas() async {
    // Verificar caché
    if (_cachedEmpresas != null &&
        _lastFetchEmpresas != null &&
        DateTime.now().difference(_lastFetchEmpresas!) < _cacheDuration) {
      debugPrint('⚡ TablasMaestrasService: Usando caché de empresas (${_cachedEmpresas!.length} items)');
      return _cachedEmpresas!;
    }

    try {
      debugPrint('🔍 TablasMaestrasService: Cargando empresas desde Supabase...');
      final List<Map<String, dynamic>> response =
          await _supabase.from('tempresas').select().order('nombre');

      final List<EmpresaEntity> empresas = response.map(EmpresaEntity.fromMap).toList();

      // Actualizar caché
      _cachedEmpresas = empresas;
      _lastFetchEmpresas = DateTime.now();

      return empresas;
    } catch (e) {
      debugPrint('❌ Error al obtener empresas: $e');
      return <EmpresaEntity>[];
    }
  }

  /// Obtiene todas las categorías de personal (con caché de 24h)
  Future<List<CategoriaPersonalEntity>> getCategorias() async {
    // Verificar caché
    if (_cachedCategorias != null &&
        _lastFetchCategorias != null &&
        DateTime.now().difference(_lastFetchCategorias!) < _cacheDuration) {
      debugPrint('⚡ TablasMaestrasService: Usando caché de categorías (${_cachedCategorias!.length} items)');
      return _cachedCategorias!;
    }

    try {
      debugPrint('🔍 TablasMaestrasService: Cargando categorías desde Supabase...');
      final List<Map<String, dynamic>> response =
          await _supabase.from('tcategorias').select().order('nombre');

      final List<CategoriaPersonalEntity> categorias = response.map(CategoriaPersonalEntity.fromMap).toList();

      // Actualizar caché
      _cachedCategorias = categorias;
      _lastFetchCategorias = DateTime.now();

      return categorias;
    } catch (e) {
      debugPrint('❌ Error al obtener categorías: $e');
      return <CategoriaPersonalEntity>[];
    }
  }

  /// Invalida todo el caché
  /// Usar cuando:
  /// - Se crea/edita/elimina una provincia, puesto, contrato, empresa o categoría
  /// - Hay problemas de sincronización de datos
  /// - Se detecta que los datos están desactualizados
  static void invalidateCache() {
    debugPrint('🔄 TablasMaestrasService: Invalidando todo el caché');
    _cachedProvincias = null;
    _cachedPuestos = null;
    _cachedContratos = null;
    _cachedEmpresas = null;
    _cachedCategorias = null;
    _cachedPoblaciones.clear();
    _lastFetchProvincias = null;
    _lastFetchPuestos = null;
    _lastFetchContratos = null;
    _lastFetchEmpresas = null;
    _lastFetchCategorias = null;
  }

  /// Invalida caché de una tabla específica
  static void invalidateCacheForTable(String tableName) {
    debugPrint('🔄 TablasMaestrasService: Invalidando caché de tabla $tableName');
    switch (tableName) {
      case 'tprovincias':
        _cachedProvincias = null;
        _lastFetchProvincias = null;
      case 'tpuestos':
        _cachedPuestos = null;
        _lastFetchPuestos = null;
      case 'tcontratos':
        _cachedContratos = null;
        _lastFetchContratos = null;
      case 'tempresas':
        _cachedEmpresas = null;
        _lastFetchEmpresas = null;
      case 'tcategorias':
        _cachedCategorias = null;
        _lastFetchCategorias = null;
      case 'tpoblaciones':
        _cachedPoblaciones.clear();
      default:
        debugPrint('⚠️ Tabla desconocida: $tableName');
    }
  }

  /// Invalida caché de poblaciones para una provincia específica
  static void invalidatePoblacionesForProvincia(String provinciaId) {
    debugPrint('🔄 TablasMaestrasService: Invalidando caché de poblaciones para provincia $provinciaId');
    _cachedPoblaciones.remove(provinciaId);
  }

  /// Fuerza la recarga de todas las tablas maestras
  /// Útil para debugging o cuando se sospecha de datos inconsistentes
  Future<void> reloadAll() async {
    debugPrint('♻️ TablasMaestrasService: Forzando recarga de todas las tablas maestras...');
    invalidateCache();

    // Cargar todas las tablas en paralelo
    await Future.wait(<Future<void>>[
      getProvincias().then((_) => debugPrint('✅ Provincias recargadas')),
      getPuestos().then((_) => debugPrint('✅ Puestos recargados')),
      getContratos().then((_) => debugPrint('✅ Contratos recargados')),
      getEmpresas().then((_) => debugPrint('✅ Empresas recargadas')),
      getCategorias().then((_) => debugPrint('✅ Categorías recargadas')),
    ]);

    debugPrint('♻️ TablasMaestrasService: ✅ Todas las tablas maestras recargadas');
  }

  // =====================================================
  // MÉTODOS DE ESCRITURA (CREATE/UPDATE/DELETE)
  // Con auto-invalidación de caché
  // =====================================================

  /// Crea una nueva categoría de personal
  /// Invalida automáticamente el caché de categorías
  Future<CategoriaPersonalEntity> createCategoria(CategoriaPersonalEntity categoria) async {
    try {
      debugPrint('➕ TablasMaestrasService: Creando categoría "${categoria.categoria}"...');

      final List<Map<String, dynamic>> response = await _supabase
          .from('tcategorias')
          .insert(categoria.toMap())
          .select();

      if (response.isEmpty) {
        throw Exception('No se recibió respuesta al crear categoría');
      }

      final CategoriaPersonalEntity created = CategoriaPersonalEntity.fromMap(response.first);

      // Auto-invalidar caché
      invalidateCacheForTable('tcategorias');
      debugPrint('✅ Categoría creada y caché invalidado');

      return created;
    } catch (e) {
      debugPrint('❌ Error al crear categoría: $e');
      rethrow;
    }
  }

  /// Actualiza una categoría de personal existente
  /// Invalida automáticamente el caché de categorías
  Future<CategoriaPersonalEntity> updateCategoria(CategoriaPersonalEntity categoria) async {
    try {
      debugPrint('📝 TablasMaestrasService: Actualizando categoría "${categoria.id}"...');

      final List<Map<String, dynamic>> response = await _supabase
          .from('tcategorias')
          .update(categoria.toMap())
          .eq('id', categoria.id)
          .select();

      if (response.isEmpty) {
        throw Exception('Categoría no encontrada');
      }

      final CategoriaPersonalEntity updated = CategoriaPersonalEntity.fromMap(response.first);

      // Auto-invalidar caché
      invalidateCacheForTable('tcategorias');
      debugPrint('✅ Categoría actualizada y caché invalidado');

      return updated;
    } catch (e) {
      debugPrint('❌ Error al actualizar categoría: $e');
      rethrow;
    }
  }

  /// Elimina una categoría de personal
  /// Invalida automáticamente el caché de categorías
  Future<void> deleteCategoria(String id) async {
    try {
      debugPrint('🗑️ TablasMaestrasService: Eliminando categoría "$id"...');

      await _supabase.from('tcategorias').delete().eq('id', id);

      // Auto-invalidar caché
      invalidateCacheForTable('tcategorias');
      debugPrint('✅ Categoría eliminada y caché invalidado');
    } catch (e) {
      debugPrint('❌ Error al eliminar categoría: $e');
      rethrow;
    }
  }

  /// Crea una nueva provincia
  /// Invalida automáticamente el caché de provincias
  Future<ProvinciaEntity> createProvincia(ProvinciaEntity provincia) async {
    try {
      debugPrint('➕ TablasMaestrasService: Creando provincia "${provincia.nombre}"...');

      final ProvinciaSupabaseModel model = ProvinciaSupabaseModel.fromEntity(provincia);
      final List<Map<String, dynamic>> response = await _supabase
          .from('tprovincias')
          .insert(model.toJson())
          .select();

      if (response.isEmpty) {
        throw Exception('No se recibió respuesta al crear provincia');
      }

      final ProvinciaEntity created = ProvinciaSupabaseModel.fromJson(response.first).toEntity();

      // Auto-invalidar caché
      invalidateCacheForTable('tprovincias');
      debugPrint('✅ Provincia creada y caché invalidado');

      return created;
    } catch (e) {
      debugPrint('❌ Error al crear provincia: $e');
      rethrow;
    }
  }

  /// Actualiza una provincia existente
  /// Invalida automáticamente el caché de provincias
  Future<ProvinciaEntity> updateProvincia(ProvinciaEntity provincia) async {
    try {
      debugPrint('📝 TablasMaestrasService: Actualizando provincia "${provincia.id}"...');

      final ProvinciaSupabaseModel model = ProvinciaSupabaseModel.fromEntity(provincia);
      final List<Map<String, dynamic>> response = await _supabase
          .from('tprovincias')
          .update(model.toJson())
          .eq('id', provincia.id)
          .select();

      if (response.isEmpty) {
        throw Exception('Provincia no encontrada');
      }

      final ProvinciaEntity updated = ProvinciaSupabaseModel.fromJson(response.first).toEntity();

      // Auto-invalidar caché
      invalidateCacheForTable('tprovincias');
      debugPrint('✅ Provincia actualizada y caché invalidado');

      return updated;
    } catch (e) {
      debugPrint('❌ Error al actualizar provincia: $e');
      rethrow;
    }
  }

  /// Elimina una provincia
  /// Invalida automáticamente el caché de provincias
  Future<void> deleteProvincia(String id) async {
    try {
      debugPrint('🗑️ TablasMaestrasService: Eliminando provincia "$id"...');

      await _supabase.from('tprovincias').delete().eq('id', id);

      // Auto-invalidar caché
      invalidateCacheForTable('tprovincias');
      debugPrint('✅ Provincia eliminada y caché invalidado');
    } catch (e) {
      debugPrint('❌ Error al eliminar provincia: $e');
      rethrow;
    }
  }

  /// Crea una nueva población
  /// Invalida automáticamente el caché de poblaciones de esa provincia
  Future<PoblacionEntity> createPoblacion(PoblacionEntity poblacion) async {
    try {
      debugPrint('➕ TablasMaestrasService: Creando población "${poblacion.nombre}"...');

      final List<Map<String, dynamic>> response = await _supabase
          .from('tpoblaciones')
          .insert(poblacion.toMap())
          .select();

      if (response.isEmpty) {
        throw Exception('No se recibió respuesta al crear población');
      }

      final PoblacionEntity created = PoblacionEntity.fromMap(response.first);

      // Auto-invalidar caché de esa provincia específica
      if (created.provinciaId != null) {
        invalidatePoblacionesForProvincia(created.provinciaId!);
      }
      debugPrint('✅ Población creada y caché de provincia invalidado');

      return created;
    } catch (e) {
      debugPrint('❌ Error al crear población: $e');
      rethrow;
    }
  }

  /// Actualiza una población existente
  /// Invalida automáticamente el caché de poblaciones de esa provincia
  Future<PoblacionEntity> updatePoblacion(PoblacionEntity poblacion) async {
    try {
      debugPrint('📝 TablasMaestrasService: Actualizando población "${poblacion.id}"...');

      final List<Map<String, dynamic>> response = await _supabase
          .from('tpoblaciones')
          .update(poblacion.toMap())
          .eq('id', poblacion.id)
          .select();

      if (response.isEmpty) {
        throw Exception('Población no encontrada');
      }

      final PoblacionEntity updated = PoblacionEntity.fromMap(response.first);

      // Auto-invalidar caché de esa provincia específica
      if (updated.provinciaId != null) {
        invalidatePoblacionesForProvincia(updated.provinciaId!);
      }
      debugPrint('✅ Población actualizada y caché de provincia invalidado');

      return updated;
    } catch (e) {
      debugPrint('❌ Error al actualizar población: $e');
      rethrow;
    }
  }

  /// Elimina una población
  /// Invalida automáticamente el caché de poblaciones de esa provincia
  Future<void> deletePoblacion(String id, String provinciaId) async {
    try {
      debugPrint('🗑️ TablasMaestrasService: Eliminando población "$id"...');

      await _supabase.from('tpoblaciones').delete().eq('id', id);

      // Auto-invalidar caché de esa provincia específica
      invalidatePoblacionesForProvincia(provinciaId);
      debugPrint('✅ Población eliminada y caché de provincia invalidado');
    } catch (e) {
      debugPrint('❌ Error al eliminar población: $e');
      rethrow;
    }
  }

  // NOTA: Implementar métodos similares para Puestos, Contratos y Empresas
  // según se vayan necesitando en la aplicación
}
