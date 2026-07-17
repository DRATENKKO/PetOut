# 🐾 PetOut

**Rutina clara para mascotas de departamento.**

PetOut es una app Flutter pensada para dueños de mascotas que quieren ordenar paseos, baños, comidas, fotos, lugares pet friendly y pequeños logros diarios sin convertir el cuidado en una planilla fome.

## Qué problema resuelve

Cuando tienes una mascota en departamento, lo difícil no es solo salir a pasear: es mantener una rutina consistente, recordar qué falta, registrar hábitos y tener lugares útiles cerca. PetOut organiza eso en una experiencia visual, cálida y rápida.

## Mejoras de producto aplicadas

- **Plan inteligente de hoy:** una tarjeta principal sugiere qué actividad falta según el registro diario.
- **Resumen real:** el home ahora muestra conteos reales desde almacenamiento local, no placeholders.
- **Explorar:** accesos rápidos a mapa pet friendly, modo aventura, galería y temas.
- **Onboarding más claro:** comunica la propuesta de valor antes que solo listar features.
- **UI más consistente:** cards redondeadas, sombras suaves, progreso visual, microcopy útil y acciones claras.
- **Mejor affordance:** las actividades indican que se puede mantener presionado para ajustar duración.

## Características actuales

### 🧭 Rutina diaria
- Paseos, baños y comidas con temporizador.
- Duraciones personalizables.
- Recomendación automática de la siguiente actividad del día.
- Progreso diario visual `0/3`, `1/3`, `2/3`, `3/3`.

### 🗺️ Lugares pet friendly
- Veterinarios.
- Tiendas de mascotas.
- Parques.
- Peluquerías caninas.
- Veterinarios 24 horas.

### 🎒 Modo aventura
- Rutas predefinidas en Viña del Mar.
- Distancias y tiempos estimados.
- Logros y celebración.

### 📸 Galería
- Captura de momentos por actividad.
- Organización local.
- Base para antes/después de paseos, baños o hitos.

### 🎨 Temas
- Temas por razas y estilos visuales.
- Perros, gatos y estilos especiales.

### 📊 Estadísticas
- Conteos por actividad.
- Rachas.
- Logros.
- Historial.

## Stack

| Tecnología | Uso |
|---|---|
| Flutter | App móvil multiplataforma |
| Dart | Lenguaje principal |
| flutter_bloc | Estado |
| shared_preferences | Persistencia local |
| flutter_map | Mapas |
| fl_chart | Estadísticas |
| image_picker | Galería/fotos |
| confetti | Celebraciones |
| flutter_local_notifications | Notificaciones |
| audioplayers | Sonidos |

## Instalación

```bash
flutter pub get
flutter run
```

Build Android:

```bash
flutter build apk --release
```

## Próximas mejoras recomendadas

- Guardar planes por horario: mañana/tarde/noche.
- Recordatorios configurables por mascota.
- Perfil de salud: vacunas, peso, alergias, veterinario.
- Exportar historial para veterinario.
- Sincronización opcional en la nube.
- Diseño adaptativo para tablets.

## Estado

Versión mejorada localmente con foco en producto + UI. Falta correr `flutter analyze/test/build` en una máquina con Flutter instalado, porque este entorno WSL no tiene el binario `flutter` disponible.
