import 'dart:async';

import 'package:ambutrack_desktop/core/datasource/base_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Tipo de evento de cambio en tiempo real
enum RealtimeChangeType {
  insert,
  update,
  delete,
}

/// Evento de cambio en tiempo real
class RealtimeChange<T> {
  const RealtimeChange({
    required this.type,
    this.oldData,
    this.newData,
  });

  final RealtimeChangeType type;
  final T? oldData;
  final T? newData;
}

/// DataSource con soporte para actualizaciones en tiempo real
///
/// Características:
/// - Sin cache (datos en tiempo real)
/// - Streams para escuchar cambios
/// - Ideal para: estado de servicios, tracking GPS, alertas
class RealtimeDataSource<T> extends BaseDataSource<T> {
  RealtimeDataSource({
    required super.tableName,
    required super.fromMap,
    required super.toMap,
    super.primaryKey,
  });

  /// Canal de Supabase Realtime
  RealtimeChannel? _channel;

  /// Controller para el stream de cambios
  final StreamController<RealtimeChange<T>> _changesController = StreamController<RealtimeChange<T>>.broadcast();

  /// Stream de cambios en tiempo real
  Stream<RealtimeChange<T>> get changes => _changesController.stream;

  /// Suscribirse a cambios en tiempo real
  void subscribe({
    String? filter,
    void Function(RealtimeChange<T> change)? onInsert,
    void Function(RealtimeChange<T> change)? onUpdate,
    void Function(RealtimeChange<T> change)? onDelete,
  }) {
    // Cancelar suscripción anterior si existe
    unsubscribe();

    // Crear nuevo canal
    _channel = client.channel('realtime:$tableName');

    // Configurar PostgresChanges con callback
  }


  /// Cancelar suscripción
  void unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }

  /// Obtener stream de todos los registros con actualizaciones en tiempo real
  Stream<List<T>> watchAll({
    String? orderBy,
    bool ascending = true,
    int? limit,
    String? filter,
  }) {
    final StreamController<List<T>> controller = StreamController<List<T>>();
    controller.onCancel = () async {
      unsubscribe();
      await controller.close();
    };

    // Lista actual de items
    List<T> currentItems = <T>[];

    // Cargar datos iniciales
    getAll(
      orderBy: orderBy,
      ascending: ascending,
      limit: limit,
    ).then((DataSourceResult<List<T>> result) {
      if (result.isSuccess && result.data != null) {
        currentItems = result.data!;
        if (!controller.isClosed) {
          controller.add(currentItems);
        }
      }
    });

    // Suscribirse a cambios
    subscribe(
      filter: filter,
      onInsert: (RealtimeChange<T> change) {
        if (change.newData != null) {
          currentItems = <T>[...currentItems, change.newData as T];
          if (!controller.isClosed) {
            controller.add(currentItems);
          }
        }
      },
      onUpdate: (RealtimeChange<T> change) {
        if (change.newData != null) {
          final Map<String, dynamic> newMap = toMap(change.newData as T);
          final String? newId = newMap[primaryKey]?.toString();
          if (newId != null) {
            currentItems = currentItems.map((T item) {
              final Map<String, dynamic> itemMap = toMap(item);
              final String? itemId = itemMap[primaryKey]?.toString();
              return itemId == newId ? change.newData as T : item;
            }).toList();
            if (!controller.isClosed) {
              controller.add(currentItems);
            }
          }
        }
      },
      onDelete: (RealtimeChange<T> change) {
        if (change.oldData != null) {
          final Map<String, dynamic> oldMap = toMap(change.oldData as T);
          final String? oldId = oldMap[primaryKey]?.toString();
          if (oldId != null) {
            currentItems = currentItems.where((T item) {
              final Map<String, dynamic> itemMap = toMap(item);
              final String? itemId = itemMap[primaryKey]?.toString();
              return itemId != oldId;
            }).toList();
            if (!controller.isClosed) {
              controller.add(currentItems);
            }
          }
        }
      },
    );

    return controller.stream;
  }

  /// Obtener stream de un registro específico con actualizaciones en tiempo real
  Stream<T?> watchById(String id) {
    final StreamController<T?> controller = StreamController<T?>();
    controller.onCancel = () async {
      unsubscribe();
      await controller.close();
    };

    // Cargar dato inicial
    getById(id).then((DataSourceResult<T> result) {
      if (result.isSuccess) {
        if (!controller.isClosed) {
          controller.add(result.data);
        }
      }
    });

    // Suscribirse a cambios del registro específico
    subscribe(
      filter: id,
      onUpdate: (RealtimeChange<T> change) {
        if (!controller.isClosed) {
          controller.add(change.newData);
        }
      },
      onDelete: (RealtimeChange<T> change) {
        if (!controller.isClosed) {
          controller.add(null);
        }
      },
    );

    return controller.stream;
  }

  /// Liberar recursos
  void dispose() {
    unsubscribe();
    _changesController.close();
  }
}
