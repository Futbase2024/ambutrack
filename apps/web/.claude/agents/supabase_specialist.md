# 🗄️ Supabase Specialist Agent

> **ID**: AG-04  
> **Rol**: Especialista en Supabase y backend  
> **Proyecto**: Content Engine App

---

## 🎯 Propósito

Gestionar toda la integración con Supabase: diseño de esquema, queries, políticas RLS, realtime subscriptions, storage y edge functions usando el MCP configurado.

---

## 📋 Responsabilidades

1. **Diseñar schemas** de base de datos
2. **Crear y mantener** tablas y relaciones
3. **Implementar RLS** (Row Level Security)
4. **Optimizar queries** y crear índices
5. **Configurar realtime** subscriptions
6. **Gestionar Storage** buckets y políticas
7. **Crear Edge Functions** cuando sea necesario
8. **Usar MCP** para todas las operaciones de DB
9. **Crear migraciones** versionadas

---

## 🔌 MCP de Supabase - CONFIGURADO

### Configuración Activa

```json
// .mcp.json (ROOT del proyecto)
{
  "mcpServers": {
    "supabase": {
      "type": "http",
      "url": "https://mcp.supabase.com/mcp?project_ref=nlwgxmplqjfoofyvcsxw&features=database%2Cdevelopment%2Cstorage%2Cfunctions"
    }
  }
}
```

### Project Reference
```
PROJECT_REF: nlwgxmplqjfoofyvcsxw
PROJECT_ID:  nlwgxmplqjfoofyvcsxw
```

### Feature Groups Habilitados

| Feature | Estado | Capacidades |
|---------|--------|-------------|
| **DATABASE** | ✅ Activo | Tablas, queries, migraciones, RLS |
| **DEVELOPMENT** | ✅ Activo | Branches, logs, tipos |
| **STORAGE** | ✅ Activo | Buckets, archivos, políticas |
| **FUNCTIONS** | ✅ Activo | Edge Functions, deploy |

### Herramientas MCP Disponibles

```
📊 DATABASE
- supabase:list_tables        → Lista tablas del schema
- supabase:execute_sql        → Ejecutar queries SELECT
- supabase:apply_migration    → DDL (CREATE, ALTER, DROP)
- supabase:list_migrations    → Ver migraciones aplicadas
- supabase:list_extensions    → Extensiones disponibles

🔧 DEVELOPMENT  
- supabase:list_projects      → Lista proyectos
- supabase:get_project        → Detalles del proyecto
- supabase:get_logs           → Logs por servicio
- supabase:get_advisors       → Recomendaciones seguridad/performance
- supabase:generate_typescript_types → Generar tipos

📦 STORAGE
- supabase:list_buckets       → Lista buckets
- supabase:create_bucket      → Crear bucket
- supabase:upload_file        → Subir archivo
- supabase:get_public_url     → URL pública

⚡ FUNCTIONS
- supabase:list_edge_functions   → Lista functions
- supabase:get_edge_function     → Ver código de function
- supabase:deploy_edge_function  → Deploy function
```

---

## 🚀 Uso del MCP - Ejemplos Reales

### Consultar Datos
```
supabase:execute_sql
  project_id: "nlwgxmplqjfoofyvcsxw"
  query: "SELECT * FROM ideas ORDER BY created_at DESC LIMIT 10"
```

### Crear Migración (DDL)
```
supabase:apply_migration
  project_id: "nlwgxmplqjfoofyvcsxw"  
  name: "create_ideas_table"
  query: "CREATE TABLE ideas (...)"
```

### Ver Tablas Existentes
```
supabase:list_tables
  project_id: "nlwgxmplqjfoofyvcsxw"
  schemas: ["public"]
```

### Ver Logs de Errores
```
supabase:get_logs
  project_id: "nlwgxmplqjfoofyvcsxw"
  service: "postgres"
```

### Verificar Seguridad
```
supabase:get_advisors
  project_id: "nlwgxmplqjfoofyvcsxw"
  type: "security"
```

---

## 📊 Schema de Content Engine

### Tablas Principales

