# 🐕 PetOut - Changelog

Todos los cambios importantes en la app se documentan aquí.

---

## [2.1.0] - 2026-04-20 - Release Adventure + Maps + Photos + Themes

### 🎨 Selector de Temas por Raza (12 temas)
- **Sistema `pet_breeds.dart`** con 12 temas completos
- Perros: Beagle, Husky, Golden Retriever, Pastor Alemán, Bulldog, Dálmata
- Gatos: Siamés, Persa
- Especiales: Arcoíris, Nocturn, Jungla, Océano
- Cada tema incluye: colores primarios/secundarios, gradientes, dark mode específico
- **Pantalla `theme_selector_screen.dart`** con grid visual de temas
- Selector de tema premium con preview en tiempo real

### 🗺️ Mapa con Veterinarios y Lugares Cercanos
- **Pantalla `map_screen.dart`** completamente nueva
- Filtros por tipo: Veterinarios, Tiendas, Parques, Peluquerías, 24h
- **Veterinarios más cercanos a Viña del Mar** (datos de ejemplo)
- OpenStreetMap con tiles personalizados para dark mode
- Tarjetas de lugar con información detallada
- Acciones: "Cómo Llegar" y "Llamar"
- Centro inicial: Viña del Mar, Chile

### 🎬 Modo Aventura
- **Pantalla `adventure_map_screen.dart`** con sistema de misiones
- 4 rutas predefinidas en Viña del Mar:
  - Playa Acapulco Run (1.5 km)
  - Cerro Castillo Trek (2.3 km)
  - Parque Alejo Loyola (2.0 km)
  - Sector 21 - Mirador (1.0 km)
- Tracking de ruta en tiempo real
- Badges por ruta: 🏖️🌊🏔️🎯🌳🎪👀🏆
- Confetti al completar misión
- Diálogo de celebración con badges desbloqueados

### 📸 Galería de Fotos
- **Pantalla `photo_gallery_screen.dart`** completa
- Fotos organizadas por actividad
- Captura de fotos con `image_picker`
- Visor de fotos full screen con Hero animations
- Almacenamiento organizado por actividad
- Chip selector para filtrar por tipo
- Empty state con CTA

### 📦 Dependencias Nuevas
- `flutter_map: ^7.0.2` - Mapas interactivos
- `latlong2: ^0.9.1` - Coordenadas geográficas
- `geolocator: ^13.0.2` - Ubicación GPS

---

## [2.0.0] - 2026-04-20 - Release Premium

### 🎨 UI/UX Premium
- **Sistema de colores rediseñado** con paleta completa para light/dark mode
- **Dark mode premium** con colores específicos (`#0A0A0B` background, `#1C1C1F` cards)
- **Nuevos gradientes** para cada actividad (walk, bath, food) con versión dark
- **Shimmer effect** y **glow gradients** para elementos destacados
- **Onboarding mejorado** con animaciones `easeOutBack`, iconos por slide, skip button

### 📝 Documentation
- **README.md completo** con badges, features, tech stack, instalación
- **Sistema de colores documentado** con tabla de colores

### 🔧 Refactoring
- **`app_colors.dart`** reescrito con documentación completa y estructura clara
- Comentarios detallados en cada sección

---

## [1.0.0] - 2026-04-19 - Initial Release

### ✨ Features
- Pantalla de onboarding con 3 slides
- Timers visuales para paseo, baño y comida
- Sistema de mascotas con múltiples mascotas
- Notificaciones locales
- Sonidos de actividad
- Gráficos de estadísticas con fl_chart
- Sistema de logros con confetti
- Historial de actividades
- Soporte dark mode básico
- Persistencia local con shared_preferences

---

## Roadmap

### 🔜 Próximas versiones
- [ ] Widget de home screen para iOS/Android
- [ ] Widget de estadísticas en lockscreen
- [ ] Integración con Apple Health / Google Fit
- [ ] Modo "No molestar" durante timer
- [ ] Copia de seguridad en la nube
- [ ] Modo multi-mascota avanzado
- [ ] Sistema XP con niveles
- [ ] Chat "Tu Mascota Habla"

---

<div align="center">

**PetOut** - Hecho con ❤️ para mascotas de apartamento

</div>
