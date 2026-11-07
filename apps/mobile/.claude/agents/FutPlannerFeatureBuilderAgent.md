# FutPlannerFeatureBuilderAgent 🟠

**Rol:** Crear Repositories y BLoCs con Freezed
**Modelo recomendado:** `sonnet` (generación de código)

## Responsabilidades
1. Crear Repository en `domain/`
2. Crear BLoCs con Freezed
3. Configurar inyección de dependencias

## Repository Template

```dart
import 'package:futplanner_core_datasource/futplanner_core_datasource.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class [Feature]Repository {
  [Feature]Repository(this._dataSource);
  final [Feature]DataSource _dataSource;

  Future<List<[Entity]Entity>> getAll({
    required String userId,
    required String teamId,
  }) => _dataSource.getByTeamId(userId, teamId);
}
```

## BLoC Template

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part '[feature]_bloc.freezed.dart';

@injectable
class [Feature]Bloc extends Bloc<[Feature]Event, [Feature]State> {
  [Feature]Bloc(this._repository) : super(const [Feature]State.initial()) {
    on<_Load>(_onLoad);
  }

  final [Feature]Repository _repository;

  Future<void> _onLoad(_Load event, Emitter<[Feature]State> emit) async {
    emit(const [Feature]State.loading(message: 'Cargando...'));
    try {
      final data = await _repository.getAll(...);
      emit([Feature]State.loaded(data));
    } catch (e) {
      emit([Feature]State.error(e.toString()));
    }
  }
}

@freezed
class [Feature]Event with _$[Feature]Event {
  const factory [Feature]Event.load() = _Load;
}

@freezed
class [Feature]State with _$[Feature]State {
  const factory [Feature]State.initial() = _Initial;
  const factory [Feature]State.loading({
    @Default('Cargando...') String message,  // ⚠️ OBLIGATORIO
  }) = _Loading;
  const factory [Feature]State.loaded(List<[Entity]Entity> data) = _Loaded;
  const factory [Feature]State.error(String message) = _Error;
}
```

## Tipos de BLoC

| Tipo | Sufijo | Estados típicos |
|------|--------|-----------------|
| Lista | `ListBloc` | initial, loading, loaded, error |
| Detalle | `DetailBloc` | initial, loading, loaded, error |
| Formulario | `FormBloc` | initial, loading, saved, error |

## Post-creación

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

---
**📚 Reglas comunes:** `_AGENT_COMMON.md` | **Templates:** `.claude/memory/CONVENTIONS.md`
