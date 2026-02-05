# 🎯 PAQUETE DATASOURCE PERSONALIZADO

## Información del Paquete
- **Nombre del Paquete**: `ambutrack_core_datasource`
- **Repositorio**: https://github.com/jesusperezdeveloper/ambutrack_core_datasource.git
- **Proyecto**: Ambutrack-web
- **Generado**: 2025-09-29T11:12:59.329467

## 🔧 Configuración en pubspec.yaml

Para usar tu paquete DataSource personalizado, agrega esta dependencia:

```yaml
dependencies:
  ambutrack_core_datasource:
    git:
      url: https://github.com/jesusperezdeveloper/ambutrack_core_datasource.git
      ref: main
```

## 🚀 Uso del Paquete Personalizado

### Importación
```dart
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
```

### Configuración Básica
```dart
// En tu feature repository
class MyFeatureRepository {
  final DataSourceBase _dataSource;

  MyFeatureRepository() : _dataSource = DataSourceFactory.createFromCustom(
    customPackageName: 'ambutrack_core_datasource',
    config: DataSourceConfig(
      // Configuración específica para tu proyecto
    ),
  );
}
```

### Integración con DI (GetIt)
```dart
// En lib/core/di/locator.dart
void configureDependencies() {
  getIt.registerLazySingleton<MyCustomDataSource>(
    () => ambutrack_core_datasource.DataSourceFactory.create(
      type: DataSourceType.firebase, // o tu tipo preferido
      customConfig: ProjectSpecificConfig(),
    ),
  );
}
```

## 📦 Funcionalidades del Paquete

Tu paquete personalizado `ambutrack_core_datasource` incluye:

- ✅ **Optimizaciones específicas** para Ambutrack-web
- ✅ **Configuraciones pre-optimizadas** según los patrones de uso
- ✅ **Factory methods personalizados** para tu dominio
- ✅ **Análisis de rendimiento integrado**
- ✅ **Soporte completo para Clean Architecture**

## 🔄 Actualización del Paquete

Para actualizar a la versión más reciente:

```bash
flutter pub deps
flutter pub upgrade ambutrack_core_datasource
flutter pub get
```

## 🛠️ Desarrollo y Contribución

Si necesitas modificar el paquete:

```bash
# Clonar el repositorio
git clone https://github.com/jesusperezdeveloper/ambutrack_core_datasource.git

# Hacer tus cambios y push
git add .
git commit -m "feat: nueva funcionalidad"
git push origin main

# Actualizar en tu proyecto
flutter pub upgrade ambutrack_core_datasource
```

## 💡 Mejores Prácticas Específicas

### Para Ambutrack-web:

1. **Configuración de Cache**: El paquete está optimizado con configuraciones de cache específicas para tus patrones de uso
2. **Manejo de Errores**: Incluye manejo de errores personalizado según tu contexto de negocio
3. **Performance**: Pre-configurado con métricas de rendimiento relevantes para tu aplicación
4. **Testing**: Incluye mocks y helpers específicos para tus casos de uso

### Comandos CLI Integrados:

```bash
# Generar nueva feature con DataSource personalizado
dart lib/core/cli/feature_generator.dart

# Analizar rendimiento del DataSource
dart lib/core/cli/datasource_analyzer.dart
```

---

## 📞 Soporte

Para soporte específico del paquete `ambutrack_core_datasource`:
- **Issues**: Usa el repositorio https://github.com/jesusperezdeveloper/ambutrack_core_datasource.git/issues
- **Documentación**: Consulta el README.md del repositorio
- **Agente Claude**: Usa el DataSource Agent incluido en `lib/core/agents/`



---

# 🗄️ DataSource Guide - Ambutrack Web

Guía completa para usar el **DataSource Agent** y el repositorio personalizado `ambutrack_core_datasource` generado automáticamente para este proyecto.

## 📦 Repositorio Personalizado

Durante la creación de tu proyecto, se generó automáticamente un repositorio privado personalizado:

