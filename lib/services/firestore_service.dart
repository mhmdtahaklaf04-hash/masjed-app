import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

/// سرویس عمومی برای عملیات CRUD روی Firestore
/// تمام Repository ها از این سرویس استفاده می‌کنند
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> collection(String name) =>
      _db.collection(name);

  Future<String> create(String collectionName, Map<String, dynamic> data) async {
    final doc = await collection(collectionName).add(data);
    return doc.id;
  }

  Future<void> createWithId(
      String collectionName, String id, Map<String, dynamic> data) {
    return collection(collectionName).doc(id).set(data);
  }

  Future<void> update(
      String collectionName, String id, Map<String, dynamic> data) {
    return collection(collectionName).doc(id).update(data);
  }

  Future<void> delete(String collectionName, String id) {
    return collection(collectionName).doc(id).delete();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getById(
      String collectionName, String id) {
    return collection(collectionName).doc(id).get();
  }

  /// دریافت لیست با صفحه‌بندی (Pagination)
  Future<QuerySnapshot<Map<String, dynamic>>> getPaginated(
    String collectionName, {
    String orderBy = 'date',
    bool descending = true,
    DocumentSnapshot? startAfter,
    int limit = AppConstants.pageSize,
  }) {
    Query<Map<String, dynamic>> query = collection(collectionName)
        .orderBy(orderBy, descending: descending)
        .limit(limit);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    return query.get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection(
    String collectionName, {
    String orderBy = 'date',
    bool descending = true,
  }) {
    return collection(collectionName)
        .orderBy(orderBy, descending: descending)
        .snapshots();
  }

  /// جستجوی ساده بر اساس عنوان (prefix search)
  Future<QuerySnapshot<Map<String, dynamic>>> search(
    String collectionName,
    String field,
    String query,
  ) {
    return collection(collectionName)
        .orderBy(field)
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .get();
  }
}
