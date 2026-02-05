import 'package:ambutrack_web/core/datasource/base_datasource.dart';
import 'package:ambutrack_web/core/datasource/complex_datasource.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementación del repositorio de personal con Supabase
@LazySingleton(as: PersonalRepository)
class PersonalRepositoryImpl implements PersonalRepository {
  PersonalRepositoryImpl() {
    _dataSource = ComplexDataSource<PersonalEntity>(
      tableName: 'tpersonal',
      fromMap: PersonalEntity.fromMap,
      toMap: (PersonalEntity entity) => entity.toMap(),
    );
  }

  late final ComplexDataSource<PersonalEntity> _dataSource;

  /// Cache manual para getAll() con JOIN
  DateTime? _lastFetch;
  List<PersonalEntity>? _cachedPersonal;
  final Duration _cacheDuration = const Duration(minutes: 15);

  @override
  Future<List<PersonalEntity>> getAll({
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    // Verificar si el caché es válido
    final bool cacheValid = _lastFetch != null &&
        _cachedPersonal != null &&
        DateTime.now().difference(_lastFetch!) < _cacheDuration;

    if (cacheValid) {
      debugPrint('💾 PersonalRepository: ⚡ Usando caché (${_cachedPersonal!.length} items)');
      return _cachedPersonal!;
    }

    try {
      debugPrint('💾 PersonalRepository: 🌐 Fetching desde Supabase con JOIN...');
      // Query con JOIN para obtener el nombre de la categoría
      final SupabaseClient supabase = Supabase.instance.client;

      dynamic query = supabase
          .from('tpersonal')
          .select('*, tcategorias(categoria)');

      // Ordenar
      query = query.order(orderBy ?? 'apellidos', ascending: ascending);

      // Limit
      if (limit != null) {
        query = query.limit(limit);
      }

      final List<Map<String, dynamic>> response = await query as List<Map<String, dynamic>>;

      // Mapear los resultados
      final List<PersonalEntity> personal = response.map((Map<String, dynamic> item) {
        // Extraer el nombre de categoría del JOIN
        final dynamic categoriaData = item['tcategorias'];
        String? categoriaNombre;

        if (categoriaData is Map && categoriaData.isNotEmpty) {
          categoriaNombre = categoriaData['categoria']?.toString();
        }

        // Crear un nuevo map con el campo categoria
        final Map<String, dynamic> itemWithCategoria = Map<String, dynamic>.from(item)
          ..['categoria'] = categoriaNombre
          ..remove('tcategorias'); // Eliminar el objeto anidado

        return PersonalEntity.fromMap(itemWithCategoria);
      }).toList();

      // Actualizar caché
      _cachedPersonal = personal;
      _lastFetch = DateTime.now();

      debugPrint('💾 PersonalRepository: ✅ Caché actualizado con ${personal.length} items');

      return personal;
    } catch (e) {
      throw Exception('Error al obtener personal: $e');
    }
  }

  @override
  Future<PersonalEntity> getById(String id) async {
    final DataSourceResult<PersonalEntity> result = await _dataSource.getById(id);

    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      throw result.error ?? Exception('Error al obtener personal');
    }
  }

  @override
  Future<PersonalEntity> create(PersonalEntity personal) async {
    final DataSourceResult<PersonalEntity> result = await _dataSource.create(personal);

    if (result.isSuccess && result.data != null) {
      debugPrint('💾 PersonalRepository: ⚡ Invalidando caché después de crear');
      // IMPORTANTE: Invalidar completamente el caché para forzar nuevo fetch con JOIN
      // No actualizamos el caché local porque result.data no tiene el campo 'categoria' del JOIN
      _cachedPersonal = null;
      _lastFetch = null;
      _dataSource.invalidateCache();
      debugPrint('💾 PersonalRepository: ✅ Caché invalidado');
      return result.data!;
    } else {
      throw result.error ?? Exception('Error al crear personal');
    }
  }

  @override
  Future<PersonalEntity> update(PersonalEntity personal) async {
    final DataSourceResult<PersonalEntity> result = await _dataSource.update(personal.id, personal);

    if (result.isSuccess && result.data != null) {
      debugPrint('💾 PersonalRepository: ⚡ Invalidando caché después de actualizar');
      // IMPORTANTE: Invalidar completamente el caché para forzar nuevo fetch con JOIN
      // No actualizamos el caché local porque result.data no tiene el campo 'categoria' del JOIN
      _cachedPersonal = null;
      _lastFetch = null;
      _dataSource.invalidateCache();
      debugPrint('💾 PersonalRepository: ✅ Caché invalidado');
      return result.data!;
    } else {
      throw result.error ?? Exception('Error al actualizar personal');
    }
  }

  @override
  Future<void> delete(String id) async {
    final DataSourceResult<void> result = await _dataSource.delete(id);

    if (result.isFailure) {
      throw result.error ?? Exception('Error al eliminar personal');
    }

    debugPrint('💾 PersonalRepository: ⚡ Invalidando caché después de eliminar');
    // IMPORTANTE: Invalidar completamente el caché para forzar nuevo fetch con JOIN
    _cachedPersonal = null;
    _lastFetch = null;
    _dataSource.invalidateCache();
    debugPrint('💾 PersonalRepository: ✅ Caché invalidado');
  }

  @override
  Future<int> count() async {
    final DataSourceResult<int> result = await _dataSource.count();

    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      throw result.error ?? Exception('Error al contar personal');
    }
  }

  @override
  Future<List<PersonalEntity>> searchByNombre(String nombre) async {
    try {
      final List<Map<String, dynamic>> response = await Supabase.instance.client
          .from('tpersonal')
          .select()
          .or('nombre.ilike.%$nombre%,apellidos.ilike.%$nombre%')
          .order('apellidos');

      return response.map(PersonalEntity.fromMap).toList();
    } catch (e) {
      throw Exception('Error al buscar personal: $e');
    }
  }
}
