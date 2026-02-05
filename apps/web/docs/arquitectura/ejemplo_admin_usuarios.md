# 👥 Ejemplo: Página de Administración de Usuarios y Roles

**Propósito**: Guía de implementación para la página de gestión de usuarios y roles

---

## 📋 Funcionalidades

1. ✅ **Listar usuarios** (Personal con usuario_id vinculado)
2. ✅ **Asignar/cambiar rol** a un usuario
3. ✅ **Activar/desactivar usuarios**
4. ✅ **Filtrar por rol**
5. ✅ **Buscar usuarios**

---

## 🏗️ Estructura de Archivos

```
lib/features/administracion/usuarios_roles/
├── domain/
│   └── (sin entities/repositories adicionales, usa PersonalRepository)
├── presentation/
│   ├── bloc/
│   │   ├── usuarios_roles_event.dart
│   │   ├── usuarios_roles_state.dart
│   │   └── usuarios_roles_bloc.dart
│   ├── pages/
│   │   └── usuarios_roles_page.dart
│   └── widgets/
│       ├── usuario_card.dart
│       ├── cambiar_rol_dialog.dart
│       └── filtros_usuarios.dart
```

---

## 📝 Código de Ejemplo

### 1. BLoC Events

```dart
// presentation/bloc/usuarios_roles_event.dart
import 'package:equatable/equatable.dart';

abstract class UsuariosRolesEvent extends Equatable {
  const UsuariosRolesEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar todos los usuarios
class UsuariosRolesLoadRequested extends UsuariosRolesEvent {}

/// Cambiar rol de un usuario
class UsuariosRolesCambiarRolRequested extends UsuariosRolesEvent {
  const UsuariosRolesCambiarRolRequested(this.personalId, this.nuevoRol);

  final String personalId;
  final String nuevoRol;

  @override
  List<Object?> get props => [personalId, nuevoRol];
}

/// Activar/desactivar usuario
class UsuariosRolesToggleActivoRequested extends UsuariosRolesEvent {
  const UsuariosRolesToggleActivoRequested(this.personalId, this.activo);

  final String personalId;
  final bool activo;

  @override
  List<Object?> get props => [personalId, activo];
}
```

### 2. BLoC States

```dart
// presentation/bloc/usuarios_roles_state.dart
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:equatable/equatable.dart';

abstract class UsuariosRolesState extends Equatable {
  const UsuariosRolesState();

  @override
  List<Object?> get props => [];
}

class UsuariosRolesInitial extends UsuariosRolesState {}

class UsuariosRolesLoading extends UsuariosRolesState {}

class UsuariosRolesLoaded extends UsuariosRolesState {
  const UsuariosRolesLoaded(this.usuarios);

  final List<PersonalEntity> usuarios;

  @override
  List<Object?> get props => [usuarios];
}

class UsuariosRolesError extends UsuariosRolesState {
  const UsuariosRolesError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
```

### 3. BLoC

