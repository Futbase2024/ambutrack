# 📦 Módulo de Stock de Equipamiento

## 🎯 Descripción

Módulo integral para la gestión de stock de equipamiento médico en ambulancias según normativa **EN 1789:2021**.

## 🚑 Tipos de Ambulancia

- **A2**: Transporte sanitario (equipamiento básico)
- **B (A1EE)**: Soporte Vital Básico
- **C (S.V.A)**: Soporte Vital Avanzado

## 📂 Contenido

### Migraciones SQL

- [migraciones_supabase.sql](./migraciones_supabase.sql): Script completo para crear las 8 tablas, vistas y funciones RPC en Supabase

### Tablas Principales

1. **categorias_equipamiento**: 9 categorías según normativa
2. **productos**: Catálogo de equipamiento médico
3. **stock_minimo_por_tipo**: Stock mínimo por tipo de ambulancia
4. **stock_vehiculo**: Stock actual por vehículo
5. **movimientos_stock**: Historial de entradas/salidas
6. **revisiones_mensuales**: Checklists mensuales (días 1, 2, 3)
7. **items_revision**: Items verificados en cada revisión
8. **alertas_stock**: Alertas automáticas de stock bajo/caducidad

### Vistas

- **v_stock_vehiculo_estado**: Stock con estados calculados
- **v_resumen_alertas_vehiculo**: Resumen de alertas por vehículo

### Funciones RPC

- **registrar_movimiento_stock()**: Registra entrada/salida/ajuste
- **generar_alertas_stock()**: Genera alertas automáticas

## 🔧 Instalación

1. Ejecutar `migraciones_supabase.sql` en el editor SQL de Supabase
2. Verificar que todas las tablas se crearon correctamente
3. Importar datos iniciales de productos (próximo paso)

## 📊 Estructura de Datos

### Categorías de Equipamiento

| Código | Categoría | Día Revisión |
|--------|-----------|--------------|
| 1.1 | Equipos de Traslado e Inmovilización | 1 |
| 1.2 | Equipos de Ventilación y Respiración | 1 |
| 1.3 | Equipos de Diagnóstico | 1 |
| 1.4 | Equipos de Infusión (Sueroterapia) | 2 |
| 1.5 | Medicación | 1 |
| 1.6 | Mochilas de Intervención | 2 |
| 1.7 | Vendajes y Asistencia Sanitaria | 2 |
| 1.8 | Protección y Rescate | 3 |
| 1.9 | Documentación | 3 |

### Estados de Stock

- **ok**: Stock suficiente
- **bajo**: Stock por debajo del mínimo
- **sin_stock**: Stock a 0

### Estados de Caducidad

- **ok**: Más de 30 días
- **proximo**: 8-30 días
- **critico**: 1-7 días
- **caducado**: Fecha pasada

## 🔄 Flujo de Trabajo

1. **Alta de productos**: Crear productos en catálogo con stock mínimo por tipo
2. **Carga inicial**: Registrar stock inicial de cada vehículo
3. **Movimientos**: Registrar entradas/salidas durante servicios
4. **Revisiones**: Realizar checklists mensuales según día
5. **Alertas**: Sistema automático de alertas de stock/caducidad

## 📱 Funcionalidades Flutter

- Vista de stock por vehículo con filtros por categoría
- Registro rápido de entradas/salidas (+/-)
- Historial de movimientos con trazabilidad
- Alertas en tiempo real
- Checklists de revisión mensual con firma digital
- Dashboard de métricas de stock

## 🔐 Seguridad

- **RLS habilitado**: Políticas de acceso por usuario autenticado
- **Trazabilidad**: Todos los movimientos registran usuario y fecha
- **Auditoría**: Historial completo de cambios

## 📖 Referencias

- Normativa EN 1789:2021
- Guía de equipamiento de ambulancias

---

*Última actualización: 2025-01-27*
