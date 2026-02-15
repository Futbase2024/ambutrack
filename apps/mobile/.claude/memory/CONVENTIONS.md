# FutPlanner - Convenciones de Desarrollo

## 1. Arquitectura Clean

```
lib/features/[feature]/
├── domain/
│   └── [feature]_repository.dart    # @LazySingleton
└── presentation/
    ├── bloc/                        # @injectable + Freezed
    ├── pages/
    ├── layouts/                     # mobile/tablet/desktop
    └── widgets/
```

**❌ PROHIBIDO:** `data/` (excepto app_config, legal), `domain/entities/`

## 2. Repository Template

```dart
@LazySingleton()
class PlayersRepository {
  PlayersRepository(this._dataSource);
  final PlayersDataSource _dataSource;

  Future<List<PlayerEntity>> getAll({
    required String userId,
    required String teamId,
  }) => _dataSource.getByTeamId(userId, teamId);
}
```

## 3. BLoC con Freezed

```dart
// ⚠️ CRÍTICO: State.loading DEBE tener message con @Default
@freezed
class PlayersState with _$PlayersState {
  const factory PlayersState.initial() = _Initial;
  const factory PlayersState.loading({
    @Default('Cargando...') String message,  // ✅ OBLIGATORIO
  }) = _Loading;
  const factory PlayersState.loaded(List<PlayerEntity> players) = _Loaded;
  const factory PlayersState.error(String message) = _Error;
}

// Emitir siempre con mensaje específico
emit(const PlayersState.loading(message: 'Cargando jugadores...'));
```

## 4. UI Material Design 3

### Imports estándar
```dart
import 'package:flutter/cupertino.dart' show CupertinoIcons;  // Solo iconos
import 'package:flutter/material.dart';
import 'package:futplanner_web/core/ui/widgets/widgets.dart';  // FM widgets
```

### Colores (vía Theme.of(context))
```dart
final colorScheme = Theme.of(context).colorScheme;
final primary = colorScheme.primary;
final surface = colorScheme.surface;
final onSurface = colorScheme.onSurface;
final onSurfaceVariant = colorScheme.onSurfaceVariant;
```

### Widgets Material 3 Preferidos
| Widget | Uso |
|--------|-----|
| `FilledButton` | Botón primario |
| `TextButton` | Botón secundario |
| `OutlinedButton` | Botón con borde |
| `TextField` | Campo de texto |
| `Card` | Contenedor con sombra |
| `CircularProgressIndicator` | Indicador de carga |
| `Scaffold` | Layout de página |
| `AppBar` | Barra de navegación |
| `NavigationBar` | Navegación inferior (M3) |

### FM Widgets Custom (lib/core/ui/widgets/)
| Widget | Uso |
|--------|-----|
| `FMCard` | Card con estilo FutPlanner |
| `FMChip` | Chip/FilterChip |
| `FMEmptyState` | Estado vacío con icono |
| `FMErrorState` | Estado de error |
| `FMLoadingState` | Estado de carga |
| `FMFormField` | Campo de formulario |
| `FMConfirmationDialog` | Diálogo de confirmación |
| `FMExpansionTile` | Tile expandible |
| `FMPlayerCard` | Card de jugador |

### 🎨 Estándar de Diseño de Diálogos (OBLIGATORIO)

> **Docs completa**: [`docs/DIALOGS_DESIGN_STANDARD.md`](../../docs/DIALOGS_DESIGN_STANDARD.md)

**BorderRadius estandarizado para TODOS los diálogos:**

| Elemento | BorderRadius |
|----------|--------------|
| Dialog principal | `16` |
| Botones (Outlined/Elevated) | `10` |
| Elementos internos | `8` (AppSizes.radiusSmall) |

**Template mínimo:**
```dart
Dialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16), // ✅ OBLIGATORIO
  ),
  child: Container(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        // Contenido
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // ✅ OBLIGATORIO
                  ),
                ),
                child: const Text('Cancelar'),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // ✅ OBLIGATORIO
                  ),
                ),
                child: const Text('Confirmar'),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
)
```

