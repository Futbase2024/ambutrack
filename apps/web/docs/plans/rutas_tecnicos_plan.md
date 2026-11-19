# Plan de Implementación: Módulo de Rutas para Técnicos

**Fecha**: 2026-02-13
**Autor**: Claude Code
**Proyecto**: AmbuTrack Web
**Módulo**: Tráfico Diario → Rutas

---

## 🎯 Objetivo

Implementar un nuevo submódulo dentro de **Tráfico Diario** que permita:
1. Calcular y visualizar rutas de un técnico con vehículo durante un turno
2. Optimizar la secuencia de traslados asignados
3. Mostrar información de distancia, tiempo estimado y orden de visitas
4. Visualizar rutas en un mapa interactivo

---

## 📋 Contexto Actual

### Entidades Disponibles en Core

Ya existen las siguientes entidades en `ambutrack_core_datasource`:

- ✅ **TrasladoEntity** - Información de traslados (origen, destino, hora, conductor, vehículo)
- ✅ **TPersonalEntity** - Información de conductores/técnicos
- ✅ **VehiculoEntity** - Información de vehículos
- ✅ **TurnoEntity** - Información de turnos (para futuro uso)

### Módulo Actual: Tráfico Diario

**Ruta actual**: `/servicios/planificar`
**Funcionalidades**:
- Gestión de traslados del día
- Asignación de conductores y vehículos
- Filtrado y búsqueda
- Realtime updates

---

## 🏗️ Arquitectura Propuesta

### 1. Navegación

**Opción A: Submódulo dentro de Tráfico Diario** (Recomendado)
```
Servicios (menú principal)
  ├── Planificar Servicios  (existe)
  └── Rutas de Técnicos     (NUEVO)
```

**Ruta propuesta**: `/servicios/rutas`

**Opción B: Pestaña adicional en página existente**
- Añadir tabs en `PlanificarServiciosPage`:
  - Tab 1: Planificación (actual)
  - Tab 2: Rutas del Día (nuevo)

**Decisión**: Opción A (más limpio, mejor separación de responsabilidades)

---

### 2. Estructura de Archivos

```
lib/features/trafico_diario/
├── presentation/
│   ├── pages/
│   │   ├── planificar_servicios_page.dart  (existe)
│   │   └── rutas_tecnicos_page.dart        (NUEVO)
│   │
│   ├── bloc/
│   │   ├── trafico_diario_bloc.dart        (existe)
│   │   ├── rutas_bloc.dart                 (NUEVO)
│   │   ├── rutas_event.dart                (NUEVO)
│   │   └── rutas_state.dart                (NUEVO)
│   │
│   └── widgets/
│       ├── rutas/                           (NUEVO)
│       │   ├── selector_tecnico_widget.dart
│       │   ├── selector_fecha_turno_widget.dart
│       │   ├── lista_traslados_ruta_widget.dart
│       │   ├── mapa_ruta_widget.dart
│       │   ├── resumen_ruta_widget.dart
│       │   └── optimizar_ruta_button.dart
│       └── ... (widgets existentes)
│
├── data/
│   └── repositories/
│       └── ruta_repository_impl.dart       (NUEVO - si necesario)
│
└── domain/
    └── repositories/
        └── ruta_repository.dart            (NUEVO - si necesario)
```

---

### 3. Nuevas Entidades (Opcional)

**Opción A: Usar entidades existentes** (Recomendado para MVP)
- No crear nuevas entidades
- Calcular rutas en el BLoC usando `TrasladoEntity`
- Almacenar rutas optimizadas solo en memoria (estado del BLoC)

**Opción B: Crear entidad `RutaEntity`** (Para persistencia futura)
```dart
// packages/ambutrack_core_datasource/lib/src/datasources/rutas/
class RutaEntity {
  final String id;
  final String personalId;
  final String vehiculoId;
  final DateTime fecha;
  final String turno; // mañana, tarde, noche
  final List<PuntoRutaEntity> puntos;
  final double distanciaTotal; // en km
  final int tiempoEstimado; // en minutos
  final DateTime? optimizadoEn;
}

class PuntoRutaEntity {
  final int orden;
  final String trasladoId;
  final String ubicacion;
  final double latitud;
  final double longitud;
  final DateTime horaEstimada;
  final int distanciaDesdeAnterior; // en metros
  final int tiempoDesdeAnterior; // en minutos
}
```

**Decisión inicial**: Opción A (sin persistencia), migrar a Opción B si se requiere histórico.

---

