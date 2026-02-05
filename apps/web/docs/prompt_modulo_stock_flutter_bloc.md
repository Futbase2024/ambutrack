# PROMPT: Módulo de Stock de Equipamiento - Flutter + BLoC + Supabase

## 🎯 CONTEXTO

Tenemos una app Flutter con **BLoC** y **Supabase** que ya gestiona vehículos (ambulancias). Necesitamos añadir el **módulo de gestión de stock de equipamiento médico** para 3 tipos de ambulancias según normativa EN 1789:2021.

**Tipos de ambulancia existentes:**
- **A2** - Transporte sanitario (equipamiento básico)
- **B (A1EE)** - Soporte Vital Básico
- **C (S.V.A)** - Soporte Vital Avanzado

---

## 🗄️ TABLAS SUPABASE A CREAR

### 1. categorias_equipamiento
```sql
CREATE TABLE categorias_equipamiento (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo VARCHAR(10) NOT NULL, -- '1.1', '1.2', etc.
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT,
  orden INT DEFAULT 0,
  dia_revision INT DEFAULT 1, -- Día 1, 2 o 3 del mes
  icono VARCHAR(50), -- nombre del icono Material/Lucide
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Datos iniciales
INSERT INTO categorias_equipamiento (codigo, nombre, dia_revision, icono) VALUES
('1.1', 'Equipos de Traslado e Inmovilización', 1, 'local_hospital'),
('1.2', 'Equipos de Ventilación y Respiración', 1, 'air'),
('1.3', 'Equipos de Diagnóstico', 1, 'monitor_heart'),
('1.4', 'Equipos de Infusión (Sueroterapia)', 2, 'water_drop'),
('1.5', 'Medicación', 1, 'medication'),
('1.6', 'Mochilas de Intervención', 2, 'backpack'),
('1.7', 'Vendajes y Asistencia Sanitaria', 2, 'healing'),
('1.8', 'Protección y Rescate', 3, 'security'),
('1.9', 'Documentación', 3, 'description');
```

### 2. productos
```sql
CREATE TABLE productos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  categoria_id UUID REFERENCES categorias_equipamiento(id),
  codigo VARCHAR(20), -- código interno opcional
  nombre VARCHAR(150) NOT NULL,
  nombre_comercial VARCHAR(100), -- ej: "ADENOCOR" para Adenosina
  descripcion TEXT,
  unidad_medida VARCHAR(20) DEFAULT 'unidades', -- unidades, ml, mg, etc.
  requiere_refrigeracion BOOLEAN DEFAULT FALSE,
  tiene_caducidad BOOLEAN DEFAULT FALSE,
  dias_alerta_caducidad INT DEFAULT 30, -- días antes para alertar
  ubicacion_default VARCHAR(100), -- "Mochila naranja", "Nevera", etc.
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_productos_categoria ON productos(categoria_id);
CREATE INDEX idx_productos_activo ON productos(activo);
```

### 3. stock_minimo_por_tipo
```sql
CREATE TABLE stock_minimo_por_tipo (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  producto_id UUID REFERENCES productos(id) ON DELETE CASCADE,
  tipo_vehiculo VARCHAR(10) NOT NULL, -- 'A2', 'B', 'C'
  cantidad_minima INT NOT NULL DEFAULT 0,
  cantidad_recomendada INT,
  obligatorio BOOLEAN DEFAULT TRUE,
  UNIQUE(producto_id, tipo_vehiculo)
);

-- Índice
CREATE INDEX idx_stock_minimo_tipo ON stock_minimo_por_tipo(tipo_vehiculo);
```

### 4. stock_vehiculo
```sql
CREATE TABLE stock_vehiculo (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vehiculo_id UUID REFERENCES vehiculos(id) ON DELETE CASCADE,
  producto_id UUID REFERENCES productos(id) ON DELETE CASCADE,
  cantidad_actual INT NOT NULL DEFAULT 0,
  fecha_caducidad DATE,
  lote VARCHAR(50),
  ubicacion VARCHAR(100),
  observaciones TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  updated_by UUID REFERENCES auth.users(id),
  UNIQUE(vehiculo_id, producto_id, lote)
);

-- Índices
CREATE INDEX idx_stock_vehiculo ON stock_vehiculo(vehiculo_id);
CREATE INDEX idx_stock_producto ON stock_vehiculo(producto_id);
CREATE INDEX idx_stock_caducidad ON stock_vehiculo(fecha_caducidad);
```

