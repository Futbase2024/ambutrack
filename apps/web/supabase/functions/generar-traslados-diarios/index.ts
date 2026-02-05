// =====================================================
// EDGE FUNCTION: generar-traslados-diarios
// Descripción: Se ejecuta automáticamente cada día para generar
// los siguientes lotes de traslados de servicios recurrentes
//
// Configuración en Supabase Dashboard:
// - Cron schedule: "0 1 * * *" (01:00 AM todos los días)
// - Secrets requeridas: SUPABASE_SERVICE_ROLE_KEY
//
// Deploy:
// supabase functions deploy generar-traslados-diarios --no-verify-jwt
//
// Autor: Sistema AmbuTrack
// Fecha: 2025-01-31
// =====================================================

import { createClient } from 'jsr:@supabase/supabase-js@2';

interface ResultadoGeneracion {
  servicios_procesados: number;
  traslados_generados: number;
  servicios_actualizados: string[];
}

// Configuración de CORS
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  // Manejar preflight CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    console.log('🚀 Iniciando generación automática de traslados...');

    // Crear cliente Supabase con service_role para ejecutar funciones PL/pgSQL
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false,
        },
      }
    );

    // Ejecutar la función PostgreSQL
    const { data, error } = await supabaseClient.rpc<ResultadoGeneracion>(
      'generar_traslados_proximos_lotes'
    );

    if (error) {
      console.error('❌ Error al ejecutar generar_traslados_proximos_lotes:', error);
      throw error;
    }

    console.log('✅ Generación completada exitosamente');
    console.log('📊 Servicios procesados:', data?.servicios_procesados ?? 0);
    console.log('📋 Traslados generados:', data?.traslados_generados ?? 0);
    console.log('📝 Detalle:', data?.servicios_actualizados ?? []);

    return new Response(
      JSON.stringify({
        success: true,
        timestamp: new Date().toISOString(),
        resultado: data,
        mensaje: `Generados ${data?.traslados_generados ?? 0} traslados para ${data?.servicios_procesados ?? 0} servicios`,
      }),
      {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json',
        },
        status: 200,
      }
    );
  } catch (err) {
    console.error('❌ Error fatal en edge function:', err);

    return new Response(
      JSON.stringify({
        success: false,
        timestamp: new Date().toISOString(),
        error: err instanceof Error ? err.message : 'Error desconocido',
      }),
      {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json',
        },
        status: 500,
      }
    );
  }
});

/* =====================================================
 * CONFIGURACIÓN DEL CRON JOB
 * =====================================================
 *
 * 1. Deploy de la función:
 *    supabase functions deploy generar-traslados-diarios --no-verify-jwt
 *
 * 2. Crear cron job en Supabase Dashboard:
 *    - Ir a "Database" → "Cron Jobs"
 *    - Click "Create a new cron job"
 *    - Schedule: "0 1 * * *" (cada día a las 01:00 AM)
 *    - SQL Command:
 *      SELECT
 *        net.http_post(
 *          url := 'https://YOUR_PROJECT_REF.supabase.co/functions/v1/generar-traslados-diarios',
 *          headers := '{"Content-Type": "application/json", "Authorization": "Bearer YOUR_ANON_KEY"}'::jsonb
 *        ) AS request_id;
 *
 * 3. Alternativa con pg_cron (más simple):
 *    SELECT cron.schedule(
 *      'generar-traslados-diarios',
 *      '0 1 * * *',
 *      $$
 *      SELECT * FROM generar_traslados_proximos_lotes();
 *      $$
 *    );
 *
 * 4. Verificar cron jobs activos:
 *    SELECT * FROM cron.job;
 *
 * 5. Ver historial de ejecuciones:
 *    SELECT * FROM cron.job_run_details
 *    ORDER BY start_time DESC
 *    LIMIT 10;
 *
 * =====================================================
 */
