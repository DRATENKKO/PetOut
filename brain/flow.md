---
slug: flow
title: Key flows
role: key flows
updated: "2026-07-02T09:00:10"
---

# Key flows

```mermaid
sequenceDiagram
  participant User as Dueño mascota
  participant Home as Home PetOut
  participant Timer as Rutina diaria
  participant Store as Persistencia local
  User->>Home: abre app
  Home->>Store: lee estado diario
  Home-->>User: muestra plan inteligente de hoy
  User->>Timer: inicia paseo/baño/comida
  Timer->>Store: guarda actividad y duración
  Store-->>Home: actualiza progreso real
  Home-->>User: racha/logro/siguiente sugerencia
```
