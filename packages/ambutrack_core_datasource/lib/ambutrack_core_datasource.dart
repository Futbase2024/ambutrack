/// AmbuTrack Core Datasource Library
///
/// Este paquete contiene los datasources centralizados para AmbuTrack.
/// Incluye entities, models, contracts y implementaciones de datasources.
library ambutrack_core_datasource;

// Core
export 'src/core/base_datasource.dart';
export 'src/core/base_entity.dart';
export 'src/core/base_model.dart';

// Datasources
export 'src/datasources/usuarios/usuarios.dart';

// Vehículos
export 'src/datasources/vehiculos/entities/vehiculos_entity.dart';
export 'src/datasources/vehiculos/vehiculos_contract.dart';
export 'src/datasources/vehiculos/vehiculos_factory.dart';
export 'src/datasources/vehiculos/implementations/supabase/supabase_vehiculo_datasource.dart';
export 'src/datasources/vehiculos/models/vehiculo_supabase_model.dart';

// Incidencias de Vehículos
export 'src/datasources/incidencias_vehiculo/entities/incidencia_vehiculo_entity.dart';
export 'src/datasources/incidencias_vehiculo/incidencia_vehiculo_contract.dart';
export 'src/datasources/incidencias_vehiculo/incidencia_vehiculo_factory.dart';
export 'src/datasources/incidencias_vehiculo/implementations/supabase/supabase_incidencia_vehiculo_datasource.dart';
export 'src/datasources/incidencias_vehiculo/models/incidencia_vehiculo_supabase_model.dart';
