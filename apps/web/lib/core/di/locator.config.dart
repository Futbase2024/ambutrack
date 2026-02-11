// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:ambutrack_core/ambutrack_core.dart' as _i40;
import 'package:ambutrack_web/core/auth/services/role_service.dart' as _i750;
import 'package:ambutrack_web/core/di/locator.dart' as _i962;
import 'package:ambutrack_web/core/network/network_info.dart' as _i321;
import 'package:ambutrack_web/core/services/auth_service.dart' as _i496;
import 'package:ambutrack_web/features/almacen/data/repositories/almacen_repository_impl.dart'
    as _i704;
import 'package:ambutrack_web/features/almacen/data/repositories/mantenimiento_electromedicina_repository_impl.dart'
    as _i804;
import 'package:ambutrack_web/features/almacen/data/repositories/movimiento_stock_repository_impl.dart'
    as _i221;
import 'package:ambutrack_web/features/almacen/data/repositories/producto_repository_impl.dart'
    as _i723;
import 'package:ambutrack_web/features/almacen/data/repositories/stock_repository_impl.dart'
    as _i345;
import 'package:ambutrack_web/features/almacen/domain/repositories/almacen_repository.dart'
    as _i983;
import 'package:ambutrack_web/features/almacen/domain/repositories/mantenimiento_electromedicina_repository.dart'
    as _i134;
import 'package:ambutrack_web/features/almacen/domain/repositories/movimiento_stock_repository.dart'
    as _i408;
import 'package:ambutrack_web/features/almacen/domain/repositories/producto_repository.dart'
    as _i971;
import 'package:ambutrack_web/features/almacen/domain/repositories/stock_repository.dart'
    as _i731;
import 'package:ambutrack_web/features/almacen/presentation/bloc/mantenimiento_electromedicina/mantenimiento_electromedicina_bloc.dart'
    as _i980;
import 'package:ambutrack_web/features/almacen/presentation/bloc/movimiento_stock/movimiento_stock_bloc.dart'
    as _i1007;
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_bloc.dart'
    as _i226;
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_bloc.dart'
    as _i533;
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_bloc.dart'
    as _i976;
import 'package:ambutrack_web/features/ausencias/data/repositories/ausencia_repository_impl.dart'
    as _i847;
import 'package:ambutrack_web/features/ausencias/data/repositories/tipo_ausencia_repository_impl.dart'
    as _i30;
import 'package:ambutrack_web/features/ausencias/domain/repositories/ausencia_repository.dart'
    as _i829;
import 'package:ambutrack_web/features/ausencias/domain/repositories/tipo_ausencia_repository.dart'
    as _i682;
import 'package:ambutrack_web/features/ausencias/presentation/bloc/ausencias_bloc.dart'
    as _i728;
import 'package:ambutrack_web/features/auth/data/repositories/auth_repository_impl.dart'
    as _i822;
import 'package:ambutrack_web/features/auth/domain/repositories/auth_repository.dart'
    as _i707;
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart'
    as _i649;
import 'package:ambutrack_web/features/contratos/data/repositories/contrato_repository_impl.dart'
    as _i552;
import 'package:ambutrack_web/features/contratos/domain/repositories/contrato_repository.dart'
    as _i922;
import 'package:ambutrack_web/features/contratos/presentation/bloc/contrato_bloc.dart'
    as _i1032;
import 'package:ambutrack_web/features/cuadrante/asignaciones/data/repositories/asignacion_vehiculo_turno_repository_impl.dart'
    as _i626;
import 'package:ambutrack_web/features/cuadrante/asignaciones/data/repositories/cuadrante_asignacion_repository_impl.dart'
    as _i396;
import 'package:ambutrack_web/features/cuadrante/asignaciones/domain/repositories/asignacion_vehiculo_turno_repository.dart'
    as _i917;
import 'package:ambutrack_web/features/cuadrante/asignaciones/domain/repositories/cuadrante_asignacion_repository.dart'
    as _i223;
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/asignaciones/asignaciones_bloc.dart'
    as _i39;
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/cuadrante_asignaciones_bloc.dart'
    as _i14;
