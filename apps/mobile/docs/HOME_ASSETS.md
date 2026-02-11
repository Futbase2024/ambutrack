# AmbuTrack Home Dashboard - Assets y Layout

## 📱 Layout del Dashboard

El home de AmbuTrack Mobile presenta **5 funcionalidades principales** en un grid de 2 columnas:

```
┌─────────────┬─────────────┐
│   Turno     │  Servicios  │
│  (reloj)    │ (hospital)  │
├─────────────┼─────────────┤
│  Trámites   │  Vehículo   │
│ (documento) │  (ambazul)  │
├─────────────┼─────────────┤
│  Vestuario  │             │
│ (maletin)   │             │
└─────────────┴─────────────┘
```

---

## 🎨 Assets Utilizados

### Iconos del Dashboard (5 botones)

| # | Funcionalidad | Icono | Ruta | Estado |
|---|---------------|-------|------|--------|
| 1 | **Turno** | reolj.png | `lib/assets/images/reolj.png` (50K) | ✅ SIEMPRE activo |
| 2 | **Servicios** | hospital.png | `lib/assets/images/hospital.png` (2.8K) | ⚠️ Requiere turno |
| 3 | **Trámites** | documento.png | `lib/assets/images/documento.png` (18K) | ⚠️ Requiere turno |
| 4 | **Vehículo** | ambazul.png | `lib/assets/images/ambazul.png` (4.8K) | ⚠️ Requiere turno |
| 5 | **Vestuario** | maletin.png | `lib/assets/images/maletin.png` (20K) | ⚠️ Requiere turno |

### Tamaños de Archivos

```bash
50K   reolj.png      # Turno (lib/assets/images/)
2.8K  hospital.png   # Servicios (lib/assets/images/)
18K   documento.png  # Trámites (lib/assets/images/)
4.8K  ambazul.png    # Vehículo (lib/assets/images/)
20K   maletin.png    # Vestuario (lib/assets/images/)
```

---

## 🏗️ Especificaciones Técnicas

### GridView Configuration

```dart
GridView.count(
  crossAxisCount: 2,        // 2 columnas
  crossAxisSpacing: 12,     // Espacio horizontal
  mainAxisSpacing: 12,      // Espacio vertical
  childAspectRatio: 1.0,    // Proporción cuadrada
  children: [/* 5 cards */],
)
```

### Estados de los Botones

| Estado | Color de Fondo | Color de Texto | Opacidad |
|--------|----------------|----------------|----------|
| **Activo** | Verde (#4CAF50) con alpha 0.1 | Verde | 1.0 |
| **Habilitado** | Gris claro | Gris oscuro | 1.0 |
| **Deshabilitado** | Gris (#BDBDBD) | Gris medio | 0.5 |

### Comportamiento

1. **Turno** (reloj.png):
   - ✅ SIEMPRE habilitado
   - Estado activo cuando el usuario tiene turno iniciado
   - Navega a `/registro-horario`

2. **Servicios** (hospital.png):
   - ⚠️ Solo habilitado si turno activo
   - Navega a `/servicios`

3. **Trámites** (documento.png):
   - ⚠️ Solo habilitado si turno activo
   - Navega a `/tramites`

4. **Vehículo** (ambazul.png):
   - ⚠️ Solo habilitado si turno activo
   - Navega a `/vehiculo`

5. **Vestuario** (maletin.png):
   - ⚠️ Solo habilitado si turno activo
   - Navega a `/vestuario`

---

## 📂 Inventario Completo de Assets

### lib/assets/icons/ (26 archivos)

```bash
# PNG disponibles para futuro
reloj.png (1.4M)          # Versión grande (no usada)
ambulancia.png (582K)
ambu.png (453K)
calendario.png (1.6M)
documento.png (787K)      # Versión grande (no usada)
equipamiento.png (582K)
gps.png (754K)
hospitales.png (538K)
rutas.png (1.3M)
servicios.png (1.0M)
turnos.png (1.5M)
vestuario.png (543K)
# ... (14 más)
```

### lib/assets/images/ (20 archivos)

```bash
# PNG usados en dashboard
reolj.png (50K)            ✅ USADO - Turno
hospital.png (2.8K)        ✅ USADO - Servicios
documento.png (18K)        ✅ USADO - Trámites
ambazul.png (4.8K)         ✅ USADO - Vehículo
maletin.png (20K)          ✅ USADO - Vestuario

# PNG usados en otras pantallas
logonuevo.png (516K)       ✅ USADO - Login page

# PNG disponibles para futuro
ambgris.png (4.7K)
camilla.png (17K)
cruz.png (40K)
docs.png (25K)
hospital1.png (19K)
medicamento.png (6.2K)
puntoxy.png (28K)
reloj1.png (40K)
ruta.png (16K)
sillaruedas.png (9.2K)
sirena.png (42K)
tiritas.png (18K)
# ... (logos)
```

---

## 🔄 Historial de Cambios

| Fecha | Cambio | Botones | Layout |
|-------|--------|---------|--------|
| 2026-02-11 | Configuración inicial | 6 | 2x3 |
| 2026-02-11 | Expansión | 9 | 3x3 |
| 2026-02-11 | Simplificación | 5 | 3+2 |
| 2026-02-11 | Layout 2 columnas | 5 | 2x3 |
| 2026-02-11 | **Iconos finales** | **5** | **2x3** |

### Versión Actual (v5)

- **5 botones** totales
- Layout: **2 columnas**, 3 filas (2+2+1)
- **Todos los iconos en `lib/assets/images/`** (consistencia)
- Tamaños optimizados: 2.8K-50K por icono
- 1 botón siempre activo (Turno)
- 4 botones condicionales (requieren turno activo)

---

## 🎯 Roadmap

### Fase Actual ✅
- [x] Dashboard con 5 funcionalidades core
- [x] Assets organizados en `lib/assets/`
- [x] Documentación actualizada

### Próximas Mejoras 🔄
- [ ] Implementar navegación para Calendario
- [ ] Implementar navegación para GPS/Rutas
- [ ] Añadir más funcionalidades según necesidad
- [ ] Optimizar tamaños de imágenes PNG

### Assets Pendientes de Uso 📦
- ambulancia.png, equipamiento.png, hospitales.png
- calendar.png, gps.png, rutas.png
- cruz.png, sirena.png, medicamento.png
- camilla.png, sillaruedas.png

---

**Última actualización:** 2026-02-11
**Archivo:** `lib/features/home_android/presentation/pages/home_android_page.dart:94-164`
**Mantenedor:** AmbuTrack Dev Team
**Versión:** v5 (Iconos finales optimizados)
