# Página de Vehículos - AmbuTrack

## ✅ Implementación Completada

Se ha creado la página de gestión de vehículos siguiendo el mismo patrón y comportamiento que el resto de la aplicación.

## 📍 Ubicación

- **Archivo**: `lib/features/vehiculos/vehiculos_page.dart`
- **Ruta**: `/vehiculos`
- **Menú**: Vehículos → Vehículos

## 🎨 Características

### 1. Header con Gradiente
- Título: "Gestión de Vehículos"
- Icono de vehículo
- Botón "Agregar Vehículo" (preparado para implementación futura)

### 2. Estadísticas Rápidas
Muestra 4 tarjetas con métricas clave:
- **Total Vehículos**: 12
- **Disponibles**: 8 (verde)
- **En Servicio**: 3 (azul)
- **Mantenimiento**: 1 (amarillo)

### 3. Lista de Vehículos
Muestra tarjetas con información detallada de cada vehículo:
- Matrícula
- Marca y modelo
- Tipo de vehículo
- Estado (con badge de color)
- Conductor (si aplica)
- Ubicación
- Kilometraje

### Vehículos de Ejemplo
1. **AMB-001-XY** - Mercedes-Benz Sprinter (Disponible)
2. **AMB-002-XY** - Ford Transit (En Servicio)
3. **AMB-003-XY** - Volkswagen Crafter (Mantenimiento)

## 🎯 Patrón de Diseño

La página sigue el mismo patrón que las demás páginas de AmbuTrack:

```dart
VehiculosPage (StatelessWidget)
  └── Scaffold
      └── SingleChildScrollView
          └── Column
              ├── _VehiculosHeader
              ├── _VehiculosStats
              └── _VehiculosList
```

### Componentes Reutilizables
- `_VehiculosHeader`: Header con gradiente y botón de acción
- `_VehiculosStats`: Tarjetas de estadísticas
- `_StatCard`: Tarjeta individual de estadística
- `_VehiculosList`: Lista de vehículos
- `_VehiculoCard`: Tarjeta de vehículo individual
- `_InfoChip`: Chip de información con icono

## 🔗 Integración con el Sistema

### Menú Actualizado
El menú principal ha sido actualizado:
- **Antes**: "Vehículos / Flota" → "Inventario de Vehículos"
- **Ahora**: "Vehículos" → "Vehículos"

### Ruta Configurada
```dart
GoRoute(
  path: '/vehiculos',
  name: 'vehiculos',
  builder: (BuildContext context, GoRouterState state) =>
      const VehiculosPage(),
),
```

## 🚀 Cómo Acceder

1. Hacer login en la aplicación
2. En el menú superior, click en "Vehículos"
3. En el dropdown, click en "Vehículos"
4. Se mostrará la página de gestión de vehículos

## 📋 Funcionalidades Pendientes (TODO)

Las siguientes funcionalidades están marcadas como `TODO` para implementación futura:

1. **Agregar Vehículo**
   - Formulario para crear nuevo vehículo
   - Validación de datos
   - Integración con Firebase/Backend

2. **Editar Vehículo**
   - Formulario de edición
   - Actualización en tiempo real

3. **Eliminar Vehículo**
   - Confirmación de eliminación
   - Eliminación de base de datos

4. **Filtros**
   - Filtrar por estado
   - Filtrar por tipo
   - Búsqueda por matrícula/marca/modelo

5. **Menú de Acciones**
   - Ver detalles
   - Editar
   - Eliminar
   - Asignar conductor
   - Ver historial

6. **Integración con Backend**
   - Conectar con Firebase Firestore
   - Implementar BLoC para gestión de estado
   - CRUD completo

## 🎨 Colores Utilizados

- **Disponible**: `AppColors.success` (verde)
- **En Servicio**: `AppColors.info` (azul)
- **Mantenimiento**: `AppColors.warning` (amarillo)
- **Averiado**: `AppColors.emergency` (rojo)
- **Fuera de Servicio**: `AppColors.gray600` (gris)

## 📱 Responsive

La página es responsive y se adapta a diferentes tamaños de pantalla:
- Desktop: Muestra todas las estadísticas en una fila
- Tablet: Se adapta el tamaño de las tarjetas
- Móvil: Las tarjetas se apilan verticalmente

## 🔄 Siguiente Paso Recomendado

Para completar la funcionalidad de vehículos, se recomienda:

1. Crear el modelo de datos `Vehiculo`
2. Implementar el repositorio con Firebase
3. Crear el BLoC para gestión de estado
4. Implementar los formularios de agregar/editar
5. Conectar con la base de datos

---

**Última actualización**: 2025-09-30
**Versión**: 1.0.0