import 'package:ambutrack_web/features/cuadrante/bases/data/repositories/bases_repository_impl.dart'
    as _i946;
import 'package:ambutrack_web/features/cuadrante/bases/domain/repositories/bases_repository.dart'
    as _i1055;
import 'package:ambutrack_web/features/cuadrante/bases/presentation/bloc/bases_bloc.dart'
    as _i117;
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/data/repositories/cuadrante_repository_impl.dart'
    as _i1029;
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/repositories/cuadrante_repository.dart'
    as _i440;
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_bloc.dart'
    as _i516;
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/presentation/bloc/cuadrante_visual_bloc.dart'
    as _i655;
import 'package:ambutrack_web/features/cuadrante/dotaciones/data/repositories/dotaciones_repository_impl.dart'
    as _i225;
import 'package:ambutrack_web/features/cuadrante/dotaciones/domain/repositories/dotaciones_repository.dart'
    as _i5;
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/bloc/dotaciones_bloc.dart'
    as _i245;
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/data/repositories/excepcion_festivo_repository_impl.dart'
    as _i492;
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/domain/repositories/excepcion_festivo_repository.dart'
    as _i172;
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/bloc/excepciones_festivos_bloc.dart'
    as _i87;
import 'package:ambutrack_web/features/home/presentation/bloc/home_bloc.dart'
    as _i848;
import 'package:ambutrack_web/features/itv_revisiones/data/repositories/itv_revision_repository_impl.dart'
    as _i662;
import 'package:ambutrack_web/features/itv_revisiones/domain/repositories/itv_revision_repository.dart'
    as _i836;
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_bloc.dart'
    as _i699;
import 'package:ambutrack_web/features/mantenimiento/data/repositories/mantenimiento_repository_impl.dart'
    as _i346;
import 'package:ambutrack_web/features/mantenimiento/domain/repositories/mantenimiento_repository.dart'
    as _i23;
import 'package:ambutrack_web/features/mantenimiento/presentation/bloc/mantenimiento_bloc.dart'
    as _i205;
import 'package:ambutrack_web/features/menu/data/repositories/menu_repository_impl.dart'
    as _i216;
import 'package:ambutrack_web/features/menu/domain/repositories/menu_repository.dart'
    as _i388;
import 'package:ambutrack_web/features/notificaciones/data/repositories/notificaciones_repository_impl.dart'
    as _i12;
import 'package:ambutrack_web/features/notificaciones/domain/repositories/notificaciones_repository.dart'
    as _i1037;
import 'package:ambutrack_web/features/notificaciones/presentation/bloc/notificacion_bloc.dart'
    as _i938;
import 'package:ambutrack_web/features/personal/data/repositories/equipamiento_personal_repository_impl.dart'
    as _i517;
import 'package:ambutrack_web/features/personal/data/repositories/historial_medico_repository_impl.dart'
    as _i711;
import 'package:ambutrack_web/features/personal/data/repositories/personal_repository_impl.dart'
    as _i901;
import 'package:ambutrack_web/features/personal/data/repositories/vestuario_repository_impl.dart'
    as _i321;
import 'package:ambutrack_web/features/personal/domain/repositories/equipamiento_personal_repository.dart'
    as _i153;
import 'package:ambutrack_web/features/personal/domain/repositories/historial_medico_repository.dart'
    as _i645;
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart'
    as _i373;
import 'package:ambutrack_web/features/personal/domain/repositories/vestuario_repository.dart'
    as _i571;
import 'package:ambutrack_web/features/personal/horarios/data/repositories/registro_horario_repository_impl.dart'
    as _i567;
import 'package:ambutrack_web/features/personal/horarios/domain/repositories/registro_horario_repository.dart'
    as _i960;
import 'package:ambutrack_web/features/personal/horarios/presentation/bloc/registro_horario_bloc.dart'
    as _i504;
import 'package:ambutrack_web/features/personal/presentation/bloc/equipamiento_personal_bloc.dart'
    as _i391;
