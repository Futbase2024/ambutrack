// =====================================================
// EDGE FUNCTION: admin-users
// Gestión de cuentas de usuario con la API de administración (service_role).
//
// Quién puede hacer qué (se valida AQUÍ, en servidor):
// - admin          → todo, cualquier rol, cualquier empresa
// - jefe_personal  → crear / editar / restablecer clave / activar usuarios
//                    con rol operativo y de SU empresa. No elimina.
// - cualquiera     → change_own_password (cambiar su propia clave)
//
// Acciones: create, update, reset_password, set_active, delete, change_own_password
// Toda alta o restablecimiento deja la clave como provisional
// (usuarios.debe_cambiar_password = true).
//
// Deploy: supabase functions deploy admin-users
// =====================================================

import { createClient, SupabaseClient } from 'jsr:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const ROLES_VALIDOS = [
  'admin', 'administrativo', 'conductor', 'coordinador', 'jefe_mantenimiento',
  'jefe_personal', 'jefe_trafico', 'operador', 'sanitario', 'tecnico',
];

/** Roles que el jefe de personal puede crear y gestionar */
const ROLES_OPERATIVOS = ['administrativo', 'conductor', 'operador', 'sanitario', 'tecnico'];

const GESTORES = ['admin', 'jefe_personal'];

interface Llamante {
  id: string;
  email: string | null;
  rol: string;
  empresa_id: string | null;
}

interface Objetivo {
  id: string;
  rol: string;
  empresa_id: string | null;
  email: string | null;
}

class ErrorHttp extends Error {
  constructor(public status: number, message: string) {
    super(message);
  }
}

function respuesta(status: number, body: Record<string, unknown>): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

// ---------------------------------------------------------------------------
// Reglas de permisos
// ---------------------------------------------------------------------------

function exigirGestor(llamante: Llamante): void {
  if (!GESTORES.includes(llamante.rol)) {
    throw new ErrorHttp(403, 'No tienes permiso para gestionar usuarios');
  }
}

function exigirRolAsignable(llamante: Llamante, rol: unknown): string {
  if (typeof rol !== 'string' || !ROLES_VALIDOS.includes(rol)) {
    throw new ErrorHttp(400, 'Rol no válido');
  }
  if (llamante.rol !== 'admin' && !ROLES_OPERATIVOS.includes(rol)) {
    throw new ErrorHttp(403, `No puedes asignar el rol "${rol}"`);
  }
  return rol;
}

function exigirPuedeActuarSobre(llamante: Llamante, objetivo: Objetivo): void {
  if (llamante.rol === 'admin') {
    return;
  }
  const mismaEmpresa = llamante.empresa_id !== null && llamante.empresa_id === objetivo.empresa_id;
  if (!ROLES_OPERATIVOS.includes(objetivo.rol) || !mismaEmpresa) {
    throw new ErrorHttp(403, 'No tienes permiso para gestionar este usuario');
  }
}

/** El jefe de personal siempre trabaja en su empresa; el admin elige */
function empresaDestino(llamante: Llamante, empresaId: unknown): string | null {
  if (llamante.rol !== 'admin') {
    if (!llamante.empresa_id) {
      throw new ErrorHttp(403, 'Tu usuario no tiene empresa asignada');
    }
    return llamante.empresa_id;
  }
  return typeof empresaId === 'string' && empresaId.length > 0 ? empresaId : null;
}

// ---------------------------------------------------------------------------
// Validaciones de datos
// ---------------------------------------------------------------------------

function texto(valor: unknown): string | null {
  return typeof valor === 'string' && valor.trim().length > 0 ? valor.trim() : null;
}

function exigirTexto(valor: unknown, campo: string): string {
  const t = texto(valor);
  if (!t) {
    throw new ErrorHttp(400, `El campo ${campo} es obligatorio`);
  }
  return t;
}

function exigirClave(valor: unknown): string {
  if (typeof valor !== 'string' || valor.length < 6 || valor.length > 72) {
    throw new ErrorHttp(400, 'La clave debe tener entre 6 y 72 caracteres');
  }
  return valor;
}

function exigirId(valor: unknown): string {
  if (typeof valor !== 'string' || !/^[0-9a-f-]{36}$/i.test(valor)) {
    throw new ErrorHttp(400, 'Identificador de usuario no válido');
  }
  return valor;
}

/** Traduce errores de Postgres / Auth a mensajes comprensibles */
function mensajeError(mensaje: string): string {
  const m = mensaje.toLowerCase();
  if (m.includes('already been registered') || m.includes('already registered') || m.includes('email_exists')) {
    return 'Ya existe un usuario con ese email';
  }
  if (m.includes('usuarios_dni_key') || (m.includes('duplicate key') && m.includes('dni'))) {
    return 'Ya existe un usuario con ese DNI';
  }
  if (m.includes('foreign key') || m.includes('violates')) {
    return 'El usuario tiene registros asociados y no se puede eliminar. Desactívalo en su lugar.';
  }
  return mensaje;
}

