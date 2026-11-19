// =====================================================
// EDGE FUNCTION: enviar-push
// Envía por Firebase Cloud Messaging (HTTP v1) una notificación de
// `tnotificaciones` a los móviles registrados de su destinatario.
//
// La llama el trigger `trg_encolar_push_notificacion` (pg_net) con
// { notificacion_id }. Sin JWT (verify_jwt = false): es segura porque
// - solo envía notificaciones que ya existen, a su propio destinatario
// - cada notificación se envía UNA vez (marca push_enviado_at)
//
// Secreto requerido: FCM_SERVICE_ACCOUNT (JSON de la cuenta de servicio de Firebase).
// Sin él la función no hace nada (push desactivado) y lo deja en el log.
//
// Deploy: supabase functions deploy enviar-push --no-verify-jwt
// =====================================================

import { createClient, SupabaseClient } from 'jsr:@supabase/supabase-js@2';

interface CuentaServicio {
  project_id: string;
  client_email: string;
  private_key: string;
}

interface Notificacion {
  id: string;
  usuario_destino_id: string;
  tipo: string;
  titulo: string;
  mensaje: string;
  entidad_tipo: string | null;
  entidad_id: string | null;
  metadata: Record<string, unknown> | null;
}

function json(status: number, body: Record<string, unknown>): Response {
  return new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json' } });
}

// ---------------------------------------------------------------------------
// OAuth2 de Google con la cuenta de servicio (JWT RS256 firmado con WebCrypto)
// ---------------------------------------------------------------------------

let tokenCache: { valor: string; caduca: number } | null = null;

function base64url(datos: ArrayBuffer | string): string {
  const bytes = typeof datos === 'string' ? new TextEncoder().encode(datos) : new Uint8Array(datos);
  let bin = '';
  bytes.forEach((b) => (bin += String.fromCharCode(b)));
  return btoa(bin).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

async function tokenGoogle(cuenta: CuentaServicio): Promise<string> {
  const ahora = Math.floor(Date.now() / 1000);
  if (tokenCache && tokenCache.caduca - 60 > ahora) {
    return tokenCache.valor;
  }

  const cabecera = base64url(JSON.stringify({ alg: 'RS256', typ: 'JWT' }));
  const cuerpo = base64url(JSON.stringify({
    iss: cuenta.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    iat: ahora,
    exp: ahora + 3600,
  }));
  const pem = cuenta.private_key.replace(/-----[^-]+-----/g, '').replace(/\s+/g, '');
  const der = Uint8Array.from(atob(pem), (c) => c.charCodeAt(0));
  const clave = await crypto.subtle.importKey(
    'pkcs8', der, { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' }, false, ['sign'],
  );
  const firma = await crypto.subtle.sign('RSASSA-PKCS1-v1_5', clave, new TextEncoder().encode(`${cabecera}.${cuerpo}`));

  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: `${cabecera}.${cuerpo}.${base64url(firma)}`,
    }),
  });
  if (!res.ok) {
    throw new Error(`OAuth Google ${res.status}: ${await res.text()}`);
  }
  const datos = await res.json();
  tokenCache = { valor: datos.access_token, caduca: ahora + (datos.expires_in ?? 3600) };
  return tokenCache.valor;
}

// ---------------------------------------------------------------------------
// Mensaje
// ---------------------------------------------------------------------------

/** Mismos canales Android que crea la app (LocalNotificationsService) */
function canalAndroid(n: Notificacion): string {
  if (n.tipo === 'alerta') return 'emergencias_v5';
  if (n.tipo.startsWith('traslado_')) return 'traslados_v5';
  if (n.tipo === 'alerta_caducidad') return 'caducidades_v5';
  if (n.tipo === 'incidencia_vehiculo_reportada') {
    const prioridad = n.metadata?.['prioridad'];
    return prioridad === 'critica' || prioridad === 'alta' ? 'emergencias_v5' : 'traslados_v5';
  }
  return 'info_v5';
}

