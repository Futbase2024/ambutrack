import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/solicitud_vestuario_entity.dart';
import '../../models/solicitud_vestuario_supabase_model.dart';
import '../../solicitudes_vestuario_contract.dart';

/// Implementación Supabase del datasource de solicitudes de vestuario
class SupabaseSolicitudesVestuarioDataSource implements SolicitudesVestuarioDataSource {
  SupabaseSolicitudesVestuarioDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  static const String _tabla = 'solicitudes_vestuario';
  static const String _tablaTallas = 'tallas_personal';
  static const String _bucket = 'vestuario-fotos';

  SolicitudVestuarioEntity _toEntity(Map<String, dynamic> json) => SolicitudVestuarioSupabaseModel.fromJson(json);

  Future<SolicitudVestuarioEntity> _actualizar(String id, Map<String, dynamic> cambios, String accion) async {
    try {
      final Map<String, dynamic> r = await _supabase.from(_tabla).update(cambios).eq('id', id).select().single();
      return _toEntity(r);
    } catch (e) {
      throw Exception('Error al $accion la solicitud de vestuario: $e');
    }
  }

  @override
  Future<List<SolicitudVestuarioEntity>> getByPersonal(String personalId) async {
    try {
      final List<Map<String, dynamic>> r = await _supabase
          .from(_tabla)
          .select()
          .eq('personal_id', personalId)
          .order('created_at', ascending: false);
      return r.map(_toEntity).toList();
    } catch (e) {
      throw Exception('Error al obtener las solicitudes de vestuario: $e');
    }
  }

  @override
  Future<SolicitudVestuarioEntity> create(SolicitudVestuarioEntity entity) async {
    try {
      final Map<String, dynamic> r = await _supabase
          .from(_tabla)
          .insert(SolicitudVestuarioSupabaseModel.toInsertJson(entity))
          .select()
          .single();
      return _toEntity(r);
    } catch (e) {
      throw Exception('Error al crear la solicitud de vestuario: $e');
    }
  }

  @override
  Future<SolicitudVestuarioEntity> cancelar(String id) {
    return _actualizar(id, <String, dynamic>{'estado': EstadoSolicitudVestuario.cancelada.value}, 'cancelar');
  }

  @override
  Future<List<PrendaCatalogoEntity>> getCatalogo() async {
    try {
      final dynamic r = await _supabase.rpc<dynamic>('fn_catalogo_vestuario');
      final List<dynamic> filas = r is List ? r : const <dynamic>[];
      return filas.whereType<Map<String, dynamic>>().map((Map<String, dynamic> f) {
        return PrendaCatalogoEntity(
          prenda: f['prenda'] as String? ?? '',
          talla: f['talla'] as String? ?? '',
          disponible: (f['disponible'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener el catálogo de vestuario: $e');
    }
  }

  @override
  Future<TallasPersonalEntity?> getTallas(String personalId) async {
    try {
      final Map<String, dynamic>? r =
          await _supabase.from(_tablaTallas).select().eq('personal_id', personalId).maybeSingle();
      return r == null ? null : SolicitudVestuarioSupabaseModel.tallasFromJson(r);
    } catch (e) {
      throw Exception('Error al obtener las tallas: $e');
    }
  }

  @override
  Future<TallasPersonalEntity> guardarTallas(TallasPersonalEntity tallas) async {
    try {
      final Map<String, dynamic> r = await _supabase
          .from(_tablaTallas)
          .upsert(SolicitudVestuarioSupabaseModel.tallasToJson(tallas))
          .select()
          .single();
      return SolicitudVestuarioSupabaseModel.tallasFromJson(r);
    } catch (e) {
      throw Exception('Error al guardar las tallas: $e');
    }
  }

  @override
  Future<String> subirFoto({required Uint8List bytes, required String extension}) async {
    final String? uid = _supabase.auth.currentUser?.id;
    if (uid == null) {
      throw Exception('No hay sesión activa');
    }
    final String ruta = '$uid/${DateTime.now().millisecondsSinceEpoch}.$extension';
    try {
      await _supabase.storage
          .from(_bucket)
          .uploadBinary(ruta, bytes, fileOptions: FileOptions(contentType: 'image/$extension'));
      return ruta;
    } catch (e) {
      throw Exception('Error al subir la foto: $e');
    }
  }

  @override
  Future<String> getUrlFoto(String ruta) async {
    try {
      return await _supabase.storage.from(_bucket).createSignedUrl(ruta, 3600);
    } catch (e) {
      throw Exception('Error al obtener la foto: $e');
    }
  }

  @override
  Future<List<SolicitudVestuarioEntity>> getAll({EstadoSolicitudVestuario? estado}) async {
    try {
      PostgrestFilterBuilder<List<Map<String, dynamic>>> query = _supabase.from(_tabla).select();
      if (estado != null) {
        query = query.eq('estado', estado.value);
      }
      final List<Map<String, dynamic>> r = await query.order('created_at', ascending: false);
      return r.map(_toEntity).toList();
    } catch (e) {
      throw Exception('Error al obtener las solicitudes de vestuario: $e');
    }
  }

  @override
  Future<SolicitudVestuarioEntity> aprobar(String id) {
    return _actualizar(id, <String, dynamic>{'estado': EstadoSolicitudVestuario.aprobada.value}, 'aprobar');
  }

  @override
  Future<SolicitudVestuarioEntity> rechazar(String id, {required String motivo}) {
    return _actualizar(
      id,
      <String, dynamic>{'estado': EstadoSolicitudVestuario.rechazada.value, 'motivo_rechazo': motivo},
      'rechazar',
    );
  }

  @override
  Future<String?> entregar(String id, {String? stockId, bool? devolverAStock}) async {
    try {
      final dynamic r = await _supabase.rpc<dynamic>(
        'fn_entregar_solicitud_vestuario',
        params: <String, dynamic>{
          'p_solicitud_id': id,
          'p_stock_id': stockId,
          'p_devolver_a_stock': devolverAStock,
        },
      );
      return r as String?;
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error al entregar la solicitud de vestuario: $e');
    }
  }
}
