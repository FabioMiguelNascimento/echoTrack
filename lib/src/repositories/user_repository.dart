import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g1_g2/src/models/base/user_base_model.dart';

class UserRepository {
  final _db = FirebaseFirestore.instance;
  final String _collectionPath = 'users';

  // O método agora retorna a CLASSE BASE
  Future<UsuarioBaseModel?> getUserData(String uid) async {
    try {
      final doc = await _db.collection(_collectionPath).doc(uid).get();
      if (!doc.exists) return null;

      // A MÁGICA:
      // Quando você chama esse factory, ele vai ler o campo 'role'
      // e retornar automaticamente um AdminModel, LojaModel ou ClienteModel.
      return UsuarioBaseModel.fromJson(doc);
    } catch (e) {
      throw Exception('Erro ao buscar dados do usuário: $e');
    }
  }

  /// Retorna os dados brutos do documento do usuário (útil para campos extras)
  Future<Map<String, dynamic>?> getUserRawData(String uid) async {
    try {
      final doc = await _db.collection(_collectionPath).doc(uid).get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      throw Exception('Erro ao buscar dados brutos do usuário: $e');
    }
  }

  // Para criar um usuário, você passa qualquer modelo filho
  Future<void> createUserData(UsuarioBaseModel usuario) async {
    // O método toJson() correto (de admin, loja ou cliente) será chamado
    await _db
        .collection(_collectionPath)
        .doc(usuario.uid)
        .set(usuario.toJson());
  }
}
