// =====================================================
// EDGE FUNCTION: resetear-clave
// Restablece la clave de otro usuario (PIN de la app móvil o contraseña web).
// Solo gestión: admin, jefe_personal, jefe_trafico, coordinador.
// La service_role nunca sale del servidor.
//
// Deploy: supabase functions deploy resetear-clave
// =====================================================

import { createClient } from 'jsr:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const ROLES_GESTION = ['admin', 'jefe_personal', 'jefe_trafico', 'coordinador'];

function respuesta(status: number, body: Record<string, unknown>): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }
  if (req.method !== 'POST') {
    return respuesta(405, { error: 'Método no permitido' });
  }

  try {
    const url = Deno.env.get('SUPABASE_URL')!;
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const authHeader = req.headers.get('Authorization') ?? '';

    // 1. Quién llama
    const cliente = createClient(url, anonKey, { global: { headers: { Authorization: authHeader } } });
    const { data: { user }, error: errorUser } = await cliente.auth.getUser();
    if (errorUser || !user) {
      return respuesta(401, { error: 'Sesión no válida' });
    }

    const admin = createClient(url, serviceKey);
    const { data: llamante } = await admin.from('usuarios').select('rol, activo').eq('id', user.id).maybeSingle();
    if (!llamante || llamante.activo === false || !ROLES_GESTION.includes(llamante.rol)) {
      return respuesta(403, { error: 'No tienes permiso para restablecer claves' });
    }

    // 2. Datos
    const { user_id: userId, password } = await req.json();
    if (typeof userId !== 'string' || typeof password !== 'string' || password.length < 6) {
      return respuesta(400, { error: 'Datos no válidos: la clave debe tener al menos 6 caracteres' });
    }

    // 3. Cambio de clave con la API de administración
    const { error } = await admin.auth.admin.updateUserById(userId, { password });
    if (error) {
      console.error('❌ Error al restablecer clave:', error.message);
      return respuesta(400, { error: error.message });
    }

    console.log(`✅ Clave restablecida para ${userId} por ${user.id}`);
    return respuesta(200, { ok: true });
  } catch (e) {
    console.error('❌ Error inesperado:', e);
    return respuesta(500, { error: 'Error inesperado al restablecer la clave' });
  }
});