import 'package:ambutrack_web/features/personal/presentation/bloc/historial_medico_bloc.dart'
    as _i762;
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_bloc.dart'
    as _i845;
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_bloc.dart'
    as _i716;
import 'package:ambutrack_web/features/servicios/pacientes/data/repositories/paciente_repository_impl.dart'
    as _i1045;
import 'package:ambutrack_web/features/servicios/pacientes/domain/repositories/paciente_repository.dart'
    as _i229;
import 'package:ambutrack_web/features/servicios/pacientes/presentation/bloc/pacientes_bloc.dart'
    as _i91;
import 'package:ambutrack_web/features/servicios/servicios/data/repositories/servicio_recurrente_repository_impl.dart'
    as _i820;
import 'package:ambutrack_web/features/servicios/servicios/data/repositories/servicio_repository_impl.dart'
    as _i512;
import 'package:ambutrack_web/features/servicios/servicios/data/repositories/traslado_repository_impl.dart'
    as _i901;
import 'package:ambutrack_web/features/servicios/servicios/domain/repositories/servicio_recurrente_repository.dart'
    as _i681;
import 'package:ambutrack_web/features/servicios/servicios/domain/repositories/servicio_repository.dart'
    as _i450;
import 'package:ambutrack_web/features/servicios/servicios/domain/repositories/traslado_repository.dart'
    as _i660;
import 'package:ambutrack_web/features/servicios/servicios/presentation/bloc/servicios_bloc.dart'
    as _i79;
import 'package:ambutrack_web/features/stock_vestuario/data/repositories/stock_vestuario_repository_impl.dart'
    as _i541;
import 'package:ambutrack_web/features/stock_vestuario/domain/repositories/stock_vestuario_repository.dart'
    as _i321;
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_bloc.dart'
    as _i440;
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/data/repositories/categoria_vehiculo_repository_impl.dart'
    as _i930;
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/domain/repositories/categoria_vehiculo_repository.dart'
    as _i537;
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/presentation/bloc/categoria_vehiculo_bloc.dart'
    as _i100;
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/data/repositories/centro_hospitalario_repository_impl.dart'
    as _i719;
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/domain/repositories/centro_hospitalario_repository.dart'
    as _i940;
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/bloc/centro_hospitalario_bloc.dart'
    as _i866;
import 'package:ambutrack_web/features/tablas/especialidades_medicas/data/repositories/especialidad_repository_impl.dart'
    as _i53;
import 'package:ambutrack_web/features/tablas/especialidades_medicas/domain/repositories/especialidad_repository.dart'
    as _i1023;
import 'package:ambutrack_web/features/tablas/especialidades_medicas/presentation/bloc/especialidad_bloc.dart'
    as _i796;
import 'package:ambutrack_web/features/tablas/facultativos/data/repositories/facultativo_repository_impl.dart'
    as _i42;
import 'package:ambutrack_web/features/tablas/facultativos/domain/repositories/facultativo_repository.dart'
    as _i931;
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_bloc.dart'
    as _i947;
import 'package:ambutrack_web/features/tablas/localidades/data/repositories/localidad_repository_impl.dart'
    as _i197;
import 'package:ambutrack_web/features/tablas/localidades/domain/repositories/localidad_repository.dart'
    as _i1057;
import 'package:ambutrack_web/features/tablas/localidades/presentation/bloc/localidad_bloc.dart'
    as _i252;
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/data/repositories/motivo_cancelacion_repository_impl.dart'
    as _i800;
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/domain/repositories/motivo_cancelacion_repository.dart'
    as _i739;
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/bloc/motivo_cancelacion_bloc.dart'
    as _i548;
import 'package:ambutrack_web/features/tablas/motivos_traslado/data/repositories/motivo_traslado_repository_impl.dart'
    as _i1073;
import 'package:ambutrack_web/features/tablas/motivos_traslado/domain/repositories/motivo_traslado_repository.dart'
    as _i36;
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/bloc/motivo_traslado_bloc.dart'
    as _i425;
import 'package:ambutrack_web/features/tablas/provincias/data/repositories/provincia_repository_impl.dart'
    as _i634;