**📍 Repositorio:** [ambutrack_core_datasource](https:&#x2F;&#x2F;github.com&#x2F;jesusperezdeveloper&#x2F;ambutrack_core_datasource.git)

Este repositorio contiene:
- ✅ Templates optimizados para tu proyecto específico
- ✅ Configuraciones personalizadas basadas en `iautomat_core_datasource`
- ✅ Contratos y entidades base listos para usar
- ✅ Implementaciones de referencia

## 🤖 DataSource Agent

El **DataSource Agent** es un asistente inteligente integrado que optimiza automáticamente la creación de features que manejan datos.

### Características principales:

- **🧠 Análisis inteligente**: Evalúa patrones de uso y recomienda optimizaciones
- **🏭 Factory Methods**: Crea datasources optimizados según el tipo de datos
- **📊 Estimación de costos**: Calcula costos estimados de Firebase/REST
- **🔧 Generación automática**: Crea código completo para entities, repositories y BLoCs

## 🛠️ Generador CLI de Features

### Uso básico:

```bash
# Crear una nueva feature completa
dart lib/core/cli/feature_generator.dart create <nombre_feature>

# Analizar uso existente
dart lib/core/cli/feature_generator.dart analyze [nombre_feature]

# Mostrar ayuda
dart lib/core/cli/feature_generator.dart help
```

### Ejemplo práctico:

```bash
# Generar feature de usuarios
dart lib/core/cli/feature_generator.dart create users
```

**Esto genera automáticamente:**
- `lib/features/users/domain/users_entity.dart`
- `lib/features/users/data/users_datasource.dart`
- `lib/features/users/data/users_repository_impl.dart`
- `lib/features/users/presentation/users_bloc.dart`
- `lib/features/users/presentation/users_page.dart`

## 📋 Tipos de DataSource Optimizados

### 1. **Simple DataSource**
Para datos estáticos o de configuración:

```dart
final configDataSource = DataSourceAgent.createSimpleDataSource<ConfigDataSource>(
  type: DataSourceType.firebase,
  collectionName: 'configurations',
);
```

**Optimizaciones:**
- Cache de 60 minutos
- Operaciones batch optimizadas
- Ideal para: categorías, configuraciones, datos de referencia

### 2. **Complex DataSource**
Para entidades dinámicas:

```dart
final userDataSource = DataSourceAgent.createComplexDataSource<UserDataSource>(
  type: DataSourceType.firebase,
  collectionName: 'users',
);
```

**Optimizaciones:**
- Cache de 15 minutos
- Soporte para búsquedas
- Ideal para: usuarios, productos, pedidos

### 3. **Real-Time DataSource**
Para datos en tiempo real:

```dart
final chatDataSource = DataSourceAgent.createRealTimeDataSource<ChatDataSource>(
  type: DataSourceType.firebase,
  collectionName: 'messages',
);
```

**Optimizaciones:**
- Cache mínimo (5 minutos)
- Streams automáticos
- Buffer para ráfagas de datos
- Ideal para: chat, notificaciones, estados en vivo

## 🔍 Análisis Inteligente

El agente puede analizar tu uso y sugerir optimizaciones:

```dart
final analysis = DataSourceAgent.analyzeUsage(
  dailyReads: 10000,
  dailyWrites: 1000,
  avgRecordSize: 512,
  requiresRealTime: false,
);

print(analysis.toString());
```

**Ejemplo de salida:**
```
🔍 Análisis DataSource (Score: 85.0/100)

📋 Recomendaciones:
  • Cache agresivo recomendado (ratio L/E alto: 10.0)
  • Considerar cache de 60+ minutos para datos estáticos

💰 Costos estimados (USD/día):
  • firebase_daily: $0.4680

🎯 Tipo sugerido: DataSourceType.firebase
```

## 🏗️ Personalización Avanzada

### Crear DataSource personalizado:

```dart
class ProductDataSource implements BaseDataSource<ProductEntity> {
  // Usar configuraciones del agente
  static const _config = DataSourceAgent._recommendedConfigs;

  // Tu implementación personalizada
  @override
  Future<ProductEntity> create(ProductEntity entity) async {
    // Lógica personalizada con optimizaciones del agente
  }
}
```

### Usar el repositorio personalizado:

El repositorio `ambutrack_core_datasource` contiene plantillas específicas para tu proyecto. Puedes:

1. **Clonar localmente** para personalizaciones:
   ```bash
   git clone https:&#x2F;&#x2F;github.com&#x2F;jesusperezdeveloper&#x2F;ambutrack_core_datasource.git
   ```

2. **Modificar templates** según tus necesidades
3. **Crear implementaciones** específicas del dominio
4. **Compartir** entre múltiples apps del mismo proyecto

## 📈 Mejores Prácticas

### 1. **Análisis antes de implementar**
```dart
// Siempre analiza antes de crear
final analysis = DataSourceAgent.analyzeUsage(
  // tus métricas estimadas
);
```

### 2. **Usar el factory correcto**
```dart
// Para datos que cambian poco
final staticDS = DataSourceAgent.createSimpleDataSource<T>();

// Para datos dinámicos
final dynamicDS = DataSourceAgent.createComplexDataSource<T>();

// Para tiempo real
final realTimeDS = DataSourceAgent.createRealTimeDataSource<T>();
```

### 3. **Generación automática**
```bash
# Siempre usar el CLI para consistencia
dart lib/core/cli/feature_generator.dart create nueva_feature
```

### 4. **Monitorear costos**
```dart
// Revisar estimaciones regularmente
final costAnalysis = DataSourceAgent.analyzeUsage(/* tus métricas reales */);
print('Costo diario estimado: \$${costAnalysis.estimatedCosts['firebase_daily']}');
```

## 🚀 Ejemplos de Uso

### Feature de Productos:

```bash
dart lib/core/cli/feature_generator.dart create products
```

**Durante la generación te preguntará:**
- Tipo de datos (simple/complex/realtime)
- Campos de la entidad (name:String, price:double, etc.)
- Backend preferido (Firebase/REST/GraphQL)
- Uso estimado diario

**Resultado:** Feature completa optimizada con:
- Entity con serialización JSON
- DataSource contract
- Repository implementation
- BLoC con eventos y states
- UI básica funcional

### Feature de Chat en Tiempo Real:

```bash
dart lib/core/cli/feature_generator.dart create chat
# Seleccionar: c) Tiempo real
# Campos: message:String, timestamp:DateTime, userId:String
# Backend: Firebase (recomendado para tiempo real)
```

## 🔧 Troubleshooting

### Error: "No se puede crear DataSource"
- Verificar que `ambutrack_core_datasource` esté accesible
- Ejecutar `flutter pub get` para actualizar dependencias

### Error: "Entity no encontrada"
- Verificar que se generó correctamente el archivo entity
- Comprobar imports en el repository

### Performance Issues:
- Usar `analyzeUsage()` para identificar cuellos de botella
- Considerar cambiar tipo de DataSource (simple/complex/realtime)
- Ajustar configuraciones de cache

## 📚 Referencias

- [Repositorio personalizado](https:&#x2F;&#x2F;github.com&#x2F;jesusperezdeveloper&#x2F;ambutrack_core_datasource.git)
- [iautomat_core_datasource documentation](https://pub.dev/packages/iautomat_core_datasource)
- [Firebase pricing](https://firebase.google.com/pricing)

---

*Generado automáticamente para Ambutrack Web con DataSource Agent 🤖*