```dart
// presentation/bloc/usuarios_roles_bloc.dart
import 'package:ambutrack_web/features/administracion/usuarios_roles/presentation/bloc/usuarios_roles_event.dart';
import 'package:ambutrack_web/features/administracion/usuarios_roles/presentation/bloc/usuarios_roles_state.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@injectable
class UsuariosRolesBloc extends Bloc<UsuariosRolesEvent, UsuariosRolesState> {
  UsuariosRolesBloc(this._personalRepository) : super(UsuariosRolesInitial()) {
    on<UsuariosRolesLoadRequested>(_onLoadRequested);
    on<UsuariosRolesCambiarRolRequested>(_onCambiarRolRequested);
    on<UsuariosRolesToggleActivoRequested>(_onToggleActivoRequested);
  }

  final PersonalRepository _personalRepository;

  Future<void> _onLoadRequested(
    UsuariosRolesLoadRequested event,
    Emitter<UsuariosRolesState> emit,
  ) async {
    debugPrint('👥 UsuariosRolesBloc: Cargando usuarios...');
    emit(UsuariosRolesLoading());

    try {
      // Obtener todos los Personal
      final List<PersonalEntity> todosPersonal = await _personalRepository.getAll();

      // Filtrar solo los que tienen usuario_id (usuarios del sistema)
      final List<PersonalEntity> usuarios = todosPersonal
          .where((PersonalEntity p) => p.usuarioId != null && p.usuarioId!.isNotEmpty)
          .toList();

      debugPrint('👥 UsuariosRolesBloc: ✅ ${usuarios.length} usuarios cargados');
      emit(UsuariosRolesLoaded(usuarios));
    } catch (e) {
      debugPrint('👥 UsuariosRolesBloc: ❌ Error: $e');
      emit(UsuariosRolesError(e.toString()));
    }
  }

  Future<void> _onCambiarRolRequested(
    UsuariosRolesCambiarRolRequested event,
    Emitter<UsuariosRolesState> emit,
  ) async {
    debugPrint('👥 UsuariosRolesBloc: Cambiando rol de ${event.personalId} a ${event.nuevoRol}');

    if (state is! UsuariosRolesLoaded) return;

    final List<PersonalEntity> usuarios = (state as UsuariosRolesLoaded).usuarios;

    try {
      // Buscar el usuario a actualizar
      final PersonalEntity? usuario = usuarios.cast<PersonalEntity?>().firstWhere(
        (PersonalEntity? p) => p?.id == event.personalId,
        orElse: () => null,
      );

      if (usuario == null) {
        throw Exception('Usuario no encontrado');
      }

      // Actualizar el rol (campo 'categoria')
      final Map<String, dynamic> updatedData = usuario.toMap();
      updatedData['categoria'] = event.nuevoRol;

      final PersonalEntity usuarioActualizado = PersonalEntity.fromMap(updatedData);

      await _personalRepository.update(usuarioActualizado);

      debugPrint('👥 UsuariosRolesBloc: ✅ Rol actualizado exitosamente');

      // Recargar usuarios
      add(UsuariosRolesLoadRequested());
    } catch (e) {
      debugPrint('👥 UsuariosRolesBloc: ❌ Error al cambiar rol: $e');
      emit(UsuariosRolesError(e.toString()));
    }
  }

  Future<void> _onToggleActivoRequested(
    UsuariosRolesToggleActivoRequested event,
    Emitter<UsuariosRolesState> emit,
  ) async {
    debugPrint('👥 UsuariosRolesBloc: Cambiando estado activo de ${event.personalId}');

    if (state is! UsuariosRolesLoaded) return;

    final List<PersonalEntity> usuarios = (state as UsuariosRolesLoaded).usuarios;

    try {
      final PersonalEntity? usuario = usuarios.cast<PersonalEntity?>().firstWhere(
        (PersonalEntity? p) => p?.id == event.personalId,
        orElse: () => null,
      );

      if (usuario == null) {
        throw Exception('Usuario no encontrado');
      }

      final Map<String, dynamic> updatedData = usuario.toMap();
      updatedData['activo'] = event.activo;

      final PersonalEntity usuarioActualizado = PersonalEntity.fromMap(updatedData);

      await _personalRepository.update(usuarioActualizado);

      debugPrint('👥 UsuariosRolesBloc: ✅ Estado activo actualizado');

      // Recargar usuarios
      add(UsuariosRolesLoadRequested());
    } catch (e) {
      debugPrint('👥 UsuariosRolesBloc: ❌ Error: $e');
      emit(UsuariosRolesError(e.toString()));
    }
  }
}
```

### 4. Dialog para Cambiar Rol