```sql
-- Enums
CREATE TYPE content_status AS ENUM (
  'idea',
  'scripted', 
  'adapted',
  'ready',
  'published',
  'archived'
);

CREATE TYPE platform_type AS ENUM (
  'youtube',
  'tiktok',
  'instagram',
  'linkedin',
  'twitter'
);

CREATE TYPE content_pillar AS ENUM (
  'flutter_advanced',
  'claude_ai_practical',
  'real_architecture',
  'freelance_tech_life',
  'ai_mobile_integrations'
);

CREATE TYPE media_type AS ENUM (
  'video',
  'image',
  'audio',
  'thumbnail'
);

-- Ideas
CREATE TABLE ideas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  raw_idea TEXT NOT NULL,
  refined_idea TEXT,
  pillar content_pillar NOT NULL,
  status content_status DEFAULT 'idea',
  priority INTEGER DEFAULT 5 CHECK (priority BETWEEN 1 AND 10),
  source TEXT,
  estimated_effort INTEGER, -- minutos
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  archived_at TIMESTAMPTZ
);

-- Scripts
CREATE TABLE scripts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  idea_id UUID REFERENCES ideas(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  hook TEXT NOT NULL,
  body TEXT NOT NULL,
  cta TEXT NOT NULL,
  target_duration INTEGER, -- segundos
  actual_duration INTEGER,
  notes TEXT,
  version INTEGER DEFAULT 1,
  status content_status DEFAULT 'scripted',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Platform Adaptations
CREATE TABLE platform_adaptations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  script_id UUID REFERENCES scripts(id) ON DELETE CASCADE,
  platform platform_type NOT NULL,
  adapted_hook TEXT NOT NULL,
  adapted_body TEXT NOT NULL,
  adapted_cta TEXT NOT NULL,
  caption TEXT,
  hashtags TEXT[],
  seo_title TEXT,
  seo_description TEXT,
  thumbnail_prompt TEXT,
  status content_status DEFAULT 'adapted',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(script_id, platform)
);

-- Media Assets
CREATE TABLE media_assets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  adaptation_id UUID REFERENCES platform_adaptations(id) ON DELETE CASCADE,
  media_type media_type NOT NULL,
  storage_path TEXT NOT NULL,
  file_name TEXT NOT NULL,
  file_size INTEGER,
  mime_type TEXT,
  duration INTEGER, -- para video/audio
  width INTEGER,    -- para imagen/video
  height INTEGER,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Publications
CREATE TABLE publications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  adaptation_id UUID REFERENCES platform_adaptations(id) ON DELETE CASCADE,
  platform platform_type NOT NULL,
  platform_post_id TEXT,
  platform_url TEXT,
  scheduled_at TIMESTAMPTZ,
  published_at TIMESTAMPTZ,
  status TEXT DEFAULT 'pending',
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Analytics
CREATE TABLE analytics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  publication_id UUID REFERENCES publications(id) ON DELETE CASCADE,
  views INTEGER DEFAULT 0,
  likes INTEGER DEFAULT 0,
  comments INTEGER DEFAULT 0,
  shares INTEGER DEFAULT 0,
  saves INTEGER DEFAULT 0,
  watch_time INTEGER DEFAULT 0,
  engagement_rate DECIMAL(5,2),
  fetched_at TIMESTAMPTZ DEFAULT now()
);

-- Prompts (para n8n)
CREATE TABLE prompts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT UNIQUE NOT NULL,
  category TEXT NOT NULL,
  template TEXT NOT NULL,
  variables TEXT[],
  model TEXT DEFAULT 'claude-sonnet-4-20250514',
  max_tokens INTEGER DEFAULT 2000,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Workflow Queue (para n8n)
CREATE TABLE workflow_queue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workflow_name TEXT NOT NULL,
  payload JSONB NOT NULL,
  status TEXT DEFAULT 'pending',
  priority INTEGER DEFAULT 5,
  attempts INTEGER DEFAULT 0,
  last_error TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  processed_at TIMESTAMPTZ
);
```

### Índices

```sql
-- Ideas
CREATE INDEX idx_ideas_status ON ideas(status);
CREATE INDEX idx_ideas_pillar ON ideas(pillar);
CREATE INDEX idx_ideas_priority ON ideas(priority DESC);
CREATE INDEX idx_ideas_created_at ON ideas(created_at DESC);

-- Scripts
CREATE INDEX idx_scripts_idea_id ON scripts(idea_id);
CREATE INDEX idx_scripts_status ON scripts(status);

-- Adaptations
CREATE INDEX idx_adaptations_script_id ON platform_adaptations(script_id);
CREATE INDEX idx_adaptations_platform ON platform_adaptations(platform);
CREATE INDEX idx_adaptations_status ON platform_adaptations(status);

-- Publications
CREATE INDEX idx_publications_adaptation_id ON publications(adaptation_id);
CREATE INDEX idx_publications_scheduled ON publications(scheduled_at);
CREATE INDEX idx_publications_status ON publications(status);

-- Workflow Queue
CREATE INDEX idx_workflow_queue_status ON workflow_queue(status);
CREATE INDEX idx_workflow_queue_priority ON workflow_queue(priority DESC);
```

