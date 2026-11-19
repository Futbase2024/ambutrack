/// Datasource de usuarios - Barrel file
///
/// Exporta:
/// - UserEntity (re-export desde auth)
/// - UsuarioDataSource contract
/// - UsuarioDataSourceFactory
/// - Implementación de Supabase
///
/// NO exporta:
/// - UsuarioSupabaseModel (uso interno)
library;

export 'entities/usuario_entity.dart';
export 'implementations/supabase/supabase.dart';
export 'usuarios_contract.dart';
export 'usuarios_factory.dart';
