// Paquete ambutrack_core_datasource
//
// Proporciona la infraestructura base para la capa de datos
// en aplicaciones Flutter empresariales.
//
// Este paquete define interfaces estándar, entidades base y utilidades
// para implementar datasources consistentes que siguen los principios
// de Clean Architecture.
//
// ## Características principales:
//
// - **Interfaces estándar**: Contratos consistentes para operaciones CRUD
// - **Múltiples backends**: Soporte para Firebase, REST APIs y más
// - **Cache integrado**: Sistema de cache automático con TTL
// - **Manejo de errores**: Excepciones estandarizadas y reintentos automáticos
// - **Tiempo real**: Soporte para streams y actualizaciones en vivo
// - **Operaciones batch**: Operaciones masivas eficientes
// - **Factory pattern**: Creación simplificada de datasources
//
// ## Uso básico:
//
// ```dart
// // Crear un datasource de Firebase
// final userDataSource = UsersDataSourceFactory.createFirebase();
//
// // Crear un datasource REST
// final userDataSource = UsersDataSourceFactory.createRest(
//   baseUrl: 'https://api.example.com',
// );
//
// // Usar el datasource
// final user = await userDataSource.getById('user123');
// final newUser = await userDataSource.create(UserEntity(...));
// ```

// Core - Clases base y interfaces principales
export 'src/core/base_entity.dart';
export 'src/core/base_datasource.dart';
export 'src/core/base_model.dart';

// Datasources - Módulos de datasources disponibles
export 'src/datasources/users/entities/users_entity.dart';
export 'src/datasources/users/users_contract.dart';
export 'src/datasources/users/users_factory.dart' show UsersDataSourceFactory, DataSourceType;

// Auth
export 'src/datasources/auth/auth_contract.dart';
export 'src/datasources/auth/auth_factory.dart' show AuthDataSourceFactory;
export 'src/datasources/auth/implementations/supabase/supabase_auth_datasource.dart';

export 'src/datasources/usuarios/entities/usuario_entity.dart';
export 'src/datasources/usuarios/usuarios_contract.dart';
export 'src/datasources/usuarios/usuarios_factory.dart' show UsuarioDataSourceFactory;

// TPersonal (tabla legacy de personal)
export 'src/datasources/tpersonal/entities/tpersonal_entity.dart';
export 'src/datasources/tpersonal/tpersonal_contract.dart';
export 'src/datasources/tpersonal/tpersonal_factory.dart' show TPersonalDataSourceFactory;

export 'src/datasources/vehiculos/entities/vehiculos_entity.dart';
export 'src/datasources/vehiculos/vehiculos_contract.dart';
export 'src/datasources/vehiculos/vehiculos_factory.dart' show VehiculoDataSourceFactory;
export 'src/datasources/vehiculos/implementations/supabase/supabase_vehiculo_datasource.dart';
export 'src/datasources/vehiculos/models/vehiculo_supabase_model.dart';

export 'src/datasources/incidencias_vehiculo/entities/incidencia_vehiculo_entity.dart';
export 'src/datasources/incidencias_vehiculo/incidencia_vehiculo_contract.dart';
export 'src/datasources/incidencias_vehiculo/incidencia_vehiculo_factory.dart';
export 'src/datasources/incidencias_vehiculo/implementations/supabase/supabase_incidencia_vehiculo_datasource.dart';
export 'src/datasources/incidencias_vehiculo/models/incidencia_vehiculo_supabase_model.dart';

export 'src/datasources/checklist_vehiculo/entities/checklist_vehiculo_entity.dart';
export 'src/datasources/checklist_vehiculo/entities/item_checklist_entity.dart';
export 'src/datasources/checklist_vehiculo/checklist_vehiculo_contract.dart';
export 'src/datasources/checklist_vehiculo/checklist_vehiculo_factory.dart' show ChecklistVehiculoDataSourceFactory;
export 'src/datasources/checklist_vehiculo/implementations/supabase/supabase_checklist_vehiculo_datasource.dart';
export 'src/datasources/checklist_vehiculo/models/checklist_vehiculo_supabase_model.dart';
export 'src/datasources/checklist_vehiculo/models/item_checklist_supabase_model.dart';

