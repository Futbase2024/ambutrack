import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/administracion/multicentro/domain/repositories/empresas_tenant_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación pass-through del repositorio de empresas
@LazySingleton(as: EmpresasTenantRepository)
class EmpresasTenantRepositoryImpl implements EmpresasTenantRepository {
  EmpresasTenantRepositoryImpl() : _dataSource = EmpresasTenantDataSourceFactory.createSupabase();

  final EmpresasTenantDataSource _dataSource;

  @override
  Future<List<EmpresaTenantEntity>> getAll() async {
    debugPrint('📦 EmpresasTenantRepository: Solicitando empresas...');
    return _dataSource.getAll();
  }

  @override
  Future<EmpresaTenantEntity?> getById(String id) async {
    return _dataSource.getById(id);
  }
}
