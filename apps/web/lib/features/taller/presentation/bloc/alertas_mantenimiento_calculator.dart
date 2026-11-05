import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_formatters.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/alerta_mantenimiento.dart';

/// Calcula alertas de mantenimiento a partir de los datos existentes
class AlertasMantenimientoCalculator {
  AlertasMantenimientoCalculator({DateTime? hoy}) : _hoy = _soloFecha(hoy ?? DateTime.now());

  /// Plazos: ≤ [diasProximo] → informativa; ≤ [diasUrgente] → aviso; vencida → crítica
  static const int diasProximo = 30;
  static const int diasUrgente = 7;

  /// Órdenes / repuestos: > [diasEspera] → aviso; > [diasEsperaCritica] → crítica
  static const int diasEspera = 7;
  static const int diasEsperaCritica = 21;

  final DateTime _hoy;

  static DateTime _soloFecha(DateTime d) {
    final DateTime l = d.toLocal();
    return DateTime(l.year, l.month, l.day);
  }

  int _diasHasta(DateTime fecha) => _soloFecha(fecha).difference(_hoy).inDays;

  SeveridadAlerta? _severidadPlazo(int dias) {
    if (dias < 0) {
      return SeveridadAlerta.critica;
    }
    if (dias <= diasUrgente) {
      return SeveridadAlerta.aviso;
    }
    return dias <= diasProximo ? SeveridadAlerta.info : null;
  }

  SeveridadAlerta? _severidadEspera(int dias) {
    if (dias > diasEsperaCritica) {
      return SeveridadAlerta.critica;
    }
    return dias > diasEspera ? SeveridadAlerta.aviso : null;
  }

  AlertaMantenimiento? _plazo({
    required String id,
    required TipoAlertaMantenimiento tipo,
    required DateTime? fecha,
    required String concepto,
    String? vehiculoId,
    String? matricula,
    Map<String, String> datos = const <String, String>{},
  }) {
    if (fecha == null) {
      return null;
    }
    final int dias = _diasHasta(fecha);
    final SeveridadAlerta? severidad = _severidadPlazo(dias);
    if (severidad == null) {
      return null;
    }
    return AlertaMantenimiento(
      id: id,
      tipo: tipo,
      severidad: severidad,
      detalle: dias < 0 ? '$concepto vencida' : '$concepto próxima a vencer',
      dias: dias,
      esPlazo: true,
      vehiculoId: vehiculoId,
      vehiculoMatricula: matricula,
      fechaLimite: fecha,
      datos: datos,
    );
  }

  /// ITV, seguro, homologación y próximo mantenimiento de vehículos no dados de baja
  List<AlertaMantenimiento> vehiculos(List<VehiculoEntity> vehiculos) {
    final List<AlertaMantenimiento> alertas = <AlertaMantenimiento>[];
    for (final VehiculoEntity v in vehiculos) {
      if (v.estado == VehiculoEstado.baja) {
        continue;
      }
      final Map<String, String> datos = <String, String>{
        'Marca / modelo': '${v.marca} ${v.modelo}'.trim(),
        'Estado vehículo': v.estado.name,
      };
      alertas.addAll(<AlertaMantenimiento?>[
        _plazo(id: 'itv_${v.id}', tipo: TipoAlertaMantenimiento.itv, fecha: v.proximaItv,
            concepto: 'ITV', vehiculoId: v.id, matricula: v.matricula, datos: datos),
        _plazo(id: 'seguro_${v.id}', tipo: TipoAlertaMantenimiento.seguro, fecha: v.fechaVencimientoSeguro,
            concepto: 'Póliza de seguro', vehiculoId: v.id, matricula: v.matricula, datos: datos),
        _plazo(id: 'homolog_${v.id}', tipo: TipoAlertaMantenimiento.homologacion,
            fecha: v.fechaVencimientoHomologacion, concepto: 'Homologación sanitaria',
            vehiculoId: v.id, matricula: v.matricula, datos: datos),
        _plazo(id: 'mantveh_${v.id}', tipo: TipoAlertaMantenimiento.mantenimientoVehiculo,
            fecha: v.proximoMantenimiento, concepto: 'Revisión de mantenimiento',
            vehiculoId: v.id, matricula: v.matricula, datos: datos),
      ].whereType<AlertaMantenimiento>());
    }
    return alertas;
  }