**Diálogos de referencia:**
- `lib/core/widgets/dialogs/professional_confirm_dialog.dart`
- `lib/core/widgets/dialogs/professional_result_dialog.dart`

---

### Sistema de Colores Monocromático (OBLIGATORIO)

**Regla:** Toda la UI usa SOLO `colorScheme.primary` con diferentes opacidades para crear jerarquía visual.

### Tema Dinámico por Equipo (v0.2.3)

El color primario del equipo activo se aplica como tema global. Al cambiar el color del equipo y guardar, toda la app se actualiza automáticamente.

**Arquitectura:**
```
ScopeBloc (team.colors.primary) → app.dart → FutPlannerMaterialTheme.light(seedColor)
```

**Colores seguros para tema** (validados WCAG AA):
```dart
// lib/core/theme/color_utils.dart
ColorUtils.safeThemeColors = [
  '#2E7D32', // Verde césped (default)
  '#1565C0', // Azul
  '#C62828', // Rojo
  '#6A1B9A', // Púrpura
  '#00838F', // Cian/Teal
  '#EF6C00', // Naranja
  '#4E342E', // Marrón
  '#37474F', // Gris oscuro
  '#000000', // Negro
  '#FF1493', // Rosa/Magenta
];
```

**Colores PROHIBIDOS** (excluidos del selector):
- Amarillo, Blanco, Gris claro, Verde neón, Dorado, Plata (bajo contraste)

**Refresh obligatorio al guardar equipo:**
```dart
// team_detail_modal.dart
if (state.isSuccess) {
  context.read<ScopeBloc>().add(const ScopeEvent.refresh()); // ← CRÍTICO
  Navigator.of(context).pop(state.originalTeam);
}
```

**❌ PROHIBIDO en stats, cards, chips y filtros:**
- `Colors.orange`, `Colors.blue`, `Colors.purple`, `Colors.green`
- `colorScheme.error` (excepto para errores reales)
- `colorScheme.secondary`, `colorScheme.tertiary`

**✅ Jerarquía con opacidades:**
```dart
final primaryColor = colorScheme.primary;

// Énfasis alto (elemento principal)
color: primaryColor,                              // 100%

// Énfasis medio (elemento secundario)
color: primaryColor.withValues(alpha: 0.7),       // 70%

// Énfasis bajo (elemento terciario)
color: primaryColor.withValues(alpha: 0.5),       // 50%

// Énfasis mínimo (elemento de fondo)
color: primaryColor.withValues(alpha: 0.4),       // 40%
```

**Ejemplo Stats Cards:**
```dart
// Stats en Mi Equipo, Jugadores, Scouting
_StatCard(label: 'Principal', color: primaryColor),                    // 100%
_StatCard(label: 'Secundario', color: primaryColor.withValues(alpha: 0.6)),  // 60%
_StatCard(label: 'Terciario', color: primaryColor.withValues(alpha: 0.4)),   // 40%
```

**Ejemplo Progress Bars:**
```dart
LinearProgressIndicator(
  backgroundColor: primaryColor.withValues(alpha: 0.1),  // Fondo sutil
  valueColor: AlwaysStoppedAnimation(
    primaryColor.withValues(alpha: completionOpacity),   // Valor según nivel
  ),
)
```

**Ejemplo Chips con jerarquía:**
```dart
// Chip principal
_InfoChip(color: primaryColor),

// Chip secundario (menos énfasis)
_InfoChip(color: primaryColor, subtle: true),  // Internamente usa alpha 0.5
```

**Técnicas de jerarquía visual permitidas:**
1. Opacidad del color (primary con alpha)
2. Peso tipográfico (w400 vs w600 vs w800)
3. Tamaño de fuente
4. Espaciado/padding
5. Bordes más o menos sutiles

