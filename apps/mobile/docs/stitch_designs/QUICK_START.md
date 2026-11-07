# 🎨 AmbuTrack - Guía Rápida de Diseño con Stitch

## 🚀 Quick Start (3 pasos)

### Paso 1: Acceder a Stitch
Abre [Google Stitch](https://stitch.google.com/) en tu navegador

### Paso 2: Copiar el Prompt
Abre el archivo `ambutrack_stitch_design_prompts.md` y copia el prompt de la página que quieres mejorar:
- **Página Home (Dashboard)**: Sección "Página 1: Home Dashboard"
- **Página Servicios**: Sección "Página 2: Servicios (Traslados)"
- **Página Vehículo**: Sección "Página 3: Vehículo"

### Paso 3: Generar el Diseño
1. En Stitch, crea un nuevo proyecto móvil (Mobile - Phone)
2. Pega el prompt en el campo de descripción
3. Haz clic en "Generate"
4. Espera a que Stitch genere el diseño
5. Ajusta los detalles si es necesario
6. Exporta como **HTML** o **PNG**

---

## 🎯 Opciones de Implementación

### Opción A: Usar Stitch Web (Más fácil)
```bash
# 1. Abrir Google Stitch en el navegador
open https://stitch.google.com/

# 2. Crear nuevo proyecto móvil
# 3. Copiar prompt desde el documento
# 4. Pegar y generar diseño
# 5. Exportar como HTML o PNG
```

### Opción B: Usar Claude Code (Conversión automática)
```bash
# 1. Generar diseño con Stitch (Opción A)
# 2. Exportar como HTML
# 3. Usar la skill /design-to-code en Claude Code
# 4. Claude convierte el HTML a código Flutter automáticamente

# Ejemplo:
/design-to-code
# Seleccionar el HTML exportado
# Claude genera código Flutter Material 3
```

### Opción C: Usar Stitch MCP (Más integrado)
```bash
# Una vez que Stitch MCP esté completamente configurado:
# 1. Pedir a Claude que genere el diseño directamente
# 2. Claude usa las herramientas de Stitch MCP
# 3. El diseño se genera automáticamente
# 4. Claude lo convierte a código Flutter

# Ejemplo prompt:
"Genera un diseño profesional para la página Home de AmbuTrack con Stitch"
```

---

## 📋 Checklists por Página

### ✅ Home Dashboard
- [ ] Tarjeta de usuario con avatar e información
- [ ] Sección de alertas de caducidad (condicional)
- [ ] Grid de funcionalidades (5 tarjetas)
- [ ] Estados: Activo (verde), Habilitado, Deshabilitado
- [ ] Pull-to-refresh
- [ ] Animaciones sutiles y feedback táctil

### ✅ Servicios (Traslados)
- [ ] Header con contador de servicios
- [ ] Lista de traslados con tarjetas
- [ ] Badges de estado con colores
- [ ] Visualización de ruta (origen/destino)
- [ ] Mini mapa en cada tarjeta
- [ ] Diálogos de confirmación
- [ ] Estado vacío cuando no hay traslados

### ✅ Vehículo
- [ ] Header con vehículo asignado
- [ ] Grid de acciones (4 tarjetas)
- [ ] Badges de notificación (puntos)
- [ ] Estados: Asignado, Sin asignación, Error
- [ ] Diálogos para cada acción
- [ ] Pull-to-refresh

---

## 🎨 Design Tokens de AmbuTrack

### Colores Principales
```dart
// AppColors.dart
class AppColors {
  static const primary = Color(0xFF1E40AF);      // Azul médico
  static const primaryLight = Color(0xFF3B82F6); // Azul claro
  static const secondary = Color(0xFF059669);    // Verde salud
  static const emergency = Color(0xFFDC2626);    // Rojo urgencia
  static const warning = Color(0xFFD97706);      // Naranja alerta
}
```

### Espaciado
```dart
// AppSizes.dart
class AppSizes {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}
```

### Border Radius
```dart
class AppRadius {
  static const small = 8.0;
  static const medium = 12.0;
  static const large = 16.0;
}
```

---

## 🔧 Implementación en Flutter

### Estructura de Carpetas
```
lib/features/
├── home_android/
│   └── presentation/
│       ├── pages/
│       │   └── home_android_page.dart (EXISTENTE - MEJORAR)
│       └── widgets/
│           ├── user_profile_card.dart (NUEVO)
│           ├── functionality_card.dart (NUEVO)
│           └── alerts_section.dart (NUEVO)
│
├── servicios/
│   └── presentation/
│       ├── pages/
│       │   └── servicios_page.dart (EXISTENTE - MEJORAR)
│       └── widgets/
│           ├── servicios_header.dart (NUEVO)
│           ├── traslado_list_card.dart (MEJORAR)
│           └── status_badge.dart (NUEVO)
│
└── vehiculo/
    └── presentation/
        ├── pages/
        │   └── vehiculo_page.dart (EXISTENTE - MEJORAR)
        └── widgets/
            ├── vehicle_header_card.dart (NUEVO)
            ├── vehicle_action_card.dart (NUEVO)
            └── notification_badge.dart (NUEVO)
```

### Ejemplo de Widget Mejorado
```dart
// lib/features/home_android/presentation/widgets/user_profile_card.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';

class UserProfileCard extends StatelessWidget {
  final String nombre;
  final String? categoria;
  final String? dni;

  const UserProfileCard({
    super.key,
    required this.nombre,
    this.categoria,
    this.dni,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),

          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${categoria ?? "Sin categoría"} ${dni != null ? "• DNI: $dni" : ""}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 📊 Proceso de Iteración

1. **Generar diseño inicial** con Stitch
2. **Revisar** el diseño generado
3. **Ajustar prompt** si es necesario
4. **Regenerar** con el prompt mejorado
5. **Exportar** como HTML
6. **Convertir** a código Flutter con /design-to-code
7. **Integrar** en el proyecto AmbuTrack
8. **Probar** en emulador/dispositivo
9. **Ajustar** según feedback
10. **Repetir** hasta satisfacer

---

## 🎓 Recursos Adicionales

- **Documentación completa**: `ambutrack_stitch_design_prompts.md`
- **Google Stitch**: https://stitch.google.com/
- **Material Design 3**: https://m3.material.io/
- **Flutter Widgets**: https://api.flutter.dev/flutter/widgets/widgets-library.html

---

## ❓ FAQ

**P: ¿Puedo generar múltiples diseños a la vez?**
R: Sí, pero es mejor generarlos uno por uno para mayor control sobre los detalles.

**P: ¿Qué formato de exportación debo usar?**
R: HTML es mejor para conversión a código Flutter, PNG para visualización rápida.

**P: ¿Cómo aseguro que el diseño sea consistente?**
R: Usa los mismos design tokens (colores, espaciado, border radius) en todos los prompts.

**P: ¿Puedo personalizar los prompts?**
R: ¡Sí! Los prompts son puntos de partida. Ajusta según tus necesidades específicas.

**P: ¿Qué hago si el diseño generado no es lo que esperaba?**
R: Refina el prompt con más detalles específicos o ajusta los parámetros en Stitch.

---

**¿Listo para empezar?** Elige la página que quieres mejorar primero y copia el prompt correspondiente del documento `ambutrack_stitch_design_prompts.md`. 🚀
