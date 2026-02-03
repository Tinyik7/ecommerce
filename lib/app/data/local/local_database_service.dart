import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/product_model.dart';

class LocalDatabaseService {
  static Database? _db;

  static Future<void> init() async {
    if (_db != null) return;
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, 'ecommerce_cache.db');
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE products(
          id INTEGER PRIMARY KEY,
          image TEXT,
          name TEXT,
          quantity INTEGER,
          price REAL,
          rating REAL,
          reviews TEXT,
          size TEXT,
          isFavorite INTEGER,
          inCart INTEGER,
          description TEXT,
          category TEXT,
          brand TEXT,
          color TEXT,
          featured INTEGER,
          discount REAL,
          inStock INTEGER,
          createdAt INTEGER,
          updatedAt INTEGER
        )
        ''');

        await db.execute('''
        CREATE TABLE cart_items(
          product_id INTEGER PRIMARY KEY,
          quantity INTEGER,
          payload TEXT
        )
        ''');

        await db.execute('''
        CREATE TABLE favorites(
          product_id INTEGER PRIMARY KEY
        )
        ''');
      },
    );
  }

  static Future<void> cacheProducts(List<ProductModel> products) async {
    final db = _db;
    if (db == null) return;
    final batch = db.batch();
    for (final product in products) {
      batch.insert(
        'products',
        product.toDb(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  static Future<List<ProductModel>> readProducts({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
  }) async {
    final db = _db;
    if (db == null) return [];

    final where = <String>[];
    final args = <Object?>[];

    if (query != null && query.isNotEmpty) {
      where.add('(LOWER(name) LIKE ? OR LOWER(description) LIKE ?)');
      final q = '%${query.toLowerCase()}%';
      args
        ..add(q)
        ..add(q);
    }
    if (category != null && category.isNotEmpty) {
      where.add('LOWER(category) = ?');
      args.add(category.toLowerCase());
    }
    if (minPrice != null) {
      where.add('price >= ?');
      args.add(minPrice);
    }
    if (maxPrice != null) {
      where.add('price <= ?');
      args.add(maxPrice);
    }

    final rows = await db.query(
      'products',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'createdAt DESC',
    );

    return rows.map(ProductModel.fromDb).toList();
  }

  static Future<void> upsertCartItem(ProductModel product) async {
    final db = _db;
    if (db == null || product.id == null) return;
    await db.insert(
      'cart_items',
      {
        'product_id': product.id,
        'quantity': product.quantity ?? 1,
        'payload': jsonEncode(product.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> removeCartItem(int productId) async {
    final db = _db;
    if (db == null) return;
    await db.delete(
      'cart_items',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  static Future<List<ProductModel>> readCartItems() async {
    final db = _db;
    if (db == null) return [];
    final rows = await db.query('cart_items');
    return rows
        .map((row) {
          final payload = row['payload'] as String?;
          if (payload == null) return null;
          final decoded = jsonDecode(payload) as Map<String, dynamic>;
          decoded['quantity'] = row['quantity'];
          final product = ProductModel.fromJson(decoded);
          product.inCart = true;
          return product;
        })
        .whereType<ProductModel>()
        .toList();
  }

  static Future<void> clearCart() async {
    final db = _db;
    if (db == null) return;
    await db.delete('cart_items');
  }

  static Future<void> setFavorite(int productId, bool isFavorite) async {
    final db = _db;
    if (db == null) return;
    if (isFavorite) {
      await db.insert(
        'favorites',
        {'product_id': productId},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await db.delete(
        'favorites',
        where: 'product_id = ?',
        whereArgs: [productId],
      );
    }
  }

  static Future<List<int>> readFavoriteIds() async {
    final db = _db;
    if (db == null) return [];
    final rows = await db.query('favorites');
    return rows.map<int>((row) => row['product_id'] as int).toList();
  }
}
