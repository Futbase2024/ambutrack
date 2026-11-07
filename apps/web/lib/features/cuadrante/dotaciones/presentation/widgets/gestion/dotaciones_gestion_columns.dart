import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/widgets/gestion/dotaciones_catalogos.dart';
import 'package:flutter/material.dart';

/// Filtro por estado de la dotación
enum DotacionEstadoFiltro { todos, activas, inactivas }

/// Tipos de destino que se pueden filtrar
const List<String> dotacionTiposDestino = <String>['Hospital', 'Base', 'Contrato'];

/// Color del tipo de destino
Color dotacionDestinoColor(String tipo) {
  switch (tipo) {
    case 'Hospital':
      return AppColors.error;
    case 'Base':
      return AppColors.primary;
    case 'Contrato':
      return AppColors.warning;
    default:
      return AppColors.gray400;
  }
}

/// Etiqueta de prioridad (Alta ≥ 8, Media ≥ 5, Baja)
String dotacionPrioridadLabel(int p) => p >= 8 ? 'Alta' : (p >= 5 ? 'Media' : 'Baja');

Color dotacionPrioridadColor(int p) =>
    p >= 8 ? AppColors.error : (p >= 5 ? AppColors.warning : AppColors.success);

/// Texto de vigencia "inicio – fin"
String dotacionVigencia(DotacionEntity d) =>
    '${GestionFormatters.fecha(d.fechaInicio)} – '
    '${d.fechaFin == null ? 'Indefinido' : GestionFormatters.fecha(d.fechaFin)}';

/// Indicador de estado activo/inactivo
class DotacionEstadoDot extends StatelessWidget {
  const DotacionEstadoDot({required this.activo, super.key});

  final bool activo;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(
      label: activo ? 'Activa' : 'Inactiva',
      color: activo ? AppColors.success : AppColors.inactive,
    );
  }
}

/// Indicador de prioridad
class DotacionPrioridadDot extends StatelessWidget {
  const DotacionPrioridadDot({required this.prioridad, super.key});

  final int prioridad;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(
      label: '$prioridad · ${dotacionPrioridadLabel(prioridad)}',
      color: dotacionPrioridadColor(prioridad),
    );
  }
}

/// Texto de celda que pinta el marcador de vacío en gris claro
class DotacionCellText extends StatelessWidget {
  const DotacionCellText(this.value, {this.bold = false, this.color, super.key});

  final String value;
  final bool bold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final bool empty = value == GestionFormatters.vacio;
    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        color: empty ? AppColors.gray300 : color,
      ),
    );
  }
}

