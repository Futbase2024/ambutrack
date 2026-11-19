-- =============================================================
-- MIGRACIÓN: Importar vehículos legacy (CADIZ - BARBATE)
-- Fuente: ambutrack_registros_vehiculos_normalizado.json
-- Fecha: 2026-06-10
-- Registros: 92
-- =============================================================

DO $$
DECLARE
  v_empresa_id UUID := '00000000-0000-0000-0000-000000000001';
  v_proxima_itv DATE := CURRENT_DATE + INTERVAL '1 year';
  v_venc_seguro DATE := CURRENT_DATE + INTERVAL '1 year';
  v_venc_homolog DATE := CURRENT_DATE + INTERVAL '2 years';
  existing_count INT;
  inserted_count INT := 0;
BEGIN

-- Verificar que la empresa existe
  SELECT COUNT(*) INTO existing_count FROM empresas WHERE id = v_empresa_id;
  IF existing_count = 0 THEN
    RAISE NOTICE '⚠ Empresa % no encontrada. Abortando.', v_empresa_id;
    RETURN;
  END IF;

  -- Contar vehículos existentes antes de insertar
  SELECT COUNT(*) INTO existing_count FROM tvehiculos;
  RAISE NOTICE '📊 Vehículos existentes antes de importar: %', existing_count;

  INSERT INTO public.tvehiculos (
    matricula,
    tipo_vehiculo,
    estado,
    marca,
    modelo,
    anio_fabricacion,
    numero_bastidor,
    capacidad_camilla,
    capacidad_pasajeros,
    empresa_id,
    categoria,
    clasificacion,
    proxima_itv,
    fecha_vencimiento_seguro,
    homologacion_sanitaria,
    fecha_vencimiento_homologacion,
    numero_interno,
    ubicacion_actual,
    equipamiento,
    observaciones
  ) VALUES
    ('0084MHG', 'CONVENCIONAL', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2023, 'WV1ZZZSY6P9050693', 1, 0, v_empresa_id, 'AMBULANCIA', 'A1 UR', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '12227', 'BARBATE (URG)', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('0152MHG', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2023, 'WV1ZZZSY6P9050692', 1, 1, v_empresa_id, 'AMBULANCIA', 'A1', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '12226', 'BARBATE (URG)', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('0242MHG', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2023, 'WV1ZZZSYXP9050680', 1, 1, v_empresa_id, 'AMBULANCIA', 'A1', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '12225', 'BARBATE (URG)', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('0303LNR', 'COLECTIVA', 'activo', 'RENAULT', 'MASTER', 2021, 'VF6VF000066341997', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11431', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Azul", "puertas_laterales": 2, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('0312LNR', 'COLECTIVA', 'activo', 'RENAULT', 'MASTER', 2021, 'VF6VF000566342000', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11432', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Azul", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('0538MYC', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER 2.5 TDI', 2025, 'WV1ZZZSY7S9004944', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '13095', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Azul", "puertas_laterales": 1, "altura_techo": "ALTO", "peso": "> 3.500 Kg."}'::jsonb, 'Zona: CADIZ'),
    ('0570MYC', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER 2.5 TDI', 2025, 'WV1ZZZSY4S9004674', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '13094', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Azul", "puertas_laterales": 1, "altura_techo": "ALTO", "peso": "> 3.500 Kg."}'::jsonb, 'Zona: CADIZ'),
    ('0600MYC', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER 2.5 TDI', 2025, 'WV1ZZZSYOS9004753', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '13093', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Azul", "puertas_laterales": 1, "altura_techo": "ALTO", "peso": "> 3.500 Kg."}'::jsonb, 'Zona: CADIZ'),
    ('0808KHT', 'COLECTIVA', 'activo', 'RENAULT', 'MASTER', 2018, 'VF1MA000257636334', 1, 1, v_empresa_id, 'AMBULANCIA', 'A1', '2050-12-31', v_venc_seguro, 'PENDIENTE', '2050-12-31', '11113', 'BARBATE (URG)', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('0815JTT', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER', 0, 'WV1ZZZ2EZG6034291', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11084', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 1, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('0840JTT', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WV1ZZZ2EZG6033644', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11085', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 1, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('0859JTT', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WV1ZZZ2EZG6033759', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11086', 'BARBATE', '{"combustible": "Gasolina", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('0885JTT', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER 2.5 TDI', 0, 'WV1ZZZ2EZG6034428', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11087', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('1029JTT', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WV1ZZZ2EZG6034437', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11088', 'BARBATE', '{"combustible": "Gasolina", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('1052JTT', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WV1ZZZ2EZG6034290', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11089', 'BARBATE', '{"combustible": "Gasolina", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('1206KGT', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER 2.5 TDI', 0, 'WV1ZZZ2EZG6039123', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11100', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 1, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('1279JWD', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WDB9067331P305030', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11090', 'BARBATE', '{"combustible": "Gasolina", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('1475JWD', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WDB9067331P304681', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11091', 'BARBATE', '{"combustible": "Gasolina", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('1476JWD', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WDB9067331P301960', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11092', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('1479JWD', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WDB9067331P295095', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11093', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('1577JJN', 'UVI MOVIL', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WV1ZZZ2EZF6020131', 1, 0, v_empresa_id, 'AMBULANCIA', 'C', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11115', 'BARBATE', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('1987KHB', 'COLECTIVA', 'baja', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'VF3YBTMRB12141678', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11075', 'BARBATE', '{"combustible": "Gasolina", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('1993HKB', 'COLECTIVA', 'baja', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'VF3YBTMRB12142824', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11076', 'BARBATE', '{"combustible": "Gasolina", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('2006HKB', 'COLECTIVA', 'baja', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'VF3YBTMRB12143370', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11077', 'BARBATE', '{"combustible": "Gasolina", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('2006JSC', 'UVI MOVIL', 'activo', 'RENAULT', 'MASTER', 2016, 'VF1MAF4VE51164762', 1, 0, v_empresa_id, 'AMBULANCIA', 'C', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '12632', 'BARBATE (URG)', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "ALTO", "peso": "> 3.500 Kg."}'::jsonb, 'Zona: CADIZ'),
    ('2017HKB', 'COLECTIVA', 'baja', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'VF3YBTMRB12147482', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11078', 'BARBATE', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('2444GWZ', 'COLECTIVA', 'baja', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'VF3YCBMFC11761461', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11124', 'BARBATE', '{"combustible": "Gasolina", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('2485LTG', 'UVI MOVIL', 'activo', 'MAN', 'DESCONOCIDO', 0, 'WMA03VUY6M9013117', 1, 0, v_empresa_id, 'AMBULANCIA', 'C', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11699', 'BARBATE (URG)', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Azul", "puertas_laterales": 2, "altura_techo": "ALTO", "peso": "<= 3.500 Kg."}'::jsonb, 'Zona: CADIZ'),
    ('2648JNG', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 2018, 'VF1MAFEYC54473834', 1, 1, v_empresa_id, 'AMBULANCIA', 'A1', '2050-12-31', v_venc_seguro, 'PENDIENTE', '2050-12-31', '11103', 'BARBATE', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('2650JNG', 'UVI MOVIL', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'VF1MAFEYC54473835', 1, 0, v_empresa_id, 'AMBULANCIA', 'B', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11101', 'BARBATE (URG)', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('2656JNG', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 2018, 'VF1MAFEYC54473836', 1, 1, v_empresa_id, 'AMBULANCIA', 'A1', '2050-12-31', v_venc_seguro, 'PENDIENTE', '2050-12-31', '11104', 'BARBATE (URG)', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('2865JJM', 'UVI MOVIL', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WV1ZZZ2EZF6020132', 1, 0, v_empresa_id, 'AMBULANCIA', 'C', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11116', 'BARBATE (URG)', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('2965LVZ', 'COLECTIVA', 'activo', 'RENAULT', 'MASTER', 0, 'SIN BASTIDOR', 1, 1, v_empresa_id, 'AMBULANCIA', 'A1', '2050-12-31', v_venc_seguro, 'PENDIENTE', '2050-12-31', '11690', 'BARBATE (URG)', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('2993JJM', 'UVI MOVIL', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WV1ZZZ2EZF6028561', 1, 0, v_empresa_id, 'AMBULANCIA', 'C', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11117', 'BARBATE', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('3007NDC', 'UVI MOVIL', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WMA03VUY3S9004789', 1, 0, v_empresa_id, 'AMBULANCIA', 'C', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '13318', 'BARBATE (URG)', '{"combustible": "Gasolina", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('3014LVZ', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'SIN BASTIDOR', 1, 1, v_empresa_id, 'AMBULANCIA', 'A1', '2050-12-31', v_venc_seguro, 'PENDIENTE', '2050-12-31', '11691', 'BARBATE (URG)', '{"combustible": "Gasolina", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('3087NDC', 'UVI MOVIL', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WMA03VUY0S9004944', 1, 0, v_empresa_id, 'AMBULANCIA', 'C', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '13319', 'BARBATE (URG)', '{"combustible": "Gasolina", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('3112HJD', 'UVI MOVIL', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WV1ZZZ2EZB6009547', 1, 0, v_empresa_id, 'AMBULANCIA', 'B', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11102', 'BARBATE', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('3161GZZ', 'COLECTIVA', 'baja', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'VF3YCDMFC11729396', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11126', 'BARBATE', '{"combustible": "Gasolina", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('3249NDC', 'UVI MOVIL', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WMA03VUYXS9004594', 1, 0, v_empresa_id, 'AMBULANCIA', 'C', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '13320', 'BARBATE (URG)', '{"combustible": "Gasolina", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('3369JLR', 'UVI MOVIL', 'activo', 'VOLKSWAGEN', 'CRAFTER 2.5 TDI', 0, 'WV1ZZZSYZJ9047972', 1, 0, v_empresa_id, 'AMBULANCIA', 'C', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11131', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('3401NDC', 'UVI MOVIL', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WMA03VUY1S9004869', 1, 0, v_empresa_id, 'AMBULANCIA', 'C', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '13321', 'BARBATE (URG)', '{"combustible": "Gasolina", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('3521JJN', 'UVI MOVIL', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WDB9066331S985888', 1, 0, v_empresa_id, 'AMBULANCIA', 'C', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11118', 'BARBATE', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('3762LMF', 'COLECTIVA', 'activo', 'RENAULT', 'MASTER', 0, 'VF6VF000466341999', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11277', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Azul", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('3764LMF', 'COLECTIVA', 'activo', 'RENAULT', 'MASTER', 0, 'VF6VF000266341998', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11278', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 1, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('3765LMF', 'COLECTIVA', 'activo', 'RENAULT', 'MASTER', 0, 'VF6VF000766342001', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11279', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('4430KHS', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 2018, 'VF1MA000557636344', 1, 1, v_empresa_id, 'AMBULANCIA', 'A1', '2050-12-31', v_venc_seguro, 'PENDIENTE', '2050-12-31', '11112', 'BARBATE (URG)', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('4616JYW', 'UVI MOVIL', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WDB9066331P340646', 1, 0, v_empresa_id, 'AMBULANCIA', 'C', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11121', 'BARBATE', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('4618JYW', 'UVI MOVIL', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WDB9066331P348929', 1, 0, v_empresa_id, 'AMBULANCIA', 'C', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11122', 'BARBATE', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('5323MBR', 'UVI MOVIL', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2022, 'WV1ZZZSYZM9057299', 1, 0, v_empresa_id, 'AMBULANCIA', 'C', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11955', 'BARBATE (URG)', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Azul", "puertas_laterales": 2, "altura_techo": "ALTO", "peso": "<= 3.500 Kg."}'::jsonb, 'Zona: CADIZ'),
    ('5342MBR', 'UVI MOVIL', 'activo', 'VOLKSWAGEN', 'CRAFTER', 0, 'WV1ZZZSYZM9057401', 1, 0, v_empresa_id, 'AMBULANCIA', 'C', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11956', 'BARBATE (URG)', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('5619LSZ', 'UVI MOVIL', 'activo', 'MAN', 'XX', 0, 'WMA03VUY3M9020302', 1, 0, v_empresa_id, 'AMBULANCIA', 'C', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11688', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 2, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('5771JZT', 'UVI MOVIL', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WV1ZZZ2EZG6022278', 1, 0, v_empresa_id, 'AMBULANCIA', 'C', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11123', 'BARBATE (URG)', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('6053KHL', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 2018, 'VF1MA000757636278', 1, 1, v_empresa_id, 'AMBULANCIA', 'A1', '2050-12-31', v_venc_seguro, 'PENDIENTE', '2050-12-31', '11105', 'BARBATE', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('6131KHL', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 2018, 'VF1MA000457636335', 1, 1, v_empresa_id, 'AMBULANCIA', 'A1', '2050-12-31', v_venc_seguro, 'PENDIENTE', '2050-12-31', '11106', 'BARBATE (URG)', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('6160HCJ', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'VF3YBBMFB11903963', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11072', 'BARBATE', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('6167HCJ', 'COLECTIVA', 'baja', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'VF3YBBMFB11903659', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11073', 'BARBATE', '{"combustible": "Gasolina", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('6177KHL', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 2018, 'VF1MA000557636280', 1, 1, v_empresa_id, 'AMBULANCIA', 'A1', '2050-12-31', v_venc_seguro, 'PENDIENTE', '2050-12-31', '11107', 'BARBATE', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('6182HCJ', 'COLECTIVA', 'baja', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'VF3YBBMFB11903717', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11074', 'BARBATE', '{"combustible": "Gasolina", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('6211KHL', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 2018, 'VF1MA000357636343', 1, 1, v_empresa_id, 'AMBULANCIA', 'A1', '2050-12-31', v_venc_seguro, 'PENDIENTE', '2050-12-31', '11108', 'BARBATE', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('6219KHL', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 2018, 'VF1MA000557636330', 1, 1, v_empresa_id, 'AMBULANCIA', 'A1', '2050-12-31', v_venc_seguro, 'PENDIENTE', '2050-12-31', '11109', 'BARBATE (URG)', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('6255KHL', 'COLECTIVA', 'activo', 'RENAULT', 'MASTER', 2018, 'VF1MA000657636336', 1, 1, v_empresa_id, 'AMBULANCIA', 'A1', '2050-12-31', v_venc_seguro, 'PENDIENTE', '2050-12-31', '11110', 'BARBATE', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('6262KHL', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 2018, 'VF1MA000757636328', 1, 1, v_empresa_id, 'AMBULANCIA', 'A1', '2050-12-31', v_venc_seguro, 'PENDIENTE', '2050-12-31', '11111', 'BARBATE (URG)', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('6322KHV', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 2018, 'VF1MA000757636331', 1, 1, v_empresa_id, 'AMBULANCIA', 'A1', '2050-12-31', v_venc_seguro, 'PENDIENTE', '2050-12-31', '11114', 'BARBATE (URG)', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('6373LWM', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WV1ZZZSYZN9012297', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11611', 'BARBATE', '{"combustible": "Gasolina", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('6378NHZ', 'UVI MOVIL', 'activo', 'MAN', 'TGE', 2025, 'WMA03VUY1S9004452', 1, 0, v_empresa_id, 'AMBULANCIA', 'C', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '13332', 'BARBATE (URG)', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Azul", "puertas_laterales": 2, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('6383NHZ', 'UVI MOVIL', 'activo', 'MAN', 'TGE', 2025, 'WMA03VUY4S9004266', 1, 0, v_empresa_id, 'AMBULANCIA', 'C', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '13330', 'BARBATE (URG)', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('6387NHZ', 'UVI MOVIL', 'activo', 'MAN', 'TGE', 2025, 'WMA03VUY9S9004473', 1, 0, v_empresa_id, 'AMBULANCIA', 'C', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '13331', 'BARBATE (URG)', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Azul", "puertas_laterales": 2, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('6451LWM', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WV1ZZZSYZN90005597', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11614', 'BARBATE', '{"combustible": "Gasolina", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('6452LWM', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WV1ZZZSYZN9012250', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11612', 'BARBATE', '{"combustible": "Gasolina", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('6453LWM', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WV1ZZZSYZN9020651', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11613', 'BARBATE', '{"combustible": "Gasolina", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('6719LWB', 'UVI MOVIL', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'SIN BASTIDOR', 1, 0, v_empresa_id, 'AMBULANCIA', 'C', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11689', 'BARBATE (URG)', '{"combustible": "Gasolina", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('6819LDD', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WDB9067331P533075', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11127', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('6825LDD', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WDB9067331P533076', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11128', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('7332GYD', 'COLECTIVA', 'baja', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'VF3YBBMFB11761855', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11125', 'BARBATE', '{"combustible": "Gasolina", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('8646MRT', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2024, 'WV1ZZZSY7R9033712', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '12633', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "ALTO", "peso": "<= 3.500 Kg."}'::jsonb, 'Zona: CADIZ'),
    ('8679JFP', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'VF1MLJ4SC52116173', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11079', 'BARBATE', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('8681JFP', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'VF1MLJ4SC52122952', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11080', 'BARBATE', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('8683JFP', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'VF1MLJ4SC52122953', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11081', 'BARBATE', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('8684JFP', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'VF1MLJ4SC52122954', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11082', 'BARBATE', '{"combustible": "Gasolina", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('8685JFP', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'VF1MLJ4SC52122955', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11083', 'BARBATE', '{"combustible": "Gasolina", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('8831MRT', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER 2.5 TDI', 2024, 'WV1ZZZSYXR9033753', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '12634', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "ALTO", "peso": "> 3.500 Kg."}'::jsonb, 'Zona: CADIZ'),
    ('8848JMG', 'UVI MOVIL', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WV1ZZZ2EZF6028562', 1, 0, v_empresa_id, 'AMBULANCIA', 'C', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11119', 'BARBATE', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('8902JMG', 'UVI MOVIL', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WV1ZZZ2EZF6028560', 1, 0, v_empresa_id, 'AMBULANCIA', 'C', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11120', 'BARBATE (URG)', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('8915KGN', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WV1ZZZ2EZG6039386', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11094', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('8923KGN', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WV1ZZZ2EZG6039343', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11095', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('8926KGN', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WV1ZZZ2EZG6039448', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11096', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('8932KGN', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WV1ZZZ2EZG6039513', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11097', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('8991KGN', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WV1ZZZ2EZG6039449', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11098', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('9091KGN', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WV1ZZZ2EZG6039514', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11099', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('9662LJH', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 0, 'WV1ZZZSYZH9011638', 1, 1, v_empresa_id, 'AMBULANCIA', 'A2', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '11132', 'BARBATE', '{"combustible": "Gasoil", "color": "AMARILLO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ'),
    ('9932MHF', 'COLECTIVA', 'activo', 'DESCONOCIDO', 'DESCONOCIDO', 2023, 'WV1ZZZSY0P9050509', 1, 1, v_empresa_id, 'AMBULANCIA', 'A1', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog, '12228', 'BARBATE (URG)', '{"combustible": "Gasoil", "color": "BLANCO", "tipo_luces": "Ambar", "puertas_laterales": 0, "altura_techo": "Desconocida", "peso": "Desconocido"}'::jsonb, 'Zona: CADIZ')
  ON CONFLICT (matricula) DO UPDATE SET
    tipo_vehiculo = EXCLUDED.tipo_vehiculo,
    estado = EXCLUDED.estado,
    marca = EXCLUDED.marca,
    modelo = EXCLUDED.modelo,
    anio_fabricacion = EXCLUDED.anio_fabricacion,
    numero_bastidor = EXCLUDED.numero_bastidor,
    capacidad_camilla = EXCLUDED.capacidad_camilla,
    capacidad_pasajeros = EXCLUDED.capacidad_pasajeros,
    clasificacion = EXCLUDED.clasificacion,
    proxima_itv = EXCLUDED.proxima_itv,
    fecha_vencimiento_seguro = EXCLUDED.fecha_vencimiento_seguro,
    homologacion_sanitaria = EXCLUDED.homologacion_sanitaria,
    fecha_vencimiento_homologacion = EXCLUDED.fecha_vencimiento_homologacion,
    numero_interno = EXCLUDED.numero_interno,
    ubicacion_actual = EXCLUDED.ubicacion_actual,
    equipamiento = EXCLUDED.equipamiento,
    observaciones = EXCLUDED.observaciones,
    updated_at = NOW();

  -- Estadísticas finales
  SELECT COUNT(*) INTO inserted_count FROM tvehiculos;
  RAISE NOTICE '📊 Vehículos después de importar: % (insertados + actualizados)', inserted_count;

  -- Resumen por estado
  FOR existing_count IN
    SELECT COUNT(*) FROM tvehiculos WHERE estado = 'activo' GROUP BY estado
  LOOP
    RAISE NOTICE '  ✅ Activos: %', existing_count;
  END LOOP;
  FOR existing_count IN
    SELECT COUNT(*) FROM tvehiculos WHERE estado = 'baja' GROUP BY estado
  LOOP
    RAISE NOTICE '  ❌ Bajas: %', existing_count;
  END LOOP;

EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE '❌ Error durante la importación: %', SQLERRM;
END $$;

-- =============================================================
-- MAPEO DE CAMPOS LEGACY → tvehiculos
-- =============================================================
-- matricula               → matricula (directo)
-- clasificacion + colectivo → tipo_vehiculo:
--   C/B → 'UVI MOVIL'
--   colectivo=true → 'COLECTIVA'
--   else → 'CONVENCIONAL'
-- estado                  → estado (OPERATIVO→activo, BAJA→baja)
-- marca                   → marca (null→'DESCONOCIDO')
-- modelo                  → modelo (null→'DESCONOCIDO')
-- fec_matriculacion       → anio_fabricacion (año extraído)
-- no_de_bastidor          → numero_bastidor
-- colectivo               → capacidad_pasajeros (true→1, false→0)
-- id_vehiculo             → numero_interno (como texto)
-- punto_de_gestion        → ubicacion_actual
-- vto_itv                 → proxima_itv (o DEFAULT +1 año)
-- vto_seg                 → fecha_vencimiento_seguro (o DEFAULT +1 año)
-- vto_tsa                 → fecha_vencimiento_homologacion (o DEFAULT +2 años)
-- tipo_combustible, etc.  → equipamiento (JSON)
-- zona_de_gestion         → observaciones
-- Fijos: empresa_id, categoria='AMBULANCIA',
--         capacidad_camilla=1, homologacion_sanitaria='PENDIENTE'
-- =============================================================