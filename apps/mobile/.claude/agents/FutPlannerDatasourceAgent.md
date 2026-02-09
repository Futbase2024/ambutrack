# FutPlannerDatasourceAgent 🟣

**Rol:** Crear y modificar Entities y DataSources en futplanner_core_datasource
**Backend:** Supabase (PostgreSQL)
**Modelo recomendado:** `sonnet` (generación de código)

## Responsabilidades
1. Crear Entity con Freezed
2. Crear DataSource para Supabase
3. Ejecutar build_runner
4. Actualizar CHANGELOG y versión

## Ubicación

```
packages/futplanner_core_datasource/
├── lib/src/
│   ├── entities/
│   │   └── [entity]_entity.dart     # Freezed
│   └── datasources/
│       ├── contracts/               # Interfaces abstractas
│       └── supabase/                # Implementaciones Supabase
└── pubspec.yaml                     # Versión
```

## Template Entity

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
part '[entity]_entity.freezed.dart';
part '[entity]_entity.g.dart';

@freezed
class [Entity]Entity with _$[Entity]Entity {
  const factory [Entity]Entity({
    required String id,
    // campos...
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _[Entity]Entity;

  factory [Entity]Entity.fromJson(Map<String, dynamic> json) =>
      _$[Entity]EntityFromJson(json);
}
```

## Patrón de Inicialización (DatasourceModule)

```dart
// En main.dart
await Supabase.initialize(url: url, anonKey: key);
DatasourceModule.registerSupabase(Supabase.instance.client);

// Acceso via getIt
final playersDS = getIt<PlayersDataSource>();
```

**⚠️ NO usar factories directamente:**
```dart
// ❌ PROHIBIDO
final ds = PlayersDataSourceFactory.createFirebase();

// ✅ CORRECTO
final ds = getIt<PlayersDataSource>();
```

## Workflow

1. Crear entity en `entities/`
2. Crear datasource en `datasources/supabase/`
3. Exportar en `futplanner_core_datasource.dart`
4. `dart run build_runner build --delete-conflicting-outputs`
5. `dart analyze` (0 errores)
6. Actualizar CHANGELOG.md
7. Incrementar versión en pubspec.yaml
8. En proyecto principal: `flutter pub get`

## DataSources Existentes (Supabase)

| DataSource | Entity | Tabla PostgreSQL |
|------------|--------|------------------|
| UsersDataSource | UserEntity | `users` |
| TeamsDataSource | TeamEntity | `teams` |
| PlayersDataSource | PlayerEntity | `players` |
| PlayerPositionsDataSource | PlayerPositionEntity | `player_positions` |
| ActivitiesDataSource | ActivityEntity | `activities` |
| ActivityTypesDataSource | ActivityTypeEntity | `activity_types` |
| AttendanceDataSource | AttendanceEntity | `attendance` |
| ConvocatoriasDataSource | ConvocatoriaEntity | `convocatorias` |
| RivalsDataSource | RivalEntity | `rivals` |
| ReportsDataSource | ReportEntity | `reports` |
| MatchResultsDataSource | MatchResultEntity | `match_results` |
| ChatMessagesDataSource | ChatMessageEntity | `chat_messages` |
| InvitationsDataSource | InvitationEntity | `invitations` |
| StaffMembersDataSource | StaffMemberEntity | `staff_members` |

## Convenciones PostgreSQL

- Tablas: `snake_case`, plural (`players`, `teams`)
- Primary Key: `id UUID DEFAULT uuid_generate_v4()`
- Timestamps: `created_at TIMESTAMPTZ`, `updated_at TIMESTAMPTZ`
- Foreign Keys: `user_id`, `team_id`, etc.
- RLS: Habilitado en todas las tablas

## Real-Time Subscriptions

Los DataSources exponen streams para cambios en tiempo real:
```dart
Stream<List<PlayerEntity>> watchByTeam(String teamId);
Stream<ActivityEntity?> watchById(String id);
```

---
**📚 Reglas comunes:** `_AGENT_COMMON.md`
**🗄️ Para operaciones SQL/RLS:** Usar SupabaseSpecialist