**⚠️ Excepciones Semánticas (NO aplica monocromático):**
1. **Posiciones de jugador** (`positions_tab.dart`): Mantener colores por línea (portero=azul, defensa=verde, mediocampo=ámbar, ataque=rojo) - convención universal en apps deportivas
2. **Indicador online** (`chat_member_avatar.dart`): `Colors.green` para estado online - convención universal de UX

## 5. LoadingOverlay (OBLIGATORIO)

```dart
state.when(
  initial: () => const SizedBox.shrink(),
  loading: (message) => LoadingOverlay(message: message),  // ✅
  loaded: (data) => ContentView(data: data),
  error: (message) => ErrorView(message: message),
)
```

## 6. AppLayoutBuilder (OBLIGATORIO)

```dart
// Page
AppLayoutBuilder(
  mobile: FeatureMobileLayout(state: state),
  tablet: FeatureTabletLayout(state: state),
  desktop: FeatureDesktopLayout(state: state),
)
```

**Breakpoints:** Mobile <600px | Tablet 600-1024px | Desktop ≥1024px

## 7. Traducciones

```dart
// ✅ SIEMPRE
Text(context.lang.playersTitle)

// ❌ NUNCA
Text('Jugadores')
```

Regenerar: `flutter gen-l10n`

## 8. Widgets

```dart
// ✅ Clases extraídas
class PlayerCard extends StatelessWidget { ... }

// ❌ PROHIBIDO métodos
Widget _buildPlayerCard() { ... }
```

## 9. Navegación GoRouter

```dart
GoRoute(
  path: '/players',
  builder: (context, state) => AppConfigWrapper(
    child: BlocProvider(
      create: (_) => getIt<PlayersListBloc>()..add(const Load()),
      child: const PlayersListPage(),
    ),
  ),
),
```

## 10. Backend: Supabase (NO Firebase)

### Inicialización (main.dart)
```dart
await Supabase.initialize(
  url: AppEnv.supabaseUrl,
  anonKey: AppEnv.supabaseAnonKey,
);
DatasourceModule.registerSupabase(Supabase.instance.client);
```

### Acceso a DataSources
```dart
// ✅ SIEMPRE via getIt (inyectado por InjectableModule)
final playersDS = getIt<PlayersDataSource>();
final teams = await getIt<TeamsDataSource>().getAll();

// ❌ PROHIBIDO - Acceso directo a Supabase
final client = Supabase.instance.client;
final data = await client.from('players').select();

// ❌ PROHIBIDO - Firebase (proyecto migrado)
import 'package:cloud_firestore/cloud_firestore.dart';
```

### Real-Time Subscriptions
```dart
// Los DataSources exponen streams para real-time
Stream<List<PlayerEntity>> watchByTeam(String teamId);
```

### Timestamps
```dart
// ✅ PostgreSQL usa DateTime ISO8601
final now = DateTime.now().toIso8601String();

// ❌ Firebase Timestamp (obsoleto)
Timestamp.fromDate(DateTime.now());
```

## Checklist Pre-Commit

- [ ] `flutter analyze` = 0 errores
- [ ] NO `data/` ni `domain/entities/`
- [ ] Repository `@LazySingleton`, BLoC `@injectable`
- [ ] `State.loading` tiene `message` con `@Default`
- [ ] `LoadingOverlay` en todas las pages
- [ ] `context.lang` para todos los textos
- [ ] Material 3 widgets (FilledButton, TextField, Card, etc.)
- [ ] Colores via `Theme.of(context).colorScheme`
- [ ] **UI Monocromática: stats/chips/filtros usan SOLO `primary` con opacidades**
- [ ] **NO `Colors.orange/blue/purple/green` en stats ni filtros**
- [ ] AppLayoutBuilder con 3 layouts separados
- [ ] Widgets extraídos como clases
- [ ] **DataSources via `getIt<>()`, NO acceso directo a Supabase**
- [ ] **NO imports de Firebase/Firestore**

## 11. Estructura de Documentación

