import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils/logger.dart';

class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  static Database? _db;

  // ── Table names ───────────────────────────────────────────────────────────
  static const String tableProducts = 'products';
  static const String tablePreferences = 'preferences';
  static const String tableHistory = 'browsing_history';

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'styleswipe.db');
    AppLogger.i('Initialising DB at $path', tag: 'LocalStorageService');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    AppLogger.i('Creating DB schema v$version', tag: 'LocalStorageService');

    // Products cache
    await db.execute('''
      CREATE TABLE $tableProducts (
        id          INTEGER PRIMARY KEY,
        title       TEXT    NOT NULL,
        price       REAL    NOT NULL,
        description TEXT    NOT NULL,
        category    TEXT    NOT NULL,
        image       TEXT    NOT NULL,
        rating      REAL    NOT NULL,
        ratingCount INTEGER NOT NULL,
        cachedAt    TEXT    NOT NULL
      )
    ''');

    // User preferences  (type: 1 = liked, 0 = disliked)
    await db.execute('''
      CREATE TABLE $tablePreferences (
        productId   INTEGER PRIMARY KEY,
        type        INTEGER NOT NULL,
        productTitle TEXT   NOT NULL,
        productImage TEXT   NOT NULL,
        productPrice REAL   NOT NULL,
        createdAt   TEXT    NOT NULL
      )
    ''');

    // In-app browsing history
    await db.execute('''
      CREATE TABLE $tableHistory (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        url         TEXT    NOT NULL,
        pageTitle   TEXT    NOT NULL,
        productId   INTEGER NOT NULL,
        productTitle TEXT   NOT NULL,
        visitedAt   TEXT    NOT NULL
      )
    ''');
  }

  // ── Products ──────────────────────────────────────────────────────────────

  Future<void> cacheProducts(List<Map<String, dynamic>> rows) async {
    final db = await database;
    final batch = db.batch();
    for (final row in rows) {
      batch.insert(tableProducts, row,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
    AppLogger.d('Cached ${rows.length} products', tag: 'LocalStorageService');
  }

  Future<List<Map<String, dynamic>>> getCachedProducts() async {
    final db = await database;
    return db.query(tableProducts, orderBy: 'cachedAt DESC');
  }

  Future<bool> hasCachedProducts() async {
    final db = await database;
    final result =
    await db.rawQuery('SELECT COUNT(*) as count FROM $tableProducts');
    return (result.first['count'] as int) > 0;
  }

  // ── Preferences ───────────────────────────────────────────────────────────

  Future<void> upsertPreference(Map<String, dynamic> row) async {
    final db = await database;
    await db.insert(tablePreferences, row,
        conflictAlgorithm: ConflictAlgorithm.replace);
    AppLogger.d('Upserted preference for productId=${row['productId']}',
        tag: 'LocalStorageService');
  }

  Future<void> removePreference(int productId) async {
    final db = await database;
    await db.delete(tablePreferences,
        where: 'productId = ?', whereArgs: [productId]);
    AppLogger.d('Removed preference for productId=$productId',
        tag: 'LocalStorageService');
  }

  Future<List<Map<String, dynamic>>> getAllPreferences() async {
    final db = await database;
    return db.query(tablePreferences, orderBy: 'createdAt DESC');
  }

  Future<Map<String, dynamic>?> getPreference(int productId) async {
    final db = await database;
    final rows = await db.query(
      tablePreferences,
      where: 'productId = ?',
      whereArgs: [productId],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  // ── Browsing History ──────────────────────────────────────────────────────

  Future<int> insertHistory(Map<String, dynamic> row) async {
    final db = await database;
    final id = await db.insert(tableHistory, row);
    AppLogger.d('Inserted history id=$id url=${row['url']}',
        tag: 'LocalStorageService');
    return id;
  }

  Future<List<Map<String, dynamic>>> getAllHistory() async {
    final db = await database;
    return db.query(tableHistory, orderBy: 'visitedAt DESC');
  }

  Future<void> deleteHistoryItem(int id) async {
    final db = await database;
    await db.delete(tableHistory, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete(tableHistory);
    AppLogger.i('Cleared all browsing history', tag: 'LocalStorageService');
  }

  // ── Teardown ──────────────────────────────────────────────────────────────

  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }
}