import 'package:ambutrack_web/features/tablas/provincias/domain/repositories/provincia_repository.dart'
    as _i958;
import 'package:ambutrack_web/features/tablas/provincias/presentation/bloc/provincia_bloc.dart'
    as _i100;
import 'package:ambutrack_web/features/tablas/tipos_paciente/data/repositories/tipo_paciente_repository_impl.dart'
    as _i567;
import 'package:ambutrack_web/features/tablas/tipos_paciente/domain/repositories/tipo_paciente_repository.dart'
    as _i98;
import 'package:ambutrack_web/features/tablas/tipos_paciente/presentation/bloc/tipo_paciente_bloc.dart'
    as _i319;
import 'package:ambutrack_web/features/tablas/tipos_traslado/data/repositories/tipo_traslado_repository_impl.dart'
    as _i889;
import 'package:ambutrack_web/features/tablas/tipos_traslado/domain/repositories/tipo_traslado_repository.dart'
    as _i529;
import 'package:ambutrack_web/features/tablas/tipos_traslado/presentation/bloc/tipo_traslado_bloc.dart'
    as _i454;
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/data/repositories/tipo_vehiculo_repository_impl.dart'
    as _i273;
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/domain/repositories/tipo_vehiculo_repository.dart'
    as _i308;
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/bloc/tipo_vehiculo_bloc.dart'
    as _i402;
import 'package:ambutrack_web/features/trafico_diario/presentation/bloc/trafico_diario_bloc.dart'
    as _i136;
import 'package:ambutrack_web/features/turnos/data/repositories/intercambio_repository_impl.dart'
    as _i326;
import 'package:ambutrack_web/features/turnos/data/repositories/plantilla_turno_repository_impl.dart'
    as _i60;
import 'package:ambutrack_web/features/turnos/data/repositories/turnos_repository_impl.dart'
    as _i212;
import 'package:ambutrack_web/features/turnos/data/services/disponibilidad_service_impl.dart'
    as _i518;
import 'package:ambutrack_web/features/turnos/data/services/generacion_automatica_service_impl.dart'
    as _i981;
import 'package:ambutrack_web/features/turnos/data/services/turno_validation_service_impl.dart'
    as _i194;
import 'package:ambutrack_web/features/turnos/domain/repositories/intercambio_repository.dart'
    as _i753;
import 'package:ambutrack_web/features/turnos/domain/repositories/plantilla_turno_repository.dart'
    as _i961;
import 'package:ambutrack_web/features/turnos/domain/repositories/turnos_repository.dart'
    as _i393;
import 'package:ambutrack_web/features/turnos/domain/services/disponibilidad_service.dart'
    as _i22;
import 'package:ambutrack_web/features/turnos/domain/services/generacion_automatica_service.dart'
    as _i870;
import 'package:ambutrack_web/features/turnos/domain/services/turno_validation_service.dart'
    as _i578;
import 'package:ambutrack_web/features/turnos/presentation/bloc/generacion_automatica_bloc.dart'
    as _i987;
import 'package:ambutrack_web/features/turnos/presentation/bloc/intercambios_bloc.dart'
    as _i242;
import 'package:ambutrack_web/features/turnos/presentation/bloc/plantillas_turnos_bloc.dart'
    as _i876;
import 'package:ambutrack_web/features/turnos/presentation/bloc/turnos_bloc.dart'
    as _i467;
import 'package:ambutrack_web/features/vacaciones/data/repositories/vacaciones_repository_impl.dart'
    as _i108;
import 'package:ambutrack_web/features/vacaciones/domain/repositories/vacaciones_repository.dart'
    as _i769;
import 'package:ambutrack_web/features/vacaciones/presentation/bloc/vacaciones_bloc.dart'
    as _i101;
import 'package:ambutrack_web/features/vehiculos/data/repositories/vehiculo_repository_impl.dart'
    as _i814;
