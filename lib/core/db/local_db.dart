import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// On-device SQLite used as the single source of truth for non-ephemeral
/// state that must survive across app launches, crashes, and the
/// known-flaky `flutter_secure_storage` keystore.
///
/// Not a general ORM — we keep it to hand-written SQL + a migration
/// ladder so we never take a codegen dependency that fights our other
/// sqlite3 consumers (see pubspec note on drift/freezed removal).
///
/// Current schema (v1):
///   • `kv_store` — opaque key-value store (auth tokens, feature flags,
///     user preferences, anything small that doesn't warrant its own
///     table yet). Values are TEXT — callers JSON-encode if needed.
///
/// Future tables slot in as additional migrations — never edit an
/// existing CREATE TABLE; add an ALTER or a new migration step and bump
/// `_dbVersion`.
class LocalDb {
  LocalDb._(this._db);
  final Database _db;

  Database get raw => _db;

  static const _dbName = 'thaiprompt.db';
  static const _dbVersion = 1;

  /// Schema migrations. Each index corresponds to the target schema
  /// version — applied sequentially from the stored `oldVersion` up to
  /// [_dbVersion]. Never mutate a landed migration.
  static final List<Future<void> Function(Database)> _migrations = [
    // v1 — initial schema.
    (db) async {
      await db.execute('''
        CREATE TABLE kv_store (
          k TEXT PRIMARY KEY NOT NULL,
          v TEXT,
          updated_at INTEGER NOT NULL
        )
      ''');
      await db.execute('CREATE INDEX idx_kv_updated_at ON kv_store(updated_at)');
    },
    // Add v2 here when the next migration lands. DO NOT rewrite v1.
  ];

  static Future<LocalDb> open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);

    final db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        // Fresh install: run all migrations in order.
        for (var i = 0; i < version; i++) {
          await _migrations[i](db);
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        for (var i = oldVersion; i < newVersion; i++) {
          await _migrations[i](db);
        }
      },
    );

    if (kDebugMode) {
      debugPrint('[LocalDb] opened at $path (v$_dbVersion)');
    }
    return LocalDb._(db);
  }
}

/// Thin helper around the `kv_store` table.
///
/// Every read/write is a single SQL statement — no caching. If we ever
/// need in-memory speed, we'll add it at the call site, not here.
class KvStore {
  KvStore(this._db);
  final LocalDb _db;

  Future<String?> read(String key) async {
    final rows = await _db.raw.query(
      'kv_store',
      columns: ['v'],
      where: 'k = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final v = rows.first['v'];
    return v is String ? v : null;
  }

  Future<void> write(String key, String value) async {
    await _db.raw.insert(
      'kv_store',
      {
        'k': key,
        'v': value,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String key) async {
    await _db.raw.delete('kv_store', where: 'k = ?', whereArgs: [key]);
  }

  Future<void> deleteAll(Iterable<String> keys) async {
    final batch = _db.raw.batch();
    for (final k in keys) {
      batch.delete('kv_store', where: 'k = ?', whereArgs: [k]);
    }
    await batch.commit(noResult: true);
  }
}

/// Async-initialized database provider. The storage helpers downstream
/// (TokenStorage, ProductCache, etc.) `ref.watch(…future)` this so the
/// rest of the app is guaranteed to see an initialized DB before any
/// read/write.
final localDbProvider = FutureProvider<LocalDb>((ref) => LocalDb.open());

final kvStoreProvider = FutureProvider<KvStore>((ref) async {
  final db = await ref.watch(localDbProvider.future);
  return KvStore(db);
});