/// Columnas de la rejilla de dotaciones
List<GestionColumn<DotacionEntity>> dotacionesGestionColumns(DotacionesCatalogos cat) {
  return <GestionColumn<DotacionEntity>>[
    GestionColumn<DotacionEntity>(
      label: 'Nombre',
      flex: 3,
      sortValue: (DotacionEntity d) => d.nombre.toLowerCase(),
      cell: (DotacionEntity d) => DotacionCellText(d.nombre, bold: true),
    ),
    GestionColumn<DotacionEntity>(
      label: 'Destino',
      flex: 3,
      sortValue: (DotacionEntity d) => '${d.tipoDestino} ${cat.destinoNombre(d) ?? ''}'.toLowerCase(),
      cell: (DotacionEntity d) => GestionDotLabel(
        label: cat.destinoNombre(d) == null ? d.tipoDestino : '${d.tipoDestino} · ${cat.destinoNombre(d)}',
        color: dotacionDestinoColor(d.tipoDestino),
      ),
    ),
    GestionColumn<DotacionEntity>(
      label: 'Tipo vehículo',
      flex: 2,
      sortValue: (DotacionEntity d) => (cat.tipoVehiculoNombre(d) ?? '').toLowerCase(),
      cell: (DotacionEntity d) => DotacionCellText(GestionFormatters.texto(cat.tipoVehiculoNombre(d))),
    ),
    GestionColumn<DotacionEntity>(
      label: 'Unidades',
      width: 90,
      alignment: Alignment.centerRight,
      sortValue: (DotacionEntity d) => d.cantidadUnidades,
      cell: (DotacionEntity d) => DotacionCellText('${d.cantidadUnidades}', bold: true),
    ),
    GestionColumn<DotacionEntity>(
      label: 'Prioridad',
      width: 110,
      sortValue: (DotacionEntity d) => d.prioridad,
      cell: (DotacionEntity d) => DotacionPrioridadDot(prioridad: d.prioridad),
    ),
    GestionColumn<DotacionEntity>(
      label: 'Vigencia',
      width: 190,
      sortValue: (DotacionEntity d) => d.fechaInicio.millisecondsSinceEpoch,
      cell: (DotacionEntity d) => DotacionCellText(
        dotacionVigencia(d),
        color: d.esVigenteEn(DateTime.now()) ? null : AppColors.error,
      ),
    ),
    GestionColumn<DotacionEntity>(
      label: 'Estado',
      width: 100,
      sortValue: (DotacionEntity d) => d.activo ? 0 : 1,
      cell: (DotacionEntity d) => DotacionEstadoDot(activo: d.activo),
    ),
  ];
}

/// Filtra dotaciones por texto (nombre, código, descripción), destino y estado
List<DotacionEntity> filtrarDotaciones(
  List<DotacionEntity> dotaciones, {
  required String query,
  required String? tipoDestino,
  required DotacionEstadoFiltro estado,
}) {
  final String q = query.trim().toLowerCase();
  return dotaciones.where((DotacionEntity d) {
    final bool matchesSearch = q.isEmpty ||
        d.nombre.toLowerCase().contains(q) ||
        (d.codigo?.toLowerCase().contains(q) ?? false) ||
        (d.descripcion?.toLowerCase().contains(q) ?? false);
    final bool matchesDestino = tipoDestino == null || d.tipoDestino == tipoDestino;
    final bool matchesEstado = estado == DotacionEstadoFiltro.todos ||
        (estado == DotacionEstadoFiltro.activas ? d.activo : !d.activo);
    return matchesSearch && matchesDestino && matchesEstado;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenDotaciones(List<DotacionEntity> todas, int filtradas) {
  final int activas = todas.where((DotacionEntity d) => d.activo).length;
  final int unidades = todas
      .where((DotacionEntity d) => d.activo)
      .fold<int>(0, (int sum, DotacionEntity d) => sum + d.cantidadUnidades);
  return <String>[
    if (filtradas == todas.length) '${todas.length} registros' else '$filtradas de ${todas.length} registros',
    '$activas activas',
    '${todas.length - activas} inactivas',
    '$unidades unidades activas',
  ];
}

/// Imprime el listado de dotaciones (filtrado y ordenado)
Future<void> imprimirDotaciones(List<DotacionEntity> dotaciones, DotacionesCatalogos cat) {
  return GestionPrint.listado(
    title: 'Dotaciones',
    headers: const <String>[
      'Código', 'Nombre', 'Destino', 'Tipo vehículo', 'Unidades', 'Prioridad', 'Vigencia', 'Estado',
    ],
    rows: dotaciones
        .map(
          (DotacionEntity d) => <String>[
            GestionFormatters.texto(d.codigo),
            d.nombre,
            '${d.tipoDestino} ${cat.destinoNombre(d) ?? ''}'.trim(),
            GestionFormatters.texto(cat.tipoVehiculoNombre(d)),
            '${d.cantidadUnidades}',
            '${d.prioridad} · ${dotacionPrioridadLabel(d.prioridad)}',
            dotacionVigencia(d),
            if (d.activo) 'Activa' else 'Inactiva',
          ],
        )
        .toList(),
  );
}