```dart
// presentation/widgets/cambiar_rol_dialog.dart
import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:flutter/material.dart';

class CambiarRolDialog extends StatefulWidget {
  const CambiarRolDialog({
    required this.usuario,
    super.key,
  });

  final PersonalEntity usuario;

  @override
  State<CambiarRolDialog> createState() => _CambiarRolDialogState();
}

class _CambiarRolDialogState extends State<CambiarRolDialog> {
  late String _rolSeleccionado;

  @override
  void initState() {
    super.initState();
    _rolSeleccionado = widget.usuario.categoria ?? 'operador';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Cambiar Rol de ${widget.usuario.nombreCompleto}'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rol actual: ${UserRole.fromString(widget.usuario.categoria).label}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            AppDropdown<String>(
              value: _rolSeleccionado,
              label: 'Nuevo Rol',
              hint: 'Selecciona un rol',
              items: UserRole.values
                  .map(
                    (UserRole role) => AppDropdownItem<String>(
                      value: role.value,
                      label: role.label,
                      subtitle: role.description,
                      icon: _getIconForRole(role),
                      iconColor: _getColorForRole(role),
                    ),
                  )
                  .toList(),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() => _rolSeleccionado = value);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_rolSeleccionado),
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  IconData _getIconForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.jefePersonal:
        return Icons.people;
      case UserRole.jefeTrafic:
        return Icons.traffic;
      case UserRole.coordinador:
        return Icons.supervised_user_circle;
      case UserRole.administrativo:
        return Icons.business;
      case UserRole.conductor:
        return Icons.drive_eta;
      case UserRole.sanitario:
        return Icons.medical_services;
      case UserRole.gestor:
        return Icons.local_shipping;
      case UserRole.tecnico:
        return Icons.build;
      case UserRole.operador:
        return Icons.visibility;
    }
  }

  Color _getColorForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.emergency;
      case UserRole.jefePersonal:
      case UserRole.jefeTrafic:
        return AppColors.primary;
      case UserRole.coordinador:
        return AppColors.secondary;
      case UserRole.administrativo:
        return AppColors.info;
      case UserRole.conductor:
      case UserRole.sanitario:
        return AppColors.success;
      default:
        return AppColors.gray400;
    }
  }
}
```

### 5. Página Principal

