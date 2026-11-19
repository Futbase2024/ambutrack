// =====================================================
// EDGE FUNCTION: resetear-clave  (LEGADO)
// Se mantiene para builds antiguas de la web. La app actual usa
// `admin-users` con action = 'reset_password'.
//
// Mismas reglas que admin-users:
// - admin          → cualquier usuario
// - jefe_personal  → solo usuarios con rol operativo de su empresa
// - resto          → prohibido
// La clave queda como provisional (debe_cambiar_password = true).
//
// Deploy: supabase functions deploy resetear-clave
// =====================================================

import { createClient } from 'jsr:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const ROLES_OPERATIVOS = ['administrativo', 'conductor', 'operador', 'sanitario', 'tecnico'];

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

    // 1. Quién llama
    const cliente = createClient(url, anonKey, {
      global: { headers: { Authorization: req.headers.get('Authorization') ?? '' } },
    });
    const { data: { user }, error: errorUser } = await cliente.auth.getUser();
    if (errorUser || !user) {
      return respuesta(401, { error: 'Sesión no válida' });
    }

    const admin = createClient(url, serviceKey, { auth: { autoRefreshToken: false, persistSession: false } });
    const { data: llamante } = await admin
      .from('usuarios')
      .select('rol, activo, empresa_id')
      .eq('id', user.id)
      .maybeSingle();
    if (!llamante || llamante.activo === false || !['admin', 'jefe_personal'].includes(llamante.rol)) {
      return respuesta(403, { error: 'No tienes permiso para restablecer claves' });
    }

    // 2. Datos
    const { user_id: userId, password } = await req.json();
    if (typeof userId !== 'string' || typeof password !== 'string' || password.length < 6 || password.length > 72) {
      return respuesta(400, { error: 'Datos no válidos: la clave debe tener entre 6 y 72 caracteres' });
    }

    // 3. Sobre quién actúa
    const { data: objetivo } = await admin
      .from('usuarios')
      .select('rol, empresa_id')
      .eq('id', userId)
      .maybeSingle();
    if (!objetivo) {
      return respuesta(404, { error: 'Usuario no encontrado' });
    }
    if (llamante.rol !== 'admin') {
      const mismaEmpresa = llamante.empresa_id !== null && llamante.empresa_id === objetivo.empresa_id;
      if (!ROLES_OPERATIVOS.includes(objetivo.rol) || !mismaEmpresa) {
        return respuesta(403, { error: 'No tienes permiso para gestionar este usuario' });
      }
    }

    // 4. Cambio de clave con la API de administración
    const { error } = await admin.auth.admin.updateUserById(userId, { password });
    if (error) {
      console.error('❌ Error al restablecer clave:', error.message);
      return respuesta(400, { error: error.message });
    }
    await admin.from('usuarios').update({ debe_cambiar_password: true }).eq('id', userId);

    console.log(`✅ Clave restablecida para ${userId} por ${user.id}`);
    return respuesta(200, { ok: true });
  } catch (e) {
    console.error('❌ Error inesperado:', e);
    return respuesta(500, { error: 'Error inesperado al restablecer la clave' });
  }
});
