# Plantillas de Turnos - Diseño Técnico

## 📋 Descripción General

Las plantillas de turnos permiten crear configuraciones reutilizables de turnos para agilizar la asignación de horarios recurrentes.

## 🗄️ Estructura de Base de Datos

### Tabla: `plantillas_turnos`

```sql
CREATE TABLE plantillas_turnos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT,
  tipo_turno VARCHAR(50) NOT NULL, -- 'manana', 'tarde', 'noche', 'guardia24h'
  hora_inicio VARCHAR(5) NOT NULL, -- Formato HH:mm
  hora_fin VARCHAR(5) NOT NULL, -- Formato HH:mm
  color VARCHAR(7), -- Color hex para visualización
  duracion_dias INTEGER DEFAULT 1, -- 1 = mismo día, 2 = turno de 24h, etc.
  observaciones TEXT,
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

-- Índices
CREATE INDEX idx_plantillas_turnos_activo ON plantillas_turnos(activo);
CREATE INDEX idx_plantillas_turnos_tipo ON plantillas_turnos(tipo_turno);
CREATE INDEX idx_plantillas_turnos_created_by ON plantillas_turnos(created_by);
```

### Row Level Security (RLS)

```sql
-- Habilitar RLS
ALTER TABLE plantillas_turnos ENABLE ROW LEVEL SECURITY;

-- Política de lectura: todos los usuarios autenticados
CREATE POLICY "Usuarios pueden leer plantillas activas"
ON plantillas_turnos FOR SELECT
TO authenticated
USING (activo = true);

-- Política de creación: solo usuarios autenticados
CREATE POLICY "Usuarios autenticados pueden crear plantillas"
ON plantillas_turnos FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = created_by);

-- Política de actualización: solo el creador
CREATE POLICY "Usuario puede actualizar sus plantillas"
ON plantillas_turnos FOR UPDATE
TO authenticated
USING (auth.uid() = created_by);

-- Política de eliminación: solo el creador
CREATE POLICY "Usuario puede eliminar sus plantillas"
ON plantillas_turnos FOR DELETE
TO authenticated
USING (auth.uid() = created_by);
```

## 📦 Entidades y Modelos

### PlantillaTurnoEntity (Domain)

```dart
class PlantillaTurnoEntity extends Equatable {
  const PlantillaTurnoEntity({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.tipoTurno,
    required this.horaInicio,
    required this.horaFin,
    this.color,
    this.duracionDias = 1,
    this.observaciones,
    this.activo = true,
  });

  final String id;
  final String nombre;
  final String? descripcion;
  final TipoTurno tipoTurno;
  final String horaInicio; // HH:mm
  final String horaFin; // HH:mm
  final String? color; // Hex color
  final int duracionDias;
  final String? observaciones;
  final bool activo;
}
```

## 🎨 UI/UX

### Página Principal: PlantillasTurnosPage

**Ubicación**: `/tablas/plantillas-turnos`

**Características**:
- Tabla con todas las plantillas
- Búsqueda por nombre
- Filtro por tipo de turno
- Acciones: Crear, Editar, Eliminar, Duplicar
- Vista previa de horarios

### Diálogo: CrearPlantillaDialog

**Campos**:
1. Nombre (requerido)
2. Descripción (opcional)
3. Tipo de Turno (dropdown)
4. Hora Inicio (time picker)
5. Hora Fin (time picker)
6. Duración (días)
7. Color (color picker)
8. Observaciones (textarea)

### Integración en TurnoFormDialog

**Nueva sección**: "Usar Plantilla"
- Dropdown con plantillas disponibles
- Al seleccionar, rellena automáticamente:
  - Tipo de turno
  - Hora inicio/fin
  - Observaciones
- Usuario puede modificar después

## 🔄 Flujo de Uso

### Caso 1: Crear Plantilla
1. Usuario va a "Tablas > Plantillas de Turnos"
2. Clic en "Crear Plantilla"
3. Rellena formulario
4. Guarda
5. Plantilla disponible en todo el sistema

### Caso 2: Usar Plantilla
1. Usuario crea/edita turno en cuadrante
2. En formulario, selecciona plantilla del dropdown
3. Campos se rellenan automáticamente
4. Usuario ajusta fechas/personal
5. Guarda turno

### Caso 3: Duplicar Plantilla
1. Usuario encuentra plantilla similar
2. Clic en "Duplicar"
3. Se crea copia con nombre "Copia de [original]"
4. Usuario modifica y guarda

## 📊 Estadísticas Útiles

- Plantillas más usadas
- Últimas plantillas creadas
- Total de turnos creados con cada plantilla

## 🚀 Fases de Implementación

### Fase 1: Backend (Base de Datos)
- [x] Diseño de tabla
- [ ] Crear tabla en Supabase
- [ ] Configurar RLS policies
- [ ] Crear índices

### Fase 2: Domain Layer
- [ ] PlantillaTurnoEntity
- [ ] PlantillaTurnoRepository (interface)

### Fase 3: Data Layer
- [ ] PlantillaTurnoModel
- [ ] PlantillasTurnosDataSource
- [ ] PlantillaTurnoRepositoryImpl

### Fase 4: Presentation Layer
- [ ] PlantillaTurnosBloc (events, states)
- [ ] PlantillasTurnosPage
- [ ] PlantillaTurnoTable
- [ ] CrearPlantillaDialog

### Fase 5: Integración
- [ ] Agregar selector en TurnoFormDialog
- [ ] Agregar ruta en app_router.dart
- [ ] Agregar opción en menú "Tablas"

### Fase 6: Testing
- [ ] Tests unitarios
- [ ] Tests de integración
- [ ] Testing manual

## 🎯 Mejoras Futuras

- Compartir plantillas entre usuarios
- Plantillas predefinidas del sistema
- Importar/Exportar plantillas
- Plantillas con personal asignado por defecto
- Sugerencias inteligentes de plantillas según contexto
