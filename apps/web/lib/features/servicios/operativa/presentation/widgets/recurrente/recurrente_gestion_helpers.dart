import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslado_gestion_helpers.dart';
import 'package:flutter/material.dart';

/// Vigencia de un servicio recurrente respecto a hoy
enum RecurrenteVigencia {
  vigente('Vigente'),
  futuro('Futuro'),
  finalizado('Finalizado');

  const RecurrenteVigencia(this.label);

  final String label;

  Color get color {
    switch (this) {
      case RecurrenteVigencia.vigente:
        return AppColors.success;
      case RecurrenteVigencia.futuro:
        return AppColors.info;
      case RecurrenteVigencia.finalizado:
        return AppColors.inactive;
    }
  }
}

/// Utilidades de la pantalla "Programación recurrente"
class RecurrenteGestion {
  const RecurrenteGestion._();

  static const List<String> _dias = <String>['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  /// Tipos de recurrencia (valor BD → etiqueta)
  static const Map<String, String> tipos = <String, String>{
    'unico': 'Único',
    'diario': 'Diario',
    'semanal': 'Semanal',
    'semanas_alternas': 'Semanas alternas',
    'dias_alternos': 'Días alternos',
    'mensual': 'Mensual',
    'especifico': 'Fechas específicas',
  };

  static String tipoLabel(String tipo) => tipos[tipo] ?? tipo;

  static String _diasSemana(List<int>? dias) {
    if (dias == null || dias.isEmpty) {
      return '';
    }
    final List<int> ordenados = List<int>.of(dias)..sort();
    return ordenados
        .where((int d) => d >= 1 && d <= 7)
        .map((int d) => _dias[d - 1])
        .join(', ');
  }

  /// Descripción legible del patrón de recurrencia
  static String patron(ServicioRecurrenteEntity s) {
    switch (s.tipoRecurrencia) {
      case 'unico':
        return 'Único (${GestionFormatters.fecha(s.fechaServicioInicio)})';
      case 'diario':
        return 'Todos los días';
      case 'semanal':
        return 'Semanal: ${_diasSemana(s.diasSemana)}';
      case 'semanas_alternas':
        return 'Cada ${s.intervaloSemanas ?? 2} semanas: ${_diasSemana(s.diasSemana)}';
      case 'dias_alternos':
        return 'Cada ${s.intervaloDias ?? 2} días';
      case 'mensual':
        final List<int> dias = List<int>.of(s.diasMes ?? const <int>[])..sort();
        return 'Mensual: días ${dias.join(', ')}';
      case 'especifico':
        return '${s.fechasEspecificas?.length ?? 0} fechas específicas';
      default:
        return tipoLabel(s.tipoRecurrencia);
    }
  }

  static RecurrenteVigencia vigencia(ServicioRecurrenteEntity s) {
    final DateTime now = DateTime.now();
    final DateTime hoy = DateTime(now.year, now.month, now.day);
    if (s.fechaServicioInicio.isAfter(hoy)) {
      return RecurrenteVigencia.futuro;
    }
    final DateTime? fin = s.fechaServicioFin;
    if (fin != null && fin.isBefore(hoy)) {
      return RecurrenteVigencia.finalizado;
    }
    return RecurrenteVigencia.vigente;
  }

  static String periodo(ServicioRecurrenteEntity s) {
    final String fin =
        s.fechaServicioFin == null ? 'indefinido' : GestionFormatters.fecha(s.fechaServicioFin);
    return '${GestionFormatters.fecha(s.fechaServicioInicio)} → $fin';
  }

  static String horario(ServicioRecurrenteEntity s) {
    final String ida = TrasladoGestion.hora(s.horaRecogida);
    if (!s.requiereVuelta) {
      return ida;
    }
    return '$ida / ${TrasladoGestion.hora(s.horaVuelta)}';
  }

  static String paciente(ServicioRecurrenteEntity s, Map<String, String> pacientes) =>
      GestionFormatters.texto(pacientes[s.idPaciente]);

  static String _ubicacion(String? tipo, String? valor, String? enCentro) {
    if (tipo == 'domicilio_paciente') {
      return 'DOMICILIO PACIENTE';
    }
    final String base = GestionFormatters.texto(valor?.toUpperCase());
    return enCentro == null || enCentro.isEmpty ? base : '$base (${enCentro.toUpperCase()})';
  }

  static String origen(ServicioRecurrenteEntity s) =>
      _ubicacion(s.tipoOrigen, s.origen, s.origenUbicacionCentro);

  static String destino(ServicioRecurrenteEntity s) =>
      _ubicacion(s.tipoDestino, s.destino, s.destinoUbicacionCentro);

  /// Filtra por texto (código, paciente, origen, destino), tipo y vigencia
  static List<ServicioRecurrenteEntity> filtrar(
    List<ServicioRecurrenteEntity> servicios, {
    required String query,
    required String? tipo,
    required RecurrenteVigencia? vigencia,
    required Map<String, String> pacientes,
  }) {
    final String q = query.trim().toLowerCase();
    return servicios.where((ServicioRecurrenteEntity s) {
      if (tipo != null && s.tipoRecurrencia != tipo) {
        return false;
      }
      if (vigencia != null && RecurrenteGestion.vigencia(s) != vigencia) {
        return false;
      }
      if (q.isEmpty) {
        return true;
      }
      return <String>[
        s.codigo,
        pacientes[s.idPaciente] ?? '',
        s.origen ?? '',
        s.destino ?? '',
      ].any((String c) => c.toLowerCase().contains(q));
    }).toList();
  }

  static List<String> resumen(List<ServicioRecurrenteEntity> todos, int filtrados) {
    int count(RecurrenteVigencia v) =>
        todos.where((ServicioRecurrenteEntity s) => vigencia(s) == v).length;
    return <String>[
      TrasladoGestion.totalRegistros(filtrados, todos.length),
      'Vigentes ${count(RecurrenteVigencia.vigente)}',
      'Futuros ${count(RecurrenteVigencia.futuro)}',
      'Finalizados ${count(RecurrenteVigencia.finalizado)}',
      'Requieren generación ${todos.where((ServicioRecurrenteEntity s) => s.requiereGeneracion).length}',
    ];
  }

  static Future<void> imprimir(
    List<ServicioRecurrenteEntity> servicios,
    Map<String, String> pacientes,
  ) {
    return GestionPrint.listado(
      title: 'Programación Recurrente',
      headers: const <String>[
        'Código', 'Paciente', 'Patrón', 'Horario', 'Periodo', 'Origen', 'Destino',
        'Generados hasta', 'Vigencia',
      ],
      rows: servicios
          .map(
            (ServicioRecurrenteEntity s) => <String>[
              s.codigo,
              paciente(s, pacientes),
              patron(s),
              horario(s),
              periodo(s),
              origen(s),
              destino(s),
              GestionFormatters.fecha(s.trasladosGeneradosHasta),
              vigencia(s).label,
            ],
          )
          .toList(),
    );
  }
}