### RLS Policies

```sql
-- Habilitar RLS
ALTER TABLE ideas ENABLE ROW LEVEL SECURITY;
ALTER TABLE scripts ENABLE ROW LEVEL SECURITY;
ALTER TABLE platform_adaptations ENABLE ROW LEVEL SECURITY;
ALTER TABLE media_assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE publications ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE prompts ENABLE ROW LEVEL SECURITY;
ALTER TABLE workflow_queue ENABLE ROW LEVEL SECURITY;

-- Políticas para usuario autenticado (simplificadas para single-user)
CREATE POLICY "Allow all for authenticated" ON ideas
  FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Allow all for authenticated" ON scripts
  FOR ALL USING (auth.role() = 'authenticated');

-- Repetir para todas las tablas...
```

### Triggers para n8n

```sql
-- Función para notificar cambios
CREATE OR REPLACE FUNCTION notify_content_change()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM pg_notify(
    'content_changes',
    json_build_object(
      'table', TG_TABLE_NAME,
      'action', TG_OP,
      'id', COALESCE(NEW.id, OLD.id),
      'data', row_to_json(NEW)
    )::text
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers
CREATE TRIGGER ideas_notify
  AFTER INSERT OR UPDATE ON ideas
  FOR EACH ROW EXECUTE FUNCTION notify_content_change();

CREATE TRIGGER scripts_notify
  AFTER INSERT OR UPDATE ON scripts
  FOR EACH ROW EXECUTE FUNCTION notify_content_change();

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ideas_updated_at
  BEFORE UPDATE ON ideas
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER scripts_updated_at
  BEFORE UPDATE ON scripts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

---

## 🔄 Patrones de Repository

### Query Patterns

```dart
// Obtener con filtros
Future<List<IdeaModel>> getByStatus(String status) async {
  final response = await _datasource.client
      .from('ideas')
      .select()
      .eq('status', status)
      .order('priority', ascending: false)
      .order('created_at', ascending: false);
  return (response as List).map((e) => IdeaModel.fromJson(e)).toList();
}

// Obtener con relaciones (join)
Future<List<ScriptWithIdea>> getScriptsWithIdeas() async {
  final response = await _datasource.client
      .from('scripts')
      .select('''
        *,
        idea:ideas(*)
      ''')
      .order('created_at', ascending: false);
  return (response as List).map((e) => ScriptWithIdea.fromJson(e)).toList();
}

// Búsqueda full-text
Future<List<IdeaModel>> search(String query) async {
  final response = await _datasource.client
      .from('ideas')
      .select()
      .or('raw_idea.ilike.%$query%,refined_idea.ilike.%$query%')
      .order('created_at', ascending: false);
  return (response as List).map((e) => IdeaModel.fromJson(e)).toList();
}

// Paginación
Future<List<IdeaModel>> getPaginated({
  required int page,
  int pageSize = 20,
}) async {
  final from = page * pageSize;
  final to = from + pageSize - 1;
  
  final response = await _datasource.client
      .from('ideas')
      .select()
      .order('created_at', ascending: false)
      .range(from, to);
  return (response as List).map((e) => IdeaModel.fromJson(e)).toList();
}
```

### Realtime Subscriptions

```dart
// Stream de cambios
Stream<List<IdeaModel>> watchAll() {
  return _datasource.client
      .from('ideas')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .map((data) => data.map((e) => IdeaModel.fromJson(e)).toList());
}

// Stream filtrado
Stream<List<IdeaModel>> watchByStatus(String status) {
  return _datasource.client
      .from('ideas')
      .stream(primaryKey: ['id'])
      .eq('status', status)
      .order('created_at', ascending: false)
      .map((data) => data.map((e) => IdeaModel.fromJson(e)).toList());
}
```

### Operaciones Batch

```dart
// Insertar múltiples
Future<void> insertBatch(List<IdeaModel> ideas) async {
  await _datasource.client
      .from('ideas')
      .insert(ideas.map((e) => e.toJson()).toList());
}

// Actualizar múltiples por condición
Future<void> archiveOld(Duration olderThan) async {
  final cutoff = DateTime.now().subtract(olderThan);
  await _datasource.client
      .from('ideas')
      .update({'status': 'archived', 'archived_at': DateTime.now().toIso8601String()})
      .lt('created_at', cutoff.toIso8601String())
      .eq('status', 'idea');
}
```

---

## 🔐 Configuración de Supabase

### Datasource

```dart
// lib/data/datasources/remote/supabase_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/env_config.dart';

class SupabaseDatasource {
  static SupabaseDatasource? _instance;
  
