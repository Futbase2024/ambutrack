# Facultativos - CRUD Completo

## 📋 Descripción

Módulo de gestión de **Facultativos** (médicos y profesionales sanitarios) del sistema AmbuTrack.

---

## 🗄️ Tabla en Supabase

### Nombre de la tabla
`tfacultativos`

### Estructura de campos

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | UUID | Sí | Identificador único (PK, auto-generado) |
| `nombre` | TEXT | Sí | Nombre del facultativo |
| `apellidos` | TEXT | Sí | Apellidos del facultativo |
| `num_colegiado` | TEXT | No | Número de colegiado profesional |
| `especialidad_id` | UUID | No | FK → `tespecialidades.id` |
| `telefono` | TEXT | No | Teléfono de contacto |
| `email` | TEXT | No | Correo electrónico |
| `activo` | BOOLEAN | Sí | Estado activo/inactivo (default: true) |
| `created_at` | TIMESTAMP | Sí | Fecha de creación (auto) |
| `updated_at` | TIMESTAMP | Sí | Fecha de actualización (auto) |

### Relaciones

- **FK con `tespecialidades`**: `especialidad_id` → `tespecialidades.id`
  - Constraint: `fk_tfacultativos_especialidad`
  - `ON DELETE SET NULL`: Si se elimina una especialidad, el facultativo queda sin especialidad
- **Campo calculado**: `especialidad_nombre` se obtiene mediante JOIN en consultas

### Índices

- `idx_facultativos_apellidos` - Búsqueda por apellidos
- `idx_facultativos_num_colegiado` - Búsqueda por número de colegiado
- `idx_facultativos_activo` - Filtrado por estado activo

### Políticas RLS

✅ **Row Level Security (RLS)** habilitado

- **SELECT**: Permitido a usuarios autenticados
- **INSERT**: Permitido a usuarios autenticados
- **UPDATE**: Permitido a usuarios autenticados
- **DELETE**: Permitido a usuarios autenticados

---

## 📂 Estructura del Código

### Domain Layer
```
lib/features/tablas/facultativos/domain/
├── entities/
│   └── facultativo_entity.dart        # Entidad de dominio
└── repositories/
    └── facultativo_repository.dart    # Contrato del repositorio
```

### Data Layer
```
lib/features/tablas/facultativos/data/
├── models/
│   ├── facultativo_model.dart         # Modelo con JSON serialization
│   └── facultativo_model.g.dart       # Código generado
├── datasources/
│   └── facultativo_datasource.dart    # Acceso a Supabase
└── repositories/
    └── facultativo_repository_impl.dart # Implementación del repositorio
```

### Presentation Layer
```
lib/features/tablas/facultativos/presentation/
├── bloc/
│   ├── facultativo_event.dart         # Eventos del BLoC
│   ├── facultativo_state.dart         # Estados del BLoC
│   └── facultativo_bloc.dart          # Lógica de negocio
├── pages/
│   └── facultativos_page.dart         # Página principal
└── widgets/
    ├── facultativo_header.dart        # Header con botón agregar
    ├── facultativo_table.dart         # Tabla de datos
    └── facultativo_form_dialog.dart   # Formulario crear/editar
```

---

## 🚀 Instalación y Configuración

### 1. Ejecutar migración en Supabase

Ejecuta el script SQL en Supabase:

```bash
# Desde el dashboard de Supabase > SQL Editor
# O usando CLI:
supabase db push
```

**Archivos**:
- `supabase/migrations/004_crear_tabla_facultativos.sql` (creación inicial)
- `supabase/migrations/006_migrar_facultativos_especialidad_fk.sql` (migración FK)

### 2. Verificar tabla creada

```sql
SELECT * FROM facultativos LIMIT 5;
```

### 3. Agregar ruta en el router

Editar `lib/core/router/app_router.dart`:

```dart
GoRoute(
  path: '/tablas/facultativos',
  name: 'facultativos',
  builder: (context, state) => const FacultativosPage(),
),
```

### 4. Agregar al menú

Editar el repositorio de menú para incluir:

```dart
MenuItemEntity(
  id: 'facultativos',
  label: 'Facultativos',
  icon: Icons.medical_services,
  route: '/tablas/facultativos',
),
```

---

## 🎯 Funcionalidades Implementadas

### ✅ CRUD Completo

- ✅ **Crear** facultativo
- ✅ **Leer** lista de facultativos
- ✅ **Actualizar** facultativo existente
- ✅ **Eliminar** facultativo

### ✅ Características

- ✅ Validación de formularios
- ✅ Navegación por teclado (Tab/Enter)
- ✅ Estado activo/inactivo
- ✅ Validación de email
- ✅ Loading automático desde BLoC
- ✅ Confirmación antes de eliminar
- ✅ Tabla responsive
- ✅ Ordenamiento por apellidos
- ✅ Estados visuales (badges)

---

## 📝 Validaciones

### Campos obligatorios
- ✅ Nombre
- ✅ Apellidos