```
doc/
├── design/                              # Prompts y diseños para Stitch
│   ├── core/
│   │   ├── core_prompt.md               # Prompt base/compartido
│   │   └── STITCH_PROMPT_TEMPLATE.md    # Template para nuevos prompts
│   └── {feature_name}/                  # Carpeta por feature
│       ├── {feature}_stitch_prompt.md   # Prompt para Stitch
│       └── {feature}.html               # HTML generado por Stitch
│
└── plans/                               # Planes de implementación
    └── {feature}_plan.md
```

**Reglas:**
- ✅ `doc/design/` (singular) - NO `designs`
- ✅ Una subcarpeta por feature dentro de `design/`
- ✅ Planes SIEMPRE en `doc/plans/`, NUNCA en `.claude/`
- ✅ **Prompts de Stitch SIEMPRE en `doc/design/{feature}/`, NUNCA en el plan**

## 12. Workflow /plan → Stitch → Código

Al generar un plan con `/plan`:

1. **Plan** → `doc/plans/{feature}_plan.md`
2. **Prompt Stitch** → `doc/design/{feature}/{feature}_stitch_prompt.md` (archivo separado)
3. **HTML generado** → `doc/design/{feature}/{feature}.html`
4. **Código Flutter** → Ejecutar `/design-to-code {feature}`

**⚠️ NUNCA incluir el prompt de Stitch dentro del plan.** El plan solo debe referenciar el archivo del prompt.

## 13. Arquitectura RFAF: Edge Functions vs DataSource (CRÍTICO)

**⚠️ REGLA FUNDAMENTAL:**
- **Edge Functions** = SOLO para **onboarding** y **sincronización masiva/programada**
- **RfafDataSource** = SIEMPRE para **carga bajo demanda** desde la UI

### ❌ PROHIBIDO - NO hacer esto NUNCA

```dart
// ❌ INCORRECTO - Llamar Edge Functions para mostrar datos en UI
await supabase.functions.invoke('get-standings', body: {...});
await supabase.functions.invoke('scrape-rfaf', body: {...});

// ❌ INCORRECTO - Crear nuevas Edge Functions para obtener datos RFAF
// Las Edge Functions NO son para carga de datos en tiempo real
```

### ✅ CORRECTO - Usar RfafDataSource (DatasourceModule.instance.rfaf)

```dart
// El DataSource maneja AUTOMÁTICAMENTE:
// 1. Cache hit → retorna datos de tablas rfaf_*
// 2. Cache miss/expired → hace scraping vía FireCrawl → actualiza cache → retorna

// Clasificación
final standings = await _rfafDataSource.getStandings(groupCode);

// Goleadores
final scorers = await _rfafDataSource.getScorersTable(
  competitionCode: competitionCode,
  groupCode: groupCode,
);

// Estadísticas de jugadores
final stats = await _rfafDataSource.getPlayerSeasonStats(
  teamCode: teamCode,
  season: '2025-26',
);

// Forzar refresh (para botón "Sincronizar")
await _rfafDataSource.forceSync(teamCode, RfafSyncScope.standings);
```

### Edge Functions - SOLO para Cron Jobs

**⚠️ IMPORTANTE:** Las Edge Functions NO se usan para operaciones del cliente.
Toda la lógica del cliente se ejecuta directamente via DataSources.

| Function | Uso EXCLUSIVO | Contexto |
|----------|---------------|----------|
| `sync-rfaf-batch` | Cron jobs | Sincronización programada nocturna |
| `cleanup-expired-cache` | Cron jobs | Limpieza de cache expirado |

```dart
// ❌ INCORRECTO - NUNCA llamar Edge Functions desde el cliente
await supabase.functions.invoke('copy-rfaf-to-team', ...);

// ✅ CORRECTO - Usar DataSources directamente
await _playersDataSource.create(player);
await _teamsDataSource.create(team);
await _extDataSource.createTeamLink(link);
```