```dart
// presentation/pages/usuarios_roles_page.dart
import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/administracion/usuarios_roles/presentation/bloc/usuarios_roles_bloc.dart';
import 'package:ambutrack_web/features/administracion/usuarios_roles/presentation/bloc/usuarios_roles_event.dart';
import 'package:ambutrack_web/features/administracion/usuarios_roles/presentation/bloc/usuarios_roles_state.dart';
import 'package:ambutrack_web/features/administracion/usuarios_roles/presentation/widgets/cambiar_rol_dialog.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

class UsuariosRolesPage extends StatelessWidget {
  const UsuariosRolesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider(
        create: (_) => GetIt.I<UsuariosRolesBloc>()..add(UsuariosRolesLoadRequested()),
        child: const _UsuariosRolesView(),
      ),
    );
  }
}

class _UsuariosRolesView extends StatefulWidget {
  const _UsuariosRolesView();

  @override
  State<_UsuariosRolesView> createState() => _UsuariosRolesViewState();
}

class _UsuariosRolesViewState extends State<_UsuariosRolesView> {
  String _searchQuery = '';
  String? _filtroRol;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.people, size: 32, color: AppColors.primary),
                const SizedBox(width: AppSizes.spacing),
                Expanded(
                  child: Text(
                    'Gestión de Usuarios y Roles',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                // Búsqueda
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar usuario...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(width: AppSizes.spacing),
                // Filtro por rol
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    value: _filtroRol,
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por rol',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Todos'),
                      ),
                      ...UserRole.values.map(
                        (role) => DropdownMenuItem(
                          value: role.value,
                          child: Text(role.label),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => _filtroRol = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacing),

            // Tabla de usuarios
            Expanded(
              child: BlocBuilder<UsuariosRolesBloc, UsuariosRolesState>(
                builder: (context, state) {
                  if (state is UsuariosRolesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is UsuariosRolesError) {
                    return Center(
                      child: Text(
                        'Error: ${state.message}',
                        style: TextStyle(color: AppColors.error),
                      ),
                    );
                  }

                  if (state is UsuariosRolesLoaded) {
                    // Filtrar usuarios
                    List<PersonalEntity> usuarios = state.usuarios;

                    // Aplicar búsqueda
                    if (_searchQuery.isNotEmpty) {
                      usuarios = usuarios.where((u) {
                        final nombre = u.nombreCompleto.toLowerCase();
                        final email = u.email?.toLowerCase() ?? '';
                        final query = _searchQuery.toLowerCase();
                        return nombre.contains(query) || email.contains(query);
                      }).toList();
                    }

                    // Aplicar filtro de rol
                    if (_filtroRol != null) {
                      usuarios = usuarios.where((u) => u.categoria == _filtroRol).toList();
                    }

                    return _buildUsuariosTable(usuarios);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsuariosTable(List<PersonalEntity> usuarios) {
    return Card(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Nombre')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Rol')),
          DataColumn(label: Text('Estado')),
          DataColumn(label: Text('Acciones')),
        ],
        rows: usuarios.map((usuario) {
          final role = UserRole.fromString(usuario.categoria);

          return DataRow(
            cells: [
              DataCell(Text(usuario.nombreCompleto)),
              DataCell(Text(usuario.email ?? 'Sin email')),
              DataCell(
                Chip(
                  label: Text(role.label),
                  backgroundColor: _getColorForRole(role).withOpacity(0.2),
                ),
              ),
              DataCell(
                Switch(
                  value: usuario.activo,
                  onChanged: (value) {
                    context.read<UsuariosRolesBloc>().add(
                          UsuariosRolesToggleActivoRequested(usuario.id, value),
                        );
                  },
                ),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _cambiarRol(context, usuario),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Future<void> _cambiarRol(BuildContext context, PersonalEntity usuario) async {
    final nuevoRol = await showDialog<String>(
      context: context,
      builder: (context) => CambiarRolDialog(usuario: usuario),
    );

    if (nuevoRol != null && context.mounted) {
      context.read<UsuariosRolesBloc>().add(
            UsuariosRolesCambiarRolRequested(usuario.id, nuevoRol),
          );
    }
  }

  Color _getColorForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.emergency;
      case UserRole.jefePersonal:
      case UserRole.jefeTrafic:
        return AppColors.primary;
      case UserRole.coordinador:
        return AppColors.secondary;
      case UserRole.administrativo:
        return AppColors.info;
      case UserRole.conductor:
      case UserRole.sanitario:
        return AppColors.success;
      default:
        return AppColors.gray400;
    }
  }
}
```

---

## 🔐 Control de Acceso

Solo usuarios con rol `admin` pueden acceder a esta página. Agregar en GoRouter:

```dart
GoRoute(
  path: '/administracion/usuarios-roles',
  name: 'usuarios_roles',
  builder: (context, state) => const UsuariosRolesPage(),
  redirect: (context, state) async {
    final roleService = getIt<RoleService>();
    final isAdmin = await roleService.isAdmin();

    if (!isAdmin) {
      return '/'; // Redirigir a dashboard
    }

    return null;
  },
),
```

---

## ✅ Checklist

- [ ] Crear estructura de archivos
- [ ] Implementar BLoC (events, states, bloc)
- [ ] Crear widgets (dialog, filtros)
- [ ] Crear página principal
- [ ] Configurar DI en `locator.dart`
- [ ] Agregar ruta en `app_router.dart` con protección admin
- [ ] Agregar opción en menú (solo visible para admin)
- [ ] Ejecutar `flutter pub run build_runner build`
- [ ] Ejecutar `flutter analyze` (0 warnings)
- [ ] Probar con diferentes roles

---

**Última actualización**: 2025-12-26