export 'src/datasources/registro_horario/entities/registro_horario_entity.dart';
export 'src/datasources/registro_horario/registro_horario_contract.dart';
export 'src/datasources/registro_horario/registro_horario_factory.dart' show RegistroHorarioDataSourceFactory;
export 'src/datasources/registro_horario/implementations/supabase/supabase_registro_horario_datasource.dart';
export 'src/datasources/registro_horario/models/registro_horario_supabase_model.dart';

export 'src/datasources/bases/entities/base_entity.dart';
export 'src/datasources/bases/bases_contract.dart';
export 'src/datasources/bases/bases_factory.dart' show BasesDataSourceFactory;
export 'src/datasources/bases/implementations/supabase/supabase_bases_datasource.dart';

export 'src/datasources/dotaciones/entities/dotacion_entity.dart';
export 'src/datasources/dotaciones/dotaciones_contract.dart';
export 'src/datasources/dotaciones/dotaciones_factory.dart' show DotacionesDataSourceFactory;
export 'src/datasources/dotaciones/implementations/supabase/supabase_dotaciones_datasource.dart';

export 'src/datasources/itv_revisiones/entities/itv_revision_entity.dart';
export 'src/datasources/itv_revisiones/itv_revision_contract.dart';
export 'src/datasources/itv_revisiones/itv_revision_factory.dart' show ItvRevisionDataSourceFactory;
export 'src/datasources/itv_revisiones/implementations/supabase/supabase_itv_revision_datasource.dart';
export 'src/datasources/itv_revisiones/models/itv_revision_supabase_model.dart';

export 'src/datasources/motivos_cancelacion/entities/motivo_cancelacion_entity.dart';
export 'src/datasources/motivos_cancelacion/motivo_cancelacion_contract.dart';
export 'src/datasources/motivos_cancelacion/motivo_cancelacion_factory.dart' show MotivoCancelacionDataSourceFactory;
export 'src/datasources/motivos_cancelacion/implementations/supabase/supabase_motivo_cancelacion_datasource.dart';
export 'src/datasources/motivos_cancelacion/models/motivo_cancelacion_supabase_model.dart';

export 'src/datasources/motivos_traslado/entities/motivo_traslado_entity.dart';
export 'src/datasources/motivos_traslado/motivo_traslado_contract.dart';
export 'src/datasources/motivos_traslado/motivo_traslado_factory.dart' show MotivoTrasladoDataSourceFactory;
export 'src/datasources/motivos_traslado/implementations/supabase/supabase_motivo_traslado_datasource.dart';
export 'src/datasources/motivos_traslado/models/motivo_traslado_supabase_model.dart';

export 'src/datasources/centros_hospitalarios/entities/centro_hospitalario_entity.dart';
export 'src/datasources/centros_hospitalarios/centro_hospitalario_contract.dart';
export 'src/datasources/centros_hospitalarios/centro_hospitalario_factory.dart' show CentroHospitalarioDataSourceFactory;
export 'src/datasources/centros_hospitalarios/implementations/supabase/supabase_centro_hospitalario_datasource.dart';
export 'src/datasources/centros_hospitalarios/models/centro_hospitalario_supabase_model.dart';

export 'src/datasources/provincias/entities/provincia_entity.dart';
export 'src/datasources/provincias/provincia_contract.dart';
export 'src/datasources/provincias/provincia_factory.dart' show ProvinciaDataSourceFactory;
export 'src/datasources/provincias/implementations/supabase/supabase_provincia_datasource.dart';
export 'src/datasources/provincias/models/provincia_supabase_model.dart';

export 'src/datasources/comunidades_autonomas/entities/comunidad_autonoma_entity.dart';
export 'src/datasources/comunidades_autonomas/comunidad_autonoma_contract.dart';
export 'src/datasources/comunidades_autonomas/comunidad_autonoma_factory.dart' show ComunidadAutonomaDataSourceFactory;
export 'src/datasources/comunidades_autonomas/implementations/supabase/supabase_comunidad_autonoma_datasource.dart';

export 'src/datasources/localidades/entities/localidad_entity.dart';
export 'src/datasources/localidades/localidad_contract.dart';
export 'src/datasources/localidades/localidad_factory.dart' show LocalidadDataSourceFactory;
export 'src/datasources/localidades/implementations/supabase/supabase_localidad_datasource.dart';
export 'src/datasources/localidades/models/localidad_supabase_model.dart';

