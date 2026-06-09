import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio encargado de gestionar todos los procesos de autenticación de la aplicación.
/// Soporta Firebase Auth, Google Sign-In y un modo invitado local.
class AuthService extends ChangeNotifier {
  // Instancia única de FirebaseAuth para la gestión de usuarios.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Instancia de Firestore para metadatos de usuario (VIP).
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Instancia para gestionar el inicio de sesión con cuentas de Google.
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isGuest = false;
  bool get isGuest => _isGuest;

  bool _isVip = false;
  bool get isVip => _isVip;

  static const String _sessionKey = 'keep_logged_in';

  AuthService() {
    _checkPersistence();
    // Escuchar cambios de autenticación para cargar metadatos automáticamente
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadUserMetadata(user.uid);
      } else if (!_isGuest) {
        _isVip = false;
        notifyListeners();
      }
    });
  }

  /// Carga metadatos del usuario desde Firestore (como el estado VIP).
  Future<void> _loadUserMetadata(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _isVip = doc.data()?['isVip'] ?? false;
      } else {
        // Si el documento no existe, lo creamos con valores por defecto
        await _firestore.collection('users').doc(uid).set({'isVip': false});
        _isVip = false;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error cargando metadatos de usuario: $e");
    }
  }

  /// Verifica si existe una sesión persistente al iniciar el servicio.
  Future<void> _checkPersistence() async {
    final prefs = await SharedPreferences.getInstance();
    final keepLoggedIn = prefs.getBool(_sessionKey) ?? false;
    
    // Si NO marcó el tick, cerramos sesión al abrir para forzar el login
    if (!keepLoggedIn) {
      await signOut(clearPersistence: false);
    }
  }

  /// Define si se debe mantener la sesión iniciada.
  Future<void> setPersistence(bool keep) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sessionKey, keep);
  }

  /// Obtiene un flujo (Stream) que emite cambios cada vez que el usuario inicia o cierra sesión.
  Stream<User?> get userStream => _auth.authStateChanges();

  /// Retorna la información del usuario actualmente autenticado, si existe.
  User? get currentUser => _auth.currentUser;

  /// Inicia sesión como invitado (local).
  void signInAsGuest() {
    _isGuest = true;
    _isVip = false;
    notifyListeners();
  }

  /// Inicia el flujo de autenticación con una cuenta de Google.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      _isGuest = false;
      if (result.user != null) {
        await _loadUserMetadata(result.user!.uid);
      }
      return result;
    } catch (e) {
      debugPrint("Error en inicio con Google: $e");
      rethrow;
    }
  }

  /// Inicia sesión utilizando correo y contraseña.
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      _isGuest = false;
      if (result.user != null) {
        await _loadUserMetadata(result.user!.uid);
      }
      return result;
    } catch (e) {
      debugPrint("Error en inicio de sesión por email: $e");
      rethrow;
    }
  }

  /// Crea una nueva cuenta de usuario en Firebase.
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _isGuest = false;
      if (result.user != null) {
        await _loadUserMetadata(result.user!.uid);
      }
      return result;
    } catch (e) {
      debugPrint("Error en registro de nuevo usuario: $e");
      rethrow;
    }
  }

  /// Cierra definitivamente la sesión.
  Future<void> signOut({bool clearPersistence = true}) async {
    try {
      if (clearPersistence) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_sessionKey);
      }
      
      await _googleSignIn.signOut();
      await _auth.signOut();
      _isGuest = false;
      _isVip = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Error al cerrar sesión: $e");
    }
  }

  /// Cambia el estado VIP del usuario y lo persiste en Firestore.
  Future<void> toggleVip() async {
    if (_isGuest || _auth.currentUser == null) return;
    
    try {
      final newVipStatus = !_isVip;
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'isVip': newVipStatus,
      });
      _isVip = newVipStatus;
      notifyListeners();
    } catch (e) {
      debugPrint("Error al actualizar estado VIP: $e");
    }
  }
}
