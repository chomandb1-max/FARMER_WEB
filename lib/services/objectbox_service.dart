import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../objectbox.g.dart'; // ئەمە زۆر گرنگە، دواتر دروست دەبێت
import '../models/expense_model.dart';
import '../models/farmer_product_model.dart';
import '../models/driver_model.dart';
import '../models/driver_work_model.dart';
import '../models/shop_type_model.dart';

class ObjectBoxService {
  late final Store store;

  // Box-ەکان بۆ هەر مۆدێلێک
  late final Box<FarmerProductModel> productBox;
  late final Box<ExpenseModel> expenseBox;
  late final Box<Driver> driverBox;
  late final Box<DriverWork> driverWorkBox;
  late final Box<ShopTypeModel> shopBox;

  // دروستکردنی سینگڵتۆن (Singleton) بۆ ئەوەی تەنها یەک جار داتابەیسەکە بکرێتەوە
  static ObjectBoxService? _instance;
  ObjectBoxService._create(this.store) {
    productBox = Box<FarmerProductModel>(store);
    expenseBox = Box<ExpenseModel>(store);
    driverBox = Box<Driver>(store);
    driverWorkBox = Box<DriverWork>(store);
    shopBox = Box<ShopTypeModel>(store);
  }

  static Future<ObjectBoxService> create() async {
    if (_instance == null) {
      final docsDir = await getApplicationDocumentsDirectory();
      final store = await openStore(directory: p.join(docsDir.path, "objectbox"));
      _instance = ObjectBoxService._create(store);
    }
    return _instance!;
  }

  // --- بەرهەمەکان (Products) ---

  Future<void> saveProduct(FarmerProductModel newProduct) async {
    productBox.put(newProduct);
  }

  Future<List<FarmerProductModel>> getProductsForFarmer(int farmerId) async {
    final query = productBox.query(FarmerProductModel_.id_farmer_user.equals(farmerId)).build();
    final results = query.find();
    query.close();
    return results;
  }

  Future<void> deleteProduct(int serverId) async {
    final query = productBox.query(FarmerProductModel_.id_product.equals(serverId)).build();
    final item = query.findFirst();
    if (item != null) {
      productBox.remove(item.id);
    }
    query.close();
  }

  Future<void> deleteLocalProduct(int id) async {
    productBox.remove(id);
  }

  // --- خەرجییەکان (Expenses) ---

  Future<void> saveExpense(ExpenseModel newExpense) async {
    expenseBox.put(newExpense);
  }

  Future<List<ExpenseModel>> getExpensesForFarmer(int farmerId) async {
    final query = expenseBox.query(ExpenseModel_.id_farmer_user.equals(farmerId)).build();
    final results = query.find();
    query.close();
    return results;
  }

  Future<void> deleteExpense(int serverId) async {
    final query = expenseBox.query(ExpenseModel_.id_expense.equals(serverId)).build();
    final item = query.findFirst();
    if (item != null) {
      expenseBox.remove(item.id);
    }
    query.close();
  }

  Future<void> deleteLocalExpense(int id) async {
    expenseBox.remove(id);
  }

  Future<List<ExpenseModel>> getUnsyncedExpenses() async {
    final query = expenseBox.query(ExpenseModel_.is_synced.equals(false)).build();
    final results = query.find();
    query.close();
    return results;
  }

  // --- سایەق و ئیشی سایەق (Driver & Work) ---

  Future<void> saveDriver(Driver driver) async {
    driverBox.put(driver);
  }

  Future<List<Driver>> getAllDrivers() async {
    return driverBox.getAll();
  }

  Future<void> saveDriverWork(DriverWork work) async {
    driverWorkBox.put(work);
  }

  Future<List<DriverWork>> getUnsyncedWorks() async {
    final query = driverWorkBox.query(DriverWork_.is_synced.equals(false)).build();
    final results = query.find();
    query.close();
    return results;
  }

