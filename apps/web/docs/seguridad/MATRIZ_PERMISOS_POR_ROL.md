# 🔐 MATRIZ DE PERMISOS POR ROL - AmbuTrack Web

> **Documento**: Control de Acceso Basado en Roles (RBAC)
> **Fecha**: 2026-02-12
> **Versión**: 1.0

---

## 📋 ÍNDICE

1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Roles del Sistema](#roles-del-sistema)
3. [Matriz de Permisos Completa](#matriz-de-permisos-completa)
4. [Análisis por Rol](#análisis-por-rol)
5. [Estado Actual de Implementación](#estado-actual-de-implementación)
6. [Plan de Implementación](#plan-de-implementación)
7. [Recomendaciones de Seguridad](#recomendaciones-de-seguridad)

---

## 1. RESUMEN EJECUTIVO

### Situación Actual

AmbuTrack cuenta con un **sistema de permisos bien diseñado** pero **parcialmente implementado**:

- ✅ **10 roles definidos** con jerarquías claras
- ✅ **45 módulos organizados** por categorías funcionales
- ✅ **Matriz de permisos completa** en código (`RolePermissions`)
- ✅ **Servicios de validación** (`RoleService`)
- ⚠️ **Validación de permisos NO aplicada en rutas** (AuthGuard solo verifica autenticación)
- ❌ **Sin RLS en Supabase** (seguridad a nivel de base de datos)
- ❌ **Sin auditoría de accesos**

### Prioridad Crítica

**URGENTE**: Implementar validación de permisos en `AuthGuard` para prevenir acceso no autorizado a módulos sensibles como:
- 🚨 **Usuarios y Roles**
- 🚨 **Gestión de Personal**
- 🚨 **Permisos y Auditorías**
- 🚨 **Configuración General**

---

## 2. ROLES DEL SISTEMA

### Clasificación de Roles

| Categoría | Roles | Nivel de Acceso |
|-----------|-------|-----------------|
| **Administración** | Admin | Total (todos los módulos) |
| **Gestión** | Jefe de Personal, Jefe de Tráfico, Administrativo | Alto (módulos de gestión) |
| **Supervisión** | Coordinador | Medio (operaciones y servicios) |
| **Técnico** | Gestor, Técnico | Medio (vehículos y mantenimiento) |
| **Operativo** | Conductor, Sanitario | Bajo (solo datos propios) |
| **Solo Lectura** | Operador | Muy Bajo (consultas) |

### Descripción Detallada de Roles

#### 1. **Admin** 👑
- **Valor BD**: `admin`
- **Descripción**: Acceso total al sistema
- **Privilegios**: Crear usuarios, asignar roles, configurar sistema, acceder a todos los módulos
- **Restricciones**: Ninguna

#### 2. **Jefe de Personal** 👔
- **Valor BD**: `jefe_personal`
- **Descripción**: Gestión completa de recursos humanos
- **Privilegios**:
  - Gestionar personal (altas, bajas, datos)
  - Asignar turnos y dotaciones
  - Gestionar formación y documentación
  - Evaluar personal
  - Gestionar ausencias y vacaciones
- **Restricciones**: Sin acceso a vehículos, tráfico ni administración del sistema

#### 3. **Jefe de Tráfico** 🚑
- **Valor BD**: `jefe_trafico`
- **Descripción**: Gestión de operaciones y flota
- **Privilegios**:
  - Planificar y asignar servicios
  - Gestionar flota de vehículos
  - Supervisar operaciones en tiempo real
  - Acceder a geoLocalización
  - Gestionar incidencias
  - Generar reportes de servicios y estadísticas de flota
- **Restricciones**: Sin acceso a gestión de personal ni administración del sistema

#### 4. **Coordinador** 📊
- **Valor BD**: `coordinador`
- **Descripción**: Supervisión operativa
- **Privilegios**:
  - Ver dashboard operativo
  - Acceder a servicios urgentes
  - Consultar histórico de servicios
  - Ver cuadrantes y dotaciones
  - Gestionar incidencias operativas
  - Comunicaciones internas
- **Restricciones**: Sin acceso a gestión de personal, vehículos, ni configuración

#### 5. **Administrativo** 📝
- **Valor BD**: `administrativo`
- **Descripción**: Gestión documental y administrativa
- **Privilegios**:
  - Gestionar contratos
  - Administrar documentación de personal
  - Administrar documentación de vehículos
  - Acceder a calendario
  - Consultar personal y vehículos (solo lectura)
- **Restricciones**: Sin acceso a operaciones, servicios ni configuración del sistema

#### 6. **Conductor** 🚗
- **Valor BD**: `conductor`
- **Descripción**: Personal operativo de conducción
- **Privilegios**:
  - Ver dashboard personal
  - Consultar mis turnos
  - Consultar mis servicios
  - Gestionar mis ausencias
- **Restricciones**: Solo acceso a datos propios, sin acceso a datos de otros usuarios

#### 7. **Sanitario** 🩺
- **Valor BD**: `sanitario`
- **Descripción**: Personal sanitario operativo
- **Privilegios**:
  - Ver dashboard personal
  - Consultar mis turnos
  - Consultar mis servicios
  - Gestionar mis ausencias
- **Restricciones**: Solo acceso a datos propios, sin acceso a datos de otros usuarios

#### 8. **Gestor** ⚙️ *(Legacy - Heredado)*
- **Valor BD**: `gestor`
- **Descripción**: Gestión de flota de vehículos
- **Privilegios**:
  - Gestionar vehículos
  - Mantenimiento preventivo
  - ITV y revisiones
  - Documentación de vehículos
  - Consumo y kilometraje
  - Historial de averías
  - Stock de equipamiento
  - Estadísticas de flota
- **Restricciones**: Sin acceso a personal, servicios ni administración

#### 9. **Técnico** 🔧 *(Legacy - Heredado)*
- **Valor BD**: `tecnico`
- **Descripción**: Mantenimiento técnico
- **Privilegios**:
  - Acceder a mantenimiento
  - Gestionar ITV y revisiones
  - Registrar reparaciones y averías
  - Gestionar stock de equipamiento
- **Restricciones**: Sin acceso a gestión de vehículos completa, personal, servicios ni administración

#### 10. **Operador** 👁️ *(Legacy - Heredado)*
- **Valor BD**: `operador`
- **Descripción**: Solo lectura (observador)
- **Privilegios**:
  - Ver dashboard
  - Consultar personal (solo lectura)
  - Consultar vehículos (solo lectura)
  - Consultar servicios (solo lectura)
- **Restricciones**: Sin permisos de escritura en ningún módulo

---

## 3. MATRIZ DE PERMISOS COMPLETA

### Leyenda

| Símbolo | Significado |
|---------|-------------|
| ✅ | Acceso completo (lectura + escritura) |
| 👁️ | Solo lectura |
| ❌ | Sin acceso |
| 🔒 | Acceso solo a datos propios |

### Tabla de Permisos

| Módulo | Admin | Jefe Personal | Jefe Tráfico | Coordinador | Administrativo | Conductor | Sanitario | Gestor | Técnico | Operador |
|--------|-------|---------------|--------------|-------------|----------------|-----------|-----------|--------|---------|----------|
| **GENERALES** |
| Dashboard | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Mi Perfil | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Mis Turnos | ✅ | ✅ | ✅ | ✅ | ✅ | 🔒 | 🔒 | ✅ | ✅ | ❌ |
| Mis Servicios | ✅ | ✅ | ✅ | ✅ | ✅ | 🔒 | 🔒 | ✅ | ✅ | ❌ |
| Mis Ausencias | ✅ | ✅ | ✅ | ✅ | ✅ | 🔒 | 🔒 | ✅ | ✅ | ❌ |
| Calendario | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ | ❌ |
| **PERSONAL (RRHH)** |
| Personal | ✅ | ✅ | ❌ | ❌ | 👁️ | ❌ | ❌ | ❌ | ❌ | 👁️ |
| Formación | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Documentación Personal | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Ausencias | ✅ | ✅ | ❌ | ❌ | ❌ | 🔒 | 🔒 | ❌ | ❌ | ❌ |
| Vacaciones | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Evaluaciones | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Historial Médico | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Equipamiento Personal | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Vestuario | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Stock Vestuario | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **TURNOS Y CUADRANTES** |
| Turnos | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Cuadrantes | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Plantillas Turnos | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Bases | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Dotaciones | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Asignaciones | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Horarios | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Excepciones | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Visual Cuadrante | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Mensual Cuadrante | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **VEHÍCULOS Y FLOTA** |
| Vehículos | ✅ | ❌ | ✅ | ❌ | 👁️ | ❌ | ❌ | ✅ | ❌ | 👁️ |
| Mantenimiento | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ |
| ITV y Revisiones | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ |
| Documentación Vehículos | ✅ | ❌ | ✅ | ❌ | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Geolocalización | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Consumo y KM | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Historial Averías | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ |
| Stock Equipamiento | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ |
| **SERVICIOS MÉDICOS** |
| Servicios | ✅ | ❌ | ✅ | ✅ | ❌ | 🔒 | 🔒 | ❌ | ❌ | 👁️ |
| Pacientes | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Urgentes | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Planificar Servicios | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Histórico Servicios | ✅ | ❌ | ✅ | ✅ | ❌ | 🔒 | 🔒 | ❌ | ❌ | 👁️ |
| Generar Diarios | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Programación Recurrente | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Estado Servicios | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **OPERACIONES** |
| Operaciones | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Incidencias | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Comunicaciones | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **TRÁFICO** |
| Tiempo Real | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Alertas Tráfico | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Rutas Alternativas | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Integración Mapas | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Prioridad Semafórica | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **TALLER** |
| Órdenes Reparación | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ |
| Historial Reparaciones | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ |
| Control Repuestos | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ |
| Alertas Mantenimiento | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ |
| Proveedores | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| **ALMACÉN** |
| Dashboard Almacén | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ |
| Proveedores Almacén | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Productos | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ |
| Movimientos | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ |
| **INFORMES Y REPORTES** |
| Servicios Realizados | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Indicadores Calidad | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Reportes Personal | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Estadísticas Flota | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Satisfacción Paciente | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Costes Operativos | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| **TABLAS MAESTRAS** |
| Centros Hospitalarios | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Motivos Traslado | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Tipos Traslado | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Motivos Cancelación | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Tipos Paciente | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Localidades | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Provincias | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Tipos Vehículo | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Vehículos Tabla | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Facultativos | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Protocolos | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Categorías Vehículos | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Especialidades | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **ADMINISTRACIÓN (CRÍTICO)** |
| 🚨 **Usuarios y Roles** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| 🚨 **Permisos de Acceso** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| 🚨 **Auditorías y Logs** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| 🚨 **Configuración General** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Contratos | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Multicentro | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **OTROS** |
| Integraciones | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Backups | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| API y Webhooks | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |

---

## 4. ANÁLISIS POR ROL

### 4.1. Admin 👑

**Total de módulos**: 70+ (TODOS)

**Responsabilidades**:
- Administración completa del sistema
- Creación y gestión de usuarios
- Asignación de roles y permisos
- Configuración global del sistema
- Acceso a auditorías y logs
- Gestión de integraciones
- Backups y seguridad

**Permisos especiales**:
- ✅ Acceso a módulos de administración (usuarios, permisos, auditorías)
- ✅ Configuración del sistema
- ✅ Gestión de integraciones y APIs
- ✅ Acceso a backups

**Restricciones**: Ninguna

---

### 4.2. Jefe de Personal 👔

**Total de módulos**: 17

**Responsabilidades**:
- Gestión completa de RRHH
- Planificación de turnos y cuadrantes
- Gestión de formación y competencias
- Evaluación del desempeño
- Control de ausencias y vacaciones
- Documentación laboral

**Módulos permitidos**:
1. Dashboard
2. Personal
3. Formación
4. Documentación Personal
5. Ausencias
6. Vacaciones
7. Evaluaciones
8. Historial Médico
9. Equipamiento Personal
10. Vestuario
11. Stock Vestuario
12. Turnos
13. Cuadrantes
14. Plantillas Turnos
15. Dotaciones
16. Asignaciones
17. Reportes Personal
18. Especialidades

**Restricciones**:
- ❌ Sin acceso a vehículos, servicios, ni operaciones
- ❌ Sin acceso a administración del sistema
- ❌ Sin acceso a configuración

---

### 4.3. Jefe de Tráfico 🚑

**Total de módulos**: 43

**Responsabilidades**:
- Operaciones y servicios médicos
- Gestión de flota de vehículos
- Planificación y asignación de servicios
- Supervisión en tiempo real
- Gestión de tráfico e incidencias
- Reportes y estadísticas operacionales

**Módulos permitidos**:
1. Dashboard
2. Servicios (crear, editar, eliminar)
3. Pacientes
4. Urgentes
5. Planificar Servicios
6. Histórico Servicios
7. Generar Diarios
8. Programación Recurrente
9. Estado Servicios
10. Vehículos
11. Mantenimiento
12. ITV y Revisiones
13. Documentación Vehículos
14. Geolocalización
15. Consumo y KM
16. Historial Averías
17. Stock Equipamiento
18. Cuadrantes
19. Dotaciones
20. Asignaciones
21. Bases
22. Operaciones
23. Incidencias
24. Tiempo Real (tráfico)
25. Alertas Tráfico
26. Rutas Alternativas
27. Integración Mapas
28. Prioridad Semafórica
29. Órdenes Reparación
30. Historial Reparaciones
31. Control Repuestos
32. Alertas Mantenimiento
33. Proveedores (taller)
34. Dashboard Almacén
35. Proveedores Almacén
36. Productos
37. Movimientos
38. Servicios Realizados (informes)
39. Indicadores Calidad
40. Estadísticas Flota
41. Satisfacción Paciente
42. Costes Operativos
43. Tablas maestras (10+)

**Restricciones**:
- ❌ Sin acceso a gestión de personal
- ❌ Sin acceso a administración del sistema

---

### 4.4. Coordinador 📊

**Total de módulos**: 14

**Responsabilidades**:
- Supervisión operativa
- Gestión de servicios urgentes
- Seguimiento de incidencias
- Comunicaciones internas
- Consulta de cuadrantes

**Módulos permitidos**:
1. Dashboard
2. Servicios (consulta)
3. Urgentes
4. Histórico Servicios
5. Cuadrantes
6. Dotaciones
7. Asignaciones
8. Bases
9. Operaciones
10. Incidencias
11. Comunicaciones
12. Tiempo Real (tráfico)
13. Alertas Tráfico
14. Rutas Alternativas
15. Integración Mapas
16. Prioridad Semafórica

**Restricciones**:
- ❌ Sin acceso a gestión de personal ni vehículos
- ❌ Sin permisos para crear/editar servicios (solo consulta)
- ❌ Sin acceso a administración

---

### 4.5. Administrativo 📝

**Total de módulos**: 6

**Responsabilidades**:
- Gestión documental
- Contratos
- Documentación de personal y vehículos
- Calendario

**Módulos permitidos**:
1. Dashboard
2. Contratos
3. Documentación Personal
4. Documentación Vehículos
5. Personal (solo lectura)
6. Vehículos (solo lectura)
7. Calendario

**Restricciones**:
- ❌ Sin acceso a operaciones, servicios ni tráfico
- ❌ Sin permisos de escritura en personal ni vehículos
- ❌ Sin acceso a administración

---

### 4.6. Conductor 🚗 y 4.7. Sanitario 🩺

**Total de módulos**: 4 (solo datos propios)

**Responsabilidades**:
- Consultar mis turnos asignados
- Ver mis servicios
- Gestionar mis ausencias personales
- Ver dashboard personal

**Módulos permitidos**:
1. Dashboard
2. 🔒 Mis Turnos (solo propios)
3. 🔒 Mis Servicios (solo propios)
4. 🔒 Mis Ausencias (solo propias)

**Restricciones**:
- ❌ Sin acceso a datos de otros usuarios
- ❌ Sin acceso a gestión ni administración
- ❌ Solo consulta de datos propios

---

### 4.8. Gestor ⚙️

**Total de módulos**: 10

**Responsabilidades**:
- Gestión completa de flota
- Mantenimiento de vehículos
- Control de gastos y estadísticas

**Módulos permitidos**:
1. Dashboard
2. Vehículos
3. Mantenimiento
4. ITV y Revisiones
5. Documentación Vehículos
6. Consumo y KM
7. Historial Averías
8. Stock Equipamiento
9. Estadísticas Flota
10. Tipos Vehículo (tabla maestra)
11. Vehículos Tabla (tabla maestra)
12. Categorías Vehículos (tabla maestra)

**Restricciones**:
- ❌ Sin acceso a personal, servicios ni administración

---

### 4.9. Técnico 🔧

**Total de módulos**: 5

**Responsabilidades**:
- Mantenimiento técnico
- Reparaciones
- Gestión de averías
- Stock de equipamiento

**Módulos permitidos**:
1. Dashboard
2. Mantenimiento
3. ITV y Revisiones
4. Historial Averías
5. Stock Equipamiento

**Restricciones**:
- ❌ Sin acceso a gestión de vehículos completa
- ❌ Sin acceso a personal, servicios ni administración

---

### 4.10. Operador 👁️

**Total de módulos**: 4 (solo lectura)

**Responsabilidades**:
- Consultas de información
- Supervisión pasiva
- Sin permisos de escritura

**Módulos permitidos**:
1. Dashboard
2. 👁️ Personal (solo lectura)
3. 👁️ Vehículos (solo lectura)
4. 👁️ Servicios (solo lectura)

**Restricciones**:
- ❌ Sin permisos de escritura en ningún módulo
- ❌ Sin acceso a gestión ni administración

---

## 5. ESTADO ACTUAL DE IMPLEMENTACIÓN

### ✅ Implementado

| Componente | Archivo | Estado |
|------------|---------|--------|
| Enums de roles | `/lib/core/auth/enums/user_role.dart` | ✅ Completo |
| Enums de módulos | `/lib/core/auth/enums/app_module.dart` | ✅ Completo |
| Matriz de permisos | `/lib/core/auth/permissions/role_permissions.dart` | ✅ Completo |
| RoleService | `/lib/core/auth/services/role_service.dart` | ✅ Completo |
| AuthService | `/lib/core/services/auth_service.dart` | ✅ Completo |
| AuthBloc | `/lib/features/auth/presentation/bloc/auth_bloc.dart` | ✅ Completo |
| AuthGuard (solo auth) | `/lib/core/router/auth_guard.dart` | ⚠️ Solo verifica autenticación |
| UserEntity | `/lib/features/auth/domain/entities/user_entity.dart` | ✅ Completo |

### ⚠️ Parcialmente Implementado

| Componente | Problema | Impacto |
|------------|---------|---------|
| **AuthGuard** | Solo verifica si el usuario está autenticado, NO verifica permisos por rol | 🚨 CRÍTICO |
| **Rutas protegidas** | Todas las rutas son accesibles si estás autenticado | 🚨 ALTO |
| **RLS en Supabase** | No hay políticas de seguridad a nivel de base de datos | 🚨 ALTO |

### ❌ No Implementado

| Componente | Descripción | Prioridad |
|------------|-------------|-----------|
| **Validación de permisos en rutas** | AuthGuard no valida rol antes de permitir acceso | 🔴 URGENTE |
| **RLS (Row Level Security)** | Seguridad a nivel de BD en Supabase | 🔴 URGENTE |
| **Auditoría de accesos** | Log de quién accede a qué módulo | 🟠 ALTA |
| **Página de Usuarios y Roles** | Gestión de usuarios (actualmente placeholder) | 🟠 ALTA |
| **Página de Permisos** | Gestión visual de permisos (actualmente placeholder) | 🟡 MEDIA |
| **Permisos granulares CRUD** | Control de Create/Read/Update/Delete por rol | 🟡 MEDIA |

---

## 6. PLAN DE IMPLEMENTACIÓN

### Fase 1: Seguridad Crítica (URGENTE - 1 semana)

#### 1.1. Modificar AuthGuard para validar permisos por rol

**Archivo**: `/lib/core/router/auth_guard.dart`

**Cambios**:
```dart
static Future<String?> redirect(BuildContext context, GoRouterState state) async {
  final authService = getIt<AuthService>();
  final roleService = getIt<RoleService>();
  final isAuthenticated = authService.isAuthenticated;
  final currentRoute = state.matchedLocation;

  // 1. Verificar autenticación
  if (!isAuthenticated && currentRoute != '/login') {
    return '/login';
  }

  if (isAuthenticated && currentRoute == '/login') {
    return '/';
  }

  // 2. Verificar permisos por rol (NUEVO)
  if (isAuthenticated && currentRoute != '/') {
    final hasAccess = await roleService.hasAccessToRoute(currentRoute);

    if (!hasAccess) {
      // Redirigir a página de error 403 (sin permisos)
      return '/403';
    }
  }

  return null;
}
```

**Archivos a crear**:
- `/lib/features/error/pages/forbidden_page.dart` (página 403)

**Resultado**: Bloquear acceso a rutas sin permisos

---

#### 1.2. Implementar RLS en Supabase

**Tablas críticas a proteger**:
1. `usuarios` - Solo admin puede gestionar
2. `personal` - Jefe de Personal puede editar
3. `vehiculos` - Jefe de Tráfico y Gestor pueden editar
4. `servicios` - Jefe de Tráfico y Coordinador pueden ver/editar
5. `traslados` - Jefe de Tráfico puede editar

**Políticas RLS (ejemplo para usuarios)**:
```sql
-- Solo admin puede ver todos los usuarios
CREATE POLICY "Admin can view all users"
  ON usuarios FOR SELECT
  TO authenticated
  USING (
    auth.uid() IN (
      SELECT id FROM usuarios WHERE rol = 'admin'
    )
  );

-- Solo admin puede insertar usuarios
CREATE POLICY "Admin can insert users"
  ON usuarios FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() IN (
      SELECT id FROM usuarios WHERE rol = 'admin'
    )
  );

-- Solo admin puede actualizar usuarios
CREATE POLICY "Admin can update users"
  ON usuarios FOR UPDATE
  TO authenticated
  USING (
    auth.uid() IN (
      SELECT id FROM usuarios WHERE rol = 'admin'
    )
  );

-- Solo admin puede eliminar usuarios
CREATE POLICY "Admin can delete users"
  ON usuarios FOR DELETE
  TO authenticated
  USING (
    auth.uid() IN (
      SELECT id FROM usuarios WHERE rol = 'admin'
    )
  );

-- Usuarios pueden ver sus propios datos
CREATE POLICY "Users can view their own data"
  ON usuarios FOR SELECT
  TO authenticated
  USING (id = auth.uid());

-- Usuarios pueden actualizar sus propios datos (excepto rol)
CREATE POLICY "Users can update their own data"
  ON usuarios FOR UPDATE
  TO authenticated
  USING (id = auth.uid())
  WITH CHECK (
    id = auth.uid() AND
    rol = (SELECT rol FROM usuarios WHERE id = auth.uid())
  );
```

**Documento a crear**: `/docs/seguridad/RLS_POLICIES.md`

---

#### 1.3. Crear página de Error 403 (Forbidden)

**Archivo**: `/lib/features/error/pages/forbidden_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';

class ForbiddenPage extends StatelessWidget {
  const ForbiddenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 120,
                color: AppColors.error,
              ),
              const SizedBox(height: 24),
              const Text(
                '403',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Acceso Denegado',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'No tienes permisos para acceder a esta página',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.gray600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Volver al Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Añadir ruta en app_router.dart**:
```dart
GoRoute(
  path: '/403',
  builder: (context, state) => const ForbiddenPage(),
),
```

---

### Fase 2: Gestión de Usuarios (ALTA - 2 semanas)

#### 2.1. Crear página funcional de Usuarios y Roles

**Funcionalidades**:
- Listar todos los usuarios con paginación
- Filtrar por rol, estado (activo/inactivo), empresa
- Crear nuevo usuario (solo admin)
- Editar usuario existente (solo admin)
- Desactivar/activar usuario (solo admin)
- Cambiar rol de usuario (solo admin)
- Resetear contraseña (solo admin)

**Archivos a crear**:
```
lib/features/usuarios/
├── data/
│   └── repositories/
│       └── usuarios_repository_impl.dart
├── domain/
│   └── repositories/
│       └── usuarios_repository.dart
├── presentation/
│   ├── bloc/
│   │   ├── usuarios_bloc.dart
│   │   ├── usuarios_event.dart
│   │   └── usuarios_state.dart
│   ├── pages/
│   │   └── usuarios_page.dart
│   └── widgets/
│       ├── usuario_table.dart
│       ├── usuario_form_dialog.dart
│       └── usuario_reset_password_dialog.dart
```

---

#### 2.2. Implementar auditoría de accesos

**Tabla en Supabase**: `auditoria_accesos`

```sql
CREATE TABLE auditoria_accesos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    usuario_email TEXT NOT NULL,
    usuario_rol TEXT NOT NULL,
    accion TEXT NOT NULL, -- 'LOGIN', 'LOGOUT', 'ACCESS_MODULE', 'CRUD_CREATE', 'CRUD_UPDATE', 'CRUD_DELETE'
    modulo TEXT, -- nombre del módulo accedido
    ruta TEXT, -- ruta específica
    entidad TEXT, -- tabla/entidad afectada (ej: 'vehiculos')
    entidad_id TEXT, -- ID del registro afectado
    ip_address TEXT,
    user_agent TEXT,
    detalles JSONB, -- información adicional
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_auditoria_usuario ON auditoria_accesos(usuario_id);
CREATE INDEX idx_auditoria_fecha ON auditoria_accesos(created_at);
CREATE INDEX idx_auditoria_accion ON auditoria_accesos(accion);
CREATE INDEX idx_auditoria_modulo ON auditoria_accesos(modulo);
```

**Servicio de auditoría**:
```dart
// lib/core/services/audit_service.dart
@lazySingleton
class AuditService {
  final SupabaseClient _supabase;
  final AuthService _authService;

  AuditService(this._supabase, this._authService);

  Future<void> logAccess({
    required String action,
    String? module,
    String? route,
    String? entity,
    String? entityId,
    Map<String, dynamic>? details,
  }) async {
    final user = _authService.currentUser;
    if (user == null) return;

    await _supabase.from('auditoria_accesos').insert({
      'usuario_id': user.id,
      'usuario_email': user.email,
      'usuario_rol': user.userMetadata?['rol'] ?? 'unknown',
      'accion': action,
      'modulo': module,
      'ruta': route,
      'entidad': entity,
      'entidad_id': entityId,
      'detalles': details,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> logLogin(String email) async {
    await logAccess(action: 'LOGIN', details: {'email': email});
  }

  Future<void> logLogout(String email) async {
    await logAccess(action: 'LOGOUT', details: {'email': email});
  }

  Future<void> logModuleAccess(String module, String route) async {
    await logAccess(action: 'ACCESS_MODULE', module: module, route: route);
  }

  Future<void> logCrudCreate(String entity, String entityId) async {
    await logAccess(
      action: 'CRUD_CREATE',
      entity: entity,
      entityId: entityId,
    );
  }

  Future<void> logCrudUpdate(String entity, String entityId) async {
    await logAccess(
      action: 'CRUD_UPDATE',
      entity: entity,
      entityId: entityId,
    );
  }

  Future<void> logCrudDelete(String entity, String entityId) async {
    await logAccess(
      action: 'CRUD_DELETE',
      entity: entity,
      entityId: entityId,
    );
  }
}
```

**Integrar en AuthBloc**:
```dart
// En _onLoginRequested
await _auditService.logLogin(email);

// En _onLogoutRequested
await _auditService.logLogout(user.email);
```

**Integrar en AuthGuard**:
```dart
// Después de verificar permisos
await getIt<AuditService>().logModuleAccess(moduleName, currentRoute);
```

---

### Fase 3: Permisos Granulares (MEDIA - 2 semanas)

#### 3.1. Definir permisos CRUD por rol

**Archivo**: `/lib/core/auth/permissions/crud_permissions.dart`

```dart
enum CrudPermission {
  create,
  read,
  update,
  delete,
}

class CrudPermissions {
  static Map<UserRole, Map<String, List<CrudPermission>>> _permissions = {
    UserRole.admin: {
      'personal': [CrudPermission.create, CrudPermission.read, CrudPermission.update, CrudPermission.delete],
      'vehiculos': [CrudPermission.create, CrudPermission.read, CrudPermission.update, CrudPermission.delete],
      'servicios': [CrudPermission.create, CrudPermission.read, CrudPermission.update, CrudPermission.delete],
      'usuarios': [CrudPermission.create, CrudPermission.read, CrudPermission.update, CrudPermission.delete],
    },
    UserRole.jefePersonal: {
      'personal': [CrudPermission.create, CrudPermission.read, CrudPermission.update, CrudPermission.delete],
      'turnos': [CrudPermission.create, CrudPermission.read, CrudPermission.update, CrudPermission.delete],
      'vehiculos': [CrudPermission.read], // solo lectura
      'servicios': [], // sin acceso
    },
    // ... más roles
  };

  static bool hasPermission(UserRole role, String entity, CrudPermission permission) {
    final entityPermissions = _permissions[role]?[entity] ?? [];
    return entityPermissions.contains(permission);
  }

  static bool canCreate(UserRole role, String entity) =>
      hasPermission(role, entity, CrudPermission.create);

  static bool canRead(UserRole role, String entity) =>
      hasPermission(role, entity, CrudPermission.read);

  static bool canUpdate(UserRole role, String entity) =>
      hasPermission(role, entity, CrudPermission.update);

  static bool canDelete(UserRole role, String entity) =>
      hasPermission(role, entity, CrudPermission.delete);
}
```

---

#### 3.2. Aplicar permisos en UI

**Ejemplo en VehiculosPage**:
```dart
// Mostrar botón "Crear" solo si tiene permiso
BlocBuilder<RoleBloc, RoleState>(
  builder: (context, state) {
    final canCreate = state.maybeWhen(
      loaded: (role) => CrudPermissions.canCreate(role, 'vehiculos'),
      orElse: () => false,
    );

    return Visibility(
      visible: canCreate,
      child: ElevatedButton(
        onPressed: () => _showCreateDialog(context),
        child: const Text('Crear Vehículo'),
      ),
    );
  },
)
```

---

### Fase 4: Mejoras y Optimización (BAJA - 1 semana)

#### 4.1. Dashboard personalizado por rol

Mostrar widgets diferentes según el rol del usuario:
- Admin → Estadísticas globales
- Jefe Personal → Métricas de RRHH
- Jefe Tráfico → Métricas operacionales
- Coordinador → Vista de servicios urgentes
- Conductor/Sanitario → Mis turnos y servicios

#### 4.2. Notificaciones por rol

Enviar notificaciones específicas según el rol:
- Admin → Errores críticos del sistema
- Jefe Personal → Ausencias sin cubrir
- Jefe Tráfico → Vehículos en mantenimiento
- Coordinador → Servicios urgentes sin asignar

#### 4.3. Caché de permisos optimizado

Implementar caché en Redis o local storage para reducir consultas:
```dart
class RoleService {
  final _cache = <String, (UserRole, DateTime)>{};
  static const _cacheDuration = Duration(minutes: 5);

  Future<UserRole> getCurrentUserRole() async {
    final userId = _authService.currentUser?.id;
    if (userId == null) throw Exception('No authenticated user');

    // Verificar caché
    if (_cache.containsKey(userId)) {
      final (role, timestamp) = _cache[userId]!;
      if (DateTime.now().difference(timestamp) < _cacheDuration) {
        return role;
      }
    }

    // Consultar BD
    final role = await _fetchRoleFromDatabase(userId);
    _cache[userId] = (role, DateTime.now());
    return role;
  }

  void invalidateCache(String userId) {
    _cache.remove(userId);
  }
}
```

---

## 7. RECOMENDACIONES DE SEGURIDAD

### 7.1. Seguridad de Frontend

| Recomendación | Descripción | Prioridad |
|---------------|-------------|-----------|
| **Validación en rutas** | Implementar validación de permisos en AuthGuard | 🔴 CRÍTICA |
| **Ocultar UI sin permisos** | No mostrar botones/opciones que el usuario no puede usar | 🔴 CRÍTICA |
| **Invalidar tokens** | Invalidar sesión al cambiar rol del usuario | 🟠 ALTA |
| **Timeout de sesión** | Cerrar sesión automáticamente después de X minutos de inactividad | 🟠 ALTA |
| **Doble autenticación (2FA)** | Para usuarios admin | 🟡 MEDIA |

### 7.2. Seguridad de Backend (Supabase)

| Recomendación | Descripción | Prioridad |
|---------------|-------------|-----------|
| **RLS (Row Level Security)** | Implementar políticas RLS en TODAS las tablas sensibles | 🔴 CRÍTICA |
| **Funciones RPC seguras** | Validar roles en funciones RPC de Supabase | 🔴 CRÍTICA |
| **Auditoría completa** | Log de TODAS las operaciones CRUD en tablas críticas | 🟠 ALTA |
| **Cifrado de datos sensibles** | Cifrar campos sensibles (DNI, teléfono, datos médicos) | 🟠 ALTA |
| **Rate limiting** | Limitar peticiones por usuario/IP para prevenir abuso | 🟡 MEDIA |
| **Backups automáticos** | Configurar backups diarios de la BD | 🟠 ALTA |

### 7.3. Mejores Prácticas

1. **Principio de mínimo privilegio**: Asignar solo los permisos necesarios para cada rol
2. **Defensa en profundidad**: Validar permisos en frontend, backend y base de datos
3. **Auditoría continua**: Revisar logs regularmente para detectar accesos sospechosos
4. **Revisión periódica de roles**: Auditar cada 6 meses qué usuarios tienen qué roles
5. **Separación de entornos**: Desarrollo, Staging y Producción con diferentes credenciales
6. **Secretos en variables de entorno**: NUNCA hardcodear credenciales en código
7. **Políticas de contraseñas**: Mínimo 12 caracteres, combinación de letras/números/símbolos
8. **Rotación de credenciales**: Cambiar credenciales de servicios cada 90 días

---

## 8. RESUMEN DE ACCIONES INMEDIATAS

### 🚨 CRÍTICO (Esta semana)

1. ✅ **Modificar AuthGuard** para validar permisos por rol
2. ✅ **Crear página 403** (Forbidden)
3. ✅ **Implementar RLS básico** en tablas: usuarios, personal, vehiculos
4. ✅ **Auditar acceso a Usuarios y Roles** (solo admin)

### 🟠 ALTA PRIORIDAD (Próximas 2 semanas)

5. ✅ **Crear página funcional de Usuarios**
6. ✅ **Implementar auditoría de accesos**
7. ✅ **Completar RLS** en todas las tablas sensibles

### 🟡 MEDIA PRIORIDAD (Próximo mes)

8. ✅ **Definir permisos CRUD granulares**
9. ✅ **Aplicar permisos en UI** (ocultar botones sin permisos)
10. ✅ **Dashboard personalizado por rol**

---

## 9. CONCLUSIÓN

AmbuTrack cuenta con una **arquitectura de permisos sólida y bien diseñada**, pero requiere:

1. **Implementación urgente de validación de permisos en rutas** para evitar acceso no autorizado
2. **RLS en Supabase** para seguridad a nivel de base de datos
3. **Auditoría de accesos** para trazabilidad y cumplimiento
4. **Página funcional de gestión de usuarios** (actualmente es placeholder)

**Estimación total**: 5-6 semanas para implementación completa

**Riesgo actual**: 🔴 ALTO - Actualmente cualquier usuario autenticado puede acceder a cualquier módulo si conoce la URL

**Prioridad**: 🚨 URGENTE - Implementar Fase 1 esta semana

---

**Documento elaborado por**: Claude Code Agent
**Fecha**: 2026-02-12
**Versión**: 1.0
