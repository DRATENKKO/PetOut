---
slug: architecture
title: System architecture
role: system architecture
updated: "2026-07-02T09:00:10"
---

# System architecture

App móvil Flutter con arquitectura simple por capas y estado con Cubits/BLoC. La persistencia actual es local.

```mermaid
graph TD
  UI[Screens / Widgets] --> Cubits[Cubits / BLoC]
  Cubits --> Models[Models]
  Cubits --> Services[Services]
  Services --> Local[shared_preferences / local files]
  UI --> Maps[flutter_map / geolocator]
  UI --> Media[image_picker / local notifications / audio]
```

## Principio
Preferir mejoras pequeñas y útiles, con feedback visual, antes que reestructuraciones grandes.
