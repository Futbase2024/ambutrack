import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslado_gestion_helpers.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/entities/servicio_entity.dart';
import 'package:flutter/material.dart';

/// Utilidades de presentación de un servicio en la rejilla y la barra de estado
abstract final class ServicioGestion {
  static const String _domicilio = 'domicilio_paciente';

  static String paciente(ServicioEntity s) => GestionFormatters.texto(s.paciente?.nombreCompleto);

  static String domicilio(ServicioEntity s) => GestionFormatters.texto(s.paciente?.domicilioDireccion);

  static String recurrencia(ServicioEntity s) => GestionFormatters.texto(s.tipoRecurrencia?.toUpperCase());

  /// Origen: dirección del paciente si es su domicilio, si no el centro
  static String origen(ServicioEntity s) => _ubicacion(s, tipo: s.tipoOrigen, centro: s.origen);

  /// Destino: dirección del paciente si es su domicilio, si no el centro
  static String destino(ServicioEntity s) => _ubicacion(s, tipo: s.tipoDestino, centro: s.destino);

  static String _ubicacion(ServicioEntity s, {required String? tipo, required String? centro}) {
    if (tipo == _domicilio) {
      final String? direccion = s.paciente?.domicilioDireccion;
      return direccion != null && direccion.trim().isNotEmpty ? direccion : 'DOMICILIO';
    }
    return GestionFormatters.texto(centro);
  }

  /// Estado con la primera letra en mayúscula ("Activo")
  static String estadoLabel(String estado) {
    final String e = estado.trim();
    return e.isEmpty ? GestionFormatters.vacio : '${e[0].toUpperCase()}${e.substring(1).toLowerCase()}';
  }

  static Color estadoColor(String estado) {
    switch (estado.toUpperCase()) {
      case 'ACTIVO':
        return AppColors.success;
      case 'SUSPENDIDO':
        return AppColors.warning;
      case 'FINALIZADO':
        return AppColors.info;
      case 'ELIMINADO':
        return AppColors.error;
      default:
        return AppColors.gray500;
    }
  }

  /// Resumen para la barra de estado
  static List<String> resumen(List<ServicioEntity> todos, int visibles) {
    int count(String estado) => todos.where((ServicioEntity s) => s.estado == estado).length;
    return <String>[
      '${todos.length} servicios',
      if (visibles != todos.length) '$visibles visibles',
      'Activos: ${count('ACTIVO')}',
      'Suspendidos: ${count('SUSPENDIDO')}',
    ];
  }
}

/// Valor de filtro de columna: el marcador de vacío se trata como vacío
String _filtro(String v) => v == GestionFormatters.vacio ? '' : v;

int _dia(DateTime? d) => d == null ? 0 : d.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;

/// Columnas de la rejilla de servicios
final List<GestionColumn<ServicioEntity>> servicioGestionColumns = <GestionColumn<ServicioEntity>>[
  GestionColumn<ServicioEntity>(
    label: 'Código',
    width: 130,
    sortValue: (ServicioEntity s) => s.codigo ?? '',
    cell: (ServicioEntity s) => TrasladoCellText(GestionFormatters.texto(s.codigo), bold: true),
  ),
  GestionColumn<ServicioEntity>(
    label: 'Paciente',
    flex: 3,
    minWidth: 180,
    sortValue: (ServicioEntity s) => ServicioGestion.paciente(s).toLowerCase(),
    cell: (ServicioEntity s) => TrasladoCellText(ServicioGestion.paciente(s), bold: true),
  ),
  GestionColumn<ServicioEntity>(
    label: 'Domicilio',
    flex: 3,
    minWidth: 180,
    sortValue: (ServicioEntity s) => ServicioGestion.domicilio(s).toLowerCase(),
    cell: (ServicioEntity s) => TrasladoCellText(ServicioGestion.domicilio(s)),
  ),
  GestionColumn<ServicioEntity>(
    label: 'F. Nacimiento',
    width: 110,
    sortValue: (ServicioEntity s) => _dia(s.paciente?.fechaNacimiento),
    cell: (ServicioEntity s) => TrasladoCellText(GestionFormatters.fecha(s.paciente?.fechaNacimiento)),
  ),
  GestionColumn<ServicioEntity>(
    label: 'Recurrencia',
    width: 120,
    sortValue: ServicioGestion.recurrencia,
    cell: (ServicioEntity s) => TrasladoCellText(ServicioGestion.recurrencia(s)),
    filterValue: (ServicioEntity s) => _filtro(ServicioGestion.recurrencia(s)),
  ),
  GestionColumn<ServicioEntity>(
    label: 'Origen',
    flex: 2,
    minWidth: 150,
    sortValue: (ServicioEntity s) => ServicioGestion.origen(s).toLowerCase(),
    cell: (ServicioEntity s) => TrasladoCellText(ServicioGestion.origen(s)),
    filterValue: (ServicioEntity s) => _filtro(ServicioGestion.origen(s)),
  ),
  GestionColumn<ServicioEntity>(
    label: 'Destino',
    flex: 2,
    minWidth: 150,
    sortValue: (ServicioEntity s) => ServicioGestion.destino(s).toLowerCase(),
    cell: (ServicioEntity s) => TrasladoCellText(ServicioGestion.destino(s)),
    filterValue: (ServicioEntity s) => _filtro(ServicioGestion.destino(s)),
  ),
  GestionColumn<ServicioEntity>(
    label: 'Estado',
    width: 110,
    sortValue: (ServicioEntity s) => s.estado,
    cell: (ServicioEntity s) => GestionDotLabel(
      label: ServicioGestion.estadoLabel(s.estado),
      color: ServicioGestion.estadoColor(s.estado),
    ),
    filterValue: (ServicioEntity s) => ServicioGestion.estadoLabel(s.estado),
  ),
];
