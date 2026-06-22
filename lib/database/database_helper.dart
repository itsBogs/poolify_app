import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'dart:async'; // Add this
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_model.dart';
import '../models/cottage_model.dart';
import '../models/reservation_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Real-time Update Stream
  final _databaseUpdateController = StreamController<String>.broadcast();
  Stream<String> get databaseUpdates => _databaseUpdateController.stream;

  void _notifyUpdate(String table) {
    _databaseUpdateController.add(table);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path;
    if (!kIsWeb && Platform.isWindows) {
      path = join(Directory.current.path, 'exported_db.db');
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, 'resort_reservation.db');
    }

    // DEBUG: Print path para madaling mahanap
    if (kDebugMode) {
      print("DATABASE PATH: $path");
    }

    return await openDatabase(
      path,
      version: 7,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        await _ensureTables(db);
        if (oldVersion < 7) {
          await _upsertDefaultCottages(db);
        }
      },
      onOpen: (db) async {
        await _ensureTables(db);
        await _ensureAdminUser(db);
        await _upsertDefaultCottagesIfNeeded(db);
        await exportDatabaseForDebug(path);
      },
    );
  }

  Future<void> _ensureTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        phone TEXT,
        role TEXT,
        profile_image TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS cottages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        price REAL,
        capacity INTEGER,
        image TEXT,
        status TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS reservations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        cottage_id INTEGER,
        reservation_date TEXT,
        time_slot TEXT,
        guests INTEGER,
        total_price REAL,
        status TEXT,
        payment_status TEXT DEFAULT 'Pending',
        payment_receipt TEXT,
        created_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (cottage_id) REFERENCES cottages (id)
      )
    ''');

    final userColumns = await db.rawQuery('PRAGMA table_info(users)');
    final hasProfileImage = userColumns.any(
      (column) => column['name'] == 'profile_image',
    );
    if (!hasProfileImage) {
      await db.execute("ALTER TABLE users ADD COLUMN profile_image TEXT");
    }

    final reservationColumns = await db.rawQuery(
      'PRAGMA table_info(reservations)',
    );
    final hasPaymentStatus = reservationColumns.any(
      (column) => column['name'] == 'payment_status',
    );
    if (!hasPaymentStatus) {
      await db.execute(
        "ALTER TABLE reservations ADD COLUMN payment_status TEXT DEFAULT 'Pending'",
      );
    }

    final hasPaymentReceipt = reservationColumns.any(
      (column) => column['name'] == 'payment_receipt',
    );
    if (!hasPaymentReceipt) {
      await db.execute(
        "ALTER TABLE reservations ADD COLUMN payment_receipt TEXT",
      );
    }
  }

  Future<void> _ensureAdminUser(Database db) async {
    final admin = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: ['admin@gmail.com'],
      limit: 1,
    );
    if (admin.isEmpty) {
      await db.insert('users', {
        'name': 'Admin User',
        'email': 'admin@gmail.com',
        'password': 'admin123',
        'phone': '09123456789',
        'role': 'admin',
      });
    }
  }

  Future<void> _upsertDefaultCottagesIfNeeded(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM cottages WHERE id BETWEEN 1 AND 17',
      ),
    );
    if (count != null && count < _defaultCottages.length) {
      if (kDebugMode) {
        print("Default cottage count is $count, expected 17. Repairing...");
      }
      await _upsertDefaultCottages(db);
    }
  }

  Future<void> _upsertDefaultCottages(Database db) async {
    for (var i = 0; i < _defaultCottages.length; i++) {
      await db.insert('cottages', {
        'id': i + 1,
        ..._defaultCottages[i],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await db.rawInsert(
      "INSERT OR REPLACE INTO sqlite_sequence(name, seq) VALUES('cottages', ?)",
      [_defaultCottages.length],
    );
  }

  Future<void> exportDatabaseForDebug(String dbPath) async {
    try {
      if (Platform.isAndroid) {
        // I-copy sa Downloads folder na madaling ma-access ng ADB pull
        Directory? externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          String backupPath = join(
            externalDir.path,
            'resort_reservation_export.db',
          );
          File(dbPath).copySync(backupPath);
          debugPrint("DATABASE EXPORTED TO: $backupPath");
          debugPrint("COMMAND TO GET IT: adb pull $backupPath .");
        }
      } else {
        final backupPath = join(Directory.current.path, 'exported_db.db');
        if (normalize(dbPath) == normalize(backupPath)) {
          debugPrint("DATABASE ACTIVE AT: $backupPath");
          return;
        }
        File(dbPath).copySync(backupPath);
        debugPrint("DATABASE EXPORTED TO: $backupPath");
      }
    } catch (e) {
      debugPrint("Export error: $e");
    }
  }

  Future<void> _exportCurrentDatabase(Database db) async {
    try {
      await db.rawQuery('PRAGMA wal_checkpoint(FULL)');
    } catch (_) {
      // Some platforms/configurations do not use WAL; exporting can still work.
    }
    await exportDatabaseForDebug(db.path);
  }

  Future<Map<String, int>> getTableCounts() async {
    final db = await database;
    return {
      'users':
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM users'),
          ) ??
          0,
      'cottages':
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM cottages'),
          ) ??
          0,
      'reservations':
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM reservations'),
          ) ??
          0,
    };
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users Table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        phone TEXT,
        role TEXT
      )
    ''');

    // Cottages Table
    await db.execute('''
      CREATE TABLE cottages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        price REAL,
        capacity INTEGER,
        image TEXT,
        status TEXT
      )
    ''');

    // Reservations Table
    await db.execute('''
      CREATE TABLE reservations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        cottage_id INTEGER,
        reservation_date TEXT,
        time_slot TEXT,
        guests INTEGER,
        total_price REAL,
        status TEXT,
        payment_status TEXT DEFAULT 'Pending',
        created_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (cottage_id) REFERENCES cottages (id)
      )
    ''');

    await _ensureAdminUser(db);
    await _upsertDefaultCottages(db);
  }

  static const List<Map<String, dynamic>> _defaultCottages = [
    {
      'name': 'Family Cottage A',
      'description':
          'A vibrant and green sanctuary tailored for the whole family, conveniently located just a few steps away from the energy of the main pool.',
      'price': 1500.0,
      'capacity': 10,
      'image': 'assets/images/family.jpg',
      'status': 'available',
    },
    {
      'name': 'Family Cottage B',
      'description':
          'A quiet and serene family getaway tucked in a peaceful corner, surrounded by refreshing, lush forest views and a cool breeze.',
      'price': 1600.0,
      'capacity': 10,
      'image': 'assets/images/family.jpg',
      'status': 'available',
    },
    {
      'name': 'Clubhouse Pavilion',
      'description':
          'The ultimate expansive gathering place designed for large groups, reunions, and celebrations seeking a blend of nature, comfort, and fun.',
      'price': 2500.0,
      'capacity': 25,
      'image': 'assets/images/club.jpg',
      'status': 'available',
    },
    {
      'name': 'Double Sky Cottage',
      'description':
          'An elevated two-story wooden cottage offering a refreshing rustic vibe, panoramic pool views, and the perfect spot to unwind.',
      'price': 2000.0,
      'capacity': 12,
      'image': 'assets/images/double.jpg',
      'status': 'available',
    },
    {
      'name': 'VIP Forest Suite A',
      'description':
          'An exclusive, fully air-conditioned premium room featuring elegant wooden interiors and first-class amenities for a luxurious stay.',
      'price': 5000.0,
      'capacity': 6,
      'image': 'assets/images/viproom.jpg',
      'status': 'available',
    },
    {
      'name': 'VIP Forest Suite B',
      'description':
          'A secluded VIP haven designed for nature lovers who prioritize ultimate privacy, peaceful surroundings, and high-end comfort.',
      'price': 5000.0,
      'capacity': 6,
      'image': 'assets/images/viproom.jpg',
      'status': 'available',
    },
    {
      'name': 'Special Wooden Cabin',
      'description':
          'A beautifully handcrafted wooden cottage with charming traditional details that blend seamlessly into the surrounding wilderness.',
      'price': 1800.0,
      'capacity': 8,
      'image': 'assets/images/specialwooden.jpg',
      'status': 'available',
    },
    {
      'name': 'Garden Table 1',
      'description':
          'A charming al-fresco dining experience set under the cool, historic shade of ancient canopy trees.',
      'price': 800.0,
      'capacity': 4,
      'image': 'assets/images/gardentable.jpg',
      'status': 'available',
    },
    {
      'name': 'Poolside Table',
      'description':
          'A casual and relaxing table set right by the pool’s edge, perfect for quick snacks between swimming laps.',
      'price': 600.0,
      'capacity': 4,
      'image': 'assets/images/pooltable.jpg',
      'status': 'available',
    },
    {
      'name': 'Poolside Canopy A',
      'description':
          'Stay cool and close to the action under our premium green canopies, situated right next to the crystal-clear water.',
      'price': 1000.0,
      'capacity': 6,
      'image': 'assets/images/poolcottage.jpg',
      'status': 'available',
    },
    {
      'name': 'Poolside Canopy B',
      'description':
          'The perfect vantage point for watching pool activities and family fun while staying comfortably shaded from the sun.',
      'price': 1000.0,
      'capacity': 6,
      'image': 'assets/images/poolcottage.jpg',
      'status': 'available',
    },
    {
      'name': 'Veranda Zen 1',
      'description':
          'A peaceful, minimalist veranda space overlooking the beautifully manicured landscape of the main resort grounds.',
      'price': 1200.0,
      'capacity': 6,
      'image': 'assets/images/veranda1.jpg',
      'status': 'available',
    },
    {
      'name': 'Veranda Zen 2',
      'description':
          'An elevated deck area featuring comfortable custom wooden seating, ideal for relaxing with a morning cup of coffee.',
      'price': 1200.0,
      'capacity': 6,
      'image': 'assets/images/veranda2.jpg',
      'status': 'available',
    },
    {
      'name': 'Veranda Zen 3',
      'description':
          'A spacious veranda designed for intimate family storytelling, small group dynamics, or just absorbing the sounds of nature.',
      'price': 1500.0,
      'capacity': 8,
      'image': 'assets/images/veranda3.jpg',
      'status': 'available',
    },
    {
      'name': 'Veranda Zen 4',
      'description':
          'Our most secluded and private veranda option, nestled deep within the resort’s richest greenery for total relaxation.',
      'price': 1500.0,
      'capacity': 8,
      'image': 'assets/images/veranda4.jpg',
      'status': 'available',
    },
    {
      'name': 'Round Table Grove',
      'description':
          'An intimate circular seating arrangement framed by nature, intentionally built for good food and great conversations.',
      'price': 700.0,
      'capacity': 5,
      'image': 'assets/images/roundtable.jpg',
      'status': 'available',
    },
    {
      'name': 'Nature Swing Seat',
      'description':
          'A whimsical and relaxing hanging swing seat surrounded by vibrant garden blooms, perfect for couples or solo daydreamers.',
      'price': 500.0,
      'capacity': 2,
      'image': 'assets/images/swing.jpg',
      'status': 'available',
    },
  ];

  // User Operations
  Future<int> registerUser(UserModel user) async {
    Database db = await database;
    final id = await db.insert('users', {
      'name': user.name,
      'email': user.email,
      'password': user.password,
      'phone': user.phone,
      'role': user.role,
      'profile_image': user.profileImage,
    });
    await _exportCurrentDatabase(db);
    _notifyUpdate('users'); // <--- NOTIFY
    if (kDebugMode) {
      final counts = await getTableCounts();
      debugPrint("REGISTERED USER ID: $id | DB COUNTS: $counts");
    }
    return id;
  }

  Future<int> updateUserProfileImage(int id, String? imagePath) async {
    Database db = await database;
    final count = await db.update(
      'users',
      {'profile_image': imagePath},
      where: 'id = ?',
      whereArgs: [id],
    );
    await _exportCurrentDatabase(db);
    _notifyUpdate('users');
    return count;
  }

  Future<List<UserModel>> getUsers() async {
    Database db = await database;
    List<Map<String, dynamic>> res = await db.query('users');
    return res.map((m) => UserModel.fromMap(m)).toList();
  }

  Future<int> deleteUser(int id) async {
    Database db = await database;
    final count = await db.delete('users', where: 'id = ?', whereArgs: [id]);
    await _exportCurrentDatabase(db);
    _notifyUpdate('users'); // <--- NOTIFY
    return count;
  }

  Future<UserModel?> loginUser(String email, String password) async {
    Database db = await database;
    List<Map<String, dynamic>> res = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (res.isNotEmpty) return UserModel.fromMap(res.first);
    return null;
  }

  // Cottage Operations
  Future<List<CottageModel>> getCottages() async {
    Database db = await database;
    List<Map<String, dynamic>> res = await db.query('cottages');
    return res.map((m) => CottageModel.fromMap(m)).toList();
  }

  Future<int> addCottage(CottageModel cottage) async {
    Database db = await database;
    final id = await db.insert('cottages', cottage.toMap());
    await _exportCurrentDatabase(db);
    _notifyUpdate('cottages'); // <--- NOTIFY
    return id;
  }

  Future<int> updateCottage(CottageModel cottage) async {
    Database db = await database;
    final count = await db.update(
      'cottages',
      cottage.toMap(),
      where: 'id = ?',
      whereArgs: [cottage.id],
    );
    await _exportCurrentDatabase(db);
    _notifyUpdate('cottages'); // <--- NOTIFY
    return count;
  }

  Future<int> deleteCottage(int id) async {
    Database db = await database;
    final count = await db.delete('cottages', where: 'id = ?', whereArgs: [id]);
    await _exportCurrentDatabase(db);
    _notifyUpdate('cottages'); // <--- NOTIFY
    return count;
  }

  // Reservation Operations
  Future<int> addReservation(ReservationModel reservation) async {
    Database db = await database;
    final id = await db.insert('reservations', {
      'user_id': reservation.userId,
      'cottage_id': reservation.cottageId,
      'reservation_date': reservation.reservationDate,
      'time_slot': reservation.timeSlot,
      'guests': reservation.guests,
      'total_price': reservation.totalPrice,
      'status': reservation.status,
      'payment_status': reservation.paymentStatus,
      'payment_receipt': reservation.paymentReceipt,
      'created_at': reservation.createdAt,
    });
    await _exportCurrentDatabase(db);
    _notifyUpdate('reservations'); // <--- NOTIFY
    if (kDebugMode) {
      final counts = await getTableCounts();
      debugPrint("ADDED RESERVATION ID: $id | DB COUNTS: $counts");
    }
    return id;
  }

  Future<int> updateReservationReceipt(int id, String? receiptPath) async {
    Database db = await database;
    final count = await db.update(
      'reservations',
      {'payment_receipt': receiptPath},
      where: 'id = ?',
      whereArgs: [id],
    );
    await _exportCurrentDatabase(db);
    _notifyUpdate('reservations');
    return count;
  }

  Future<List<ReservationModel>> getAllReservations() async {
    Database db = await database;
    final List<Map<String, dynamic>> res = await db.rawQuery('''
      SELECT r.*, u.name as userName, c.name as cottageName, c.image as cottageImage
      FROM reservations r
      JOIN users u ON r.user_id = u.id
      JOIN cottages c ON r.cottage_id = c.id
      ORDER BY r.created_at DESC
    ''');
    return res.map((m) => ReservationModel.fromMap(m)).toList();
  }

  Future<List<ReservationModel>> getUserReservations(int userId) async {
    Database db = await database;
    final List<Map<String, dynamic>> res = await db.rawQuery(
      '''
      SELECT r.*, c.name as cottageName, c.image as cottageImage
      FROM reservations r
      JOIN cottages c ON r.cottage_id = c.id
      WHERE r.user_id = ?
      ORDER BY r.created_at DESC
    ''',
      [userId],
    );
    return res.map((m) => ReservationModel.fromMap(m)).toList();
  }

  Future<int> updateReservationStatus(int id, String status) async {
    Database db = await database;
    final count = await db.update(
      'reservations',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
    await _exportCurrentDatabase(db);
    _notifyUpdate('reservations');
    return count;
  }

  Future<int> updatePaymentStatus(int id, String paymentStatus) async {
    Database db = await database;
    final count = await db.update(
      'reservations',
      {'payment_status': paymentStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
    await _exportCurrentDatabase(db);
    _notifyUpdate('reservations');
    return count;
  }

  Future<int> deleteReservation(int id) async {
    Database db = await database;
    final count = await db.delete(
      'reservations',
      where: 'id = ?',
      whereArgs: [id],
    );
    await _exportCurrentDatabase(db);
    _notifyUpdate('reservations');
    return count;
  }
}