export 'src/datasources/especialidades_medicas/entities/especialidad_entity.dart';
export 'src/datasources/especialidades_medicas/especialidad_contract.dart';
export 'src/datasources/especialidades_medicas/especialidad_factory.dart' show EspecialidadDataSourceFactory;
export 'src/datasources/especialidades_medicas/implementations/supabase/supabase_especialidad_datasource.dart';
export 'src/datasources/especialidades_medicas/models/especialidad_supabase_model.dart';

export 'src/datasources/facultativos/entities/facultativo_entity.dart';
export 'src/datasources/facultativos/facultativo_contract.dart';
export 'src/datasources/facultativos/facultativo_factory.dart' show FacultativoDataSourceFactory;
export 'src/datasources/facultativos/implementations/supabase/supabase_facultativo_datasource.dart';
export 'src/datasources/facultativos/models/facultativo_supabase_model.dart';

export 'src/datasources/tipos_paciente/entities/tipo_paciente_entity.dart';
export 'src/datasources/tipos_paciente/tipo_paciente_contract.dart';
export 'src/datasources/tipos_paciente/tipo_paciente_factory.dart' show TipoPacienteDataSourceFactory;
export 'src/datasources/tipos_paciente/implementations/supabase/supabase_tipo_paciente_datasource.dart';
export 'src/datasources/tipos_paciente/models/tipo_paciente_supabase_model.dart';

export 'src/datasources/contratos/entities/contrato_entity.dart';
export 'src/datasources/contratos/contrato_contract.dart';
export 'src/datasources/contratos/contrato_factory.dart' show ContratoDataSourceFactory;
export 'src/datasources/contratos/implementations/supabase/supabase_contrato_datasource.dart';
export 'src/datasources/contratos/models/contrato_supabase_model.dart';

export 'src/datasources/tipos_traslado/entities/tipo_traslado_entity.dart';
export 'src/datasources/tipos_traslado/tipo_traslado_contract.dart';
export 'src/datasources/tipos_traslado/tipo_traslado_factory.dart' show TipoTrasladoDataSourceFactory;
export 'src/datasources/tipos_traslado/implementations/supabase/supabase_tipo_traslado_datasource.dart';
export 'src/datasources/tipos_traslado/models/tipo_traslado_supabase_model.dart';

export 'src/datasources/tipos_vehiculo/entities/tipo_vehiculo_entity.dart';
export 'src/datasources/tipos_vehiculo/tipo_vehiculo_contract.dart';
export 'src/datasources/tipos_vehiculo/tipo_vehiculo_factory.dart' show TipoVehiculoDataSourceFactory;
export 'src/datasources/tipos_vehiculo/implementations/supabase/supabase_tipo_vehiculo_datasource.dart';
export 'src/datasources/tipos_vehiculo/models/tipo_vehiculo_supabase_model.dart';

export 'src/datasources/categorias_vehiculo/entities/categoria_vehiculo_entity.dart';
export 'src/datasources/categorias_vehiculo/categoria_vehiculo_contract.dart';
export 'src/datasources/categorias_vehiculo/categoria_vehiculo_factory.dart' show CategoriaVehiculoDataSourceFactory;
export 'src/datasources/categorias_vehiculo/implementations/supabase/supabase_categoria_vehiculo_datasource.dart';
export 'src/datasources/categorias_vehiculo/models/categoria_vehiculo_supabase_model.dart';

