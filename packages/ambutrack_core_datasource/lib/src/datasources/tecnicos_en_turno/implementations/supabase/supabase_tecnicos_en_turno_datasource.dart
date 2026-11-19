import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/tecnico_en_turno_entity.dart';
import '../../models/tecnico_en_turno_supabase_model.dart';
import '../../tecnicos_en_turno_contract.dart';

/// Implementación Supabase de [TecnicosEnTurnoDataSource].
///
/// La categoría se toma de la ficha del personal (`tpersonal.categoria_id`
/// → `tcategorias.categoria`), no del campo libre `turnos.categoriaPersonal`.
class SupabaseTecnicosEnTurnoDataSource implements TecnicosEnTurnoDataSource {
  SupabaseTecnicosEnTurnoDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  @override
  Future<List<TecnicoEnTurnoEntity>> getTecnicosEnTurno({
    required DateTime ahora,
    Duration margenProximos = const Duration(hours: 2),
    List<String> categorias = kCategoriasTecnicos,
  }) async {
    try {
      // 1. Personal activo de las categorías indicadas
      final Map<String, Map<String, dynamic>> personalPorId = await _tecnicos(categorias);
      if (personalPorId.isEmpty) {
        return <TecnicoEnTurnoEntity>[];
      }

      // 2. Turnos en curso o que empiezan dentro del margen
      final List<dynamic> turnos = await _supabase
          .from('turnos')
          .select('id, idPersonal, nombrePersonal, tipoTurno, fechaInicio, fechaFin')
          .eq('activo', true)
          .inFilter('idPersonal', personalPorId.keys.toList())
          .lte('fechaInicio', ahora.add(margenProximos).toUtc().toIso8601String())
          .gt('fechaFin', ahora.toUtc().toIso8601String())
          .order('fechaInicio');
      if (turnos.isEmpty) {
        return <TecnicoEnTurnoEntity>[];
      }

      // Un turno por técnico (el que empieza antes)
      final Map<String, Map<String, dynamic>> turnoPorPersonal = <String, Map<String, dynamic>>{};
      for (final dynamic t in turnos) {
        turnoPorPersonal.putIfAbsent(t['idPersonal'] as String, () => Map<String, dynamic>.from(t as Map));
      }

      // 3. Último fichaje de cada técnico desde el inicio de su turno
      final Map<String, Map<String, dynamic>> fichajePorPersonal = await _ultimosFichajes(turnoPorPersonal);

      return turnoPorPersonal.entries.map((MapEntry<String, Map<String, dynamic>> e) {
        final Map<String, dynamic> p = personalPorId[e.key]!;
        final Map<String, dynamic>? fichaje = fichajePorPersonal[e.key];
        final DateTime inicio = DateTime.parse(e.value['fechaInicio'] as String);
        // Solo vale un fichaje hecho dentro del turno (o hasta 2 h antes)
        final bool fichajeValido = fichaje != null &&
            DateTime.parse(fichaje['fecha_hora'] as String).isAfter(inicio.subtract(const Duration(hours: 2)));
        return TecnicoEnTurnoSupabaseModel.fromRows(
          turno: e.value,
          personal: p,
          categoria: p['_categoria'] as String,
          fichaje: fichajeValido ? fichaje : null,
        ).toEntity();
      }).toList();
    } catch (e) {
      debugPrint('❌ TecnicosEnTurnoDataSource: error al cargar técnicos en turno: $e');
      rethrow;
    }
  }

  /// Personal activo cuya categoría está en [categorias], indexado por id.
  ///
  /// La categoría sale de `tcategorias` vía `categoria_id`; si la ficha no
  /// tiene `categoria_id`, se interpreta el texto libre `tpersonal.categoria`
  /// (p. ej. "Técnico en Emergencias Sanitarias" → TES). La categoría
  /// resuelta se guarda en la clave `_categoria`.
  Future<Map<String, Map<String, dynamic>>> _tecnicos(List<String> categorias) async {
    final List<dynamic> cats = await _supabase.from('tcategorias').select('id, categoria');
    final Map<String, String> categoriaPorId = <String, String>{
      for (final dynamic c in cats) c['id'] as String: (c['categoria'] as String? ?? '').toUpperCase(),
    };

    final List<dynamic> personal = await _supabase
        .from('tpersonal')
        .select('id, nombre, apellidos, categoria_id, categoria')
        .eq('activo', true);

    final Map<String, Map<String, dynamic>> resultado = <String, Map<String, dynamic>>{};
    for (final dynamic p in personal) {
      final String? porId = categoriaPorId[p['categoria_id']];
      final String categoria = porId ?? _categoriaDesdeTexto(p['categoria'] as String?);
      if (categorias.contains(categoria)) {
        resultado[p['id'] as String] = <String, dynamic>{
          ...Map<String, dynamic>.from(p as Map),
          '_categoria': categoria,
        };
      }
    }
    return resultado;
  }

  /// Normaliza el texto libre de categoría a TES / CONDUCTOR
  static String _categoriaDesdeTexto(String? texto) {
    final String t = (texto ?? '').toUpperCase().trim();
    if (t == 'TES' || t.contains('EMERGENCIAS SANITARIAS')) {
      return 'TES';
    }
    if (t.contains('CONDUCTOR')) {
      return 'CONDUCTOR';
    }
    return t;
  }

  /// Último fichaje (más reciente) por técnico desde el turno más temprano
  Future<Map<String, Map<String, dynamic>>> _ultimosFichajes(
    Map<String, Map<String, dynamic>> turnoPorPersonal,
  ) async {
    final DateTime desde = turnoPorPersonal.values
        .map((Map<String, dynamic> t) => DateTime.parse(t['fechaInicio'] as String))
        .reduce((DateTime a, DateTime b) => a.isBefore(b) ? a : b)
        .subtract(const Duration(hours: 2));

    final List<dynamic> registros = await _supabase
        .from('registros_horarios')
        .select('personal_id, tipo, fecha_hora')
        .eq('activo', true)
        .inFilter('personal_id', turnoPorPersonal.keys.toList())
        .gte('fecha_hora', desde.toUtc().toIso8601String())
        .order('fecha_hora', ascending: false);

    final Map<String, Map<String, dynamic>> ultimo = <String, Map<String, dynamic>>{};
    for (final dynamic r in registros) {
      ultimo.putIfAbsent(r['personal_id'] as String, () => Map<String, dynamic>.from(r as Map));
    }
    return ultimo;
  }
}