### Campos opcionales
- Número de colegiado
- Especialidad (dropdown con opciones de `tespecialidades`)
- Teléfono
- Email (con validación de formato)

### Validación de email
```dart
if (value != null && value.trim().isNotEmpty && !value.contains('@')) {
  return 'Email inválido';
}
```

---

## 🎨 UI/UX

### Diseño de tabla
- Header con color primario (`AppColors.primary`)
- Badges de estado (Activo/Inactivo)
- Iconos de acciones (editar, eliminar)
- Responsive (scroll horizontal en pantallas pequeñas)

### Formulario
- Campos con iconos descriptivos
- Labels flotantes
- **Dropdown de especialidades**: Carga especialidades activas de Supabase
- **Loading inicial**: Muestra `AppLoadingIndicator` mientras carga especialidades
- Switch para estado activo/inactivo
- Navegación con Tab/Enter entre campos
- Loading indicator mientras se guardan cambios

---

## 🔐 Seguridad

- ✅ Row Level Security (RLS) habilitado
- ✅ Solo usuarios autenticados pueden acceder
- ✅ Validación en frontend y backend
- ✅ UUID como identificador (no secuencial)

---

## 📊 Datos de Ejemplo

La migración incluye 5 facultativos de ejemplo con especialidades asignadas mediante FK:

1. **Carlos García López** - Cardiología (FK → tespecialidades)
2. **María Martínez Fernández** - Neurología (FK → tespecialidades)
3. **José Rodríguez Sánchez** - Traumatología (FK → tespecialidades)
4. **Ana López Pérez** - Pediatría (FK → tespecialidades)
5. **David González Ruiz** - Anestesiología (FK → tespecialidades)

> **Nota**: La migración 006 convirtió el campo `especialidad` TEXT a `especialidad_id` UUID FK, preservando los datos existentes mediante mapeo automático.

---

## 🧪 Testing

### Verificar DataSource
```dart
final datasource = getIt<FacultativoDataSource>();
final facultativos = await datasource.getAll();
print('Facultativos: ${facultativos.length}');
```

### Verificar BLoC
```dart
final bloc = getIt<FacultativoBloc>();
bloc.add(const FacultativoLoadAllRequested());
```

---

## 🐛 Troubleshooting

### Error: "Table 'facultativos' does not exist"
**Solución**: Ejecutar la migración SQL en Supabase

### Error: "No issues found" pero no aparecen datos
**Solución**: Verificar políticas RLS en Supabase

### Error: Injectable no encuentra FacultativoBloc
**Solución**: Ejecutar `flutter pub run build_runner build --delete-conflicting-outputs`

---

## 📚 Referencias

- **Migraciones SQL**:
  - `supabase/migrations/004_crear_tabla_facultativos.sql` (creación inicial)
  - `supabase/migrations/006_migrar_facultativos_especialidad_fk.sql` (migración FK)
- **Entity**: `lib/features/tablas/facultativos/domain/entities/facultativo_entity.dart`
- **Model**: `lib/features/tablas/facultativos/data/models/facultativo_model.dart`
- **DataSource**: `lib/features/tablas/facultativos/data/datasources/facultativo_datasource.dart`
- **FormDialog**: `lib/features/tablas/facultativos/presentation/widgets/facultativo_form_dialog.dart`
- **Documentación Supabase**: https://supabase.com/docs
- **Clean Architecture**: Seguir patrón del proyecto
- **BLoC Pattern**: Estados simplificados (Initial, Loading, Loaded, Error)

---

## ✅ Checklist de Implementación

- [x] Crear entidad de dominio
- [x] Crear contrato de repositorio
- [x] Crear modelo con JSON serialization
- [x] Crear DataSource con Supabase
- [x] Implementar repositorio
- [x] Crear BLoC (Events, States, Bloc)
- [x] Crear página principal
- [x] Crear widgets (Header, Table, FormDialog)
- [x] Ejecutar build_runner
- [x] Verificar 0 warnings en flutter analyze
- [x] Crear migración SQL
- [ ] Ejecutar migración en Supabase
- [ ] Agregar ruta en router
- [ ] Agregar al menú
- [ ] Testing manual
- [ ] Testing unitario (opcional)

---

**Creado**: 2025-12-18
**Última actualización**: 2025-12-18
**Versión**: 2.0.0 (Migración FK completada)

---

## 🔄 Historial de Cambios

### v2.0.0 (2025-12-18)
- ✅ Migración de `especialidad` TEXT → `especialidad_id` UUID FK
- ✅ Relación FK con `tespecialidades`
- ✅ Campo calculado `especialidad_nombre` en JOIN
- ✅ Dropdown de especialidades en formulario con carga asíncrona
- ✅ Loading indicator durante carga de especialidades
- ✅ Preservación de datos existentes en migración

### v1.0.0 (2025-12-18)
- CRUD completo de Facultativos
- Especialidad como campo TEXT libre
