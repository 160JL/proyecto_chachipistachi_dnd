import 'dart:io';

/// Servicio para gestionar los IDs de publicidad de Google AdMob.
class AdService {
  /// Retorna el ID de la unidad de anuncio para el banner.
  /// Se utilizan IDs de prueba proporcionados por Google.
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // ID de prueba Android
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // ID de prueba iOS
    } else {
      throw UnsupportedError('Plataforma no soportada para anuncios');
    }
  }
}
