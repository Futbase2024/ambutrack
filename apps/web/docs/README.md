# Documentación AmbuTrack Web

Esta carpeta contiene toda la documentación técnica y de desarrollo del proyecto AmbuTrack Web.

## 📁 Estructura de Documentación

### 🚗 [vehiculos/](vehiculos/)
Documentación relacionada con el módulo de vehículos y flota.

- **[README.md](vehiculos/README.md)** - Guía principal del módulo de vehículos
- **[itv_revisiones.md](vehiculos/itv_revisiones.md)** - Documentación de ITV y revisiones técnicas

### 📊 [tablas/](tablas/)
Documentación de tablas maestras del sistema.

- **[crud_plan.md](tablas/crud_plan.md)** - Plan de implementación de CRUDs para tablas maestras

### 🏗️ [arquitectura/](arquitectura/)
Documentación técnica y arquitectural del proyecto.

- **[codebase_analysis.md](arquitectura/codebase_analysis.md)** - Análisis del codebase
- **[datasource_guide.md](arquitectura/datasource_guide.md)** - Guía de uso de DataSources
- **[cache_invalidation.md](arquitectura/cache_invalidation.md)** - Guía de invalidación de cache

### 🗄️ [supabase/](supabase/)
Documentación de integración con Supabase.

- **[README.md](supabase/README.md)** - Guía completa de Supabase (Auth, PostgreSQL, Realtime)
- **[migration.md](supabase/migration.md)** - Proceso de migración Firebase → Supabase

### 🧪 [testing/](testing/)
Documentación de testing y pruebas.

- **[auth.md](testing/auth.md)** - Documentación de testing de autenticación

---

## 🔍 Índice Rápido

### Por Módulo
- **Vehículos**: [vehiculos/README.md](vehiculos/README.md)
- **Tablas Maestras**: [tablas/crud_plan.md](tablas/crud_plan.md)

### Por Tecnología
- **Supabase**: [supabase/README.md](supabase/README.md)
- **DataSources**: [arquitectura/datasource_guide.md](arquitectura/datasource_guide.md)
- **Cache**: [arquitectura/cache_invalidation.md](arquitectura/cache_invalidation.md)

### Por Tipo de Tarea
- **Testing**: [testing/auth.md](testing/auth.md)
- **Migración**: [supabase/migration.md](supabase/migration.md)
- **Análisis**: [arquitectura/codebase_analysis.md](arquitectura/codebase_analysis.md)

---

## 📝 Convenciones de Documentación

### Nombres de Archivos
- Minúsculas con guiones bajos: `crud_plan.md`
- README.md para documentación principal de cada carpeta
- Nombres descriptivos y concisos

### Estructura de Carpetas
```
docs/
├── README.md                    # Este archivo
├── [modulo]/                    # Carpeta por módulo
│   ├── README.md               # Documentación principal del módulo
│   └── [sub_documentos].md    # Documentos específicos
└── ...
```

### Formato de Documentos
- Título principal con `#`
- Secciones con `##`, `###`, etc.
- Emojis para categorías (opcional pero recomendado)
- Enlaces relativos entre documentos
- Código con bloques de sintaxis Dart/Flutter

---

**Última actualización**: 2025-12-17
