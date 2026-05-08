/// ⚠️ App Configuration - NO COMMIT THIS FILE
///
/// Este archivo contiene API keys y configuraciones sensibles.
/// NO lo subas a ningún repositorio público.
///
/// Para usar este archivo:
/// 1. Copia este archivo a api_config.dart
/// 2. Añade tu API key de Google Maps si es necesaria
/// 3. Asegúrate de que api_config.dart esté en .gitignore
///
/// Nota: PetOut usa OpenStreetMap por defecto, que no requiere API key.
/// Solo necesitas una key si decides usar Google Maps tiles.
class ApiConfig {
  static const String googleMapsApiKey = 'YOUR_API_KEY_HERE';
  static const String mapTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const bool useGoogleTiles = false;
}
