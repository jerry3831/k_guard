import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/app_user_model.dart';


abstract class AuthSQLiteDataSource {
  Future<AppUserModel> createUser({
    required String fullName,
    required String email,
    required String password,
  });
  Future<AppUserModel?> getUserByEmail(String email);
  Future<bool> verifyPassword(String plainPassword, String storedHash);
}

class AuthSQLiteDataSourceImpl implements AuthSQLiteDataSource {
  static const _dbName     = 'currencyguard.db';
  static const _dbVersion  = 1;
  static const _tableUsers = 'users';

  static Database? _database;
  static Completer<Database>? _openCompleter;

  Future<Database> get _db async {
    if (_database != null) return _database!;
    if (_openCompleter != null) return _openCompleter!.future;

    _openCompleter = Completer<Database>();
    try {
      final db = await _openDatabase();
      _database = db;
      _openCompleter!.complete(db);
      return db;
    } catch (e) {
      _openCompleter = null;
      rethrow;
    }
  }


  Future<String> _getDatabaseDirectory() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return getDatabasesPath();
    }

    String baseDir;

    if (Platform.isLinux) {
      final home = Platform.environment['HOME'] ??
          Platform.environment['USERPROFILE'] ??
          '.';
      baseDir = p.join(home, '.local', 'share', 'currencyguard');
    } else if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'] ?? '.';
      baseDir = p.join(appData, 'currencyguard');
    } else if (Platform.isMacOS) {
      final home = Platform.environment['HOME'] ?? '.';
      baseDir = p.join(home, 'Library', 'Application Support', 'currencyguard');
    } else {
      baseDir = p.join(Directory.current.path, 'currencyguard_data');
    }

    final dir = Directory(baseDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return baseDir;
  }


  Future<Database> _openDatabase() async {
    try {
      final dbDir  = await _getDatabaseDirectory()
          .timeout(const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException(
              'Database directory resolution timed out'));

      final dbPath = p.join(dbDir, _dbName);

      final db = await databaseFactory
          .openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: _dbVersion,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        ),
      )
          .timeout(const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException(
              'openDatabase() timed out after 10 seconds'));

      return db;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to open local database: $e');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableUsers (
        id            TEXT PRIMARY KEY,
        full_name     TEXT NOT NULL,
        email         TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        created_at    TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  }


  String _generateSalt() {
    final random = Random.secure();
    final bytes  = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  String _hashPassword(String password) {
    final salt        = _generateSalt();
    final saltedInput = utf8.encode(salt + password);
    final digest      = sha256.convert(saltedInput).toString();
    return '$salt:$digest';
  }

  @override
  Future<bool> verifyPassword(
      String plainPassword, String storedHash) async {
    final parts = storedHash.split(':');
    if (parts.length != 2) return false;
    final salt           = parts[0];
    final expectedDigest = parts[1];
    final saltedInput    = utf8.encode(salt + plainPassword);
    final actualDigest   = sha256.convert(saltedInput).toString();
    return actualDigest == expectedDigest;
  }


  @override
  Future<AppUserModel> createUser({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final db   = await _db;
    final id   = _generateUuid();
    final now  = DateTime.now().toUtc().toIso8601String();
    final hash = _hashPassword(password);

    try {
      await db.insert(
        _tableUsers,
        {
          'id':            id,
          'full_name':     fullName,
          'email':         email.toLowerCase().trim(),
          'password_hash': hash,
          'created_at':    now,
        },
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw const _DuplicateEmailException();
      }
      throw Exception('Database error during registration: $e');
    }

    return AppUserModel(
      id:        id,
      fullName:  fullName,
      email:     email.toLowerCase().trim(),
      createdAt: DateTime.parse(now),
    );
  }


  @override
  Future<AppUserModel?> getUserByEmail(String email) async {
    final db = await _db;
    try {
      final rows = await db.query(
        _tableUsers,
        where:     'email = ?',
        whereArgs: [email.toLowerCase().trim()],
        limit:     1,
      );
      if (rows.isEmpty) return null;
      return _rowToModel(rows.first);
    } on DatabaseException catch (e) {
      throw Exception('Database error during login lookup: $e');
    }
  }


  AppUserModel _rowToModel(Map<String, dynamic> row) {
    return AppUserModel(
      id:           row['id'] as String,
      fullName:     row['full_name'] as String,
      email:        row['email'] as String,
      createdAt:    DateTime.parse(row['created_at'] as String),
      passwordHash: row['password_hash'] as String?,
    );
  }

  String _generateUuid() {
    final random = Random.secure();
    final bytes  = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6]     = (bytes[6] & 0x0f) | 0x40;
    bytes[8]     = (bytes[8] & 0x3f) | 0x80;
    final hex    = bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20, 32)}';
  }
}

class _DuplicateEmailException implements Exception {
  const _DuplicateEmailException();
}