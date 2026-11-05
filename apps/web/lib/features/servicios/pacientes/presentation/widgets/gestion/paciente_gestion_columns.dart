import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Filtro por estado del paciente
enum PacienteEstadoFiltro { todos, activos, inactivos }

/// Indicador de estado activo/inactivo del paciente
class PacienteEstadoDot extends StatelessWidget {
  const PacienteEstadoDot({required this.activo, super.key});

  final bool activo;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(
      label: activo ? 'Activo' : 'Inactivo',
      color: activo ? AppColors.success : AppColors.inactive,
    );
  }
}

/// Texto de celda que pinta el marcador de vacío en gris claro
class PacienteCellText extends StatelessWidget {
  const PacienteCellText(this.value, {this.bold = false, super.key});

  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final bool empty = value == GestionFormatters.vacio;
    return Text(
      value,
      style: TextStyle(
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        color: empty ? AppColors.gray300 : null,
      ),
    );
  }
}

/// Teléfono principal del paciente (móvil, si no fijo)
String? pacienteTelefono(PacienteEntity p) {
  final String? movil = p.telefonoMovil?.trim();
  if (movil != null && movil.isNotEmpty) {
    return movil;
  }
  return p.telefonoFijo;
}

/// Documento "DNI 12345678A"
String pacienteDocumento(PacienteEntity p) {
  if (p.documento.trim().isEmpty) {
    return GestionFormatters.vacio;
  }
  return '${p.tipoDocumento} ${p.documento}';
}

/// Paciente con datos de contacto pendientes (sin dirección o sin teléfono)
bool pacienteDatosPendientes(PacienteEntity p) {
  final bool sinDireccion = p.domicilioDireccion?.trim().isEmpty ?? true;
  final bool sinTelefono = (p.telefonoMovil?.trim().isEmpty ?? true) &&
      (p.telefonoFijo?.trim().isEmpty ?? true);
  return sinDireccion || sinTelefono;
}

/// Columnas de la rejilla de pacientes
final List<GestionColumn<PacienteEntity>> pacienteGestionColumns =
    <GestionColumn<PacienteEntity>>[
  GestionColumn<PacienteEntity>(
    label: 'Identificación',
    flex: 2,
    sortValue: (PacienteEntity p) => (p.identificacion ?? '').toLowerCase(),
    cell: (PacienteEntity p) =>
        PacienteCellText(GestionFormatters.texto(p.identificacion), bold: true),
  ),
  GestionColumn<PacienteEntity>(
    label: 'Nombre',
    flex: 4,
    sortValue: (PacienteEntity p) => p.nombreCompleto.toLowerCase(),
    cell: (PacienteEntity p) => PacienteCellText(p.nombreCompleto, bold: true),
  ),
  GestionColumn<PacienteEntity>(
    label: 'Documento',
    flex: 2,
    sortValue: (PacienteEntity p) => p.documento.toLowerCase(),
    cell: (PacienteEntity p) => PacienteCellText(pacienteDocumento(p)),
  ),
  GestionColumn<PacienteEntity>(
    label: 'Edad',
    width: 70,
    sortValue: (PacienteEntity p) => p.edad,
    cell: (PacienteEntity p) => PacienteCellText('${p.edad}'),
  ),
  GestionColumn<PacienteEntity>(
    label: 'Dirección',
    flex: 4,
    sortValue: (PacienteEntity p) => (p.domicilioDireccion ?? '').toLowerCase(),
    cell: (PacienteEntity p) => PacienteCellText(GestionFormatters.texto(p.domicilioDireccion)),
  ),
  GestionColumn<PacienteEntity>(
    label: 'Teléfono',
    flex: 2,
    cell: (PacienteEntity p) => PacienteCellText(GestionFormatters.telefono(pacienteTelefono(p))),
  ),
  GestionColumn<PacienteEntity>(
    label: 'Estado',
    width: 100,
    sortValue: (PacienteEntity p) => p.activo ? 0 : 1,
    cell: (PacienteEntity p) => PacienteEstadoDot(activo: p.activo),
  ),
];

/// Filtra pacientes por texto (identificación, nombre, documento, teléfono, dirección) y estado
List<PacienteEntity> filtrarPacientes(
  List<PacienteEntity> pacientes, {
  required String query,
  required PacienteEstadoFiltro estado,
}) {
  final String q = query.trim().toLowerCase();
  final String qDigits = q.replaceAll(RegExp(r'\D'), '');
  bool contiene(String? v) => v?.toLowerCase().contains(q) ?? false;
  bool telefono(String? v) =>
      qDigits.isNotEmpty && (v?.replaceAll(RegExp(r'\D'), '').contains(qDigits) ?? false);

  return pacientes.where((PacienteEntity p) {
    final bool matchesSearch = q.isEmpty ||
        contiene(p.identificacion) ||
        contiene(p.nombreCompleto) ||
        contiene(p.documento) ||
        contiene(p.domicilioDireccion) ||
        contiene(p.telefonoMovil) ||
        contiene(p.telefonoFijo) ||
        telefono(p.telefonoMovil) ||
        telefono(p.telefonoFijo);
    final bool matchesEstado = estado == PacienteEstadoFiltro.todos ||
        (estado == PacienteEstadoFiltro.activos ? p.activo : !p.activo);
    return matchesSearch && matchesEstado;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenPacientes(List<PacienteEntity> todos, int filtrados) {
  final DateTime hoy = DateTime.now();
  final DateTime inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
  final int activos = todos.where((PacienteEntity p) => p.activo).length;
  final int registradosHoy = todos
      .where((PacienteEntity p) => p.createdAt != null && p.createdAt!.isAfter(inicioHoy))
      .length;
  final int pendientes = todos.where(pacienteDatosPendientes).length;
  return <String>[
    if (filtrados == todos.length)
      '${todos.length} registros'
    else
      '$filtrados de ${todos.length} registros',
    '$activos activos',
    'Registrados hoy $registradosHoy',
    'Datos de contacto pendientes $pendientes',
  ];
}

/// Imprime el listado de pacientes (filtrado y ordenado)
Future<void> imprimirPacientes(List<PacienteEntity> pacientes) {
  return GestionPrint.listado(
    title: 'Pacientes',
    headers: const <String>[
      'Identificación', 'Nombre', 'Documento', 'Edad', 'Dirección', 'Teléfono', 'Email', 'Estado',
    ],
    rows: pacientes
        .map(
          (PacienteEntity p) => <String>[
            GestionFormatters.texto(p.identificacion),
            p.nombreCompleto,
            pacienteDocumento(p),
            '${p.edad}',
            GestionFormatters.texto(p.domicilioDireccion),
            GestionFormatters.telefono(pacienteTelefono(p)),
            GestionFormatters.texto(p.email),
            if (p.activo) 'Activo' else 'Inactivo',
          ],
        )
        .toList(),
  );
}