// ---------------------------------------------------------------------------
// Auditoría (la service_role no tiene auth.uid(): registramos quién lo hizo)
// ---------------------------------------------------------------------------

async function auditar(
  admin: SupabaseClient,
  llamante: Llamante,
  accion: 'INSERT' | 'UPDATE' | 'DELETE',
  objetivoId: string,
  empresaId: string | null,
  detalle: Record<string, unknown>,
): Promise<void> {
  const { error } = await admin.from('audit_log').insert({
    empresa_id: empresaId,
    tabla: 'usuarios',
    registro_id: objetivoId,
    accion,
    usuario_id: llamante.id,
    usuario_email: llamante.email,
    datos_despues: { ...detalle, realizado_por_rol: llamante.rol },
  });
  if (error) {
    console.error('⚠️ No se pudo registrar la auditoría:', error.message);
  }
}

async function cargarObjetivo(admin: SupabaseClient, id: string): Promise<Objetivo> {
  const { data, error } = await admin
    .from('usuarios')
    .select('id, rol, empresa_id, email')
    .eq('id', id)
    .maybeSingle();
  if (error || !data) {
    throw new ErrorHttp(404, 'Usuario no encontrado');
  }
  return data as Objetivo;
}

// ---------------------------------------------------------------------------
// Acciones
// ---------------------------------------------------------------------------

async function crear(admin: SupabaseClient, llamante: Llamante, p: Record<string, unknown>): Promise<Response> {
  exigirGestor(llamante);
  const email = exigirTexto(p.email, 'email').toLowerCase();
  const clave = exigirClave(p.password);
  const nombre = exigirTexto(p.nombre, 'nombre');
  const apellidos = texto(p.apellidos);
  const rol = exigirRolAsignable(llamante, p.rol);
  const empresaId = empresaDestino(llamante, p.empresa_id);

  const { data: creado, error: errorAuth } = await admin.auth.admin.createUser({
    email,
    password: clave,
    email_confirm: true,
    user_metadata: { nombre, apellidos },
  });
  if (errorAuth || !creado.user) {
    throw new ErrorHttp(400, mensajeError(errorAuth?.message ?? 'No se pudo crear la cuenta'));
  }
  const id = creado.user.id;

  // El trigger on_auth_user_created ya insertó la fila básica: la completamos
  const { error: errorPerfil } = await admin
    .from('usuarios')
    .update({
      nombre,
      apellidos,
      dni: texto(p.dni)?.toUpperCase() ?? null,
      telefono: texto(p.telefono),
      rol,
      empresa_id: empresaId,
      personal_id: texto(p.personal_id),
      activo: p.activo !== false,
      debe_cambiar_password: true,
    })
    .eq('id', id);

  if (errorPerfil) {
    await admin.auth.admin.deleteUser(id); // rollback: no dejar cuentas a medias
    throw new ErrorHttp(400, mensajeError(errorPerfil.message));
  }

  if (p.activo === false) {
    await admin.auth.admin.updateUserById(id, { ban_duration: '876000h' });
  }

  await auditar(admin, llamante, 'INSERT', id, empresaId, { operacion: 'alta_usuario', email, rol });
  console.log(`✅ Usuario ${email} (${rol}) creado por ${llamante.id}`);
  return respuesta(201, { ok: true, user_id: id });
}

async function actualizar(admin: SupabaseClient, llamante: Llamante, p: Record<string, unknown>): Promise<Response> {
  exigirGestor(llamante);
  const objetivo = await cargarObjetivo(admin, exigirId(p.user_id));
  exigirPuedeActuarSobre(llamante, objetivo);
  const rol = exigirRolAsignable(llamante, p.rol);
  const empresaId = empresaDestino(llamante, p.empresa_id);
  const activo = p.activo !== false;

  if (objetivo.id === llamante.id && (rol !== objetivo.rol || !activo)) {
    throw new ErrorHttp(400, 'No puedes cambiar tu propio rol ni desactivarte');
  }

  const { error } = await admin
    .from('usuarios')
    .update({
      nombre: exigirTexto(p.nombre, 'nombre'),
      apellidos: texto(p.apellidos),
      dni: texto(p.dni)?.toUpperCase() ?? null,
      telefono: texto(p.telefono),
      rol,
      empresa_id: empresaId,
      activo,
      ...(p.personal_id !== undefined ? { personal_id: texto(p.personal_id) } : {}),
    })
    .eq('id', objetivo.id);
  if (error) {
    throw new ErrorHttp(400, mensajeError(error.message));
  }

  await admin.auth.admin.updateUserById(objetivo.id, { ban_duration: activo ? 'none' : '876000h' });
  await auditar(admin, llamante, 'UPDATE', objetivo.id, empresaId, { operacion: 'edicion_usuario', rol, activo });
  return respuesta(200, { ok: true });
}