  Future<void> deleteDriverWork(int idWorkFromSupabase) async {
    // تێبینی: لێرە لە جیاتی id، بەدوای کۆڵۆمی id_work یان هاوشێوە دەگەڕێین ئەگەر هەبێت
    // ئەگەر مەبەستت ئایدی ناوخۆییەکەیە (id)، ئەوا:
    driverWorkBox.remove(idWorkFromSupabase);
  }

  Future<void> deleteLocalDriverWork(int id) async {
    driverWorkBox.remove(id);
  }

  // --- نوسینگەکان (Shops) ---

  Future<void> saveShop(ShopTypeModel shop) async {
    shopBox.put(shop);
  }

  Future<List<ShopTypeModel>> getShopsForFarmer(int farmerId) async {
    final query = shopBox.query(ShopTypeModel_.t_id_farmer.equals(farmerId)).build();
    final results = query.find();
    query.close();
    return results;
  }

  Future<void> deleteShop(int serverId) async {
    final query = shopBox.query(ShopTypeModel_.t_id_type.equals(serverId)).build();
    shopBox.removeMany(query.find().map((e) => e.id).toList());
    query.close();
  }

  Future<List<ShopTypeModel>> getUnsyncedShops() async {
    final query = shopBox.query(ShopTypeModel_.is_synced.equals(false)).build();
    final results = query.find();
    query.close();
    return results;
  }

  // ئەمە بخەرە ناو کلاسی ObjectBoxService
  Future<void> saveOrUpdateShop(ShopTypeModel shop) async {
  // ۱. دەگەڕێین بزانین ئایا ئەم نوسینگەیە پێشتر لە مۆبایلەکە هەیە؟
  // تێبینی: ShopTypeModel_ ناوی کڵاسەکەتە لەگەڵ ئەندەرسکۆر
  final query = shopBox
      .query(ShopTypeModel_.t_id_type.equals(shop.t_id_type!))
      .build();
  
  final existingShop = query.findFirst();
  query.close();

  if (existingShop != null) {
    // ۲. ئەگەر هەبوو، ئایدییە لۆکاڵییەکەی (id) دەدەینە نوێیەکە تا نوێی (Update) بکاتەوە نەک زیادی بکات
    shop.id = existingShop.id;
  }
  
  // ۳. ئێستا بەبێ کێشەی Unique Constraint پاشەکەوتی دەکات
  shopBox.put(shop);
  }

  // ئەم فەنکشنە بۆ ئەوەیە جوتیارەکان لە ناو مۆبایلەکەدا نوێ بکاتەوە یان زیادیان بکات
  Future<void> saveOrUpdateDriver(Driver driver) async {
    // ١. دەگەڕێین بزانین ئایا ئەم جوتیارە پێشتر بەم (d_id_farmer)ە لە مۆبایلەکە هەیە؟
    // d_id_farmer ئەو ئایدییە یە کە لە سێرڤەرەوە (Supabase) دێت
    final query = driverBox
        .query(Driver_.d_id_farmer.equals(driver.d_id_farmer ?? 0))
        .build();
    
    final existingDriver = query.findFirst();
    query.close();

    if (existingDriver != null) {
      // ٢. ئەگەر هەبوو، ئایدییە ناوخۆییەکەی (id) دەدەینە نوێیەکە تاوەکو Updateی بکات
      driver.id = existingDriver.id;
    }
    
    // ٣. پاشەکەوتکردن لە ناو مۆبایل
    driverBox.put(driver);
  }

  // فەنکشنێک بۆ هێنانی لیستی جوتیارەکان بەپێی ئایدی خاوەن مەکینەکە (Driver/User)
  Future<List<Driver>> getDriversForUser(int userId) async {
    final query = driverBox
        .query(Driver_.id_farmer_user.equals(userId))
        .build();
    final results = query.find();
    query.close();
    return results;
  }


}