  /// Órdenes activas con demasiados días en taller
  List<AlertaMantenimiento> ordenes(List<OrdenReparacionEntity> ordenes) {
    final List<AlertaMantenimiento> alertas = <AlertaMantenimiento>[];
    for (final OrdenReparacionEntity o in ordenes.where((OrdenReparacionEntity o) => o.estado.isActiva)) {
      final int dias = -_diasHasta(o.fechaEntrada);
      final SeveridadAlerta? severidad = _severidadEspera(dias);
      if (severidad == null) {
        continue;
      }
      alertas.add(AlertaMantenimiento(
        id: 'orden_${o.id}',
        tipo: TipoAlertaMantenimiento.ordenAbierta,
        severidad: severidad,
        detalle: 'Orden ${o.numeroOrden} lleva $dias días en taller (${o.estado.displayName})',
        dias: dias,
        esPlazo: false,
        vehiculoId: o.vehiculoId,
        vehiculoMatricula: o.vehiculoMatricula,
        datos: <String, String>{
          'Nº orden': GestionFormatters.texto(o.numeroOrden),
          'Taller': GestionFormatters.texto(o.tallerNombre),
          'Estado orden': o.estado.displayName,
          'Prioridad': o.prioridad.displayName,
          'Entrada': GestionFormatters.fecha(o.fechaEntrada),
        },
      ));
    }
    return alertas;
  }

  /// Repuestos solicitados/pedidos de órdenes activas que llevan demasiado esperando
  List<AlertaMantenimiento> repuestos(
    List<RepuestoOrdenEntity> repuestos,
    Map<String, OrdenReparacionEntity> ordenes,
  ) {
    final List<AlertaMantenimiento> alertas = <AlertaMantenimiento>[];
    for (final RepuestoOrdenEntity r in repuestos) {
      final OrdenReparacionEntity? o = ordenes[r.ordenId];
      final bool pendiente = r.estado == EstadoRepuesto.solicitado || r.estado == EstadoRepuesto.pedido;
      if (o == null || !o.estado.isActiva || !pendiente) {
        continue;
      }
      final int dias = -_diasHasta(r.fechaPedido ?? r.createdAt);
      final SeveridadAlerta? severidad = _severidadEspera(dias);
      if (severidad == null) {
        continue;
      }
      alertas.add(AlertaMantenimiento(
        id: 'repuesto_${r.id}',
        tipo: TipoAlertaMantenimiento.repuestoPendiente,
        severidad: severidad,
        detalle: '"${r.descripcion}" ${r.estado.displayName.toLowerCase()} hace $dias días',
        dias: dias,
        esPlazo: false,
        vehiculoId: o.vehiculoId,
        vehiculoMatricula: o.vehiculoMatricula,
        datos: <String, String>{
          'Repuesto': r.descripcion,
          'Referencia': GestionFormatters.texto(r.referencia),
          'Proveedor': GestionFormatters.texto(r.proveedorNombre),
          'Estado repuesto': r.estado.displayName,
          'Pedido': GestionFormatters.fecha(r.fechaPedido),
          'Nº orden': GestionFormatters.texto(o.numeroOrden),
        },
      ));
    }
    return alertas;
  }

  /// Mantenimientos programados vencidos o próximos
  List<AlertaMantenimiento> mantenimientos(
    List<MantenimientoEntity> mantenimientos,
    Map<String, String> matriculas,
  ) {
    return mantenimientos
        .where((MantenimientoEntity m) => m.estado == EstadoMantenimiento.programado)
        .map(
          (MantenimientoEntity m) => _plazo(
            id: 'mant_${m.id}',
            tipo: TipoAlertaMantenimiento.mantenimientoProgramado,
            fecha: m.fechaProgramada ?? m.fecha,
            concepto: 'Mantenimiento ${m.tipoMantenimiento.displayName.toLowerCase()}',
            vehiculoId: m.vehiculoId,
            matricula: matriculas[m.vehiculoId],
            datos: <String, String>{
              'Descripción': GestionFormatters.texto(m.descripcion),
              'Taller': GestionFormatters.texto(m.taller),
              'Tipo': m.tipoMantenimiento.displayName,
            },
          ),
        )
        .whereType<AlertaMantenimiento>()
        .toList();
  }
}
