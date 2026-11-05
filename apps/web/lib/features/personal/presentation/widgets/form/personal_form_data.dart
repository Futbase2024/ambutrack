import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/personal/domain/entities/categoria_personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/categoria_servicio.dart';
import 'package:ambutrack_web/features/personal/domain/entities/configuracion_validacion_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/empresa_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/poblacion_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/puesto_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/tipo_contrato_entity.dart';
import 'package:flutter/material.dart';

/// Estado editable del formulario de Personal (crear y editar)
class PersonalFormData {
  PersonalFormData({PersonalEntity? p})
      : nombre = TextEditingController(text: (p?.nombre ?? '').toUpperCase()),
        apellidos = TextEditingController(text: (p?.apellidos ?? '').toUpperCase()),
        dni = TextEditingController(text: p?.dni ?? ''),
        email = TextEditingController(text: p?.email ?? ''),
        telefono = TextEditingController(text: p?.telefono ?? ''),
        movil = TextEditingController(text: p?.movil ?? ''),
        direccion = TextEditingController(text: p?.direccion ?? ''),
        codigoPostal = TextEditingController(text: p?.codigoPostal ?? ''),
        nass = TextEditingController(text: p?.nass ?? ''),
        usuario = TextEditingController(text: p?.usuario ?? ''),
        pwdWeb = TextEditingController(text: p?.pwdWeb ?? ''),
        pwd = TextEditingController(text: p?.pwd ?? '') {
    if (p != null) {
      tesSiNo = p.tesSiNo ?? false;
      fechaNacimiento = p.fechaNacimiento;
      fechaInicio = p.fechaInicio;
      fechaAlta = p.fechaAlta;
      dataAnti = p.dataAnti;
      categoriaServicio = p.categoriaServicio;
      configuracionValidaciones = p.configuracionValidaciones;
    }
  }

  final TextEditingController nombre;
  final TextEditingController apellidos;
  final TextEditingController dni;
  final TextEditingController email;
  final TextEditingController telefono;
  final TextEditingController movil;
  final TextEditingController direccion;
  final TextEditingController codigoPostal;
  final TextEditingController nass;
  final TextEditingController usuario;
  final TextEditingController pwdWeb;
  final TextEditingController pwd;

  bool tesSiNo = false;
  DateTime? fechaNacimiento;
  DateTime? fechaInicio;
  DateTime? fechaAlta;
  DateTime? dataAnti;

  // Foreign Keys
  String? provinciaId;
  String? poblacionId;
  String? puestoId;
  String? contratoId;
  String? empresaIdFk;
  String? categoriaIdFk;
  CategoriaServicio categoriaServicio = CategoriaServicio.programado;

  // Configuración de validaciones de turnos
  ConfiguracionValidacionEntity? configuracionValidaciones;

  // Asignación por defecto
  String? contratoAsignadoId;
  String? baseId;
  String? dotacionId;
  String? vehiculoId;

  // Listas para desplegables
  List<ProvinciaEntity> provincias = <ProvinciaEntity>[];
  List<PoblacionEntity> poblaciones = <PoblacionEntity>[];
  List<PuestoEntity> puestos = <PuestoEntity>[];
  List<TipoContratoEntity> contratos = <TipoContratoEntity>[];
  List<EmpresaEntity> empresas = <EmpresaEntity>[];
  List<CategoriaPersonalEntity> categoriasPersonal = <CategoriaPersonalEntity>[];

  // Listas para asignación por defecto
  List<ContratoEntity> contratosCliente = <ContratoEntity>[];
  List<BaseCentroEntity> bases = <BaseCentroEntity>[];
  List<DotacionEntity> dotaciones = <DotacionEntity>[];
  List<VehiculoEntity> vehiculos = <VehiculoEntity>[];

  /// Asigna los valores guardados DESPUÉS de cargar las listas
  void asignarClaves(PersonalEntity p) {
    provinciaId = p.provinciaId;
    poblacionId = p.poblacionId;
    puestoId = p.puestoTrabajoId;
    contratoId = p.contratoId;
    empresaIdFk = p.empresaId;
    categoriaIdFk = p.categoriaId;
    contratoAsignadoId = p.contratoAsignadoId;
    baseId = p.baseId;
    dotacionId = p.dotacionId;
    vehiculoId = p.vehiculoId;
  }

  void dispose() {
    for (final TextEditingController c in <TextEditingController>[
      nombre,
      apellidos,
      dni,
      email,
      telefono,
      movil,
      direccion,
      codigoPostal,
      nass,
      usuario,
      pwdWeb,
      pwd,
    ]) {
      c.dispose();
    }
  }
}