export 'src/datasources/turnos/entities/turno_entity.dart';
export 'src/datasources/turnos/entities/plantilla_turno_entity.dart';
export 'src/datasources/turnos/entities/solicitud_intercambio_entity.dart';
export 'src/datasources/turnos/turno_contract.dart';
export 'src/datasources/turnos/plantilla_turno_contract.dart';
export 'src/datasources/turnos/solicitud_intercambio_contract.dart';
export 'src/datasources/turnos/turno_factory.dart' show TurnoDataSourceFactory;
export 'src/datasources/turnos/plantilla_turno_factory.dart' show PlantillaTurnoDataSourceFactory;
export 'src/datasources/turnos/solicitud_intercambio_factory.dart' show SolicitudIntercambioDataSourceFactory;
export 'src/datasources/turnos/implementations/supabase/supabase_turno_datasource.dart';
export 'src/datasources/turnos/implementations/supabase/supabase_plantilla_turno_datasource.dart';
export 'src/datasources/turnos/implementations/supabase/supabase_solicitud_intercambio_datasource.dart';
export 'src/datasources/turnos/models/turno_supabase_model.dart';
export 'src/datasources/turnos/models/plantilla_turno_supabase_model.dart';
export 'src/datasources/turnos/models/solicitud_intercambio_supabase_model.dart';

export 'src/datasources/mantenimiento/entities/mantenimiento_entity.dart';
export 'src/datasources/mantenimiento/mantenimiento_contract.dart';
export 'src/datasources/mantenimiento/mantenimiento_factory.dart' show MantenimientoDataSourceFactory;
export 'src/datasources/mantenimiento/implementations/supabase/supabase_mantenimiento_datasource.dart';
export 'src/datasources/mantenimiento/models/mantenimiento_supabase_model.dart';

export 'src/datasources/excepciones_festivos/entities/excepcion_festivo_entity.dart';
export 'src/datasources/excepciones_festivos/excepciones_festivos_contract.dart';
export 'src/datasources/excepciones_festivos/excepciones_festivos_factory.dart' show ExcepcionesFestivosDataSourceFactory;

export 'src/datasources/asignaciones_vehiculos_turnos/entities/asignacion_vehiculo_turno_entity.dart';
export 'src/datasources/asignaciones_vehiculos_turnos/asignaciones_vehiculos_turnos_contract.dart';
export 'src/datasources/asignaciones_vehiculos_turnos/asignaciones_vehiculos_turnos_factory.dart' show AsignacionVehiculoTurnoDataSourceFactory;
export 'src/datasources/asignaciones_vehiculos_turnos/implementations/supabase/supabase_asignaciones_vehiculos_turnos_datasource.dart';
export 'src/datasources/asignaciones_vehiculos_turnos/models/asignacion_vehiculo_turno_supabase_model.dart';

export 'src/datasources/cuadrante_asignaciones/entities/cuadrante_asignacion_entity.dart';
export 'src/datasources/cuadrante_asignaciones/cuadrante_asignacion_contract.dart';
export 'src/datasources/cuadrante_asignaciones/cuadrante_asignacion_factory.dart' show CuadranteAsignacionDataSourceFactory;
export 'src/datasources/cuadrante_asignaciones/implementations/supabase/supabase_cuadrante_asignacion_datasource.dart';
export 'src/datasources/cuadrante_asignaciones/models/cuadrante_asignacion_supabase_model.dart';

export 'src/datasources/tipos_ausencia/entities/tipo_ausencia_entity.dart';
export 'src/datasources/tipos_ausencia/tipo_ausencia_contract.dart';
export 'src/datasources/tipos_ausencia/tipo_ausencia_factory.dart' show TipoAusenciaDataSourceFactory;
export 'src/datasources/tipos_ausencia/implementations/supabase/supabase_tipo_ausencia_datasource.dart';
export 'src/datasources/tipos_ausencia/models/tipo_ausencia_supabase_model.dart';

export 'src/datasources/ausencias/entities/ausencia_entity.dart';
export 'src/datasources/ausencias/ausencia_contract.dart';
export 'src/datasources/ausencias/ausencia_factory.dart' show AusenciaDataSourceFactory;
export 'src/datasources/ausencias/implementations/supabase/supabase_ausencia_datasource.dart';
export 'src/datasources/ausencias/models/ausencia_supabase_model.dart';

export 'src/datasources/vacaciones/entities/vacaciones_entity.dart';
export 'src/datasources/vacaciones/vacaciones_contract.dart';
export 'src/datasources/vacaciones/vacaciones_factory.dart' show VacacionesDataSourceFactory;
export 'src/datasources/vacaciones/implementations/supabase/supabase_vacaciones_datasource.dart';
export 'src/datasources/vacaciones/models/vacaciones_supabase_model.dart';