function mensajeFcm(n: Notificacion, token: string): Record<string, unknown> {
  return {
    message: {
      token,
      notification: { title: n.titulo, body: n.mensaje },
      // data: solo strings
      data: {
        notificacion_id: n.id,
        tipo: n.tipo,
        entidad_tipo: n.entidad_tipo ?? '',
        entidad_id: n.entidad_id ?? '',
      },
      android: {
        priority: 'HIGH',
        notification: { channel_id: canalAndroid(n), sound: 'default' },
      },
      apns: {
        headers: { 'apns-priority': '10' },
        payload: { aps: { sound: 'default' } },
      },
    },
  };
}

/**
 * true = token muerto → hay que borrarlo. Solo errores que señalan al TOKEN:
 * 404/UNREGISTERED (app desinstalada, token caducado) o 400 "not a valid FCM
 * registration token". Un INVALID_ARGUMENT genérico suele ser un fallo del
 * mensaje: borrar el token ahí dejaba al móvil sin push sin motivo.
 */
function tokenInvalido(status: number, cuerpo: string): boolean {
  return status === 404 || /UNREGISTERED/.test(cuerpo) || (status === 400 && /registration token/i.test(cuerpo));
}

async function enviar(admin: SupabaseClient, cuenta: CuentaServicio, n: Notificacion): Promise<Record<string, number>> {
  const { data: dispositivos } = await admin
    .from('dispositivos_push')
    .select('id, token')
    .eq('usuario_id', n.usuario_destino_id);

  const resumen = { enviados: 0, fallidos: 0, borrados: 0 };
  if (!dispositivos || dispositivos.length === 0) {
    return resumen;
  }

  const accessToken = await tokenGoogle(cuenta);
  const url = `https://fcm.googleapis.com/v1/projects/${cuenta.project_id}/messages:send`;

  await Promise.all(dispositivos.map(async (d: { id: string; token: string }) => {
    const res = await fetch(url, {
      method: 'POST',
      headers: { Authorization: `Bearer ${accessToken}`, 'Content-Type': 'application/json' },
      body: JSON.stringify(mensajeFcm(n, d.token)),
    });
    if (res.ok) {
      resumen.enviados++;
      return;
    }
    const cuerpo = await res.text();
    if (tokenInvalido(res.status, cuerpo)) {
      console.warn(`🗑️ FCM ${res.status}: token del dispositivo ${d.id} borrado: ${cuerpo}`);
      await admin.from('dispositivos_push').delete().eq('id', d.id);
      resumen.borrados++;
    } else {
      resumen.fallidos++;
      console.error(`❌ FCM ${res.status} para dispositivo ${d.id}: ${cuerpo}`);
    }
  }));
  return resumen;
}

// ---------------------------------------------------------------------------
// Entrada
// ---------------------------------------------------------------------------

Deno.serve(async (req) => {
  if (req.method !== 'POST') {
    return json(405, { error: 'Método no permitido' });
  }

  try {
    const { notificacion_id: id } = await req.json();
    if (typeof id !== 'string' || !/^[0-9a-f-]{36}$/i.test(id)) {
      return json(400, { error: 'notificacion_id no válido' });
    }

    const secreto = Deno.env.get('FCM_SERVICE_ACCOUNT');
    if (!secreto) {
      console.warn('⚠️ FCM_SERVICE_ACCOUNT no configurado: push desactivado');
      return json(200, { ok: false, motivo: 'push_no_configurado' });
    }
    const cuenta = JSON.parse(secreto) as CuentaServicio;

    const admin = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    // Reclamar la notificación de forma atómica: solo se envía una vez
    const { data: notificacion } = await admin
      .from('tnotificaciones')
      .update({ push_enviado_at: new Date().toISOString() })
      .eq('id', id)
      .is('push_enviado_at', null)
      .select('id, usuario_destino_id, tipo, titulo, mensaje, entidad_tipo, entidad_id, metadata')
      .maybeSingle();

    if (!notificacion) {
      return json(200, { ok: true, motivo: 'ya_enviada_o_inexistente' });
    }

    const resumen = await enviar(admin, cuenta, notificacion as Notificacion);
    console.log(`📲 Push ${id}: ${JSON.stringify(resumen)}`);
    return json(200, { ok: true, ...resumen });
  } catch (e) {
    console.error('❌ Error en enviar-push:', e);
    return json(500, { error: 'Error al enviar el push' });
  }
});
