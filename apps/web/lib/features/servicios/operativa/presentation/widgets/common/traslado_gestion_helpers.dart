import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utilidades comunes de las pantallas operativas de traslados
class TrasladoGestion {
  const TrasladoGestion._();

  static final DateFormat _hora = DateFormat('HH:mm');
  static final DateFormat _fechaHora = DateFormat('dd/MM/yyyy HH:mm');

  /// Estados finales (servicio ya cerrado)
  static const Set<String> estadosFinales = <String>{
    'finalizado',
    'cancelado',
    'no_realizado',
    'anulado',
    'suspendido',
  };

  /// Estados en ruta (conductor operando)
  static const Set<String> estadosEnRuta = <String>{
    'recibido_conductor',
    'en_origen',
    'saliendo_origen',
    'en_transito',
    'en_destino',
  };

  /// Opciones del filtro de estado (null = todos)
  static Map<String?, String> opcionesEstado(Iterable<String> estados) {
    return <String?, String>{
      null: 'Todos',
      for (final String e in estados) e: estadoLabel(e),
    };
  }

  /// Todos los estados del ciclo de vida, en orden cronológico
  static const List<String> todosLosEstados = <String>[
    'pendiente',
    'asignado',
    'enviado',
    'recibido_conductor',
    'en_origen',
    'saliendo_origen',
    'en_transito',
    'en_destino',
    'finalizado',
    'cancelado',
    'no_realizado',
    'suspendido',
    'anulado',
  ];

  static String estadoLabel(String? estado) =>
      EstadoTraslado.fromValue(estado)?.label ?? GestionFormatters.texto(estado);

  static Color estadoColor(String? estado) {
    switch (estado) {
      case 'pendiente':
        return AppColors.warning;
      case 'asignado':
      case 'enviado':
        return AppColors.info;
      case 'recibido_conductor':
      case 'en_origen':
      case 'saliendo_origen':
      case 'en_transito':
      case 'en_destino':
        return AppColors.primary;
      case 'finalizado':
        return AppColors.success;
      case 'cancelado':
      case 'no_realizado':
        return AppColors.error;
      case 'suspendido':
        return AppColors.highPriority;
      default:
        return AppColors.inactive;
    }
  }

  /// Urgente: prioridad alta (1–3) o motivo de traslado de urgencias
  static bool esUrgente(TrasladoEntity t) {
    final String motivo = (t.motivoTraslado?.nombre ?? '').toUpperCase();
    return t.prioridad <= 3 || motivo.contains('URGEN');
  }

  static String prioridadLabel(int prioridad) {
    if (prioridad <= 2) {
      return 'Crítica ($prioridad)';
    }
    if (prioridad == 3) {
      return 'Alta (3)';
    }
    if (prioridad <= 6) {
      return 'Media ($prioridad)';
    }
    return 'Baja ($prioridad)';
  }

  static Color prioridadColor(int prioridad) {
    if (prioridad <= 2) {
      return AppColors.emergency;
    }
    if (prioridad == 3) {
      return AppColors.highPriority;
    }
    if (prioridad <= 6) {
      return AppColors.mediumPriority;
    }
    return AppColors.lowPriority;
  }

  static String hora(DateTime? value) =>
      value == null ? GestionFormatters.vacio : _hora.format(value.toLocal());

  static String fechaHora(DateTime? value) =>
      value == null ? GestionFormatters.vacio : _fechaHora.format(value.toLocal());

  static String paciente(TrasladoEntity t) =>
      GestionFormatters.texto(t.pacienteNombre?.toUpperCase());

  static String tipo(TrasladoEntity t) => GestionFormatters.texto(t.tipoTraslado?.toUpperCase());

  static String _ubicacion(String? tipoUbicacion, String? valor) {
    if (tipoUbicacion == 'domicilio_paciente') {
      return 'DOMICILIO PACIENTE';
    }
    return GestionFormatters.texto(valor?.toUpperCase());
  }

  static String origen(TrasladoEntity t) => _ubicacion(t.tipoOrigen, t.origen);

  static String destino(TrasladoEntity t) => _ubicacion(t.tipoDestino, t.destino);