export 'src/datasources/historial_medico/entities/historial_medico_entity.dart';
export 'src/datasources/historial_medico/historial_medico_contract.dart';
export 'src/datasources/historial_medico/historial_medico_factory.dart' show HistorialMedicoDataSourceFactory;
export 'src/datasources/historial_medico/implementations/supabase/supabase_historial_medico_datasource.dart';
export 'src/datasources/historial_medico/models/historial_medico_supabase_model.dart';

export 'src/datasources/equipamiento_personal/entities/equipamiento_personal_entity.dart';
export 'src/datasources/equipamiento_personal/equipamiento_personal_contract.dart';
export 'src/datasources/equipamiento_personal/equipamiento_personal_factory.dart' show EquipamientoPersonalDataSourceFactory;
export 'src/datasources/equipamiento_personal/implementations/supabase/supabase_equipamiento_personal_datasource.dart';
export 'src/datasources/equipamiento_personal/models/equipamiento_personal_supabase_model.dart';

export 'src/datasources/vestuario/entities/vestuario_entity.dart';
export 'src/datasources/vestuario/vestuario_contract.dart';
export 'src/datasources/vestuario/vestuario_factory.dart' show VestuarioDataSourceFactory;
export 'src/datasources/vestuario/implementations/supabase/supabase_vestuario_datasource.dart';
export 'src/datasources/vestuario/models/vestuario_supabase_model.dart';

export 'src/datasources/stock_vestuario/entities/stock_vestuario_entity.dart';
export 'src/datasources/stock_vestuario/stock_vestuario_contract.dart';
export 'src/datasources/stock_vestuario/stock_vestuario_factory.dart' show StockVestuarioDataSourceFactory;

// Formación y Certificaciones
export 'src/datasources/certificaciones/entities/certificacion_entity.dart';
export 'src/datasources/certificaciones/certificacion_contract.dart';
export 'src/datasources/certificaciones/certificacion_factory.dart' show CertificacionDataSourceFactory;
export 'src/datasources/certificaciones/implementations/supabase/supabase_certificacion_datasource.dart';
export 'src/datasources/certificaciones/models/certificacion_supabase_model.dart';

export 'src/datasources/cursos/entities/curso_entity.dart';
export 'src/datasources/cursos/curso_contract.dart';
export 'src/datasources/cursos/curso_factory.dart' show CursoDataSourceFactory;
export 'src/datasources/cursos/implementations/supabase/supabase_curso_datasource.dart';
export 'src/datasources/cursos/models/curso_supabase_model.dart';

export 'src/datasources/formacion_personal/entities/formacion_personal_entity.dart';
export 'src/datasources/formacion_personal/formacion_personal_contract.dart';
export 'src/datasources/formacion_personal/formacion_personal_factory.dart' show FormacionPersonalDataSourceFactory;
export 'src/datasources/formacion_personal/implementations/supabase/supabase_formacion_personal_datasource.dart';
export 'src/datasources/formacion_personal/models/formacion_personal_supabase_model.dart';

// ✅ STOCK VEHÍCULOS - Para caducidades y control de equipamiento por vehículo
export 'src/datasources/stock/entities/categoria_equipamiento_entity.dart';
export 'src/datasources/stock/entities/vehiculo_stock_resumen_entity.dart';
export 'src/datasources/stock/entities/stock_vehiculo_entity.dart' show StockVehiculoEntity;
export 'src/datasources/stock/entities/movimiento_stock_entity.dart' show MovimientoStockEntity;
export 'src/datasources/stock/entities/alerta_stock_entity.dart';
export 'src/datasources/stock/entities/stock_minimo_entity.dart';
export 'src/datasources/stock/entities/revision_mensual_entity.dart';
export 'src/datasources/stock/entities/item_revision_entity.dart' hide ItemRevisionEntity; // Ocultar para evitar conflicto con ambulancias_revisiones
export 'src/datasources/stock/stock_contract.dart';
export 'src/datasources/stock/stock_factory.dart' show StockDataSourceFactory;
export 'src/datasources/stock/implementations/supabase/supabase_stock_datasource.dart';
export 'src/datasources/stock/models/categoria_equipamiento_supabase_model.dart';
export 'src/datasources/stock/models/stock_vehiculo_supabase_model.dart';
export 'src/datasources/stock/models/movimiento_stock_supabase_model.dart';
export 'src/datasources/stock/models/alerta_stock_supabase_model.dart';
export 'src/datasources/stock/models/stock_minimo_supabase_model.dart';
export 'src/datasources/stock/models/revision_mensual_supabase_model.dart';
export 'src/datasources/stock/models/item_revision_supabase_model.dart';

