// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart'
    as _i1033;
import 'package:ambutrack_desktop/core/di/locator.dart' as _i842;
import 'package:ambutrack_desktop/core/network/network_info.dart' as _i518;
import 'package:ambutrack_desktop/core/services/auth_service.dart' as _i987;
import 'package:ambutrack_desktop/features/auth/data/repositories/auth_repository_impl.dart'
    as _i344;
import 'package:ambutrack_desktop/features/auth/domain/repositories/auth_repository.dart'
    as _i607;
import 'package:ambutrack_desktop/features/auth/presentation/bloc/auth_bloc.dart'
    as _i861;
import 'package:ambutrack_desktop/features/menu/data/repositories/menu_repository_impl.dart'
    as _i317;
import 'package:ambutrack_desktop/features/menu/domain/repositories/menu_repository.dart'
    as _i765;
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
    gh.lazySingleton<_i1033.ContratoDataSource>(
      () => registerModule.contratoDataSource,
    );
    gh.lazySingleton<_i1033.ProvinciaDataSource>(
      () => registerModule.provinciaDataSource,
    );
    gh.lazySingleton<_i1033.ComunidadAutonomaDataSource>(
      () => registerModule.comunidadAutonomaDataSource,
    );
    gh.lazySingleton<_i1033.LocalidadDataSource>(
      () => registerModule.localidadDataSource,
    );
    gh.lazySingleton<_i1033.UsuarioDataSource>(
      () => registerModule.usuarioDataSource,
    );
    gh.lazySingleton<_i973.InternetConnectionChecker>(
      () => networkModule.connectionChecker,
    );
    gh.lazySingleton<_i987.AuthService>(() => _i987.AuthService());
    gh.lazySingleton<_i765.MenuRepository>(() => _i317.MenuRepositoryImpl());
    gh.lazySingleton<_i518.NetworkInfo>(
      () => _i518.NetworkInfoImpl(gh<_i973.InternetConnectionChecker>()),
    );
    gh.lazySingleton<_i607.AuthRepository>(
      () => _i344.AuthRepositoryImpl(gh<_i987.AuthService>()),
    );
    gh.factory<_i861.AuthBloc>(
      () => _i861.AuthBloc(gh<_i607.AuthRepository>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i842.RegisterModule {}

class _$NetworkModule extends _i518.NetworkModule {}
