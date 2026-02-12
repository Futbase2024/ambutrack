# App Loading Indicators

Componentes de carga personalizados para AmbuTrack Web.

## Componentes

### 1. AppLoadingIndicator

Indicador de carga principal con animación de ambulancia.

**Características**:
- Ambulancia animada con efecto de escala (pulse)
- Luces de emergencia parpadeantes (roja y azul)
- Mensaje opcional debajo de la animación
- Tamaño configurable

**Uso básico**:
```dart
const AppLoadingIndicator()
```

**Con mensaje**:
```dart
const AppLoadingIndicator(
  message: 'Cargando vehículos...',
)
```

**Tamaño personalizado**:
```dart
const AppLoadingIndicator(
  size: 150.0,
  message: 'Procesando...',
)
```

### 2. AppLoadingOverlay

Overlay que cubre toda la pantalla durante operaciones bloqueantes.

**Uso**:
```dart
Stack(
  children: [
    // Tu contenido
    MyContent(),

    // Mostrar overlay condicionalmente
    if (isLoading)
      const AppLoadingOverlay(
        message: 'Guardando cambios...',
      ),
  ],
)
```

**Con BLoC**:
```dart
BlocBuilder<MyBloc, MyState>(
  builder: (context, state) {
    return Stack(
      children: [
        MyContent(),

        if (state is MyLoading)
          const AppLoadingOverlay(
            message: 'Cargando datos...',
          ),
      ],
    );
  },
)
```

## Ejemplos de Integración

### En una lista (como VehiculosPage)

```dart
BlocBuilder<VehiculosBloc, VehiculosState>(
  builder: (context, state) {
    if (state is VehiculosLoading) {
      return const Center(
        child: AppLoadingIndicator(
          message: 'Cargando vehículos...',
        ),
      );
    }

    if (state is VehiculosLoaded) {
      return MyList(data: state.vehiculos);
    }

    return const SizedBox.shrink();
  },
)
```

### En un formulario de guardado

```dart
ElevatedButton(
  onPressed: isLoading ? null : () async {
    setState(() => isLoading = true);
    await saveData();
    setState(() => isLoading = false);
  },
  child: isLoading
    ? const SizedBox(
        width: 20,
        height: 20,
        child: AppLoadingIndicator(size: 20),
      )
    : const Text('Guardar'),
)
```

## Animaciones

- **Pulse**: Escala de 0.95 a 1.05 (efecto de latido)
- **Luces**: Alternancia entre luz roja y azul
- **Duración**: 1.5 segundos por ciclo
- **Curva**: easeInOut para suavidad

## Personalización

Si necesitas un tamaño diferente, usa el parámetro `size`:

- `size: 80.0` - Pequeño (botones, inline)
- `size: 120.0` - Mediano (default, centrado en pantalla)
- `size: 160.0` - Grande (pantallas de bienvenida)

## Colores Utilizados

- **Ambulancia**: AppColors.primary
- **Cruz médica**: AppColors.error
- **Luz roja**: AppColors.emergency
- **Luz azul**: AppColors.info
- **Fondo**: AppColors.primary con opacidad

## Notas

- ✅ Reutilizable en toda la aplicación
- ✅ Sin magic values (todas las dimensiones relativas al `size`)
- ✅ Animación ligera y performante
- ✅ Accesible y profesional
- ⚠️ **NO** usar `CircularProgressIndicator` - usar siempre `AppLoadingIndicator`