// Almacén (legacy - mantener compatibilidad)
export 'src/datasources/almacen/entities/proveedor_entity.dart';
export 'src/datasources/almacen/entities/stock_almacen_entity.dart';
export 'src/datasources/almacen/models/proveedor_supabase_model.dart';
export 'src/datasources/almacen/models/stock_almacen_supabase_model.dart';
export 'src/datasources/almacen/almacen_contract.dart';
export 'src/datasources/almacen/almacen_factory.dart' show AlmacenDataSourceFactory;
export 'src/datasources/almacen/implementations/supabase/supabase_almacen_datasource.dart';

// ✅ Almacén (NUEVO sistema simplificado)
export 'src/datasources/almacen/entities/almacen_entity.dart';
export 'src/datasources/almacen/entities/producto_entity.dart';
export 'src/datasources/almacen/entities/stock_entity.dart';
export 'src/datasources/almacen/entities/movimiento_stock_entity.dart' hide MovimientoStockEntity;
export 'src/datasources/almacen/entities/mantenimiento_electromedicina_entity.dart';
export 'src/datasources/almacen/models/almacen_supabase_model.dart';
export 'src/datasources/almacen/models/producto_supabase_model.dart';
export 'src/datasources/almacen/models/stock_supabase_model.dart';
export 'src/datasources/almacen/models/movimiento_stock_supabase_model.dart' hide MovimientoStockSupabaseModel;
export 'src/datasources/almacen/models/mantenimiento_electromedicina_supabase_model.dart';
export 'src/datasources/almacen/producto_contract.dart';
export 'src/datasources/almacen/producto_factory.dart';
export 'src/datasources/almacen/stock_contract.dart' hide StockDataSource;
export 'src/datasources/almacen/stock_factory.dart' hide StockDataSourceFactory;
export 'src/datasources/almacen/movimiento_stock_contract.dart';
export 'src/datasources/almacen/movimiento_stock_factory.dart';
export 'src/datasources/almacen/mantenimiento_electromedicina_contract.dart';
export 'src/datasources/almacen/mantenimiento_electromedicina_factory.dart';
export 'src/datasources/almacen/implementations/supabase/supabase_producto_datasource.dart';
export 'src/datasources/almacen/implementations/supabase/supabase_stock_datasource.dart' hide SupabaseStockDataSource;
export 'src/datasources/almacen/implementations/supabase/supabase_movimiento_stock_datasource.dart';
export 'src/datasources/almacen/implementations/supabase/supabase_mantenimiento_electromedicina_datasource.dart';

// Proveedor (parte del sistema de almacén)
export 'src/datasources/almacen/proveedor_contract.dart';
export 'src/datasources/almacen/proveedor_factory.dart' show ProveedorDataSourceFactory;
export 'src/datasources/almacen/implementations/supabase/supabase_proveedor_datasource.dart';

// Pacientes
export 'src/datasources/pacientes/entities/paciente_entity.dart';
export 'src/datasources/pacientes/paciente_contract.dart';
export 'src/datasources/pacientes/paciente_factory.dart' show PacienteDataSourceFactory;
export 'src/datasources/pacientes/implementations/supabase/supabase_paciente_datasource.dart';
export 'src/datasources/pacientes/models/paciente_supabase_model.dart';

// Servicios Recurrentes
export 'src/datasources/servicios_recurrentes/entities/servicio_recurrente_entity.dart';
export 'src/datasources/servicios_recurrentes/models/servicio_recurrente_supabase_model.dart';
export 'src/datasources/servicios_recurrentes/servicio_recurrente_contract.dart';
export 'src/datasources/servicios_recurrentes/servicio_recurrente_factory.dart' show ServicioRecurrenteDataSourceFactory;
export 'src/datasources/servicios_recurrentes/implementations/supabase/supabase_servicio_recurrente_datasource.dart';

