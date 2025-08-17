// lib/services/auth_service.dart
import 'package:pedeai/Commom/supabaseConf.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = SupabaseConfig.client;
  final SupabaseClient _adminClient = SupabaseConfig.adminClient;

  // Verificar se usuário está logado
  bool get isLoggedIn => _client.auth.currentUser != null;

  // Obter usuário atual
  User? get currentUser => _client.auth.currentUser;

  // Obter token atual
  String? get currentToken => _client.auth.currentSession?.accessToken;

  // Stream para mudanças de autenticação
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Verificar se email foi confirmado
  bool get isEmailConfirmed => currentUser?.emailConfirmedAt != null;

  // Login
  Future<AuthResponse> signIn({required String email, required String password}) async {
    try {
      final response = await _client.auth.signInWithPassword(email: email, password: password);
      return response;
    } catch (e) {
      throw Exception('Erro ao fazer login: ${e.toString()}');
    }
  }

  // Cadastro
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    /*required String name,
    String? phone,*/
    Map<String, dynamic>? metadata,
  }) async {
    try {
      //final response = await _client.auth.signUp(email: email, password: password, data: {'name': name, if (phone != null) 'phone': phone, if (metadata != null) ...metadata});
      final response = await _client.auth.signUp(email: email, password: password, data: {if (metadata != null) ...metadata});
      return response;
    } catch (e) {
      throw Exception('Erro ao criar conta: ${e.toString()}');
    }
  }

  // Reset de senha
  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email, redirectTo: 'your-app://reset-password');
    } catch (e) {
      throw Exception('Erro ao enviar email de recuperação: ${e.toString()}');
    }
  }

  // Atualizar senha
  Future<UserResponse> updatePassword({required String newPassword}) async {
    try {
      final response = await _client.auth.updateUser(UserAttributes(password: newPassword));
      return response;
    } catch (e) {
      throw Exception('Erro ao atualizar senha: ${e.toString()}');
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Erro ao fazer logout: ${e.toString()}');
    }
  }

  // Reenviar email de confirmação
  Future<void> resendConfirmationEmail() async {
    if (currentUser?.email != null) {
      try {
        await _client.auth.resend(type: OtpType.signup, email: currentUser!.email!);
      } catch (e) {
        throw Exception('Erro ao reenviar email de confirmação: ${e.toString()}');
      }
    }
  }

  // No seu AuthService, adicione este método:
Future<String?> emailJaExiste(String email) async {
  try {
    final response = await _adminClient.auth.admin.listUsers();
    
    // Procura o usuário pelo email
    for (final user in response) {
      if (user.email == email) {
        return user.id; // Retorna o UID se encontrar
      }
    }
    
    return null; // Retorna null se não encontrar
  } catch (e) {
    return null; // Retorna null em caso de erro
  }
}

  Future<void> deletarUsuario(String uid) async {
    try {
      await _adminClient.auth.admin.deleteUser(uid);
    } catch (e) {
      throw Exception('Erro ao deletar usuário: ${e.toString()}');
    }
  }
}