  static String personal(String? id, Map<String, String> nombres) {
    if (id == null || id.isEmpty) {
      return GestionFormatters.vacio;
    }
    return nombres[id] ?? 'ID ${id.substring(0, id.length < 8 ? id.length : 8)}';
  }

  static String conductor(TrasladoEntity t, Map<String, String> nombres) =>
      personal(t.idPersonalConductor, nombres);

  static String vehiculo(TrasladoEntity t) => GestionFormatters.texto(t.matriculaVehiculo);

  /// Filtra por texto (código, paciente, origen, destino, conductor, matrícula) y estado
  static List<TrasladoEntity> filtrar(
    List<TrasladoEntity> traslados, {
    required String query,
    required String? estado,
    required Map<String, String> nombres,
  }) {
    final String q = query.trim().toLowerCase();
    return traslados.where((TrasladoEntity t) {
      final bool matchesEstado = estado == null || t.estado == estado;
      if (!matchesEstado) {
        return false;
      }
      if (q.isEmpty) {
        return true;
      }
      final List<String> campos = <String>[
        t.codigo ?? '',
        t.pacienteNombre ?? '',
        t.origen ?? '',
        t.destino ?? '',
        t.matriculaVehiculo ?? '',
        t.motivoTraslado?.nombre ?? '',
        nombres[t.idPersonalConductor] ?? '',
      ];
      return campos.any((String c) => c.toLowerCase().contains(q));
    }).toList();
  }

  /// Recuentos por grupo de estado para la barra de estado
  static List<String> recuentosEstado(List<TrasladoEntity> traslados) {
    int count(bool Function(String e) test) =>
        traslados.where((TrasladoEntity t) => test(t.estado ?? '')).length;
    return <String>[
      'Pendientes ${count((String e) => e == 'pendiente')}',
      'Asignados ${count((String e) => e == 'asignado' || e == 'enviado')}',
      'En ruta ${count(estadosEnRuta.contains)}',
      'Finalizados ${count((String e) => e == 'finalizado')}',
      'Incidencias ${count((String e) => estadosFinales.contains(e) && e != 'finalizado')}',
    ];
  }

  /// Texto "N registros" o "M de N registros"
  static String totalRegistros(int filtrados, int total) =>
      filtrados == total ? '$total registros' : '$filtrados de $total registros';

  /// Imprime un listado de traslados
  static Future<void> imprimir({
    required String title,
    required List<TrasladoEntity> traslados,
    required Map<String, String> nombres,
    String? subtitle,
  }) {
    return GestionPrint.listado(
      title: title,
      subtitle: subtitle,
      headers: const <String>[
        'Fecha', 'Hora', 'Código', 'Paciente', 'Tipo', 'Origen', 'Destino',
        'Prioridad', 'Conductor', 'Vehículo', 'Estado',
      ],
      rows: traslados
          .map(
            (TrasladoEntity t) => <String>[
              GestionFormatters.fecha(t.fecha),
              hora(t.horaProgramada),
              GestionFormatters.texto(t.codigo),
              paciente(t),
              tipo(t),
              origen(t),
              destino(t),
              prioridadLabel(t.prioridad),
              conductor(t, nombres),
              vehiculo(t),
              estadoLabel(t.estado),
            ],
          )
          .toList(),
    );
  }
}

/// Texto de celda que pinta el marcador de vacío en gris claro
class TrasladoCellText extends StatelessWidget {
  const TrasladoCellText(this.value, {this.bold = false, super.key});

  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final bool empty = value == GestionFormatters.vacio;
    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        color: empty ? AppColors.gray300 : null,
      ),
    );
  }
}

/// Indicador de estado del traslado
class TrasladoEstadoDot extends StatelessWidget {
  const TrasladoEstadoDot({required this.estado, super.key});

  final String? estado;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(
      label: TrasladoGestion.estadoLabel(estado),
      color: TrasladoGestion.estadoColor(estado),
    );
  }
}

/// Indicador de prioridad del traslado
class TrasladoPrioridadDot extends StatelessWidget {
  const TrasladoPrioridadDot({required this.prioridad, super.key});

  final int prioridad;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(
      label: TrasladoGestion.prioridadLabel(prioridad),
      color: TrasladoGestion.prioridadColor(prioridad),
    );
  }
}