### 5. movimientos_stock
```sql
CREATE TABLE movimientos_stock (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stock_vehiculo_id UUID REFERENCES stock_vehiculo(id),
  vehiculo_id UUID REFERENCES vehiculos(id),
  producto_id UUID REFERENCES productos(id),
  tipo_movimiento VARCHAR(20) NOT NULL, -- 'entrada', 'salida', 'ajuste', 'caducidad', 'transferencia'
  cantidad INT NOT NULL,
  cantidad_anterior INT,
  cantidad_nueva INT,
  motivo TEXT,
  referencia VARCHAR(100), -- nº servicio, nº pedido, etc.
  vehiculo_destino_id UUID REFERENCES vehiculos(id), -- para transferencias
  usuario_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_movimientos_vehiculo ON movimientos_stock(vehiculo_id);
CREATE INDEX idx_movimientos_fecha ON movimientos_stock(created_at);
CREATE INDEX idx_movimientos_tipo ON movimientos_stock(tipo_movimiento);
```

### 6. revisiones_mensuales
```sql
CREATE TABLE revisiones_mensuales (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vehiculo_id UUID REFERENCES vehiculos(id) ON DELETE CASCADE,
  fecha DATE NOT NULL,
  mes INT NOT NULL, -- 1-12
  anio INT NOT NULL,
  dia_revision INT NOT NULL, -- 1, 2 o 3
  tecnico_id UUID REFERENCES auth.users(id),
  tecnico_nombre VARCHAR(100),
  completada BOOLEAN DEFAULT FALSE,
  firma_base64 TEXT,
  observaciones_generales TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  UNIQUE(vehiculo_id, mes, anio, dia_revision)
);
```