## 🎨 Diseño de UI

### Página: `RutasTecnicosPage`

**Layout estructura**:

```
┌─────────────────────────────────────────────────────────────┐
│  AppBar: "Rutas de Técnicos"                                │
├─────────────────────────────────────────────────────────────┤
│  [Filtros Superior]                                         │
│  ┌───────────────┐ ┌──────────────┐ ┌──────────────────┐   │
│  │ Técnico: ▼    │ │ Fecha: 📅    │ │ Turno: ▼         │   │
│  └───────────────┘ └──────────────┘ └──────────────────┘   │
│                                      [🔄 Calcular Ruta]     │
├─────────────────────────────────────────────────────────────┤
│  [Contenido Principal - Split View]                         │
│  ┌──────────────────────┬──────────────────────────────┐   │
│  │ Panel Izquierdo 40%  │ Panel Derecho 60%            │   │
│  │                      │                              │   │
│  │ [Resumen]            │ [Mapa Interactivo]           │   │
│  │ ┌──────────────────┐ │ ┌──────────────────────────┐ │   │
│  │ │ Traslados: 8     │ │ │                          │ │   │
│  │ │ Distancia: 45 km │ │ │      🗺️ MAPA             │ │   │
│  │ │ Tiempo: 2h 15min │ │ │                          │ │   │
│  │ └──────────────────┘ │ │                          │ │   │
│  │                      │ │                          │ │   │
│  │ [Lista Traslados]    │ │                          │ │   │
│  │ ┌──────────────────┐ │ │                          │ │   │
│  │ │ 1. 08:00 - Hosp. │ │ │                          │ │   │
│  │ │    A → Domicilio │ │ │                          │ │   │
│  │ │    5.2 km, 12min │ │ └──────────────────────────┘ │   │
│  │ ├──────────────────┤ │                              │   │
│  │ │ 2. 08:30 - Hosp. │ │ [Acciones]                   │   │
│  │ │    B → Centro X  │ │ [📊 Exportar PDF]            │   │
│  │ │    8.1 km, 18min │ │ [📧 Enviar a Técnico]        │   │
│  │ └──────────────────┘ │ [🔄 Optimizar Ruta]          │   │
│  └──────────────────────┴──────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

**Componentes principales**:

1. **Selector de Técnico** (`AppSearchableDropdown`)
   - Lista de técnicos activos con vehículos asignados
   - Muestra: Nombre + Vehículo actual

2. **Selector de Fecha** (`AppDatePicker`)
   - Por defecto: fecha actual
   - Permite seleccionar cualquier fecha

3. **Selector de Turno** (`AppDropdown`)
   - Opciones: Mañana, Tarde, Noche, Todo el día
   - Por defecto: detectar turno actual

4. **Panel Resumen** (`ResumenRutaWidget`)
   - Cards con métricas:
     - Total traslados
     - Distancia total
     - Tiempo estimado total
     - Hora inicio/fin estimada

5. **Lista de Traslados** (`ListaTrasladosRutaWidget`)
   - Lista ordenada con:
     - Número de orden
     - Hora programada
     - Origen → Destino
     - Distancia y tiempo desde punto anterior
     - Estado del traslado
   - Drag & drop para reordenar (opcional)

6. **Mapa Interactivo** (`MapaRutaWidget`)
   - Visualización de ruta con marcadores
   - Líneas conectando puntos
   - Información en hover/clic
   - Integración con Google Maps / Mapbox

7. **Botones de Acción**
   - Calcular/Recalcular ruta
   - Optimizar orden (algoritmo)
   - Exportar PDF
   - Enviar por email/notificación

---

## 🧩 Lógica de Negocio

### Flujo Principal

1. **Usuario selecciona**:
   - Técnico/Conductor
   - Fecha
   - Turno (opcional)

2. **Sistema carga**:
   - Traslados asignados a ese técnico en esa fecha
   - Información del vehículo asignado
   - Ubicaciones (origen/destino de cada traslado)

3. **Sistema calcula**:
   - Ruta entre todos los puntos
   - Distancias entre puntos consecutivos
   - Tiempos estimados
   - Métricas totales

4. **Usuario puede**:
   - Ver ruta en mapa
   - Reordenar manualmente traslados
   - Optimizar automáticamente
   - Exportar información

---

### Algoritmo de Optimización (Opcional - Fase 2)

**Problema**: TSP (Traveling Salesman Problem) simplificado

**Estrategias**:

**Opción A: Greedy (Vecino más cercano)** - Simple, rápido
```
1. Empezar desde ubicación actual del vehículo
2. Seleccionar siguiente traslado más cercano no visitado
3. Repetir hasta completar todos
```

**Opción B: Respeto a horas programadas** - Realista
```
1. Ordenar traslados por hora programada
2. Validar que sea posible cumplir tiempos
3. Ajustar orden solo si mejora eficiencia sin incumplir horarios
```

**Opción C: Integración con API externa** - Profesional
- Google Maps Directions API
- Mapbox Optimization API
- OpenRouteService

**Decisión MVP**: Opción B (respetar horarios, calcular distancias)

---

## 🔌 Integraciones Necesarias

### 1. Servicio de Mapas

**Opciones**:

| Servicio | Pros | Contras | Coste |
|----------|------|---------|-------|
| **Google Maps** | Completo, preciso | Requiere API key, costoso | $$ |
| **Mapbox** | Buena UX, customizable | Requiere API key | $ |
| **OpenStreetMap** | Gratis, open source | Menos preciso | Gratis |
| **flutter_map** | Offline, customizable | Requiere tiles server | Gratis* |

**Decisión MVP**: `google_maps_flutter` (ya ampliamente usado en Flutter)

**Configuración necesaria**:
```yaml
# pubspec.yaml
dependencies:
  google_maps_flutter: ^2.9.0
  google_maps_flutter_web: ^0.5.10
