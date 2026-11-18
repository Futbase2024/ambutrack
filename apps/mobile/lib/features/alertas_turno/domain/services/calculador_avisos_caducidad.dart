import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

import '../models/aviso_caducidad.dart';

/// Calcula todo lo caducado o a punto de caducar (lógica pura, sin I/O)
///
/// - Vehículo: ITV, seguro y homologación (aviso a 15 días)
/// - Personal: documentos de `tdocumentos_personal` (aviso a 30 días)
/// - Material: stock del vehículo con estado caducado / crítico / próximo
class CalculadorAvisosCaducidad {
  const CalculadorAvisosCaducidad._();

  static const int diasAvisoVehiculo = 15;
  static const int diasAvisoMaterial = 30;

  /// Lista completa ordenada: caducados primero y luego por fecha
  static List<AvisoCaducidad> calcular({
    required DateTime ahora,
    VehiculoEntity? vehiculo,
    List<DocumentoPersonalEntity> documentos = const <DocumentoPersonalEntity>[],
    List<StockVehiculoEntity> material = const <StockVehiculoEntity>[],
  }) {
    final List<AvisoCaducidad> avisos = <AvisoCaducidad>[
      if (vehiculo != null) ...deVehiculo(vehiculo, ahora),
      ...deDocumentos(documentos, ahora),
      ...deMaterial(material, ahora),
    ];
    return avisos..sort(_comparar);
  }

  static List<AvisoCaducidad> deVehiculo(VehiculoEntity v, DateTime ahora) {
    return <AvisoCaducidad>[
      ?_fecha('ITV de ${v.matricula}', v.proximaItv, ahora, OrigenAviso.vehiculo, diasAvisoVehiculo),
      ?_fecha('Seguro de ${v.matricula}', v.fechaVencimientoSeguro, ahora, OrigenAviso.vehiculo, diasAvisoVehiculo),
      ?_fecha(
        'Homologación de ${v.matricula}',
        v.fechaVencimientoHomologacion,
        ahora,
        OrigenAviso.vehiculo,
        diasAvisoVehiculo,
      ),
    ];
  }

  static List<AvisoCaducidad> deDocumentos(List<DocumentoPersonalEntity> documentos, DateTime ahora) {
    final List<AvisoCaducidad> avisos = <AvisoCaducidad>[];
    for (final DocumentoPersonalEntity d in documentos) {
      final EstadoDocumentoPersonal estado = EstadoDocumentoPersonal.calcular(d.fechaCaducidad, ahora);
      if (estado != EstadoDocumentoPersonal.caducado && estado != EstadoDocumentoPersonal.proximoACaducar) {
        continue;
      }
      avisos.add(AvisoCaducidad(
        origen: OrigenAviso.personal,
        nivel: estado == EstadoDocumentoPersonal.caducado ? NivelCaducidad.caducado : NivelCaducidad.proximo,
        titulo: d.nombre?.isNotEmpty ?? false ? d.nombre! : d.tipo.label,
        fecha: d.fechaCaducidad,
      ));
    }
    return avisos;
  }

  static List<AvisoCaducidad> deMaterial(List<StockVehiculoEntity> material, DateTime ahora) {
    final List<AvisoCaducidad> avisos = <AvisoCaducidad>[];
    for (final StockVehiculoEntity s in material) {
      if (s.excluido || s.cantidadActual <= 0) {
        continue;
      }
      final NivelCaducidad? nivel = _nivelMaterial(s, ahora);
      if (nivel == null) {
        continue;
      }
      final String lote = s.lote?.isNotEmpty ?? false ? ' · Lote ${s.lote}' : '';
      avisos.add(AvisoCaducidad(
        origen: OrigenAviso.material,
        nivel: nivel,
        titulo: s.productoNombre ?? s.nombreComercial ?? 'Producto',
        fecha: s.fechaCaducidad,
        detalle: 'x${s.cantidadActual}$lote',
      ));
    }
    return avisos;
  }

  /// Usa el estado calculado por la vista; si no viene, lo deduce de la fecha
  static NivelCaducidad? _nivelMaterial(StockVehiculoEntity s, DateTime ahora) {
    switch (s.estadoCaducidad) {
      case 'caducado':
        return NivelCaducidad.caducado;
      case 'critico':
      case 'proximo':
        return NivelCaducidad.proximo;
      case 'ok':
      case 'sin_caducidad':
        return null;
    }
    final DateTime? fecha = s.fechaCaducidad;
    return fecha == null ? null : _nivel(fecha, ahora, diasAvisoMaterial);
  }

  static AvisoCaducidad? _fecha(String titulo, DateTime fecha, DateTime ahora, OrigenAviso origen, int dias) {
    final NivelCaducidad? nivel = _nivel(fecha, ahora, dias);
    return nivel == null ? null : AvisoCaducidad(origen: origen, nivel: nivel, titulo: titulo, fecha: fecha);
  }

  static NivelCaducidad? _nivel(DateTime fecha, DateTime ahora, int diasAviso) {
    final DateTime hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final DateTime dia = DateTime(fecha.year, fecha.month, fecha.day);
    if (dia.isBefore(hoy)) {
      return NivelCaducidad.caducado;
    }
    return dia.difference(hoy).inDays <= diasAviso ? NivelCaducidad.proximo : null;
  }

  static int _comparar(AvisoCaducidad a, AvisoCaducidad b) {
    if (a.caducado != b.caducado) {
      return a.caducado ? -1 : 1;
    }
    final DateTime fa = a.fecha ?? DateTime(9999);
    final DateTime fb = b.fecha ?? DateTime(9999);
    return fa.compareTo(fb);
  }
}