async function restablecerClave(admin: SupabaseClient, llamante: Llamante, p: Record<string, unknown>): Promise<Response> {
  exigirGestor(llamante);
  const objetivo = await cargarObjetivo(admin, exigirId(p.user_id));
  exigirPuedeActuarSobre(llamante, objetivo);
  const clave = exigirClave(p.password);

  const { error } = await admin.auth.admin.updateUserById(objetivo.id, { password: clave });
  if (error) {
    throw new ErrorHttp(400, mensajeError(error.message));
  }
  await admin.from('usuarios').update({ debe_cambiar_password: true }).eq('id', objetivo.id);

  await auditar(admin, llamante, 'UPDATE', objetivo.id, objetivo.empresa_id, { operacion: 'restablecer_clave' });
  return respuesta(200, { ok: true });
}

async function cambiarEstado(admin: SupabaseClient, llamante: Llamante, p: Record<string, unknown>): Promise<Response> {
  exigirGestor(llamante);
  const objetivo = await cargarObjetivo(admin, exigirId(p.user_id));
  exigirPuedeActuarSobre(llamante, objetivo);
  const activo = p.activo === true;
  if (objetivo.id === llamante.id && !activo) {
    throw new ErrorHttp(400, 'No puedes desactivar tu propio usuario');
  }

  const { error } = await admin.from('usuarios').update({ activo }).eq('id', objetivo.id);
  if (error) {
    throw new ErrorHttp(400, mensajeError(error.message));
  }
  // Baneado = no puede iniciar sesión ni refrescar el token
  await admin.auth.admin.updateUserById(objetivo.id, { ban_duration: activo ? 'none' : '876000h' });

  await auditar(admin, llamante, 'UPDATE', objetivo.id, objetivo.empresa_id, {
    operacion: activo ? 'activar_usuario' : 'desactivar_usuario',
  });
  return respuesta(200, { ok: true });
}

async function eliminar(admin: SupabaseClient, llamante: Llamante, p: Record<string, unknown>): Promise<Response> {
  if (llamante.rol !== 'admin') {
    throw new ErrorHttp(403, 'Solo un administrador puede eliminar usuarios');
  }
  const objetivo = await cargarObjetivo(admin, exigirId(p.user_id));
  if (objetivo.id === llamante.id) {
    throw new ErrorHttp(400, 'No puedes eliminar tu propio usuario');
  }

  // Borra auth.users → la fila de usuarios cae por ON DELETE CASCADE
  const { error } = await admin.auth.admin.deleteUser(objetivo.id);
  if (error) {
    throw new ErrorHttp(400, mensajeError(error.message));
  }
  await auditar(admin, llamante, 'DELETE', objetivo.id, objetivo.empresa_id, {
    operacion: 'eliminar_usuario',
    email: objetivo.email,
  });
  return respuesta(200, { ok: true });
}

async function cambiarClavePropia(admin: SupabaseClient, llamante: Llamante, p: Record<string, unknown>): Promise<Response> {
  const clave = exigirClave(p.password);
  const { error } = await admin.auth.admin.updateUserById(llamante.id, { password: clave });
  if (error) {
    throw new ErrorHttp(400, mensajeError(error.message));
  }
  await admin.from('usuarios').update({ debe_cambiar_password: false }).eq('id', llamante.id);
  await auditar(admin, llamante, 'UPDATE', llamante.id, llamante.empresa_id, { operacion: 'cambio_clave_propia' });
  return respuesta(200, { ok: true });
}

// ---------------------------------------------------------------------------
// Entrada
// ---------------------------------------------------------------------------

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

    // 1. Quién llama (JWT verificado por Supabase Auth)
    const cliente = createClient(url, anonKey, {
      global: { headers: { Authorization: req.headers.get('Authorization') ?? '' } },
    });
    const { data: { user }, error: errorUser } = await cliente.auth.getUser();
    if (errorUser || !user) {
      return respuesta(401, { error: 'Sesión no válida' });
    }

    const admin = createClient(url, serviceKey, { auth: { autoRefreshToken: false, persistSession: false } });
    const { data: perfil } = await admin
      .from('usuarios')
      .select('rol, activo, empresa_id')
      .eq('id', user.id)
      .maybeSingle();
    if (!perfil || perfil.activo === false) {
      return respuesta(403, { error: 'Usuario no autorizado' });
    }
    const llamante: Llamante = { id: user.id, email: user.email ?? null, rol: perfil.rol, empresa_id: perfil.empresa_id };

    // 2. Acción
    const payload = (await req.json()) as Record<string, unknown>;
    switch (payload.action) {
      case 'create':
        return await crear(admin, llamante, payload);
      case 'update':
        return await actualizar(admin, llamante, payload);
      case 'reset_password':
        return await restablecerClave(admin, llamante, payload);
      case 'set_active':
        return await cambiarEstado(admin, llamante, payload);
      case 'delete':
        return await eliminar(admin, llamante, payload);
      case 'change_own_password':
        return await cambiarClavePropia(admin, llamante, payload);
      default:
        return respuesta(400, { error: 'Acción no válida' });
    }
  } catch (e) {
    if (e instanceof ErrorHttp) {
      return respuesta(e.status, { error: e.message });
    }
    console.error('❌ Error inesperado en admin-users:', e);
    return respuesta(500, { error: 'Error inesperado en la gestión de usuarios' });
  }
});
