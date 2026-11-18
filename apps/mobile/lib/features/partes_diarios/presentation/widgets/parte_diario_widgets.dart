import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../servicios/presentation/widgets/traslado_card.dart';
import '../../domain/resumen_parte_diario.dart';

/// Barra para cambiar de día (anterior / siguiente)
class ParteDiaSelector extends StatelessWidget {
  const ParteDiaSelector({required this.dia, required this.onAnterior, required this.onSiguiente, super.key});

  final DateTime dia;
  final VoidCallback onAnterior;

  /// `null` si no se puede avanzar (el día es hoy)
  final VoidCallback? onSiguiente;

  @override
  Widget build(BuildContext context) {
    final String texto = DateFormat("EEEE, d 'de' MMMM", 'es').format(dia);
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: <Widget>[
            IconButton(icon: const Icon(Icons.chevron_left), onPressed: onAnterior, tooltip: 'Día anterior'),
            Expanded(
              child: Text(
                texto[0].toUpperCase() + texto.substring(1),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.gray900),
              ),
            ),
            IconButton(icon: const Icon(Icons.chevron_right), onPressed: onSiguiente, tooltip: 'Día siguiente'),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta con las cifras del día
class ParteResumenCard extends StatelessWidget {
  const ParteResumenCard({required this.resumen, super.key});

  final ResumenParteDiario resumen;

  @override
  Widget build(BuildContext context) {
    return _ParteCard(
      titulo: 'Resumen de la jornada',
      icono: Icons.assignment_outlined,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              _Cifra(
                valor: formatDuracion(resumen.tiempoTrabajado),
                etiqueta: resumen.jornadaAbierta ? 'Fichado (en curso)' : 'Tiempo fichado',
                color: AppColors.primary,
              ),
              _Cifra(
                valor: '${resumen.kmTotales.round()} km',
                etiqueta: 'Recorridos',
                color: AppColors.info,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              _Cifra(valor: '${resumen.realizados}', etiqueta: 'Realizados', color: AppColors.success),
              _Cifra(valor: '${resumen.noRealizados}', etiqueta: 'No realizados', color: AppColors.error),
              _Cifra(valor: '${resumen.pendientes}', etiqueta: 'Pendientes', color: AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }
}

/// Lista de fichajes de entrada y salida del día
class ParteFichajesSection extends StatelessWidget {
  const ParteFichajesSection({required this.fichajes, super.key});

  final List<RegistroHorarioEntity> fichajes;

  @override
  Widget build(BuildContext context) {
    final List<RegistroHorarioEntity> ordenados = List<RegistroHorarioEntity>.of(fichajes)
      ..sort((RegistroHorarioEntity a, RegistroHorarioEntity b) => a.fechaHora.compareTo(b.fechaHora));
    return _ParteCard(
      titulo: 'Fichajes',
      icono: Icons.schedule,
      child: ordenados.isEmpty
          ? const _TextoVacio('Sin fichajes este día')
          : Column(children: <Widget>[for (final RegistroHorarioEntity f in ordenados) _FichajeTile(fichaje: f)]),
    );
  }
}

class _FichajeTile extends StatelessWidget {
  const _FichajeTile({required this.fichaje});

  final RegistroHorarioEntity fichaje;

  @override
  Widget build(BuildContext context) {
    final bool entrada = fichaje.tipo.toLowerCase() == 'entrada';
    final Color color = entrada ? AppColors.success : AppColors.error;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(entrada ? Icons.login : Icons.logout, color: color),
      title: Text(entrada ? 'Entrada' : 'Salida', style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: fichaje.vehiculoMatricula == null ? null : Text('Vehículo ${fichaje.vehiculoMatricula}'),
      trailing: Text(
        DateFormat('HH:mm').format(fichaje.fechaHora.toLocal()),
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

/// Servicios asignados ese día (pulsar abre el detalle)
class ParteServiciosSection extends StatelessWidget {
  const ParteServiciosSection({required this.traslados, super.key});

  final List<TrasladoEntity> traslados;

  @override
  Widget build(BuildContext context) {
    return _ParteCard(
      titulo: 'Servicios (${traslados.length})',
      icono: Icons.local_shipping_outlined,
      child: traslados.isEmpty
          ? const _TextoVacio('Sin servicios asignados este día')
          : Column(
              children: <Widget>[
                for (final TrasladoEntity t in traslados)
                  TrasladoCard(traslado: t, onTap: () => context.push('/servicios/${t.id}')),
              ],
            ),
    );
  }
}

/// Mensaje centrado (error, sin datos...) con botón opcional de reintento
class ParteMensaje extends StatelessWidget {
  const ParteMensaje({required this.icon, required this.texto, this.onReintentar, super.key});

  final IconData icon;
  final String texto;
  final VoidCallback? onReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 56, color: AppColors.gray400),
            const SizedBox(height: 12),
            Text(texto, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.gray700)),
            if (onReintentar != null) ...<Widget>[
              const SizedBox(height: 16),
              FilledButton.icon(onPressed: onReintentar, icon: const Icon(Icons.refresh), label: const Text('Reintentar')),
            ],
          ],
        ),
      ),
    );
  }
}

class _ParteCard extends StatelessWidget {
  const _ParteCard({required this.titulo, required this.icono, required this.child});

  final String titulo;
  final IconData icono;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.gray200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icono, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gray900)),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _Cifra extends StatelessWidget {
  const _Cifra({required this.valor, required this.etiqueta, required this.color});

  final String valor;
  final String etiqueta;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(valor, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(etiqueta, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.gray600)),
        ],
      ),
    );
  }
}

class _TextoVacio extends StatelessWidget {
  const _TextoVacio(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(texto, style: const TextStyle(color: AppColors.gray500)),
    );
  }
}
