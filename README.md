# 🐕 PetOut - Premium Pet Activity Timers

<div align="center">

![PetOut Logo](assets/images/logo.png)

**La app definitiva para el cuidado de mascotas en departamentos**

✨ Timers visuales premium ✨ Logros y estadísticas ✨ Mapas ✨ Adventure Mode ✨ Fotos ✨ 12 Temas ✨

[![Flutter](https://img.shields.io/badge/Flutter-3.11+-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11+-0175C2?style=flat-square&logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)]()
[![Version](https://img.shields.io/badge/Version-2.1.0-blue?style=flat-square)]()

</div>

---

## 🎯 Características

### 🚶 Paseos
- Timer visual con cuenta regresiva animada
- Configuración de duración personalizada (5-120 min)
- Notificaciones al completar
- **Modo Aventura** con rutas GPS

### 🛁 Baño
- Timer con gradientes azules relajantes
- Sonidos de notificación personalizados
- Registro automático de actividades

### 🍖 Comida
- Recordatorios de alimentación
- Historial de comidas
- Estadísticas semanales

### 🗺️ Mapa de Veterinarios
- Veterinarios más cercanos con ubicación GPS
- Tiendas de mascotas
- Parques para paseo
- Peluquerías caninas
- Veterinarios 24 horas
- Filtros por tipo y acciones rápidas

### 🎬 Modo Aventura
- Rutas predefinidas por la ciudad
- Tracking de camino en tiempo real
- Badges desbloqueables por completar rutas
- Celebración con confetti
- 4 rutas iniciales en Viña del Mar

### 📸 Galería de Fotos
- Fotos antes/después de cada actividad
- Captura directa desde la app
- Visor full screen con zoom
- Organización por tipo de actividad

### 🎨 12 Temas Visuales
| Raza | Paleta | Descripción |
|------|--------|-------------|
| 🐕 Beagle | Café/Dorado | El clásico original |
| 🐺 Husky | Azul/Blanco | Ártico y fresco |
| 🦮 Golden | Dorado | Cálido y acogedor |
| 🐕‍🦺 Pastor | Negro/Fuego | Elegante y fuerte |
| 🐶 Bulldog | Gris | Sofisticado |
| 🐩 Dálmata | Blanco/Negro | Minimalista |
| 🐱 Siamés | Azul/Crema | Exótico |
| 😺 Persa | Rosa | Suave y dulce |
| 🦄 Arcoíris | Vibrante | Divertido |
| 🌙 Nocturn | Púrpura | Dark mode + |
| 🌿 Jungla | Verde | Natural |
| 🌊 Océano | Azul agua | Fresco |

### 🎖️ Sistema de Logros
- **9 logros únicos** para desbloquear
- Animaciones con confetti al completar
- Progreso guardado automáticamente

### 📊 Estadísticas
- Gráficos de actividad con fl_chart
- Historial por mascota
- Rachas de actividad

---

## 🛠️ Tech Stack

| Tecnología | Uso |
|------------|-----|
| Flutter 3.11+ | Framework principal |
| flutter_bloc | Estado con BLoC pattern |
| google_fonts | Tipografía Poppins |
| fl_chart | Gráficos de estadísticas |
| flutter_map | Mapas interactivos |
| latlong2 | Coordenadas GPS |
| image_picker | Captura de fotos |
| confetti | Animaciones de celebración |
| flutter_local_notifications | Notificaciones push |
| audioplayers | Sonidos de actividad |
| shared_preferences | Persistencia local |

---

## 📦 Instalación

```bash
# Clonar el repositorio
git clone https://github.com/tu-usuario/PetOut.git
cd PetOut

# Instalar dependencias
flutter pub get

# Ejecutar en desarrollo
flutter run

# Build release
flutter build apk --release
flutter build appbundle --release
```

### 📍 Configuración de Mapas

Para que los mapas funcionen correctamente, necesitas:

1. **Android** - Agregar en `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

2. **iOS** - Agregar en `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>PetOut necesita tu ubicación para mostrar veterinarios cercanos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>PetOut necesita acceso a tus fotos para guardar momentos con tu mascota</string>
```

---

## 🎨 Sistema de Diseño

### Colores

| Color | Hex | Uso |
|-------|-----|-----|
| Beagle Brown | `#C4813A` | Color primario |
| Beagle Tan | `#E8C07D` | Color secundario |
| Beagle Cream | `#F5EBE0` | Fondo modo claro |
| Dark BG | `#0A0A0B` | Fondo modo oscuro |

### Tipografía
- **Poppins** (Google Fonts)
- Pesos: 400, 500, 600, 700

---

## 📱 Screenshots

> _(Agregar screenshots en /assets/screenshots/)_

---

## 🗺️ Rutas de Aventura

Las rutas iniciales están basadas en **Viña del Mar, Chile**:

1. **Playa Acapulco Run** - 1.5 km
   - 🏖️🌊
   - Paseo por la costanera

2. **Cerro Castillo Trek** - 2.3 km
   - 🏔️🎯
   - Vistas panorámicas

3. **Parque Alejo Loyola** - 2.0 km
   - 🌳🎪
   - Zona de juegos

4. **Sector 21 - Mirador** - 1.0 km
   - 👀🏆
   - Ruta corta pero intensa

---

## 🤝 Contribuir

1. Fork el repositorio
2. Crea una rama (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -m 'feat: nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

---

## 📄 Licencia

MIT License - ver archivo [LICENSE](LICENSE) para más detalles.

---

## 👨‍💻 Autor

**Tu Nombre** - [tu-email@ejemplo.com](mailto:tu-email@ejemplo.com)

---

<div align="center">

Hecho con ❤️ y 🐕 usando Flutter

</div>