// Traslados
export 'src/datasources/traslados/entities/traslado_entity.dart';
export 'src/datasources/traslados/entities/estado_traslado.dart';
export 'src/datasources/traslados/entities/evento_traslado_type.dart';
export 'src/datasources/traslados/entities/ubicacion_entity.dart';
export 'src/datasources/traslados/entities/historial_estado_entity.dart';
export 'src/datasources/traslados/entities/traslado_evento_entity.dart';
export 'src/datasources/traslados/models/traslado_supabase_model.dart';
export 'src/datasources/traslados/traslado_contract.dart';
export 'src/datasources/traslados/traslado_factory.dart' show TrasladoDataSourceFactory;
export 'src/datasources/traslados/implementations/supabase/supabase_traslado_datasource.dart';

// Ambulancias y Revisiones
export 'src/datasources/ambulancias_revisiones/entities/tipo_ambulancia_entity.dart';
export 'src/datasources/ambulancias_revisiones/entities/ambulancia_entity.dart';
export 'src/datasources/ambulancias_revisiones/entities/revision_entity.dart';
export 'src/datasources/ambulancias_revisiones/entities/item_revision_entity.dart'; // ItemRevisionEntity principal (con cantidadEsperada, observaciones, conforme)
export 'src/datasources/ambulancias_revisiones/ambulancias_revisiones_contract.dart';
export 'src/datasources/ambulancias_revisiones/ambulancias_revisiones_factory.dart' show AmbulanciasRevisionesDataSourceFactory;
export 'src/datasources/ambulancias_revisiones/implementations/supabase/supabase_ambulancias_datasource.dart';
export 'src/datasources/ambulancias_revisiones/models/tipo_ambulancia_supabase_model.dart';
export 'src/datasources/ambulancias_revisiones/models/ambulancia_supabase_model.dart';
export 'src/datasources/ambulancias_revisiones/models/revision_supabase_model.dart';
export 'src/datasources/ambulancias_revisiones/models/item_revision_supabase_model.dart' hide ItemRevisionSupabaseModel;

// Notificaciones
export 'src/datasources/notificaciones/entities/notificacion_entity.dart';
export 'src/datasources/notificaciones/notificaciones_contract.dart';
export 'src/datasources/notificaciones/notificaciones_factory.dart' show NotificacionesDataSourceFactory;
export 'src/datasources/notificaciones/implementations/supabase/supabase_notificaciones_datasource.dart';
export 'src/datasources/notificaciones/models/notificacion_supabase_model.dart';

// Documentación de Vehículos
export 'src/datasources/documentacion_vehiculos/entities/tipo_documento_entity.dart';
export 'src/datasources/documentacion_vehiculos/entities/documentacion_vehiculo_entity.dart';
export 'src/datasources/documentacion_vehiculos/tipo_documento_datasource_contract.dart';
export 'src/datasources/documentacion_vehiculos/documentacion_vehiculo_datasource_contract.dart';
export 'src/datasources/documentacion_vehiculos/documentacion_vehiculos_datasource_factory.dart'
    show DocumentacionVehiculosDataSourceFactory;
export 'src/datasources/documentacion_vehiculos/models/tipo_documento_supabase_model.dart';
export 'src/datasources/documentacion_vehiculos/models/documentacion_vehiculo_supabase_model.dart';

// Alertas de Caducidad
export 'src/datasources/alertas_caducidad/entities/alerta_caducidad_entity.dart';
export 'src/datasources/alertas_caducidad/alertas_caducidad_contract.dart';
export 'src/datasources/alertas_caducidad/alertas_caducidad_factory.dart'
    show AlertasCaducidadDataSourceFactory;
export 'src/datasources/alertas_caducidad/implementations/supabase/supabase_alertas_caducidad_datasource.dart';
export 'src/datasources/alertas_caducidad/models/alerta_caducidad_supabase_model.dart';

// Utils - Utilidades públicas
export 'src/utils/exceptions/datasource_exception.dart';
export 'src/utils/typedefs/datasource_typedefs.dart';

// NO exportar implementaciones específicas (Firebase, REST)
// NO exportar mixins internos
// NO exportar barrels internos

/// Versión del paquete
const String packageVersion = '0.1.0';