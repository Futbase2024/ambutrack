# Changelog

Todos los cambios notables de este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto se adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-01-09

### ✨ Agregado
- Estructura base del paquete ambutrack_core_datasource
- Clases base: `BaseEntity`, `BaseDatasource`, `BaseModel`
- Módulo completo de usuarios con `UserEntity` y `UsersDataSource`
- Implementación Firebase para datasource de usuarios
- Implementación REST API para datasource de usuarios
- Sistema de cache integrado con `CacheMixin`
- Manejo de errores robusto con `ErrorHandlerMixin`
- Factory pattern para creación de datasources
- Soporte para operaciones CRUD básicas
- Operaciones específicas de usuarios (búsqueda, roles, perfiles)
- Soporte para streams y tiempo real
- Operaciones batch para eficiencia
- Sistema de excepciones estandarizadas
- Tipos de datos y definiciones reutilizables
- Documentación completa con ejemplos
- Configuración desde variables de entorno
- Soporte para múltiples datasources simultáneos

### 🏗️ Arquitectura
- Separación clara entre contratos públicos e implementaciones privadas
- Sistema de barrels para control de exportaciones
- Clean Architecture con inversión de dependencias
- Factory pattern para abstracción de creación
- Mixins para funcionalidades transversales

### 🔧 Características técnicas
- Cache automático con TTL configurable
- Reintentos automáticos con exponential backoff
- Manejo de errores específico por plataforma (Firebase, REST)
- Operaciones batch eficientes
- Streams para actualizaciones en tiempo real
- Validación de datos de entrada y salida
- Soporte para paginación y filtros
- Exportación e importación de datos

### 📱 Compatibilidad
- Flutter 3.10.0+
- Dart 3.0.0+
- Firebase (Cloud Firestore)
- REST APIs con Dio
- Soporte para plataformas móviles y web

### 🧪 Testing
- Estructura preparada para tests unitarios
- Interfaces mockeables
- Ejemplos de testing incluidos

### 📚 Documentación
- README completo con ejemplos
- Documentación inline con DartDoc
- Ejemplos de uso para todos los casos principales
- Guías de extensibilidad y personalización

---

## Formato de versiones

- **Major**: Cambios incompatibles en la API
- **Minor**: Nuevas funcionalidades compatibles hacia atrás
- **Patch**: Correcciones de bugs compatibles hacia atrás

## Tipos de cambios

- **✨ Agregado**: para nuevas funcionalidades
- **🔄 Cambiado**: para cambios en funcionalidades existentes
- **❌ Deprecado**: para funcionalidades que serán removidas pronto
- **🗑️ Removido**: para funcionalidades removidas
- **🐛 Corregido**: para correcciones de bugs
- **🔒 Seguridad**: en caso de vulnerabilidades
