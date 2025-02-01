import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:restaurant_review/data/model/restaurant.dart';
import 'dart:convert';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal() {
    _instance = this;
  }

  factory DatabaseHelper() => _instance ?? DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initializeDb();
    return _database!;
  }

  static const String _tableName = 'favorites';

  Future<Database> _initializeDb() async {
    var path = await getDatabasesPath();
    var db = openDatabase(
      join(path, 'restaurant_db.db'),
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            name TEXT,
            description TEXT,
            city TEXT,
            address TEXT,
            pictureId TEXT,
            categories TEXT,
            menus TEXT,
            rating REAL,
            customerReviews TEXT
          )''');
      },
      version: 1,
    );
    return db;
  }

  Future<void> insertFavorite(Restaurant restaurant) async {
    final Database db = await database;
    await db.insert(
      _tableName,
      {
        'id': restaurant.id,
        'name': restaurant.name,
        'description': restaurant.description,
        'city': restaurant.city,
        'address': restaurant.address,
        'pictureId': restaurant.pictureId,
        'categories': jsonEncode(restaurant.categories),
        'menus': jsonEncode(restaurant.menus),
        'rating': restaurant.rating,
        'customerReviews': jsonEncode(restaurant.customerReviews),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavorite(String? id) async {
    if (id == null) return;

    final Database db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Restaurant>> getFavorites() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);

    return List.generate(maps.length, (i) {
      return Restaurant(
        id: maps[i]['id'],
        name: maps[i]['name'],
        description: maps[i]['description'],
        city: maps[i]['city'],
        address: maps[i]['address'],
        pictureId: maps[i]['pictureId'],
        categories: (maps[i]['categories'] != null)
            ? (jsonDecode(maps[i]['categories']) as List<dynamic>)
                .map((item) => Category.fromJson(item))
                .toList()
            : [],
        menus: (maps[i]['menus'] != null)
            ? Menus.fromJson(jsonDecode(maps[i]['menus']))
            : null,
        rating: maps[i]['rating'] is num
            ? (maps[i]['rating'] as num).toDouble()
            : 0.0,
        customerReviews: (maps[i]['customerReviews'] != null)
            ? (jsonDecode(maps[i]['customerReviews']) as List<dynamic>)
                .map((item) => CustomerReview.fromJson(item))
                .toList()
            : [],
      );
    });
  }

  Future<bool> isFavorite(String? id) async {
    if (id == null) return false;

    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty;
  }
}
