import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Contrato del repositorio de empresas (multi-tenant, tabla `empresas`)
abstract class EmpresasTenantRepository {
  Future<List<EmpresaTenantEntity>> getAll();
  Future<EmpresaTenantEntity?> getById(String id);
}