### 7. items_revision
```sql
CREATE TABLE items_revision (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  revision_id UUID REFERENCES revisiones_mensuales(id) ON DELETE CASCADE,
  producto_id UUID REFERENCES productos(id),
  verificado BOOLEAN DEFAULT FALSE,
  cantidad_encontrada INT,
  caducidad_ok BOOLEAN DEFAULT TRUE,
  estado VARCHAR(20) DEFAULT 'pendiente', -- 'ok', 'falta', 'caducado', 'dañado'
  observacion TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 8. alertas_stock
```sql
CREATE TABLE alertas_stock (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vehiculo_id UUID REFERENCES vehiculos(id),
  producto_id UUID REFERENCES productos(id),
  tipo_alerta VARCHAR(30) NOT NULL, -- 'stock_bajo', 'caducidad_proxima', 'caducado', 'sin_stock'
  mensaje TEXT,
  nivel VARCHAR(10) DEFAULT 'warning', -- 'info', 'warning', 'critical'
  fecha_caducidad DATE,
  cantidad_actual INT,
  cantidad_minima INT,
  resuelta BOOLEAN DEFAULT FALSE,
  resuelta_por UUID REFERENCES auth.users(id),
  resuelta_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índice
CREATE INDEX idx_alertas_activas ON alertas_stock(resuelta, created_at);
```

---

## 📦 VISTAS ÚTILES

### Vista de stock con estado
```sql
CREATE OR REPLACE VIEW v_stock_vehiculo_estado AS
SELECT 
  sv.id,
  sv.vehiculo_id,
  v.matricula,
  v.tipo as tipo_vehiculo,
  sv.producto_id,
  p.nombre as producto_nombre,
  p.nombre_comercial,
  c.codigo as categoria_codigo,
  c.nombre as categoria_nombre,
  sv.cantidad_actual,
  COALESCE(sm.cantidad_minima, 0) as cantidad_minima,
  sv.fecha_caducidad,
  sv.lote,
  sv.ubicacion,
  CASE 
    WHEN sv.cantidad_actual = 0 THEN 'sin_stock'
    WHEN sv.cantidad_actual < COALESCE(sm.cantidad_minima, 0) THEN 'bajo'
    ELSE 'ok'
  END as estado_stock,
  CASE 
    WHEN sv.fecha_caducidad IS NULL THEN 'sin_caducidad'
    WHEN sv.fecha_caducidad < CURRENT_DATE THEN 'caducado'
    WHEN sv.fecha_caducidad < CURRENT_DATE + INTERVAL '7 days' THEN 'critico'
    WHEN sv.fecha_caducidad < CURRENT_DATE + INTERVAL '30 days' THEN 'proximo'
    ELSE 'ok'
  END as estado_caducidad
FROM stock_vehiculo sv
JOIN vehiculos v ON sv.vehiculo_id = v.id
JOIN productos p ON sv.producto_id = p.id
JOIN categorias_equipamiento c ON p.categoria_id = c.id
LEFT JOIN stock_minimo_por_tipo sm ON sm.producto_id = p.id AND sm.tipo_vehiculo = v.tipo;
```

### Vista resumen alertas por vehículo
```sql
CREATE OR REPLACE VIEW v_resumen_alertas_vehiculo AS
SELECT 
  vehiculo_id,
  COUNT(*) FILTER (WHERE tipo_alerta = 'sin_stock' AND NOT resuelta) as sin_stock,
  COUNT(*) FILTER (WHERE tipo_alerta = 'stock_bajo' AND NOT resuelta) as stock_bajo,
  COUNT(*) FILTER (WHERE tipo_alerta = 'caducado' AND NOT resuelta) as caducados,
  COUNT(*) FILTER (WHERE tipo_alerta = 'caducidad_proxima' AND NOT resuelta) as proximos_caducar,
  COUNT(*) FILTER (WHERE NOT resuelta) as total_alertas
FROM alertas_stock
GROUP BY vehiculo_id;
```

---

## 🔄 FUNCIONES RPC SUPABASE

### Registrar movimiento de stock
```sql
CREATE OR REPLACE FUNCTION registrar_movimiento_stock(
  p_vehiculo_id UUID,
  p_producto_id UUID,
  p_tipo VARCHAR(20),
  p_cantidad INT,
  p_motivo TEXT DEFAULT NULL,
  p_lote VARCHAR(50) DEFAULT NULL,
  p_fecha_caducidad DATE DEFAULT NULL,
  p_usuario_id UUID DEFAULT NULL
) RETURNS JSON AS $$
DECLARE
  v_stock_id UUID;
  v_cantidad_anterior INT;
  v_cantidad_nueva INT;
BEGIN
  -- Buscar o crear registro de stock
  SELECT id, cantidad_actual INTO v_stock_id, v_cantidad_anterior
  FROM stock_vehiculo 
  WHERE vehiculo_id = p_vehiculo_id 
    AND producto_id = p_producto_id
    AND (lote = p_lote OR (lote IS NULL AND p_lote IS NULL))
  LIMIT 1;
  
  IF v_stock_id IS NULL THEN
    v_cantidad_anterior := 0;
    INSERT INTO stock_vehiculo (vehiculo_id, producto_id, cantidad_actual, lote, fecha_caducidad)
    VALUES (p_vehiculo_id, p_producto_id, 0, p_lote, p_fecha_caducidad)
    RETURNING id INTO v_stock_id;
  END IF;
  
  -- Calcular nueva cantidad
  IF p_tipo IN ('entrada', 'ajuste_positivo') THEN
    v_cantidad_nueva := v_cantidad_anterior + p_cantidad;
  ELSIF p_tipo IN ('salida', 'caducidad', 'ajuste_negativo') THEN
    v_cantidad_nueva := GREATEST(0, v_cantidad_anterior - p_cantidad);
  ELSE
    v_cantidad_nueva := p_cantidad; -- ajuste absoluto
  END IF;
  
  -- Actualizar stock
  UPDATE stock_vehiculo 
  SET cantidad_actual = v_cantidad_nueva,
      fecha_caducidad = COALESCE(p_fecha_caducidad, fecha_caducidad),
      updated_at = NOW(),
      updated_by = p_usuario_id
  WHERE id = v_stock_id;
  
  -- Registrar movimiento
  INSERT INTO movimientos_stock (
    stock_vehiculo_id, vehiculo_id, producto_id, 
    tipo_movimiento, cantidad, cantidad_anterior, cantidad_nueva,
    motivo, usuario_id
  ) VALUES (
    v_stock_id, p_vehiculo_id, p_producto_id,
    p_tipo, p_cantidad, v_cantidad_anterior, v_cantidad_nueva,
    p_motivo, p_usuario_id
  );
  
  RETURN json_build_object(
    'success', true,
    'stock_id', v_stock_id,
    'cantidad_anterior', v_cantidad_anterior,
    'cantidad_nueva', v_cantidad_nueva
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Generar alertas automáticas
```sql
CREATE OR REPLACE FUNCTION generar_alertas_stock() RETURNS void AS $$
BEGIN
  -- Limpiar alertas resueltas antiguas (>30 días)
  DELETE FROM alertas_stock WHERE resuelta AND resuelta_at < NOW() - INTERVAL '30 days';
  
  -- Alertas de stock bajo
  INSERT INTO alertas_stock (vehiculo_id, producto_id, tipo_alerta, mensaje, nivel, cantidad_actual, cantidad_minima)
  SELECT 
    sv.vehiculo_id,
    sv.producto_id,
    CASE WHEN sv.cantidad_actual = 0 THEN 'sin_stock' ELSE 'stock_bajo' END,
    p.nombre || ': ' || sv.cantidad_actual || '/' || sm.cantidad_minima,
    CASE WHEN sv.cantidad_actual = 0 THEN 'critical' ELSE 'warning' END,
    sv.cantidad_actual,
    sm.cantidad_minima
  FROM stock_vehiculo sv
  JOIN vehiculos v ON sv.vehiculo_id = v.id
  JOIN productos p ON sv.producto_id = p.id
  JOIN stock_minimo_por_tipo sm ON sm.producto_id = p.id AND sm.tipo_vehiculo = v.tipo
  WHERE sv.cantidad_actual < sm.cantidad_minima
    AND NOT EXISTS (
      SELECT 1 FROM alertas_stock a 
      WHERE a.vehiculo_id = sv.vehiculo_id 
        AND a.producto_id = sv.producto_id 
        AND a.tipo_alerta IN ('sin_stock', 'stock_bajo')
        AND NOT a.resuelta
    );
  
  -- Alertas de caducidad
  INSERT INTO alertas_stock (vehiculo_id, producto_id, tipo_alerta, mensaje, nivel, fecha_caducidad, cantidad_actual)
  SELECT 
    sv.vehiculo_id,
    sv.producto_id,
    CASE 
      WHEN sv.fecha_caducidad < CURRENT_DATE THEN 'caducado'
      ELSE 'caducidad_proxima'
    END,
    p.nombre || ' caduca: ' || sv.fecha_caducidad,
    CASE 
      WHEN sv.fecha_caducidad < CURRENT_DATE THEN 'critical'
      WHEN sv.fecha_caducidad < CURRENT_DATE + INTERVAL '7 days' THEN 'critical'
      ELSE 'warning'
    END,
    sv.fecha_caducidad,
    sv.cantidad_actual
  FROM stock_vehiculo sv
  JOIN productos p ON sv.producto_id = p.id
  WHERE sv.fecha_caducidad IS NOT NULL
    AND sv.fecha_caducidad < CURRENT_DATE + INTERVAL '30 days'
    AND sv.cantidad_actual > 0
    AND NOT EXISTS (
      SELECT 1 FROM alertas_stock a 
      WHERE a.vehiculo_id = sv.vehiculo_id 
        AND a.producto_id = sv.producto_id 
        AND a.tipo_alerta IN ('caducado', 'caducidad_proxima')
        AND NOT a.resuelta
    );
END;
$$ LANGUAGE plpgsql;
```

---

## 📱 ESTRUCTURA FLUTTER - BLoC

### Estructura de carpetas
```
lib/
├── features/
│   └── stock/
│       ├── data/
│       │   ├── models/
│       │   │   ├── producto_model.dart
│       │   │   ├── stock_vehiculo_model.dart
│       │   │   ├── movimiento_stock_model.dart
│       │   │   ├── categoria_equipamiento_model.dart
│       │   │   ├── revision_mensual_model.dart
│       │   │   └── alerta_stock_model.dart
│       │   ├── repositories/
│       │   │   ├── stock_repository.dart
│       │   │   ├── productos_repository.dart
│       │   │   └── revisiones_repository.dart
│       │   └── datasources/
│       │       └── stock_remote_datasource.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── producto.dart
│       │   │   ├── stock_vehiculo.dart
│       │   │   └── alerta.dart
│       │   └── usecases/
│       │       ├── get_stock_vehiculo.dart
│       │       ├── registrar_movimiento.dart
│       │       ├── get_alertas.dart
│       │       └── realizar_revision.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── stock_bloc.dart
│           │   ├── stock_event.dart
│           │   ├── stock_state.dart
│           │   ├── alertas_bloc.dart
│           │   └── revision_bloc.dart
│           ├── pages/
│           │   ├── stock_vehiculo_page.dart
│           │   ├── detalle_producto_page.dart
│           │   ├── movimiento_stock_page.dart
│           │   ├── alertas_page.dart
│           │   ├── revision_mensual_page.dart
│           │   └── historial_movimientos_page.dart
│           └── widgets/
│               ├── stock_item_card.dart
│               ├── categoria_expansion_tile.dart
│               ├── estado_stock_badge.dart
│               ├── alerta_card.dart
│               ├── checklist_item.dart
│               └── firma_pad.dart
```

### Modelos Dart

```dart
// lib/features/stock/data/models/producto_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'producto_model.freezed.dart';
part 'producto_model.g.dart';

@freezed
class ProductoModel with _$ProductoModel {
  const factory ProductoModel({
    required String id,
    required String categoriaId,
    String? codigo,
    required String nombre,
    String? nombreComercial,
    String? descripcion,
    @Default('unidades') String unidadMedida,
    @Default(false) bool requiereRefrigeracion,
    @Default(false) bool tieneCaducidad,
    @Default(30) int diasAlertaCaducidad,
    String? ubicacionDefault,
    @Default(true) bool activo,
  }) = _ProductoModel;

  factory ProductoModel.fromJson(Map<String, dynamic> json) =>
      _$ProductoModelFromJson(json);
}

// lib/features/stock/data/models/stock_vehiculo_model.dart
@freezed
class StockVehiculoModel with _$StockVehiculoModel {
  const factory StockVehiculoModel({
    required String id,
    required String vehiculoId,
    required String productoId,
    required int cantidadActual,
    int? cantidadMinima,
    DateTime? fechaCaducidad,
    String? lote,
    String? ubicacion,
    String? observaciones,
    // Campos de la vista
    String? productoNombre,
    String? nombreComercial,
    String? categoriaCodigo,
    String? categoriaNombre,
    String? estadoStock, // 'ok', 'bajo', 'sin_stock'
    String? estadoCaducidad, // 'ok', 'proximo', 'critico', 'caducado'
  }) = _StockVehiculoModel;

  factory StockVehiculoModel.fromJson(Map<String, dynamic> json) =>
      _$StockVehiculoModelFromJson(json);
}

// lib/features/stock/data/models/movimiento_stock_model.dart
enum TipoMovimiento { entrada, salida, ajuste, caducidad, transferencia }

@freezed
class MovimientoStockModel with _$MovimientoStockModel {
  const factory MovimientoStockModel({
    required String id,
    String? stockVehiculoId,
    required String vehiculoId,
    required String productoId,
    required TipoMovimiento tipoMovimiento,
    required int cantidad,
    int? cantidadAnterior,
    int? cantidadNueva,
    String? motivo,
    String? referencia,
    String? vehiculoDestinoId,
    String? usuarioId,
    required DateTime createdAt,
    // Campos join
    String? productoNombre,
    String? vehiculoMatricula,
  }) = _MovimientoStockModel;

  factory MovimientoStockModel.fromJson(Map<String, dynamic> json) =>
      _$MovimientoStockModelFromJson(json);
}

// lib/features/stock/data/models/alerta_stock_model.dart
enum TipoAlerta { stockBajo, sinStock, caducidadProxima, caducado }
enum NivelAlerta { info, warning, critical }

@freezed
class AlertaStockModel with _$AlertaStockModel {
  const factory AlertaStockModel({
    required String id,
    required String vehiculoId,
    required String productoId,
    required TipoAlerta tipoAlerta,
    required String mensaje,
    @Default(NivelAlerta.warning) NivelAlerta nivel,
    DateTime? fechaCaducidad,
    int? cantidadActual,
    int? cantidadMinima,
    @Default(false) bool resuelta,
    DateTime? resueltaAt,
    required DateTime createdAt,
    // Campos join
    String? productoNombre,
    String? vehiculoMatricula,
  }) = _AlertaStockModel;

  factory AlertaStockModel.fromJson(Map<String, dynamic> json) =>
      _$AlertaStockModelFromJson(json);
}
```

### BLoC de Stock

```dart
// lib/features/stock/presentation/bloc/stock_event.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_event.freezed.dart';

@freezed
class StockEvent with _$StockEvent {
  // Cargar stock de un vehículo
  const factory StockEvent.loadStockVehiculo(String vehiculoId) = _LoadStockVehiculo;
  
  // Filtrar por categoría
  const factory StockEvent.filtrarPorCategoria(String? categoriaId) = _FiltrarPorCategoria;
  
  // Buscar producto
  const factory StockEvent.buscarProducto(String query) = _BuscarProducto;
  
  // Registrar entrada
  const factory StockEvent.registrarEntrada({
    required String vehiculoId,
    required String productoId,
    required int cantidad,
    String? lote,
    DateTime? fechaCaducidad,
    String? motivo,
  }) = _RegistrarEntrada;
  
  // Registrar salida
  const factory StockEvent.registrarSalida({
    required String vehiculoId,
    required String productoId,
    required int cantidad,
    String? motivo,
    String? referencia,
  }) = _RegistrarSalida;
  
  // Ajustar stock
  const factory StockEvent.ajustarStock({
    required String vehiculoId,
    required String productoId,
    required int nuevaCantidad,
    required String motivo,
  }) = _AjustarStock;
  
  // Transferir entre vehículos
  const factory StockEvent.transferirStock({
    required String vehiculoOrigenId,
    required String vehiculoDestinoId,
    required String productoId,
    required int cantidad,
  }) = _TransferirStock;
  
  // Actualizar caducidad
  const factory StockEvent.actualizarCaducidad({
    required String stockId,
    required DateTime fechaCaducidad,
    String? lote,
  }) = _ActualizarCaducidad;
}

// lib/features/stock/presentation/bloc/stock_state.dart
@freezed
class StockState with _$StockState {
  const factory StockState({
    @Default(StockStatus.initial) StockStatus status,
    @Default([]) List<StockVehiculoModel> items,
    @Default([]) List<CategoriaEquipamientoModel> categorias,
    String? categoriaSeleccionada,
    String? busqueda,
    String? vehiculoId,
    String? errorMessage,
    // Resumen
    @Default(0) int totalItems,
    @Default(0) int itemsBajoStock,
    @Default(0) int itemsProximosCaducar,
    @Default(0) int itemsCaducados,
  }) = _StockState;
}

enum StockStatus { initial, loading, loaded, error, saving, saved }

// lib/features/stock/presentation/bloc/stock_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  final StockRepository _stockRepository;
  
  StockBloc({required StockRepository stockRepository})
      : _stockRepository = stockRepository,
        super(const StockState()) {
    on<_LoadStockVehiculo>(_onLoadStockVehiculo);
    on<_FiltrarPorCategoria>(_onFiltrarPorCategoria);
    on<_BuscarProducto>(_onBuscarProducto);
    on<_RegistrarEntrada>(_onRegistrarEntrada);
    on<_RegistrarSalida>(_onRegistrarSalida);
    on<_AjustarStock>(_onAjustarStock);
    on<_TransferirStock>(_onTransferirStock);
  }

  Future<void> _onLoadStockVehiculo(
    _LoadStockVehiculo event,
    Emitter<StockState> emit,
  ) async {
    emit(state.copyWith(status: StockStatus.loading, vehiculoId: event.vehiculoId));
    
    try {
      final items = await _stockRepository.getStockVehiculo(event.vehiculoId);
      final categorias = await _stockRepository.getCategorias();
      
      emit(state.copyWith(
        status: StockStatus.loaded,
        items: items,
        categorias: categorias,
        totalItems: items.length,
        itemsBajoStock: items.where((i) => i.estadoStock == 'bajo' || i.estadoStock == 'sin_stock').length,
        itemsProximosCaducar: items.where((i) => i.estadoCaducidad == 'proximo' || i.estadoCaducidad == 'critico').length,
        itemsCaducados: items.where((i) => i.estadoCaducidad == 'caducado').length,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StockStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRegistrarEntrada(
    _RegistrarEntrada event,
    Emitter<StockState> emit,
  ) async {
    emit(state.copyWith(status: StockStatus.saving));
    
    try {
      await _stockRepository.registrarMovimiento(
        vehiculoId: event.vehiculoId,
        productoId: event.productoId,
        tipo: 'entrada',
        cantidad: event.cantidad,
        lote: event.lote,
        fechaCaducidad: event.fechaCaducidad,
        motivo: event.motivo,
      );
      
      emit(state.copyWith(status: StockStatus.saved));
      
      // Recargar stock
      add(StockEvent.loadStockVehiculo(event.vehiculoId));
    } catch (e) {
      emit(state.copyWith(
        status: StockStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
  
  // ... implementar resto de handlers
}
```

### Repository

```dart
// lib/features/stock/data/repositories/stock_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class StockRepository {
  final SupabaseClient _supabase;
  
  StockRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<List<StockVehiculoModel>> getStockVehiculo(String vehiculoId) async {
    final response = await _supabase
        .from('v_stock_vehiculo_estado')
        .select()
        .eq('vehiculo_id', vehiculoId)
        .order('categoria_codigo')
        .order('producto_nombre');
    
    return (response as List)
        .map((json) => StockVehiculoModel.fromJson(json))
        .toList();
  }

  Future<List<CategoriaEquipamientoModel>> getCategorias() async {
    final response = await _supabase
        .from('categorias_equipamiento')
        .select()
        .order('orden');
    
    return (response as List)
        .map((json) => CategoriaEquipamientoModel.fromJson(json))
        .toList();
  }

  Future<void> registrarMovimiento({
    required String vehiculoId,
    required String productoId,
    required String tipo,
    required int cantidad,
    String? lote,
    DateTime? fechaCaducidad,
    String? motivo,
  }) async {
    await _supabase.rpc('registrar_movimiento_stock', params: {
      'p_vehiculo_id': vehiculoId,
      'p_producto_id': productoId,
      'p_tipo': tipo,
      'p_cantidad': cantidad,
      'p_lote': lote,
      'p_fecha_caducidad': fechaCaducidad?.toIso8601String(),
      'p_motivo': motivo,
      'p_usuario_id': _supabase.auth.currentUser?.id,
    });
  }

  Future<List<AlertaStockModel>> getAlertasVehiculo(String vehiculoId) async {
    final response = await _supabase
        .from('alertas_stock')
        .select('*, productos(nombre)')
        .eq('vehiculo_id', vehiculoId)
        .eq('resuelta', false)
        .order('nivel', ascending: false)
        .order('created_at', ascending: false);
    
    return (response as List)
        .map((json) => AlertaStockModel.fromJson(json))
        .toList();
  }

  Future<List<MovimientoStockModel>> getHistorialMovimientos({
    String? vehiculoId,
    String? productoId,
    DateTime? desde,
    DateTime? hasta,
    int limit = 50,
  }) async {
    var query = _supabase
        .from('movimientos_stock')
        .select('*, productos(nombre), vehiculos(matricula)');
    
    if (vehiculoId != null) query = query.eq('vehiculo_id', vehiculoId);
    if (productoId != null) query = query.eq('producto_id', productoId);
    if (desde != null) query = query.gte('created_at', desde.toIso8601String());
    if (hasta != null) query = query.lte('created_at', hasta.toIso8601String());
    
    final response = await query
        .order('created_at', ascending: false)
        .limit(limit);
    
    return (response as List)
        .map((json) => MovimientoStockModel.fromJson(json))
        .toList();
  }
}
```

---

## 🖼️ WIDGETS UI

### Card de Item de Stock
```dart
// lib/features/stock/presentation/widgets/stock_item_card.dart
class StockItemCard extends StatelessWidget {
  final StockVehiculoModel item;
  final VoidCallback? onTap;
  final VoidCallback? onAddPressed;
  final VoidCallback? onRemovePressed;

  const StockItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onAddPressed,
    this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Indicador de estado
              _buildEstadoIndicador(),
              const SizedBox(width: 12),
              
              // Info del producto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productoNombre ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (item.nombreComercial != null)
                      Text(
                        item.nombreComercial!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildCantidadChip(),
                        if (item.fechaCaducidad != null) ...[
                          const SizedBox(width: 8),
                          _buildCaducidadChip(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Botones +/-
              if (onRemovePressed != null)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: item.cantidadActual > 0 ? onRemovePressed : null,
                  color: Colors.red[400],
                ),
              if (onAddPressed != null)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: onAddPressed,
                  color: Colors.green[400],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoIndicador() {
    Color color;
    IconData icon;
    
    switch (item.estadoStock) {
      case 'sin_stock':
        color = Colors.red;
        icon = Icons.error;
        break;
      case 'bajo':
        color = Colors.orange;
        icon = Icons.warning;
        break;
      default:
        if (item.estadoCaducidad == 'caducado') {
          color = Colors.red;
          icon = Icons.event_busy;
        } else if (item.estadoCaducidad == 'critico' || item.estadoCaducidad == 'proximo') {
          color = Colors.orange;
          icon = Icons.schedule;
        } else {
          color = Colors.green;
          icon = Icons.check_circle;
        }
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildCantidadChip() {
    final esBajo = item.estadoStock == 'bajo' || item.estadoStock == 'sin_stock';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: esBajo ? Colors.red[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: esBajo ? Colors.red[200]! : Colors.blue[200]!,
        ),
      ),
      child: Text(
        '${item.cantidadActual}/${item.cantidadMinima ?? 0}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: esBajo ? Colors.red[700] : Colors.blue[700],
        ),
      ),
    );
  }

  Widget _buildCaducidadChip() {
    if (item.fechaCaducidad == null) return const SizedBox.shrink();
    
    final diasRestantes = item.fechaCaducidad!.difference(DateTime.now()).inDays;
    Color color;
    
    if (diasRestantes < 0) {
      color = Colors.red;
    } else if (diasRestantes < 7) {
      color = Colors.red;
    } else if (diasRestantes < 30) {
      color = Colors.orange;
    } else {
      color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            DateFormat('MM/yy').format(item.fechaCaducidad!),
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
```

### Página de Stock del Vehículo
```dart
// lib/features/stock/presentation/pages/stock_vehiculo_page.dart
class StockVehiculoPage extends StatelessWidget {
  final String vehiculoId;
  final String? vehiculoNombre;

  const StockVehiculoPage({
    super.key,
    required this.vehiculoId,
    this.vehiculoNombre,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StockBloc(
        stockRepository: context.read<StockRepository>(),
      )..add(StockEvent.loadStockVehiculo(vehiculoId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(vehiculoNombre ?? 'Stock'),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => _navigateToAlertas(context),
            ),
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => _navigateToHistorial(context),
            ),
          ],
        ),
        body: BlocBuilder<StockBloc, StockState>(
          builder: (context, state) {
            if (state.status == StockStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state.status == StockStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.errorMessage ?? 'Error al cargar stock'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<StockBloc>()
                          .add(StockEvent.loadStockVehiculo(vehiculoId)),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            
            return Column(
              children: [
                // Resumen superior
                _buildResumenCard(state),
                
                // Buscador
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar producto...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    onChanged: (value) => context.read<StockBloc>()
                        .add(StockEvent.buscarProducto(value)),
                  ),
                ),
                
                // Filtros por categoría
                _buildCategoriaChips(context, state),
                
                // Lista de items
                Expanded(
                  child: _buildStockList(context, state),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddProductoSheet(context),
          icon: const Icon(Icons.add),
          label: const Text('Añadir'),
        ),
      ),
    );
  }

  Widget _buildResumenCard(StockState state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildResumenItem('Total', state.totalItems.toString(), Icons.inventory_2),
          _buildResumenItem('Bajo stock', state.itemsBajoStock.toString(), Icons.warning, 
              color: state.itemsBajoStock > 0 ? Colors.orange : null),
          _buildResumenItem('Caducados', state.itemsCaducados.toString(), Icons.event_busy,
              color: state.itemsCaducados > 0 ? Colors.red : null),
        ],
      ),
    );
  }

  Widget _buildResumenItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriaChips(BuildContext context, StockState state) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.categorias.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('Todos'),
                selected: state.categoriaSeleccionada == null,
                onSelected: (_) => context.read<StockBloc>()
                    .add(const StockEvent.filtrarPorCategoria(null)),
              ),
            );
          }
          
          final categoria = state.categorias[index - 1];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(categoria.codigo),
              selected: state.categoriaSeleccionada == categoria.id,
              onSelected: (_) => context.read<StockBloc>()
                  .add(StockEvent.filtrarPorCategoria(categoria.id)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStockList(BuildContext context, StockState state) {
    // Agrupar por categoría
    final itemsPorCategoria = <String, List<StockVehiculoModel>>{};
    for (final item in state.items) {
      final key = item.categoriaCodigo ?? 'Otros';
      itemsPorCategoria.putIfAbsent(key, () => []).add(item);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: itemsPorCategoria.length,
      itemBuilder: (context, index) {
        final categoria = itemsPorCategoria.keys.elementAt(index);
        final items = itemsPorCategoria[categoria]!;
        
        return ExpansionTile(
          title: Text(
            '${items.first.categoriaNombre ?? categoria}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text('${items.length} productos'),
          initiallyExpanded: index == 0,
          children: items.map((item) => StockItemCard(
            item: item,
            onTap: () => _navigateToDetalle(context, item),
            onAddPressed: () => _showAddStockDialog(context, item),
            onRemovePressed: () => _showRemoveStockDialog(context, item),
          )).toList(),
        );
      },
    );
  }
  
  // ... métodos de navegación y diálogos
}
```

---

## 📊 DATOS INICIALES - PRODUCTOS

Te proporciono un script SQL con los productos de los 3 tipos de ambulancia. ¿Quieres que lo genere completo para importar directamente en Supabase?

---

## 🚀 PASOS SIGUIENTES

1. **Ejecutar migraciones SQL** en Supabase
2. **Importar datos iniciales** de productos y stock mínimo
3. **Implementar BLoCs** siguiendo la estructura
4. **Crear páginas** de stock, alertas y revisiones
5. **Conectar con módulo de vehículos** existente

¿Necesitas que genere alguna parte específica con más detalle?