**Nota:** La Edge Function `copy-rfaf-to-team` fue eliminada. Toda la lógica
de copia de datos RFAF → FutPlanner ahora está en `RfafTeamSetupRepository.createTeamWithRfafData()`.

### Arquitectura de Repositories RFAF

Los repositories de features RFAF (Standings, Scorers, PlayerStats) deben:

1. **Inyectar SupabaseClient** para queries simples a tabla `teams`
2. **Usar RfafDataSource** vía `DatasourceModule.instance.rfaf` para datos RFAF
3. **NUNCA llamar Edge Functions** para obtener datos

```dart
@LazySingleton()
class StandingsRepository {
  StandingsRepository(this._supabase);  // Para leer de tabla teams

  final SupabaseClient _supabase;

  // ✅ Acceso a RfafDataSource via singleton
  RfafDataSource get _rfafDataSource => DatasourceModule.instance.rfaf;

  Future<List<StandingModel>> getStandings(String groupCode) async {
    // RfafDataSource maneja cache + scraping automáticamente
    final standings = await _rfafDataSource.getStandings(groupCode);
    return standings.map(StandingModel.fromRfafEntity).toList();
  }

  // Para obtener códigos del equipo, leer de tabla teams (ya copiados por Edge Function en onboarding)
  Future<CompetitionInfo> getCompetitionInfoFromTeam(String teamId) async {
    final response = await _supabase
        .from('teams')
        .select('rfaf_team_code, group_code, competition_code')
        .eq('id', teamId)
        .maybeSingle();
    // ...
  }
}
```

### Flujo de Datos Completo

```
┌─────────────────────────────────────────────────────────────────────┐
│                         ONBOARDING                                   │
│  RfafTeamSetupBloc → RfafTeamSetupRepository.createTeamWithRfafData │
│  (TODO via DataSources, NO Edge Functions)                           │
│  - Crear equipo en `teams`                                           │
│  - Crear vínculo en `ext_team_links`                                 │
│  - Copiar ext_squad_members → players                                │
│  - Copiar ext_matches → activities                                   │
└─────────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────────┐
│                      USO NORMAL (UI)                                 │
│  StandingsPage/ScorersPage/PlayerStatsPage                          │
│  ↓                                                                   │
│  Repository.getCompetitionInfoFromTeam(teamId)                       │
│  → Lee de ext_team_links + ext_teams                                 │
│  ↓                                                                   │
│  ExternalDataSource.getStandings(groupCode, provider)                │
│  → Cache hit: lee de ext_standings                                   │
│  → Cache miss: Fallback a LaPreferente scraping                      │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                    CRON JOBS (Edge Functions)                        │
│  - sync-rfaf-batch: Actualiza cache de standings/scorers             │
│  - cleanup-expired-cache: Limpia registros expirados                 │
│  (Ejecutados automáticamente, NO desde el cliente)                   │
└─────────────────────────────────────────────────────────────────────┘
```

### Reglas para Columnas de Tablas

| Tabla | Columnas | Nota |
|-------|----------|------|
| `ext_team_links` | `team_id`, `provider`, `external_code`, `group_code` | Vínculo equipo FutPlanner ↔ externo |
| `ext_teams` | `external_code`, `provider`, `group_code`, `competition_code` | Cache de equipos externos |
| `ext_standings` | `provider`, `group_code`, `team_external_code`, ... | Cache de clasificaciones |
| `ext_scorers` | `provider`, `group_code`, `player_name`, ... | Cache de goleadores |
| `players` | `source_type` = 'rfaf_import' | Jugadores importados de RFAF |

```dart
// ✅ CORRECTO - Usar ext_team_links para obtener códigos
final link = await _extDataSource.getPrimaryTeamLink(teamId);
final groupCode = link?.groupCode;

// ❌ INCORRECTO - NO existen estas columnas en teams
.select('rfaf_group_code, rfaf_competition_code')
```

## Comandos Útiles

```bash
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
```