```

**Credenciales**: Añadir `GOOGLE_MAPS_API_KEY` en configuración de entorno

---

### 2. Cálculo de Distancias/Rutas

**Opciones**:

**A. Google Distance Matrix API**
```dart
final response = await http.get(
  Uri.parse('https://maps.googleapis.com/maps/api/distancematrix/json'
    '?origins=$lat1,$lng1'
    '&destinations=$lat2,$lng2'
    '&key=$apiKey'),
);
```

**B. Cálculo aproximado (Haversine)** - Sin API
```dart
double calcularDistancia(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371; // Radio Tierra en km
  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
      sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}
```

**Decisión MVP**: Opción B (Haversine) para MVP, migrar a A si se requiere precisión de rutas reales.

---

### 3. Geocodificación (si no hay coordenadas)

Si `TrasladoEntity` no tiene coordenadas GPS para origen/destino:

**Opciones**:
- Google Geocoding API
- Nominatim (OpenStreetMap)
- Precarga de coordenadas en base de datos

**Decisión**: Verificar primero si existen coordenadas en base de datos. Si no, usar Geocoding API.

---

## 📊 Modelo de Datos

### Estado del BLoC

```dart
@freezed
class RutasState with _$RutasState {
  const factory RutasState.initial() = _Initial;

  const factory RutasState.loading() = _Loading;

  const factory RutasState.loaded({
    required String tecnicoId,
    required String tecnicoNombre,
    required String vehiculoMatricula,
    required DateTime fecha,
    required String? turno,
    required List<TrasladoConRutaInfo> traslados,
    required RutaResumen resumen,
  }) = _Loaded;

  const factory RutasState.error({
    required String message,
  }) = _Error;

  const factory RutasState.empty({
    String? mensaje,
  }) = _Empty;
}

@freezed
class TrasladoConRutaInfo with _$TrasladoConRutaInfo {
  const factory TrasladoConRutaInfo({
    required int orden,
    required TrasladoEntity traslado,
    required PuntoUbicacion origen,
    required PuntoUbicacion destino,
    double? distanciaKm,
    int? tiempoMinutos,
    DateTime? horaEstimadaLlegada,
  }) = _TrasladoConRutaInfo;
}

@freezed
class PuntoUbicacion with _$PuntoUbicacion {
  const factory PuntoUbicacion({
    required String nombre,
    required double latitud,
    required double longitud,
    String? direccion,
  }) = _PuntoUbicacion;
}

@freezed
class RutaResumen with _$RutaResumen {
  const factory RutaResumen({
    required int totalTraslados,
    required double distanciaTotalKm,
    required int tiempoTotalMinutos,
    DateTime? horaInicio,
    DateTime? horaFin,
  }) = _RutaResumen;
}
```

### Eventos del BLoC

```dart
@freezed
class RutasEvent with _$RutasEvent {
  const factory RutasEvent.started() = _Started;

  const factory RutasEvent.cargarRutaRequested({
    required String tecnicoId,
    required DateTime fecha,
    String? turno,
  }) = _CargarRutaRequested;

  const factory RutasEvent.optimizarRutaRequested() = _OptimizarRutaRequested;

