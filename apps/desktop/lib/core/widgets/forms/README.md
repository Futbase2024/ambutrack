# Formularios AmbuTrack

Componentes de formulario reutilizables con navegación automática.

## AppTextField

TextField personalizado con navegación automática mediante Enter y Tab.

### Características

✅ **Navegación con Enter**: Presionar Enter avanza al siguiente campo
✅ **Navegación con Tab**: Funcionalidad nativa de Flutter
✅ **Shift+Tab**: Retroceder al campo anterior
✅ **Estilos consistentes**: Usa AppColors automáticamente
✅ **Validación integrada**: Compatible con Form y validators
✅ **Sin magic values**: Todos los estilos definidos con constantes

### Uso Básico

```dart
AppTextField(
  controller: _nombreController,
  label: 'Nombre',
  hint: 'Ingrese el nombre',
  icon: Icons.person,
)
```

### Con Validación

```dart
AppTextField(
  controller: _emailController,
  label: 'Email *',
  hint: 'correo@ejemplo.com',
  icon: Icons.email,
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'El email es obligatorio';
    }
    if (!value.contains('@')) {
      return 'Email inválido';
    }
    return null;
  },
)
```

### Campos Numéricos

```dart
AppTextField(
  controller: _edadController,
  label: 'Edad',
  hint: 'Ej: 25',
  icon: Icons.cake,
  keyboardType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
  ],
)
```

### Campos Multilínea

```dart
AppTextField(
  controller: _observacionesController,
  label: 'Observaciones',
  hint: 'Comentarios adicionales',
  icon: Icons.note,
  maxLines: 3,
  // En campos multilínea, Enter inserta nueva línea
  // Tab sigue navegando al siguiente campo
)
```

### Campos Deshabilitados

```dart
AppTextField(
  controller: _idController,
  label: 'ID (auto-generado)',
  enabled: false,
  readOnly: true,
)
```

## AppPasswordField

Campo de contraseña con botón mostrar/ocultar.

```dart
AppPasswordField(
  controller: _passwordController,
  label: 'Contraseña *',
  hint: 'Ingrese su contraseña',
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null;
  },
)
```

## Ejemplo Completo de Formulario

```dart
class MiFormulario extends StatefulWidget {
  const MiFormulario({super.key});

  @override
  State<MiFormulario> createState() => _MiFormularioState();
}

class _MiFormularioState extends State<MiFormulario> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      // Guardar datos
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            controller: _nombreController,
            label: 'Nombre *',
            hint: 'Ej: Juan Pérez',
            icon: Icons.person,
            autofocus: true, // Primer campo con autofocus
            validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
          ),
          const SizedBox(height: 16),

          AppTextField(
            controller: _emailController,
            label: 'Email *',
            hint: 'correo@ejemplo.com',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
          ),
          const SizedBox(height: 16),

          AppTextField(
            controller: _telefonoController,
            label: 'Teléfono',
            hint: 'Ej: 123456789',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          AppPasswordField(
            controller: _passwordController,
            label: 'Contraseña *',
            hint: 'Mínimo 6 caracteres',
            validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _guardar,
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
```

## Flujo de Navegación

1. Usuario completa el primer campo
2. Presiona **Enter** o **Tab**
3. El foco se mueve automáticamente al siguiente campo
4. Continúa hasta el último campo
5. En el último campo, Enter activa el botón de submit (si está configurado)

## Parámetros Disponibles

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `controller` | `TextEditingController` | Controlador del campo (requerido) |
| `label` | `String?` | Etiqueta sobre el campo |
| `hint` | `String?` | Texto de ayuda placeholder |
| `icon` | `IconData?` | Icono izquierdo |
| `prefixIcon` | `Widget?` | Widget personalizado izquierdo |
| `suffixIcon` | `Widget?` | Widget personalizado derecho |
| `validator` | `Function?` | Validador del formulario |
| `keyboardType` | `TextInputType?` | Tipo de teclado |
| `inputFormatters` | `List<TextInputFormatter>?` | Formateadores de entrada |
| `maxLines` | `int` | Líneas máximas (default: 1) |
| `minLines` | `int?` | Líneas mínimas |
| `obscureText` | `bool` | Ocultar texto (passwords) |
| `enabled` | `bool` | Campo habilitado (default: true) |
| `readOnly` | `bool` | Solo lectura (default: false) |
| `autofocus` | `bool` | Auto-foco inicial (default: false) |
| `onChanged` | `Function(String)?` | Callback al cambiar |
| `onSubmitted` | `Function(String)?` | Callback al presionar Enter |

## Reglas del Proyecto

✅ Archivo de 212 líneas (límite: 350)
✅ Usa AppColors para todos los colores
✅ Sin magic values (constantes definidas)
✅ Widget reutilizable en toda la app
✅ Compatible con Form y validación

## Migración desde TextFormField

**Antes (INCORRECTO)**:
```dart
TextFormField(
  controller: controller,
  decoration: InputDecoration(
    labelText: 'Nombre',
    hintText: 'Ingrese el nombre',
  ),
)
```

**Después (CORRECTO)**:
```dart
AppTextField(
  controller: controller,
  label: 'Nombre',
  hint: 'Ingrese el nombre',
  icon: Icons.person,
)
```

## Notas Importantes

⚠️ **NO usar TextFormField directamente** - Usar siempre `AppTextField`
⚠️ **NO usar InputDecoration manual** - AppTextField lo maneja automáticamente
✅ **SÍ usar en toda la aplicación** - Consistencia visual
✅ **SÍ aprovechar navegación con Enter** - Mejor UX
