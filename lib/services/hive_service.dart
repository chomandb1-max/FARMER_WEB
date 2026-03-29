import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense_model.dart';
import '../models/farmer_product_model.dart';
import '../models/driver_model.dart';
import '../models/driver_work_model.dart';
import '../models/shop_type_model.dart';

class HiveService {
  // دروستکردنی سینگڵتۆن (Singleton)
  static HiveService? _instance;
  HiveService._();

  static Future<HiveService> create() async {
    if (_instance == null) {
      // لێرە initFlutter لادەبەین چونکە لە main بە مەرجی وێب/مۆبایل دامان ناوە
      
      // تۆمارکردنی ئەداپتەرەکان (ئەمانە وەک خۆی بمێنێتەوە)
      if (!Hive.isAdapterRegistered(DriverAdapter().typeId)) Hive.registerAdapter(DriverAdapter());
      if (!Hive.isAdapterRegistered(DriverWorkAdapter().typeId)) Hive.registerAdapter(DriverWorkAdapter());
      if (!Hive.isAdapterRegistered(ExpenseModelAdapter().typeId)) Hive.registerAdapter(ExpenseModelAdapter());
      if (!Hive.isAdapterRegistered(FarmerProductModelAdapter().typeId)) Hive.registerAdapter(FarmerProductModelAdapter());
      if (!Hive.isAdapterRegistered(ShopTypeModelAdapter().typeId)) Hive.registerAdapter(ShopTypeModelAdapter());

      // کردنەوەی سندوقەکان
      await Hive.openBox<Driver>('drivers');
      await Hive.openBox<DriverWork>('driver_works');
      await Hive.openBox<ExpenseModel>('expenses');
      await Hive.openBox<FarmerProductModel>('products');
      await Hive.openBox<ShopTypeModel>('shops');

      _instance = HiveService._();
    }
    return _instance!;
  }

  // دەستگەیشتن بە Box-ەکان بە ئاسانی
  Box<Driver> get driverBox => Hive.box<Driver>('drivers');
  Box<DriverWork> get driverWorkBox => Hive.box<DriverWork>('driver_works');
  Box<ExpenseModel> get expenseBox => Hive.box<ExpenseModel>('expenses');
  Box<FarmerProductModel> get productBox => Hive.box<FarmerProductModel>('products');
  Box<ShopTypeModel> get shopBox => Hive.box<ShopTypeModel>('shops');

  // --- بەرهەمەکان (Products) ---

  Future<void> saveProduct(FarmerProductModel newProduct) async {
    // ئەگەر ئایدی سفر بوو، ئایدییەکی نوێی بۆ دروست دەکەین
    if (newProduct.id == 0) {
      newProduct.id = DateTime.now().millisecondsSinceEpoch ~/ 1000;    }
    await productBox.put(newProduct.id, newProduct);
  }

  Future<List<FarmerProductModel>> getProductsForFarmer(int farmerId) async {
    return productBox.values.where((p) => p.id_farmer_user == farmerId).toList();
  }

  Future<void> deleteProduct(int serverId) async {
    final itemToDelete = productBox.values.firstWhere(
      (p) => p.id_product == serverId,
      orElse: () => FarmerProductModel(id: -1),
    );
    if (itemToDelete.id != -1) {
      await productBox.delete(itemToDelete.id);
    }
  }

  Future<void> deleteLocalProduct(int id) async {
    await productBox.delete(id);
  }

  // --- خەرجییەکان (Expenses) ---

  Future<void> saveExpense(ExpenseModel newExpense) async {
    if (newExpense.id == 0) {
      newExpense.id = DateTime.now().millisecondsSinceEpoch ~/ 1000;    }
    await expenseBox.put(newExpense.id, newExpense);
  }

  Future<List<ExpenseModel>> getExpensesForFarmer(int farmerId) async {
    return expenseBox.values.where((e) => e.id_farmer_user == farmerId).toList();
  }

  Future<void> deleteExpense(int serverId) async {
    final item = expenseBox.values.firstWhere(
      (e) => e.id_expense == serverId,
      orElse: () => ExpenseModel(id: -1),
    );
    if (item.id != -1) await expenseBox.delete(item.id);
  }

  Future<void> deleteLocalExpense(int id) async {
    await expenseBox.delete(id);
  }

  Future<List<ExpenseModel>> getUnsyncedExpenses() async {
    return expenseBox.values.where((e) => e.is_synced == false).toList();
  }

  // --- سایەق و ئیشی سایەق (Driver & Work) ---



   Future<void> saveDriver(Driver driver) async {

    if (driver.id == 0) {

      driver.id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    }

    await driverBox.put(driver.id, driver);

  }


  Future<List<Driver>> getAllDrivers() async {
    return driverBox.values.toList();
  }

  Future<void> saveDriverWork(DriverWork work) async {
    if (work.id == 0) {
      work.id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    }
    await driverWorkBox.put(work.id, work);
  }

  Future<List<DriverWork>> getUnsyncedWorks() async {
    return driverWorkBox.values.where((w) => w.is_synced == false).toList();
  }

  Future<void> deleteDriverWork(int id) async {
    await driverWorkBox.delete(id);
  }

  // --- نوسینگەکان (Shops) ---

  Future<void> saveShop(ShopTypeModel shop) async {
    if (shop.id == 0) {
      shop.id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    }
    await shopBox.put(shop.id, shop);
  }

  Future<List<ShopTypeModel>> getShopsForFarmer(int farmerId) async {
    return shopBox.values.where((s) => s.t_id_farmer == farmerId).toList();
  }

  Future<void> deleteShop(int serverId) async {
    final itemsToDelete = shopBox.values.where((s) => s.t_id_type == serverId).toList();
    for (var item in itemsToDelete) {
      await shopBox.delete(item.id);
    }
  }

  Future<List<ShopTypeModel>> getUnsyncedShops() async {
    return shopBox.values.where((s) => s.is_synced == false).toList();
  }

  // --- Update or Save Logic (بۆ ڕێگری لە دووبارەبوونەوە) ---

  Future<void> saveOrUpdateShop(ShopTypeModel shop) async {
    final existingShop = shopBox.values.firstWhere(
      (s) => s.t_id_type == shop.t_id_type,
      orElse: () => ShopTypeModel(id: -1),
    );

    if (existingShop.id != -1) {
      shop.id = existingShop.id;
    } else if (shop.id == 0) {
      shop.id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    }
    await shopBox.put(shop.id, shop);
  }

  Future<void> saveOrUpdateDriver(Driver driver) async {
    final existingDriver = driverBox.values.firstWhere(
      (d) => d.d_id_farmer == driver.d_id_farmer,
      orElse: () => Driver(id: -1),
    );

    if (existingDriver.id != -1) {
      driver.id = existingDriver.id;
    } else if (driver.id == 0) {
      driver.id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    }
    await driverBox.put(driver.id, driver);
  }

  Future<List<Driver>> getDriversForUser(int userId) async {
    return driverBox.values.where((d) => d.id_farmer_user == userId).toList();
  }
  
  // --- ئەم دوو فەنکشنە زیاد بکە بۆ ئەوەی ئیرەرەکان نەمێنن ---

  Future<void> deleteLocalDriverWork(int id) async {
    await driverWorkBox.delete(id);
  }

  Future<void> deleteLocalShop(int id) async {
    await shopBox.delete(id);
  }

}