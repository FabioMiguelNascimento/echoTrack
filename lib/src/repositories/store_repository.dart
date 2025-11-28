import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:g1_g2/src/models/store_model.dart';

class StoreRepository {
  final _db = FirebaseFirestore.instance;
  final String _collection = 'stores';

  Future<void> createStore(StoreModel store) async {
    await _db.collection(_collection).doc(store.uid).set(store.toJson());
  }

  /// Uploads a store image to Firebase Storage and returns the download URL.
  Future<String> uploadStoreImage(String uid, XFile file) async {
    final storage = FirebaseStorage.instance;
    final ref = storage
        .ref()
        .child('stores')
        .child(uid)
        .child('avatar_${DateTime.now().millisecondsSinceEpoch}.jpg');

    final localFile = File(file.path);
    if (!await localFile.exists()) {
      throw Exception('Arquivo não encontrado no caminho: ${file.path}');
    }

    // Try to infer a content type from the file extension
    String contentType = 'application/octet-stream';
    final lower = file.path.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      contentType = 'image/jpeg';
    } else if (lower.endsWith('.png')) {
      contentType = 'image/png';
    }

    try {
      final metadata = SettableMetadata(contentType: contentType);
      final uploadTask = ref.putFile(localFile, metadata);
      // Await the UploadTask itself to obtain the TaskSnapshot
      await uploadTask;
      // Ensure the file was uploaded before getting download URL
      final url = await ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      // Provide more context for the caller
      throw Exception('FirebaseStorage error (${e.code}): ${e.message}');
    } catch (e) {
      throw Exception('Erro ao enviar imagem: $e');
    }
  }

  Future<StoreModel?> getStoreById(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return StoreModel.fromJson(doc);
  }

  Future<void> updateStore(String id, StoreModel updated) async {
    await _db.collection(_collection).doc(id).update(updated.toJson());
  }

  /// Deletes the store document for the given uid.
  Future<void> deleteStore(String uid) async {
    final storage = FirebaseStorage.instance;

    // 1) Delete all files under storage path 'stores/{uid}/'
    final rootRef = storage.ref().child('stores').child(uid);
    Future<void> _deleteRef(Reference ref) async {
      final list = await ref.listAll();
      // delete files
      for (final item in list.items) {
        await item.delete();
      }
      // recurse on prefixes (subfolders)
      for (final prefix in list.prefixes) {
        await _deleteRef(prefix);
      }
    }

    try {
      await _deleteRef(rootRef);
    } catch (e) {
      // ignore if folder does not exist or other storage errors; continue with Firestore cleanup
    }

    // 2) Delete coupons related to this store and any user_coupons referencing them
    try {
      final couponsSnap = await _db
          .collection('coupons')
          .where('storeId', isEqualTo: uid)
          .get();
      for (final doc in couponsSnap.docs) {
        final couponId = doc.id;
        // delete user_coupons referencing this coupon
        final userCoupons = await _db
            .collection('user_coupons')
            .where('couponId', isEqualTo: couponId)
            .get();
        for (final uc in userCoupons.docs) {
          await uc.reference.delete();
        }
        // delete coupon
        await doc.reference.delete();
      }
    } catch (e) {
      // log/ignore and continue
    }

    // 3) Delete the store document itself
    await _db.collection(_collection).doc(uid).delete();
  }
}