import 'package:ambutrack_web/features/vehiculos/domain/repositories/vehiculo_repository.dart'
    as _i145;
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/stock_equipamiento/stock_equipamiento_bloc.dart'
    as _i1015;
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart'
    as _i1042;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i973;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i454.SupabaseClient>(() => registerModule.supabaseClient);
    gh.lazySingleton<_i40.ContratoDataSource>(
      () => registerModule.contratoDataSource,
    );
    gh.lazySingleton<_i40.ProvinciaDataSource>(
      () => registerModule.provinciaDataSource,
    );
    gh.lazySingleton<_i40.ComunidadAutonomaDataSource>(
      () => registerModule.comunidadAutonomaDataSource,
    );
    gh.lazySingleton<_i40.LocalidadDataSource>(
      () => registerModule.localidadDataSource,
    );
    gh.lazySingleton<_i973.InternetConnectionChecker>(
      () => networkModule.connectionChecker,
    );
    gh.lazySingleton<_i496.AuthService>(() => _i496.AuthService());
    gh.lazySingleton<_i961.PlantillaTurnoRepository>(
      () => _i60.PlantillaTurnoRepositoryImpl(),
    );
    gh.lazySingleton<_i769.VacacionesRepository>(
      () => _i108.VacacionesRepositoryImpl(),
    );
    gh.lazySingleton<_i308.TipoVehiculoRepository>(
      () => _i273.TipoVehiculoRepositoryImpl(),
    );
    gh.lazySingleton<_i98.TipoPacienteRepository>(
      () => _i567.TipoPacienteRepositoryImpl(),
    );
    gh.lazySingleton<_i681.ServicioRecurrenteRepository>(
      () => _i820.ServicioRecurrenteRepositoryImpl(),
    );
    gh.lazySingleton<_i321.StockVestuarioRepository>(
      () => _i541.StockVestuarioRepositoryImpl(),
    );
    gh.lazySingleton<_i571.VestuarioRepository>(
      () => _i321.VestuarioRepositoryImpl(),
    );
    gh.lazySingleton<_i388.MenuRepository>(() => _i216.MenuRepositoryImpl());
    gh.lazySingleton<_i172.ExcepcionFestivoRepository>(
      () => _i492.ExcepcionFestivoRepositoryImpl(),
    );
    gh.lazySingleton<_i958.ProvinciaRepository>(
      () => _i634.ProvinciaRepositoryImpl(),
    );
    gh.lazySingleton<_i578.TurnoValidationService>(
      () => _i194.TurnoValidationServiceImpl(),
    );
    gh.lazySingleton<_i731.StockRepository>(() => _i345.StockRepositoryImpl());
    gh.lazySingleton<_i223.CuadranteAsignacionRepository>(
      () => _i396.CuadranteAsignacionRepositoryImpl(),
    );
    gh.lazySingleton<_i829.AusenciaRepository>(
      () => _i847.AusenciaRepositoryImpl(),
    );
    gh.lazySingleton<_i440.CuadranteRepository>(
      () => _i1029.CuadranteRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i707.AuthRepository>(
      () => _i822.AuthRepositoryImpl(gh<_i496.AuthService>()),
    );
    gh.lazySingleton<_i145.VehiculoRepository>(
      () => _i814.VehiculoRepositoryImpl(),
    );
    gh.lazySingleton<_i529.TipoTrasladoRepository>(
      () => _i889.TipoTrasladoRepositoryImpl(),
    );
    gh.lazySingleton<_i1057.LocalidadRepository>(
      () => _i197.LocalidadRepositoryImpl(),
    );
    gh.lazySingleton<_i870.GeneracionAutomaticaService>(
      () => _i981.GeneracionAutomaticaServiceImpl(),
    );
    gh.lazySingleton<_i940.CentroHospitalarioRepository>(
      () => _i719.CentroHospitalarioRepositoryImpl(),
    );
    gh.lazySingleton<_i836.ItvRevisionRepository>(
      () => _i662.ItvRevisionRepositoryImpl(),
    );
    gh.lazySingleton<_i23.MantenimientoRepository>(
      () => _i346.MantenimientoRepositoryImpl(),
    );
    gh.lazySingleton<_i983.AlmacenRepository>(
      () => _i704.AlmacenRepositoryImpl(),
    );
    gh.lazySingleton<_i971.ProductoRepository>(
      () => _i723.ProductoRepositoryImpl(),
    );
    gh.lazySingleton<_i153.EquipamientoPersonalRepository>(
      () => _i517.EquipamientoPersonalRepositoryImpl(),
    );
    gh.factory<_i976.StockBloc>(
      () => _i976.StockBloc(
        gh<_i731.StockRepository>(),
        gh<_i971.ProductoRepository>(),
      ),
    );
    gh.lazySingleton<_i931.FacultativoRepository>(
      () => _i42.FacultativoRepositoryImpl(),
    );
    gh.lazySingleton<_i393.TurnosRepository>(
      () => _i212.TurnosRepositoryImpl(),
    );
    gh.lazySingleton<_i1023.EspecialidadRepository>(
      () => _i53.EspecialidadRepositoryImpl(),
    );
    gh.lazySingleton<_i408.MovimientoStockRepository>(
      () => _i221.MovimientoStockRepositoryImpl(),
    );
    gh.lazySingleton<_i134.MantenimientoElectromedicinaRepository>(
      () => _i804.MantenimientoElectromedicinaRepositoryImpl(),
    );
    gh.lazySingleton<_i36.MotivoTrasladoRepository>(
      () => _i1073.MotivoTrasladoRepositoryImpl(),
    );
    gh.lazySingleton<_i739.MotivoCancelacionRepository>(
      () => _i800.MotivoCancelacionRepositoryImpl(),
    );
    gh.factory<_i402.TipoVehiculoBloc>(
      () => _i402.TipoVehiculoBloc(gh<_i308.TipoVehiculoRepository>()),
    );
    gh.lazySingleton<_i1055.BasesRepository>(() => _i946.BasesRepositoryImpl());
    gh.factory<_i533.ProveedoresBloc>(
      () => _i533.ProveedoresBloc(gh<_i983.AlmacenRepository>()),
    );
    gh.factory<_i980.MantenimientoElectromedicinaBloc>(
      () => _i980.MantenimientoElectromedicinaBloc(
        gh<_i134.MantenimientoElectromedicinaRepository>(),
      ),
    );
    gh.factory<_i440.StockVestuarioBloc>(
      () => _i440.StockVestuarioBloc(gh<_i321.StockVestuarioRepository>()),
    );
    gh.lazySingleton<_i660.TrasladoRepository>(
      () => _i901.TrasladoRepositoryImpl(),
    );
    gh.lazySingleton<_i22.DisponibilidadService>(
      () => _i518.DisponibilidadServiceImpl(),
    );
    gh.lazySingleton<_i917.AsignacionVehiculoTurnoRepository>(
      () => _i626.AsignacionVehiculoTurnoRepositoryImpl(),
    );
    gh.lazySingleton<_i373.PersonalRepository>(
      () => _i901.PersonalRepositoryImpl(),
    );
    gh.factory<_i716.VestuarioBloc>(
      () => _i716.VestuarioBloc(gh<_i571.VestuarioRepository>()),
    );
    gh.lazySingleton<_i5.DotacionesRepository>(
      () => _i225.DotacionesRepositoryImpl(),
    );
    gh.lazySingleton<_i450.ServicioRepository>(
      () => _i512.ServicioRepositoryImpl(),
    );
    gh.lazySingleton<_i645.HistorialMedicoRepository>(
      () => _i711.HistorialMedicoRepositoryImpl(),
    );
    gh.lazySingleton<_i922.ContratoRepository>(
      () => _i552.ContratoRepositoryImpl(gh<_i40.ContratoDataSource>()),
    );
    gh.lazySingleton<_i1037.NotificacionesRepository>(
      () => _i12.NotificacionesRepositoryImpl(),
    );
    gh.lazySingleton<_i229.PacienteRepository>(
      () => _i1045.PacienteRepositoryImpl(),
    );
    gh.factory<_i762.HistorialMedicoBloc>(
      () => _i762.HistorialMedicoBloc(gh<_i645.HistorialMedicoRepository>()),
    );
    gh.lazySingleton<_i537.CategoriaVehiculoRepository>(
      () => _i930.CategoriaVehiculoRepositoryImpl(),
    );
    gh.factory<_i655.CuadranteVisualBloc>(
      () => _i655.CuadranteVisualBloc(
        gh<_i5.DotacionesRepository>(),
        gh<_i917.AsignacionVehiculoTurnoRepository>(),
        gh<_i373.PersonalRepository>(),
        gh<_i145.VehiculoRepository>(),
      ),
    );
    gh.lazySingleton<_i960.RegistroHorarioRepository>(
      () => _i567.RegistroHorarioRepositoryImpl(),
    );
    gh.lazySingleton<_i682.TipoAusenciaRepository>(
      () => _i30.TipoAusenciaRepositoryImpl(),
    );
    gh.factory<_i947.FacultativoBloc>(
      () => _i947.FacultativoBloc(gh<_i931.FacultativoRepository>()),
    );
    gh.factory<_i252.LocalidadBloc>(
      () => _i252.LocalidadBloc(gh<_i1057.LocalidadRepository>()),
    );
    gh.factory<_i14.CuadranteAsignacionesBloc>(
      () => _i14.CuadranteAsignacionesBloc(
        gh<_i223.CuadranteAsignacionRepository>(),
      ),
    );
    gh.factory<_i100.ProvinciaBloc>(
      () => _i100.ProvinciaBloc(gh<_i958.ProvinciaRepository>()),
    );
    gh.factory<_i319.TipoPacienteBloc>(
      () => _i319.TipoPacienteBloc(gh<_i98.TipoPacienteRepository>()),
    );
    gh.factory<_i454.TipoTrasladoBloc>(
      () => _i454.TipoTrasladoBloc(gh<_i529.TipoTrasladoRepository>()),
    );
    gh.factory<_i467.TurnosBloc>(
      () => _i467.TurnosBloc(
        gh<_i393.TurnosRepository>(),
        gh<_i578.TurnoValidationService>(),
      ),
    );
    gh.factory<_i876.PlantillasTurnosBloc>(
      () => _i876.PlantillasTurnosBloc(gh<_i961.PlantillaTurnoRepository>()),
    );
    gh.factory<_i699.ItvRevisionBloc>(
      () => _i699.ItvRevisionBloc(gh<_i836.ItvRevisionRepository>()),
    );
    gh.factory<_i91.PacientesBloc>(
      () => _i91.PacientesBloc(gh<_i229.PacienteRepository>()),
    );
    gh.factory<_i39.AsignacionesBloc>(
      () =>
          _i39.AsignacionesBloc(gh<_i917.AsignacionVehiculoTurnoRepository>()),
    );
    gh.lazySingleton<_i321.NetworkInfo>(
      () => _i321.NetworkInfoImpl(gh<_i973.InternetConnectionChecker>()),
    );
    gh.factory<_i101.VacacionesBloc>(
      () => _i101.VacacionesBloc(
        gh<_i769.VacacionesRepository>(),
        gh<_i1037.NotificacionesRepository>(),
        gh<_i373.PersonalRepository>(),
      ),
    );
    gh.factory<_i87.ExcepcionesFestivosBloc>(
      () =>
          _i87.ExcepcionesFestivosBloc(gh<_i172.ExcepcionFestivoRepository>()),
    );
    gh.factory<_i391.EquipamientoPersonalBloc>(
      () => _i391.EquipamientoPersonalBloc(
        gh<_i153.EquipamientoPersonalRepository>(),
      ),
    );
    gh.factory<_i796.EspecialidadBloc>(
      () => _i796.EspecialidadBloc(gh<_i1023.EspecialidadRepository>()),
    );
    gh.factory<_i938.NotificacionBloc>(
      () => _i938.NotificacionBloc(gh<_i1037.NotificacionesRepository>()),
    );
    gh.factory<_i987.GeneracionAutomaticaBloc>(
      () => _i987.GeneracionAutomaticaBloc(
        gh<_i870.GeneracionAutomaticaService>(),
        gh<_i393.TurnosRepository>(),
        gh<_i373.PersonalRepository>(),
      ),
    );
    gh.factory<_i845.PersonalBloc>(
      () => _i845.PersonalBloc(gh<_i373.PersonalRepository>()),
    );
    gh.factory<_i548.MotivoCancelacionBloc>(
      () =>
          _i548.MotivoCancelacionBloc(gh<_i739.MotivoCancelacionRepository>()),
    );
    gh.lazySingleton<_i753.IntercambioRepository>(
      () => _i326.IntercambioRepositoryImpl(gh<_i393.TurnosRepository>()),
    );
    gh.factory<_i1042.VehiculosBloc>(
      () => _i1042.VehiculosBloc(gh<_i145.VehiculoRepository>()),
    );
    gh.factory<_i1015.StockEquipamientoBloc>(
      () => _i1015.StockEquipamientoBloc(gh<_i145.VehiculoRepository>()),
    );
    gh.lazySingleton<_i750.RoleService>(
      () => _i750.RoleService(
        gh<_i496.AuthService>(),
        gh<_i373.PersonalRepository>(),
      ),
    );
    gh.factory<_i848.HomeBloc>(
      () => _i848.HomeBloc(
        gh<_i321.NetworkInfo>(),
        gh<_i145.VehiculoRepository>(),
      ),
    );
    gh.factory<_i1007.MovimientoStockBloc>(
      () => _i1007.MovimientoStockBloc(gh<_i408.MovimientoStockRepository>()),
    );
    gh.factory<_i649.AuthBloc>(
      () => _i649.AuthBloc(gh<_i707.AuthRepository>()),
    );
    gh.factory<_i516.CuadranteBloc>(
      () => _i516.CuadranteBloc(
        gh<_i440.CuadranteRepository>(),
        gh<_i145.VehiculoRepository>(),
      ),
    );
    gh.factory<_i1032.ContratoBloc>(
      () => _i1032.ContratoBloc(gh<_i922.ContratoRepository>()),
    );
    gh.factory<_i226.ProductoBloc>(
      () => _i226.ProductoBloc(gh<_i971.ProductoRepository>()),
    );
    gh.factory<_i205.MantenimientoBloc>(
      () => _i205.MantenimientoBloc(gh<_i23.MantenimientoRepository>()),
    );
    gh.factory<_i504.RegistroHorarioBloc>(
      () => _i504.RegistroHorarioBloc(gh<_i960.RegistroHorarioRepository>()),
    );
    gh.factory<_i866.CentroHospitalarioBloc>(
      () => _i866.CentroHospitalarioBloc(
        gh<_i940.CentroHospitalarioRepository>(),
      ),
    );
    gh.factory<_i79.ServiciosBloc>(
      () => _i79.ServiciosBloc(repository: gh<_i450.ServicioRepository>()),
    );
    gh.factory<_i100.CategoriaVehiculoBloc>(
      () =>
          _i100.CategoriaVehiculoBloc(gh<_i537.CategoriaVehiculoRepository>()),
    );
    gh.factory<_i425.MotivoTrasladoBloc>(
      () => _i425.MotivoTrasladoBloc(gh<_i36.MotivoTrasladoRepository>()),
    );
    gh.factory<_i136.TraficoDiarioBloc>(
      () => _i136.TraficoDiarioBloc(gh<_i660.TrasladoRepository>()),
    );
    gh.factory<_i245.DotacionesBloc>(
      () => _i245.DotacionesBloc(gh<_i5.DotacionesRepository>()),
    );
    gh.factory<_i117.BasesBloc>(
      () => _i117.BasesBloc(gh<_i1055.BasesRepository>()),
    );
    gh.factory<_i242.IntercambiosBloc>(
      () => _i242.IntercambiosBloc(gh<_i753.IntercambioRepository>()),
    );
    gh.factory<_i728.AusenciasBloc>(
      () => _i728.AusenciasBloc(
        gh<_i829.AusenciaRepository>(),
        gh<_i682.TipoAusenciaRepository>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i962.RegisterModule {}

class _$NetworkModule extends _i321.NetworkModule {}
