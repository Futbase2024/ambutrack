import 'entities/empresa_tenant_entity.dart';

/// Contrato del datasource de empresas (multi-tenant, tabla `empresas`).
///
/// Solo lectura: la gestión de altas/bajas de empresas se hace en BD.
abstract class EmpresasTenantDataSource {
  Future<List<EmpresaTenantEntity>> getAll();
  Future<EmpresaTenantEntity?> getById(String id);
}
