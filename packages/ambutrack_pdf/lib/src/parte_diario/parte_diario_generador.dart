import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';

import 'parte_diario_builder.dart';
import 'parte_diario_data.dart';
import 'parte_diario_pdf.dart';

/// Origen de los datos del parte diario.
///
/// Cada app lo implementa en su repositorio (pass-through a los datasources),
/// así la orquestación es la misma en web y móvil.
abstract class ParteDiarioFuentes {
  Future<List<InicioTurnoEntity>> iniciosTurno(String personalId, DateTime desde, DateTime hasta);

  Future<List<RegistroHorarioEntity>> fichajes(String personalId, DateTime desde, DateTime hasta);

  /// Traslados del día (de cualquier persona: el builder filtra los propios)
  Future<List<TrasladoEntity>> traslados(DateTime dia);

  Future<List<ConsumoCombustibleEntity>> repostajes(DateTime desde, DateTime hasta);

  Future<List<IncidenciaVehiculoEntity>> incidenciasVehiculo(String vehiculoId);

  Future<EmpresaTenantEntity?> empresa(String empresaId);

  /// ID → nombre de los centros hospitalarios
  Future<Map<String, String>> nombresCentros();
}

/// Carga todo lo necesario y construye los partes de una persona y un día
class ParteDiarioGenerador {
  const ParteDiarioGenerador(this._fuentes);

  final ParteDiarioFuentes _fuentes;

  Future<List<ParteDiarioData>> cargar({
    required String personalId,
    required String personalNombre,
    required DateTime dia,
    String? empresaId,
  }) async {
    final DateTime desde = DateTime(dia.year, dia.month, dia.day);
    final DateTime hasta = desde.add(const Duration(days: 1));
    debugPrint('📄 ParteDiarioGenerador: cargando parte de $personalNombre (${desde.toIso8601String()})');

    final List<Object> base = await Future.wait<Object>(<Future<Object>>[
      _fuentes.iniciosTurno(personalId, desde, hasta),
      _fuentes.fichajes(personalId, desde, hasta.subtract(const Duration(milliseconds: 1))),
      _fuentes.traslados(desde),
    ]);
    final List<InicioTurnoEntity> inicios = base[0] as List<InicioTurnoEntity>;
    final Set<String> vehiculos = inicios.map((InicioTurnoEntity i) => i.vehiculoId).whereType<String>().toSet();
    final String? idEmpresa = empresaId ?? inicios.map((InicioTurnoEntity i) => i.empresaId).nonNulls.firstOrNull;

    final List<Object?> extra = await Future.wait<Object?>(<Future<Object?>>[
      _opcional(() => _fuentes.repostajes(desde, hasta), const <ConsumoCombustibleEntity>[]),
      _opcional(() => _incidencias(vehiculos, desde, hasta), const <IncidenciaVehiculoEntity>[]),
      _opcional(() async => idEmpresa == null ? null : _fuentes.empresa(idEmpresa), null),
      _opcional(_fuentes.nombresCentros, const <String, String>{}),
    ]);

    return ParteDiarioBuilder.construirDia(
      personalId: personalId,
      personalNombre: personalNombre,
      dia: desde,
      empresa: await ParteDiarioPdf.empresaDesde(extra[2] as EmpresaTenantEntity?),
      inicios: inicios,
      fichajes: base[1] as List<RegistroHorarioEntity>,
      traslados: base[2] as List<TrasladoEntity>,
      repostajes: (extra[0]! as List<ConsumoCombustibleEntity>)
          .where((ConsumoCombustibleEntity r) => _enRango(r.fecha, desde, hasta))
          .toList(),
      incidencias: extra[1]! as List<IncidenciaVehiculoEntity>,
      nombresCentros: extra[3]! as Map<String, String>,
    );
  }

  /// Partes de varias personas del mismo día (datos comunes cargados una vez)
  Future<List<ParteDiarioData>> cargarVarios({
    required List<({String id, String nombre})> personas,
    required DateTime dia,
    String? empresaId,
  }) async {
    final ParteDiarioGenerador conCache = ParteDiarioGenerador(_FuentesConCache(_fuentes));
    final List<ParteDiarioData> partes = <ParteDiarioData>[];
    for (final ({String id, String nombre}) p in personas) {
      partes.addAll(await conCache.cargar(personalId: p.id, personalNombre: p.nombre, dia: dia, empresaId: empresaId));
    }
    return partes;
  }

  Future<List<IncidenciaVehiculoEntity>> _incidencias(Set<String> vehiculos, DateTime desde, DateTime hasta) async {
    final List<List<IncidenciaVehiculoEntity>> listas =
        await Future.wait(vehiculos.map(_fuentes.incidenciasVehiculo));
    return listas
        .expand((List<IncidenciaVehiculoEntity> l) => l)
        .where((IncidenciaVehiculoEntity i) => _enRango(i.fechaReporte, desde, hasta))
        .toList();
  }

  static bool _enRango(DateTime d, DateTime desde, DateTime hasta) {
    final DateTime local = d.toLocal();
    return !local.isBefore(desde) && local.isBefore(hasta);
  }

  /// Los datos secundarios no deben impedir imprimir el parte
  static Future<T> _opcional<T>(Future<T> Function() carga, T porDefecto) async {
    try {
      return await carga();
    } catch (e) {
      debugPrint('⚠️ ParteDiarioGenerador: dato opcional no disponible ($e)');
      return porDefecto;
    }
  }
}

/// Memoriza las consultas comunes a todas las personas de un mismo día
class _FuentesConCache implements ParteDiarioFuentes {
  _FuentesConCache(this._origen);

  final ParteDiarioFuentes _origen;
  final Map<String, Future<Object?>> _cache = <String, Future<Object?>>{};

  Future<T> _memo<T>(String clave, Future<T> Function() carga) async {
    return await (_cache[clave] ??= carga()) as T;
  }

  @override
  Future<List<InicioTurnoEntity>> iniciosTurno(String personalId, DateTime desde, DateTime hasta) =>
      _origen.iniciosTurno(personalId, desde, hasta);

  @override
  Future<List<RegistroHorarioEntity>> fichajes(String personalId, DateTime desde, DateTime hasta) =>
      _origen.fichajes(personalId, desde, hasta);

  @override
  Future<List<TrasladoEntity>> traslados(DateTime dia) =>
      _memo('traslados-${dia.toIso8601String()}', () => _origen.traslados(dia));

  @override
  Future<List<ConsumoCombustibleEntity>> repostajes(DateTime desde, DateTime hasta) =>
      _memo('repostajes-${desde.toIso8601String()}', () => _origen.repostajes(desde, hasta));

  @override
  Future<List<IncidenciaVehiculoEntity>> incidenciasVehiculo(String vehiculoId) =>
      _memo('incidencias-$vehiculoId', () => _origen.incidenciasVehiculo(vehiculoId));

  @override
  Future<EmpresaTenantEntity?> empresa(String empresaId) =>
      _memo('empresa-$empresaId', () => _origen.empresa(empresaId));

  @override
  Future<Map<String, String>> nombresCentros() => _memo('centros', _origen.nombresCentros);
}