  const factory RutasEvent.reordenarTrasladosRequested({
    required List<String> nuevoOrden,
  }) = _ReordenarTrasladosRequested;

  const factory RutasEvent.exportarPdfRequested() = _ExportarPdfRequested;

  const factory RutasEvent.enviarATecnicoRequested() = _EnviarATecnicoRequested;

  const factory RutasEvent.refreshRequested() = _RefreshRequested;
}
```

---

## 🗄️ Cambios en Base de Datos (Opcional)

### Opción A: Sin cambios (MVP)
- Usar solo datos existentes en `traslados`
- Calcular todo en memoria

### Opción B: Tabla de rutas precalculadas (Futuro)

```sql
-- Tabla para almacenar rutas calculadas
CREATE TABLE rutas_tecnico (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  personal_id UUID REFERENCES tpersonal(id),
  vehiculo_id UUID REFERENCES vehiculos(id),
  fecha DATE NOT NULL,
  turno VARCHAR(20),
  puntos_ruta JSONB NOT NULL, -- Array de puntos ordenados
  distancia_total_km DECIMAL(10,2),
  tiempo_total_minutos INTEGER,
  optimizado_en TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(personal_id, fecha, turno)
);

-- Índices
CREATE INDEX idx_rutas_tecnico_personal_fecha ON rutas_tecnico(personal_id, fecha);
CREATE INDEX idx_rutas_tecnico_fecha ON rutas_tecnico(fecha);
```

**Decisión MVP**: Opción A (sin persistencia), evaluar Opción B si se requiere histórico.

---

## 📦 Dependencias Nuevas

Añadir a `pubspec.yaml`:

```yaml
dependencies:
  # Mapas
  google_maps_flutter: ^2.9.0
  google_maps_flutter_web: ^0.5.10

  # Geocodificación (opcional)
  geocoding: ^3.0.0

  # Cálculos geográficos
  geolocator: ^13.0.1

  # Exportar PDF (opcional - Fase 2)
  pdf: ^3.11.1
  printing: ^5.13.2

  # Utils
  collection: ^1.18.0 # Para algoritmos de ordenamiento