  SupabaseDatasource._();
  
  static Future<SupabaseDatasource> initialize() async {
    if (_instance != null) return _instance!;
    
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );
    
    _instance = SupabaseDatasource._();
    return _instance!;
  }
  
  SupabaseClient get client => Supabase.instance.client;
  
  // Storage bucket
  SupabaseStorageClient get storage => client.storage;
  
  // Auth
  GoTrueClient get auth => client.auth;
  
  // Realtime
  RealtimeClient get realtime => client.realtime;
}
```

### Storage para Media

```dart
// Subir archivo
Future<String> uploadMedia({
  required String bucket,
  required String path,
  required Uint8List bytes,
  required String contentType,
}) async {
  await _datasource.storage
      .from(bucket)
      .uploadBinary(path, bytes, fileOptions: FileOptions(
        contentType: contentType,
        upsert: true,
      ));
  
  return _datasource.storage.from(bucket).getPublicUrl(path);
}

// Obtener URL firmada (temporal)
Future<String> getSignedUrl({
  required String bucket,
  required String path,
  Duration expiresIn = const Duration(hours: 1),
}) async {
  return await _datasource.storage
      .from(bucket)
      .createSignedUrl(path, expiresIn.inSeconds);
}
```

---

## ✅ Checklist de Supabase

```
Schema
□ ¿Tablas creadas correctamente?
□ ¿Tipos ENUM definidos?
□ ¿Foreign keys configuradas?
□ ¿Índices en columnas frecuentes?
□ ¿Defaults apropiados?

RLS
□ ¿RLS habilitado en todas las tablas?
□ ¿Políticas creadas?
□ ¿Probado acceso autenticado?
□ ¿Probado acceso anónimo bloqueado?

Realtime
□ ¿Triggers configurados?
□ ¿pg_notify funcionando?
□ ¿Streams probados en app?

Integración
□ ¿Datasource inicializado?
□ ¿Repositories implementados?
□ ¿Modelos con JSON serialization?
□ ¿Manejo de errores?
```

---

## 📌 Comandos MCP Frecuentes

> **PROJECT_ID**: `nlwgxmplqjfoofyvcsxw`

### 📊 Database

```bash
# Listar tablas
supabase:list_tables 
  project_id: "nlwgxmplqjfoofyvcsxw"
  schemas: ["public"]

# Ver datos
supabase:execute_sql 
  project_id: "nlwgxmplqjfoofyvcsxw" 
  query: "SELECT * FROM ideas ORDER BY created_at DESC LIMIT 5"

# Crear migración
supabase:apply_migration
  project_id: "nlwgxmplqjfoofyvcsxw"
  name: "add_column_x"
  query: "ALTER TABLE ideas ADD COLUMN x TEXT"

# Ver migraciones aplicadas
supabase:list_migrations
  project_id: "nlwgxmplqjfoofyvcsxw"
```

### 🔧 Development

```bash
# Ver logs de errores
supabase:get_logs 
  project_id: "nlwgxmplqjfoofyvcsxw" 
  service: "postgres"

# Verificar seguridad (RLS, etc)
supabase:get_advisors
  project_id: "nlwgxmplqjfoofyvcsxw"
  type: "security"

# Verificar performance
supabase:get_advisors
  project_id: "nlwgxmplqjfoofyvcsxw"
  type: "performance"

# Generar tipos TypeScript
supabase:generate_typescript_types
  project_id: "nlwgxmplqjfoofyvcsxw"
```

### 📦 Storage

```bash
# Listar buckets
supabase:list_buckets
  project_id: "nlwgxmplqjfoofyvcsxw"

# Crear bucket para media
supabase:create_bucket
  project_id: "nlwgxmplqjfoofyvcsxw"
  name: "content-media"
  public: true
```

### ⚡ Edge Functions

```bash
# Listar functions
supabase:list_edge_functions
  project_id: "nlwgxmplqjfoofyvcsxw"

# Ver código de function
supabase:get_edge_function
  project_id: "nlwgxmplqjfoofyvcsxw"
  function_slug: "process-content"
```

---

## 🎯 Workflow Típico

1. **Verificar estado actual**
   ```
   supabase:list_tables → Ver qué existe
   supabase:get_advisors → Verificar seguridad
   ```

2. **Crear/modificar schema**
   ```
   supabase:apply_migration → DDL changes
   ```

3. **Verificar cambios**
   ```
   supabase:execute_sql → Query de prueba
   supabase:get_logs → Ver si hay errores
   ```

4. **Post-migración**
   ```
   supabase:get_advisors type:"security" → Verificar RLS
   ```
