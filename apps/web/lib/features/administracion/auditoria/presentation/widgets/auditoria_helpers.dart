import 'dart:convert';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Tablas auditadas → nombre legible
const Map<String, String> auditoriaTablas = <String, String>{
  'usuarios': 'Usuarios',
  'tpersonal': 'Personal',
  'tvehiculos': 'Vehículos',
  'traslados': 'Traslados',
  'servicios': 'Servicios',
  'contratos': 'Contratos',
  'ttalleres': 'Talleres',
  'tordenes_reparacion': 'Órdenes de reparación',
  'tmantenimientos': 'Mantenimientos',
  'titv_revisiones': 'ITV/Revisiones',
  'empresas': 'Empresas',
  'pacientes': 'Pacientes',
  'historial_medico': 'Historial médico',
  'ausencias': 'Ausencias',
  'vacaciones': 'Vacaciones',
  'incidencias': 'Incidencias',
  'incidencias_vehiculos': 'Averías de vehículos',
  'servicios_recurrentes': 'Servicios recurrentes',
  'turnos': 'Turnos',
  'stock': 'Stock de almacén',
  'productos': 'Productos',
  'proveedores': 'Proveedores',
};

/// Acciones → nombre legible
const Map<String, String> auditoriaAcciones = <String, String>{
  'INSERT': 'Alta',
  'UPDATE': 'Modificación',
  'DELETE': 'Baja',
};

String auditoriaTablaLabel(String tabla) => auditoriaTablas[tabla] ?? tabla;

String auditoriaAccionLabel(String accion) => auditoriaAcciones[accion] ?? accion;

Color auditoriaAccionColor(String accion) {
  switch (accion) {
    case 'INSERT':
      return AppColors.success;
    case 'UPDATE':
      return AppColors.info;
    case 'DELETE':
      return AppColors.error;
    default:
      return AppColors.gray500;
  }
}

/// Email del usuario o "Sistema" si el cambio no lo hizo un usuario autenticado
String auditoriaUsuarioLabel(AuditLogEntity e) {
  final String? email = e.usuarioEmail;
  return email == null || email.trim().isEmpty ? 'Sistema' : email.trim();
}

final DateFormat _fechaHora = DateFormat('dd/MM/yyyy HH:mm');
final DateFormat _fechaHoraSeg = DateFormat('dd/MM/yyyy HH:mm:ss');
final DateFormat _fecha = DateFormat('dd/MM/yyyy');
final RegExp _isoDateTime = RegExp(r'^\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}');
final RegExp _isoDate = RegExp(r'^\d{4}-\d{2}-\d{2}$');

/// Fecha y hora del registro de auditoría: "05/11/2026 10:32:15"
String auditoriaFechaHora(DateTime fecha) => _fechaHoraSeg.format(fecha.toLocal());

/// Descripción legible del registro afectado (nombre, matrícula, código...)
String auditoriaDescripcion(AuditLogEntity e) {
  final Map<String, dynamic> d = e.datos;
  final String? nombre = _texto(d['nombre']);
  final String? apellidos = _texto(d['apellidos']);
  if (nombre != null && apellidos != null) {
    return '$nombre $apellidos';
  }
  for (final String clave in <String>['nombre', 'matricula', 'codigo', 'numero_orden', 'email']) {
    final String? v = _texto(d[clave]);
    if (v != null) {
      return v;
    }
  }
  final String? id = e.registroId;
  if (id == null || id.isEmpty) {
    return GestionFormatters.vacio;
  }
  return id.length > 8 ? '${id.substring(0, 8)}…' : id;
}

String? _texto(Object? value) {
  if (value == null) {
    return null;
  }
  final String s = value.toString().trim();
  return s.isEmpty ? null : s;
}

/// Lista corta de campos modificados: "estado, matricula +2"
String auditoriaCamposResumen(AuditLogEntity e, {int max = 3}) {
  final List<String> campos = e.camposModificados;
  if (campos.isEmpty) {
    return GestionFormatters.vacio;
  }
  if (campos.length <= max) {
    return campos.join(', ');
  }
  return '${campos.take(max).join(', ')} +${campos.length - max}';
}

/// Formatea un valor JSON para mostrarlo (fechas ISO, booleanos, null, JSON anidado)
String auditoriaValor(Object? value) {
  if (value == null) {
    return GestionFormatters.vacio;
  }
  if (value is bool) {
    return value ? 'Sí' : 'No';
  }
  if (value is Map || value is List) {
    return jsonEncode(value);
  }
  final String s = value.toString();
  if (s.trim().isEmpty) {
    return GestionFormatters.vacio;
  }
  if (_isoDate.hasMatch(s)) {
    final DateTime? d = DateTime.tryParse(s);
    return d == null ? s : _fecha.format(d);
  }
  if (_isoDateTime.hasMatch(s)) {
    final DateTime? d = DateTime.tryParse(s);
    return d == null ? s : _fechaHora.format(d.toLocal());
  }
  return s;
}

/// Fila de la tabla de cambios de la ficha
class AuditoriaCambio {
  const AuditoriaCambio({
    required this.campo,
    required this.antes,
    required this.despues,
    required this.cambiado,
  });

  final String campo;
  final String antes;
  final String despues;
  final bool cambiado;
}

/// Cambios del registro: solo campos modificados en UPDATE, todos en INSERT/DELETE
List<AuditoriaCambio> auditoriaCambios(AuditLogEntity e) {
  final Map<String, dynamic> antes = e.datosAntes ?? const <String, dynamic>{};
  final Map<String, dynamic> despues = e.datosDespues ?? const <String, dynamic>{};
  final Iterable<String> campos;
  if (e.esModificacion) {
    campos = e.camposModificados.isNotEmpty
        ? e.camposModificados
        : despues.keys.where((String k) => jsonEncode(antes[k]) != jsonEncode(despues[k]));
  } else {
    campos = (e.esBaja ? antes : despues).keys;
  }
  return campos
      .map(
        (String c) => AuditoriaCambio(
          campo: c,
          antes: e.esAlta ? GestionFormatters.vacio : auditoriaValor(antes[c]),
          despues: e.esBaja ? GestionFormatters.vacio : auditoriaValor(despues[c]),
          cambiado: e.esModificacion,
        ),
      )
      .toList();
}

/// Búsqueda de texto en cliente (registro, email, descripción, campos)
List<AuditLogEntity> filtrarAuditoria(List<AuditLogEntity> rows, String query) {
  final String q = query.trim().toLowerCase();
  if (q.isEmpty) {
    return rows;
  }
  return rows.where((AuditLogEntity e) {
    return <String?>[
      e.registroId,
      e.usuarioEmail,
      auditoriaDescripcion(e),
      auditoriaTablaLabel(e.tabla),
      ...e.camposModificados,
    ].any((String? v) => v != null && v.toLowerCase().contains(q));
  }).toList();
}