```

---

## 🧪 Testing

### Tests Unitarios (BLoC)

```dart
// test/unit/presentation/features/rutas/bloc/rutas_bloc_test.dart
group('RutasBloc', () {
  test('estado inicial es RutasState.initial()', () {
    expect(bloc.state, const RutasState.initial());
  });

  blocTest<RutasBloc, RutasState>(
    'cargar ruta emite [loading, loaded] cuando hay traslados',
    build: () {
      when(() => mockTrasladoRepository.getTrasladosPorTecnicoYFecha(
        any(), any(), turno: any(named: 'turno'),
      )).thenAnswer((_) async => mockTraslados);
      return bloc;
    },
    act: (bloc) => bloc.add(RutasEvent.cargarRutaRequested(
      tecnicoId: 'tecnico-1',
      fecha: DateTime(2026, 2, 13),
      turno: 'mañana',
    )),
    expect: () => [
      const RutasState.loading(),
      isA<RutasState>().having(
        (s) => s.maybeMap(loaded: (l) => l.traslados.length, orElse: () => 0),
        'traslados count',
        greaterThan(0),
      ),
    ],
  );
});
```

### Tests de Widgets

```dart
// test/widget/presentation/features/rutas/pages/rutas_tecnicos_page_test.dart
testWidgets('muestra selector de técnico', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: RutasTecnicosPage()),
  );

  expect(find.text('Técnico:'), findsOneWidget);
  expect(find.byType(AppSearchableDropdown), findsOneWidget);
});
```

---

## 📅 Fases de Implementación

### **Fase 1: MVP - Visualización Básica** ⏱️ 3-4 días

**Alcance**:
- ✅ Crear página `RutasTecnicosPage`
- ✅ Implementar `RutasBloc` con estados/eventos básicos
- ✅ Selectores de técnico, fecha, turno
- ✅ Cargar traslados del técnico
- ✅ Calcular distancias aproximadas (Haversine)
- ✅ Mostrar lista de traslados con orden
- ✅ Mostrar resumen (total traslados, distancia, tiempo)
- ✅ Añadir ruta en el router
- ✅ Añadir opción en menú de Servicios

**Entregables**:
- Página funcional con carga de datos
- Cálculos de distancia y tiempo
- UI limpia con Material Design 3
- Tests unitarios del BLoC
- 0 warnings en `flutter analyze`

---

### **Fase 2: Mapas y Visualización** ⏱️ 2-3 días

**Alcance**:
- ✅ Integrar `google_maps_flutter`
- ✅ Crear `MapaRutaWidget`
- ✅ Mostrar marcadores en mapa (origen/destino de cada traslado)
- ✅ Dibujar líneas de ruta
- ✅ Información en marcadores (número, hora, destino)
- ✅ Zoom automático para mostrar toda la ruta
- ✅ Interacción (clic en marcador → destacar en lista)

**Entregables**:
- Mapa funcional con ruta visualizada
- Sincronización entre lista y mapa
- Tests de integración

---

### **Fase 3: Optimización** ⏱️ 2 días

**Alcance**:
- ✅ Implementar algoritmo de optimización (respetando horarios)
- ✅ Botón "Optimizar Ruta"
- ✅ Comparación antes/después
- ✅ Drag & drop manual para reordenar
- ✅ Validación de tiempos (alertar si no es factible)

**Entregables**:
- Algoritmo funcional
- UX fluida para reordenamiento
- Tests del algoritmo

---

### **Fase 4: Acciones Avanzadas** ⏱️ 1-2 días

**Alcance**:
- ✅ Exportar a PDF
- ✅ Enviar ruta al técnico (email/notificación)
- ✅ Compartir ruta (link)
- ✅ Imprimir hoja de ruta

**Entregables**:
- Funcionalidades de exportación
- Integración con sistema de notificaciones

---

### **Fase 5: Persistencia y Histórico** ⏱️ 2 días

**Alcance**:
- ✅ Crear tabla `rutas_tecnico` en Supabase
- ✅ Guardar rutas calculadas
- ✅ Consultar rutas pasadas
- ✅ Comparar eficiencia entre días

**Entregables**:
- Datasource + Repository
- Histórico funcional
- Analytics básicos

---

## ✅ Checklist de Implementación (Fase 1 - MVP)

```
□ Crear carpeta `lib/features/trafico_diario/presentation/widgets/rutas/`
□ Crear `rutas_bloc.dart` + estados/eventos con Freezed
□ Crear `rutas_tecnicos_page.dart`
□ Crear `selector_tecnico_widget.dart`
□ Crear `selector_fecha_turno_widget.dart`
□ Crear `lista_traslados_ruta_widget.dart`
□ Crear `resumen_ruta_widget.dart`
□ Implementar servicio de cálculo de distancias (Haversine)
□ Registrar BLoC en DI (`injection.dart`)
□ Añadir ruta `/servicios/rutas` en router
□ Añadir opción "Rutas de Técnicos" en menú Servicios
□ Crear tests unitarios de `RutasBloc`
□ Crear tests de widgets principales
□ Ejecutar `flutter analyze` → 0 warnings
□ Documentar uso en README del módulo
```

---

## 🎯 Métricas de Éxito

1. **Funcionalidad**:
   - ✅ Usuario puede ver traslados ordenados de un técnico
   - ✅ Sistema calcula distancias y tiempos
   - ✅ UI es responsiva y clara

2. **Calidad**:
   - ✅ 0 warnings en `flutter analyze`
   - ✅ Cobertura de tests ≥ 85%
   - ✅ No hay regresiones en módulo existente

3. **UX**:
   - ✅ Carga rápida (< 2 segundos)
   - ✅ Información clara y útil
   - ✅ Acciones evidentes

---

## 🚧 Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Datos de ubicación incompletos | Alta | Alto | Validar datos, usar geocodificación de respaldo |
| Cálculos de distancia inexactos | Media | Medio | Usar API de Google Maps en Fase 2 |
| Performance con muchos traslados | Baja | Medio | Paginación, lazy loading del mapa |
| Coste de APIs externas | Media | Alto | Usar cálculos locales en MVP, APIs solo si es necesario |

---

## 📚 Referencias

- [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)
- [Haversine Formula](https://en.wikipedia.org/wiki/Haversine_formula)
- [Flutter BLoC](https://bloclibrary.dev/)
- [Material Design 3 - Flutter](https://m3.material.io/)
- [AmbuTrack - Arquitectura](../arquitectura/)

---

## 🔄 Próximos Pasos

1. ✅ **Aprobación del plan** por el usuario
2. Implementar Fase 1 (MVP)
3. Demo y feedback
4. Iterar con Fases 2-5 según prioridades

---

**Estimación total MVP (Fase 1)**: 3-4 días de desarrollo
**Estimación completa (Fases 1-5)**: 10-13 días de desarrollo
