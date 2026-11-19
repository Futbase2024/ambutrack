import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/estado_tramite_badge.dart';
import '../widgets/form/tramite_form_seccion.dart';
import '../widgets/historial_timeline_widget.dart';
import '../widgets/lista/tramite_item.dart';
import '../widgets/lista/tramites_lista.dart';

/// Detalle de un trámite (vacación o ausencia)
class TramiteDetallePage extends StatefulWidget {
  const TramiteDetallePage.vacacion({required this.vacacion, super.key})
      : ausencia = null,
        tipoAusencia = null;

  const TramiteDetallePage.ausencia({required this.ausencia, required this.tipoAusencia, super.key})
      : vacacion = null;

  final VacacionesEntity? vacacion;
  final AusenciaEntity? ausencia;
  final TipoAusenciaEntity? tipoAusencia;

  @override
  State<TramiteDetallePage> createState() => _TramiteDetallePageState();
}

class _TramiteDetallePageState extends State<TramiteDetallePage> {
  final UsuarioDataSource _usuarios = UsuarioDataSourceFactory.createSupabase();
  String? _nombreSolicitante;

  @override
  void initState() {
    super.initState();
    _cargarNombreSolicitante();
  }

  Future<void> _cargarNombreSolicitante() async {
    try {
      final String idPersonal = widget.vacacion?.idPersonal ?? widget.ausencia!.idPersonal;
      final UserEntity? usuario = await _usuarios.getById(idPersonal);
      if (mounted) {
        setState(() => _nombreSolicitante = usuario?.nombreCompleto ?? 'Usuario desconocido');
      }
    } catch (e) {
      debugPrint('❌ TramiteDetalle: error al cargar solicitante: $e');
      if (mounted) {
        setState(() => _nombreSolicitante = 'Usuario desconocido');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _DatosTramite d = _DatosTramite.desde(widget);

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Detalle del trámite'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          children: <Widget>[
            _Cabecera(datos: d),
            const SizedBox(height: 24),
            TramiteFormSeccion(
              titulo: 'Datos de la solicitud',
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  _DatoFila(icono: Icons.login_rounded, etiqueta: 'Desde', valor: _fechaLarga(d.inicio)),
                  const Divider(height: 1, indent: 52, color: AppColors.gray100),
                  _DatoFila(icono: Icons.logout_rounded, etiqueta: 'Hasta', valor: _fechaLarga(d.fin)),
                  const Divider(height: 1, indent: 52, color: AppColors.gray100),
                  _DatoFila(
                    icono: Icons.date_range_outlined,
                    etiqueta: 'Duración',
                    valor: '${d.dias} ${d.dias == 1 ? 'día' : 'días'} naturales',
                  ),
                  const Divider(height: 1, indent: 52, color: AppColors.gray100),
                  _DatoFila(
                    icono: Icons.send_outlined,
                    etiqueta: 'Solicitado el',
                    valor: DateFormat("d 'de' MMMM yyyy, HH:mm", 'es').format(d.fechaSolicitud.toLocal()),
                  ),
                ],
              ),
            ),
            if (d.motivo != null && d.motivo!.isNotEmpty)
              TramiteFormSeccion(titulo: 'Motivo', child: _Texto(d.motivo!)),
            if (d.observaciones != null && d.observaciones!.isNotEmpty)
              TramiteFormSeccion(titulo: 'Observaciones', child: _Texto(d.observaciones!)),
            HistorialTimelineWidget(
              fechaSolicitud: d.fechaSolicitud,
              solicitadoPor: _nombreSolicitante ?? 'Cargando…',
              estado: d.estado,
              fechaAprobacion: d.fechaAprobacion,
              aprobadoPor: d.aprobadoPor,
              observaciones: d.fechaAprobacion != null ? d.observaciones : null,
            ),
          ],
        ),
      ),
    );
  }

  static String _fechaLarga(DateTime fecha) {
    final String texto = DateFormat("EEEE, d 'de' MMMM yyyy", 'es').format(fecha);
    return texto[0].toUpperCase() + texto.substring(1);
  }
}

/// Datos unificados de vacación o ausencia
class _DatosTramite {
  const _DatosTramite({
    required this.item,
    required this.inicio,
    required this.fin,
    required this.dias,
    required this.estado,
    required this.fechaSolicitud,
    this.motivo,
    this.observaciones,
    this.aprobadoPor,
    this.fechaAprobacion,
  });

  factory _DatosTramite.desde(TramiteDetallePage w) {
    final VacacionesEntity? v = w.vacacion;
    if (v != null) {
      return _DatosTramite(
        item: TramiteItem.vacacion(v),
        inicio: v.fechaInicio,
        fin: v.fechaFin,
        dias: v.diasSolicitados,
        estado: v.estado,
        fechaSolicitud: v.fechaSolicitud ?? v.createdAt ?? DateTime.now(),
        observaciones: v.observaciones,
        aprobadoPor: v.aprobadoPor,
        fechaAprobacion: v.fechaAprobacion,
      );
    }
    final AusenciaEntity a = w.ausencia!;
    return _DatosTramite(
      item: TramiteItem.ausencia(a, <TipoAusenciaEntity>[if (w.tipoAusencia != null) w.tipoAusencia!]),
      inicio: a.fechaInicio,
      fin: a.fechaFin,
      dias: a.diasAusencia,
      estado: a.estado.name,
      fechaSolicitud: a.createdAt,
      motivo: a.motivo,
      observaciones: a.observaciones,
      aprobadoPor: a.aprobadoPor,
      fechaAprobacion: a.fechaAprobacion,
    );
  }

  final TramiteItem item;
  final DateTime inicio;
  final DateTime fin;
  final int dias;
  final String estado;
  final DateTime fechaSolicitud;
  final String? motivo;
  final String? observaciones;
  final String? aprobadoPor;
  final DateTime? fechaAprobacion;
}

/// Tarjeta superior: tipo, estado y periodo
class _Cabecera extends StatelessWidget {
  const _Cabecera({required this.datos});

  final _DatosTramite datos;

  @override
  Widget build(BuildContext context) {
    final TramiteItem item = datos.item;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icono, size: 26, color: item.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.titulo,
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.gray900),
                ),
              ),
              IntrinsicWidth(child: EstadoTramiteBadge(estado: datos.estado, isAusencia: item.esAusencia)),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            TramiteFila.periodo(datos.inicio, datos.fin),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.gray900),
          ),
          const SizedBox(height: 2),
          Text(
            '${datos.dias} ${datos.dias == 1 ? 'día' : 'días'} naturales',
            style: const TextStyle(fontSize: 14, color: AppColors.gray500),
          ),
        ],
      ),
    );
  }
}

/// Fila etiqueta / valor del detalle
class _DatoFila extends StatelessWidget {
  const _DatoFila({required this.icono, required this.etiqueta, required this.valor});

  final IconData icono;
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: <Widget>[
          Icon(icono, size: 20, color: AppColors.gray400),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(etiqueta, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Texto libre (motivo, observaciones)
class _Texto extends StatelessWidget {
  const _Texto(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(texto, style: const TextStyle(fontSize: 15, color: AppColors.gray700, height: 1.45));
  }
}
