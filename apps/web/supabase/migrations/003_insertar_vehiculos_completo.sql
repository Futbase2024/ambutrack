-- =====================================================
-- AMBUTRACK - INSERCIÓN DE VEHÍCULOS INICIALES (COMPLETO)
-- Archivo: 003_insertar_vehiculos_completo.sql
-- Descripción: Inserción masiva de 88 vehículos con todos los campos NOT NULL
-- Fecha: 2025-12-16
-- =====================================================

DO $$
DECLARE
    v_empresa_id UUID := '00000000-0000-0000-0000-000000000001';
    v_proxima_itv DATE := CURRENT_DATE + INTERVAL '1 year';
    v_venc_seguro DATE := CURRENT_DATE + INTERVAL '1 year';
    v_venc_homolog DATE := CURRENT_DATE + INTERVAL '2 years';
BEGIN
    -- =====================================================
    -- INSERCIÓN MASIVA DE 88 VEHÍCULOS
    -- =====================================================
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
        proxima_itv,
        fecha_vencimiento_seguro,
        homologacion_sanitaria,
        fecha_vencimiento_homologacion
    ) VALUES
    -- Vehículos 1-10
    ('0084GMG', 'CONVENCIONAL', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2023, 'WV1ZZZ0G6PG050651', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('0152MIG', 'CONVENCIONAL', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2023, 'WV1ZZZ0G9PG050692', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('0242MHG', 'CONVENCIONAL', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2023, 'WV1ZZZ0V8PG050680', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('0301NR', 'COLECTIVA', 'activo', 'RENAULT', 'MASTER', 2021, 'VF6VP00D266341997', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),    
    ('0338MYL', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER 2.5 TDI', 2025, 'WV1ZZZ0FS9G060844', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('0570MYC', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER 2.5 TDI', 2025, 'WV1ZZZ0HS9G060674', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('0600MYF', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER 2.5 TDI', 2025, 'WV1ZZZ0NG9G060753', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('0808KHT', 'CONVENCIONAL', 'activo', 'RENAULT', 'MASTER', 2022, 'VF1MA00D27G36334', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('0815JYT', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2020, 'WV1ZZZ0EG6G32491', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),

    -- Vehículos 11-20
    ('0840JTT', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2020, 'WV1ZZZ0EG6G33644', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('0850JTT', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2020, 'WV1ZZZ0EG6G39759', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('0885JTT', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER 2.5 TDI', 2020, 'WV1ZZZ0EG6G34428', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('1029JTT', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2020, 'WV1ZZZ0EG6G34437', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('1052JTT', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2020, 'WV1ZZZ0EG6G34290', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('1206KGY', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER 2.5 TDI', 2020, 'WV1ZZZ0EG6G39123', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('1279JWD', 'COLECTIVA', 'activo', 'MERCEDES', 'SPRINTER', 2020, 'WDB9G7331H9G0590', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('1475JWD', 'COLECTIVA', 'activo', 'MERCEDES', 'SPRINTER', 2020, 'WDB9G7331H9G0681', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('1476JWD', 'COLECTIVA', 'activo', 'MERCEDES', 'SPRINTER', 2020, 'WDB9G7331H9G1960', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('1977JN', 'UVI MÓVIL', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2020, 'WV1ZZZ0EF6G20131', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),

    -- Vehículos 21-30
    ('1987KHB', 'COLECTIVA', 'baja', 'FIAT', 'DUCATO', 2022, 'VF3YBIMBR12141678', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('1993KHG', 'COLECTIVA', 'baja', 'FIAT', 'DUCATO', 2022, 'VF3YBIMBR12142824', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('2006RHX', 'COLECTIVA', 'baja', 'FIAT', 'DUCATO', 2022, 'VF3YBIMBR12143370', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('2040JSC', 'UVI MÓVIL', 'activo', 'RENAULT', 'MASTER', 2024, 'VF1MA6AVES11461262', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('2017JKR', 'COLECTIVA', 'baja', 'FIAT', 'DUCATO', 2022, 'VF3YBIMBR12147482', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('2444GXV', 'UVI MÓVIL', 'activo', 'FIAT', 'DUCATO', 2021, 'VF3CBMFCL17G1461', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('2485LTG', 'UVI MÓVIL', 'activo', 'MAN', 'TGE', 2022, 'WMAJ3VJVEM9D11117', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('2644JRG', 'CONVENCIONAL', 'activo', 'RENAULT', 'MASTER', 2022, 'VF1MA6EXCS4473834', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('2650JNG', 'UVI MÓVIL', 'activo', 'RENAULT', 'MASTER', 2020, 'VF1MA6EXCS4473835', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('2665JNG', 'CONVENCIONAL', 'activo', 'RENAULT', 'MASTER', 2022, 'VF1MA6EXCS4473836', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),

    -- Vehículos 31-40
    ('2865JJM', 'UVI MÓVIL', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2020, 'WV1ZZZ0F6G020132', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('2906LKZ', 'CONVENCIONAL', 'activo', 'RENAULT', 'MASTER', 2022, 'VF1MA6AVES11461263', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('2981KMY', 'UVI MÓVIL', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2020, 'WV1ZZZ0F6G028561', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('3007NDC', 'UVI MÓVIL', 'activo', 'MAN', 'TGE', 2025, 'WMAJ3VJV1S9D04789', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('3014JXZ', 'CONVENCIONAL', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2022, 'WV1ZZZ0EG6G050547', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('3087NDC', 'UVI MÓVIL', 'activo', 'MAN', 'TGE', 2025, 'WMAJ3VJV0S9D04944', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('3112JXD', 'UVI MÓVIL', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2020, 'WV1ZZZ0EG6G050567', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('3161GZZ', 'COLECTIVA', 'baja', 'FIAT', 'DUCATO', 2021, 'VF3YCBMFCL1729396', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('3240JNC', 'UVI MÓVIL', 'activo', 'MAN', 'TGE', 2025, 'WMAJ3VJV0S9D04594', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('3369JLR', 'UVI MÓVIL', 'activo', 'VOLKSWAGEN', 'CRAFTER 2.5 TDI', 2020, 'WV1ZZZ0V9D047972', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),

    -- Vehículos 41-50
    ('3403MGC', 'UVI MÓVIL', 'activo', 'MAN', 'TGE', 2025, 'WMAJ3VJV1S9D04869', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('3521JJN', 'UVI MÓVIL', 'activo', 'MERCEDES', 'SPRINTER', 2020, 'WDB9G6331H9R5888', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('3782JXN', 'COLECTIVA', 'activo', 'RENAULT', 'MASTER', 2021, 'VF6VP00D46G43H99', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('3764LMF', 'COLECTIVA', 'activo', 'RENAULT', 'MASTER', 2021, 'VF6VP00D266341998', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('3765LMF', 'COLECTIVA', 'activo', 'RENAULT', 'MASTER', 2021, 'VF6VP00D266340701', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('4370JRS', 'CONVENCIONAL', 'activo', 'RENAULT', 'MASTER', 2022, 'VF1MA00DS7G36344', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('4618JTW', 'UVI MÓVIL', 'activo', 'MERCEDES', 'SPRINTER', 2020, 'WDB9G6331H9R4688', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('4618JTW_DUP', 'UVI MÓVIL', 'activo', 'MERCEDES', 'SPRINTER', 2020, 'WDB9G6331H9R3929', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('5323MBR', 'UVI MÓVIL', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2023, 'WV1ZZZ0VXH0S7299', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('5342MBR', 'UVI MÓVIL', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2023, 'WV1ZZZ0V0H0S7401', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),

    -- Vehículos 51-60
    ('5619LSZ', 'UVI MÓVIL', 'activo', 'MAN', 'TGE', 2022, 'WMAJ3VJ0EM9D20302', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('5771JLF', 'UVI MÓVIL', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2020, 'WV1ZZZ0F6G022278', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('6053GHL', 'CONVENCIONAL', 'activo', 'RENAULT', 'MASTER', 2022, 'VF1MA00D57G36278', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('6131KHL', 'CONVENCIONAL', 'activo', 'RENAULT', 'MASTER', 2022, 'VF1MA00D57G36335', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('6150HCJ', 'COLECTIVA', 'activo', 'FIAT', 'DUCATO', 2020, 'VF3YBIMBRF11003963', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('6167JLC', 'COLECTIVA', 'baja', 'FIAT', 'DUCATO', 2021, 'VF3YBIMBF11003659', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('6177KHL', 'CONVENCIONAL', 'activo', 'RENAULT', 'MASTER', 2022, 'VF1MA00D57G36280', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('6184FXD', 'COLECTIVA', 'baja', 'FIAT', 'DUCATO', 2021, 'VF3YBIMBF11003717', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('6211KHL', 'CONVENCIONAL', 'activo', 'RENAULT', 'MASTER', 2022, 'VF1MA00D57G36343', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('6215KHL', 'CONVENCIONAL', 'activo', 'RENAULT', 'MASTER', 2022, 'VF1MA00D57G36230', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),

    -- Vehículos 61-70
    ('6255KHL', 'CONVENCIONAL', 'activo', 'RENAULT', 'MASTER', 2022, 'VF1MA00D57G36336', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('6262KHL', 'CONVENCIONAL', 'activo', 'RENAULT', 'MASTER', 2022, 'VF1MA00D57R36328', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('6323GND', 'CONVENCIONAL', 'activo', 'RENAULT', 'MASTER', 2022, 'VF1MA00D57R36331', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('6371LMW', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2022, 'WV1ZZZ0VRJ011297', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('6851LMW', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2022, 'WV1ZZZ0V8J0050597', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('6852LMW', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2022, 'WV1ZZZ0VRJ011250', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('6853LMW', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2022, 'WV1ZZZ0V8J0020651', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('6719LWB', 'UVI MÓVIL', 'activo', 'MERCEDES', 'SPRINTER', 2022, 'WDB9G7331H9R4869', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('6819LDD', 'UVI MÓVIL', 'activo', 'MERCEDES', 'SPRINTER', 2022, 'WDB9G7331H9R4875', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('7331GXD', 'COLECTIVA', 'baja', 'MERCEDES', 'SPRINTER', 2020, 'WDB9G7331H9533075', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),

    -- Vehículos 71-80
    ('6825LDD', 'COLECTIVA', 'baja', 'MERCEDES', 'SPRINTER', 2020, 'WDB9G7331H9533076', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('7336ZVD', 'COLECTIVA', 'baja', 'FIAT', 'DUCATO', 2021, 'VF3YBIMBF11741855', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('8646MRT', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2024, 'WV1ZZZ0V7RJ033712', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('8670JLP', 'COLECTIVA', 'activo', 'RENAULT', 'MASTER', 2020, 'VF1ML4XCS2L16173', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('8681JBP', 'CONVENCIONAL', 'activo', 'RENAULT', 'MASTER', 2020, 'VF1ML4XCS2L22852', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('8684JBP', 'COLECTIVA', 'activo', 'RENAULT', 'MASTER', 2020, 'VF1ML4XCS2L22953', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('8684JBP_DUP2', 'COLECTIVA', 'activo', 'RENAULT', 'MASTER', 2020, 'VF1ML4XCS2L22954', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('8685JBP', 'COLECTIVA', 'activo', 'RENAULT', 'MASTER', 2020, 'VF1ML4XCS2L22955', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('8848JMG', 'UVI MÓVIL', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2020, 'WV1ZZZ0EG6028562', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('8920JMG', 'UVI MÓVIL', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2024, 'WV1ZZZ0EG6028560', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),

    -- Vehículos 81-88
    ('8915KGN', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2020, 'WV1ZZZ0EG6G039386', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('8923KGN', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2020, 'WV1ZZZ0EG6G039363', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('8926KGN', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2020, 'WV1ZZZ0EG6G039448', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('8932KGN', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2020, 'WV1ZZZ0EG6G039513', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('8991KGN', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2020, 'WV1ZZZ0EG6G039449', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('9021KGN', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2020, 'WV1ZZZ0EG6G039514', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('9682LRH', 'COLECTIVA', 'activo', 'VOLKSWAGEN', 'CRAFTER 2.5 TDI', 2020, 'WV1ZZZ0VHJ011638', 1, 1, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog),
    ('9932MHF', 'CONVENCIONAL', 'activo', 'VOLKSWAGEN', 'CRAFTER', 2023, 'WV1ZZZ0R9PG050509', 1, 0, v_empresa_id, 'AMBULANCIA', v_proxima_itv, v_venc_seguro, 'PENDIENTE', v_venc_homolog);

    RAISE NOTICE '✅ Se han insertado 88 vehículos exitosamente';
    RAISE NOTICE 'Empresa ID: %', v_empresa_id;
    RAISE NOTICE 'Próxima ITV por defecto: %', v_proxima_itv;
    RAISE NOTICE 'Vencimiento seguro por defecto: %', v_venc_seguro;
    RAISE NOTICE 'Vencimiento homologación por defecto: %', v_venc_homolog;
END $$;
