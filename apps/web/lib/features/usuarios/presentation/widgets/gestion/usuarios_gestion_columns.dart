import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Filtro por estado del usuario
enum UsuarioEstadoFiltro { todos, activos, inactivos }

/// Color asociado a cada rol
Color usuarioRolColor(String? rol) {
  switch (rol?.toLowerCase()) {
    case 'admin':
      return AppColors.error;
    case 'coordinador':
      return AppColors.primary;
    case 'conductor':
      return AppColors.info;
    case 'sanitario':
      return AppColors.success;
    case 'jefe_personal':
      return AppColors.secondary;
    case 'jefe_mantenimiento':
      return AppColors.warning;
    default:
      return AppColors.gray400;
  }
}

/// Nombre visible de un rol
String usuarioRolNombre(String rol) {
  switch (rol.toLowerCase()) {
    case 'admin':
      return 'Administrador';
    case 'coordinador':
      return 'Coordinador';
    case 'conductor':
      return 'Conductor';
    case 'sanitario':
      return 'Sanitario';
    case 'jefe_personal':
      return 'Jefe de Personal';
    case 'jefe_mantenimiento':
      return 'Jefe de Mantenimiento';
    default:
      return rol
          .replaceAll('_', ' ')
          .split(' ')
          .map((String w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
          .join(' ');
  }
}

String usuarioNombre(UserEntity u) => u.displayName ?? u.email;

bool usuarioActivo(UserEntity u) => u.activo ?? false;

/// Indicador del rol (o "Sin rol" en gris)
class UsuarioRolDot extends StatelessWidget {
  const UsuarioRolDot({required this.rol, super.key});

  final String? rol;

  @override
  Widget build(BuildContext context) {
    final String? r = rol;
    if (r == null) {
      return const UsuarioCellText(GestionFormatters.vacio);
    }
    return GestionDotLabel(label: usuarioRolNombre(r), color: usuarioRolColor(r));
  }
}

/// Indicador de estado activo/inactivo
class UsuarioEstadoDot extends StatelessWidget {
  const UsuarioEstadoDot({required this.activo, super.key});

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
class UsuarioCellText extends StatelessWidget {
  const UsuarioCellText(this.value, {this.bold = false, super.key});

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

/// Columnas de la rejilla de usuarios
final List<GestionColumn<UserEntity>> usuariosGestionColumns = <GestionColumn<UserEntity>>[
  GestionColumn<UserEntity>(
    label: 'DNI',
    width: 110,
    sortValue: (UserEntity u) => (u.dni ?? '').toLowerCase(),
    cell: (UserEntity u) => UsuarioCellText(GestionFormatters.texto(u.dni)),
  ),
  GestionColumn<UserEntity>(
    label: 'Nombre',
    flex: 3,
    sortValue: (UserEntity u) => usuarioNombre(u).toLowerCase(),
    cell: (UserEntity u) => UsuarioCellText(usuarioNombre(u), bold: true),
  ),
  GestionColumn<UserEntity>(
    label: 'Email',
    flex: 3,
    sortValue: (UserEntity u) => u.email.toLowerCase(),
    cell: (UserEntity u) => UsuarioCellText(u.email),
  ),
  GestionColumn<UserEntity>(
    label: 'Teléfono',
    width: 120,
    cell: (UserEntity u) => UsuarioCellText(GestionFormatters.telefono(u.phoneNumber)),
  ),
  GestionColumn<UserEntity>(
    label: 'Rol',
    width: 170,
    sortValue: (UserEntity u) => u.rol == null ? '' : usuarioRolNombre(u.rol!),
    cell: (UserEntity u) => UsuarioRolDot(rol: u.rol),
  ),
  GestionColumn<UserEntity>(
    label: 'Empresa',
    flex: 2,
    sortValue: (UserEntity u) => (u.empresaNombre ?? '').toLowerCase(),
    cell: (UserEntity u) => UsuarioCellText(GestionFormatters.texto(u.empresaNombre)),
  ),
  GestionColumn<UserEntity>(
    label: 'Estado',
    width: 100,
    sortValue: (UserEntity u) => usuarioActivo(u) ? 0 : 1,
    cell: (UserEntity u) => UsuarioEstadoDot(activo: usuarioActivo(u)),
  ),
];

/// Filtra usuarios por texto (nombre, email, DNI), rol y estado
List<UserEntity> filtrarUsuarios(
  List<UserEntity> usuarios, {
  required String query,
  required String? rol,
  required UsuarioEstadoFiltro estado,
}) {
  final String q = query.trim().toLowerCase();
  return usuarios.where((UserEntity u) {
    final bool matchesSearch = q.isEmpty ||
        (u.displayName?.toLowerCase().contains(q) ?? false) ||
        u.email.toLowerCase().contains(q) ||
        (u.dni?.toLowerCase().contains(q) ?? false);
    final bool matchesRol = rol == null || u.rol?.toLowerCase() == rol;
    final bool matchesEstado = estado == UsuarioEstadoFiltro.todos ||
        (estado == UsuarioEstadoFiltro.activos ? usuarioActivo(u) : !usuarioActivo(u));
    return matchesSearch && matchesRol && matchesEstado;
  }).toList();
}

/// Roles presentes en los datos (para el filtro), ordenados por nombre visible
List<String> rolesDisponibles(List<UserEntity> usuarios) {
  final Set<String> roles = <String>{
    for (final UserEntity u in usuarios)
      if (u.rol != null) u.rol!.toLowerCase(),
  };
  return roles.toList()..sort((String a, String b) => usuarioRolNombre(a).compareTo(usuarioRolNombre(b)));
}

/// Resumen para la barra de estado
List<String> resumenUsuarios(List<UserEntity> todos, int filtrados) {
  final int activos = todos.where(usuarioActivo).length;
  final int admins = todos.where((UserEntity u) => u.rol?.toLowerCase() == 'admin').length;
  return <String>[
    if (filtrados == todos.length) '${todos.length} registros' else '$filtrados de ${todos.length} registros',
    '$activos activos',
    '${todos.length - activos} inactivos',
    'Administradores $admins',
  ];
}

/// Imprime el listado de usuarios (filtrado y ordenado)
Future<void> imprimirUsuarios(List<UserEntity> usuarios) {
  return GestionPrint.listado(
    title: 'Usuarios del sistema',
    headers: const <String>['DNI', 'Nombre', 'Email', 'Teléfono', 'Rol', 'Empresa', 'Estado'],
    rows: usuarios
        .map(
          (UserEntity u) => <String>[
            GestionFormatters.texto(u.dni),
            usuarioNombre(u),
            u.email,
            GestionFormatters.telefono(u.phoneNumber),
            if (u.rol == null) GestionFormatters.vacio else usuarioRolNombre(u.rol!),
            GestionFormatters.texto(u.empresaNombre),
            if (usuarioActivo(u)) 'Activo' else 'Inactivo',
          ],
        )
        .toList(),
  );
}
