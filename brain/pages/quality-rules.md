---
id: quality-rules
title: Reglas de calidad para cambios en PetOut
category: decision
status: active
created: "2026-07-02T09:00:11"
updated: "2026-07-02T09:49:10"
---

## compiled_truth

PetOut se verifica con `flutter analyze`, `flutter test` y `flutter build web --no-tree-shake-icons` antes de considerar lista una mejora. El timer debe mantener sincronizadas las notificaciones: cancelar programadas viejas al iniciar/resetear/completar, reprogramar al cambiar duración y no dejar avisos fantasma al pasar a modo infinito.

Cambios de UX validados: registrar rápido “Ya está hecho” debe respetar duración personalizada; la home muestra momentum diario (3/3, minutos y racha) para dar feedback útil sin abrumar.


## timeline

- time: 2026-07-02T09:00:11
  kind: decision
  summary: "Created this page: Reglas de calidad para cambios en PetOut"
  source: Hermes setup inicial
  affects: [quality-rules]

- time: 2026-07-02T09:00:11
  kind: decision
  summary: Seed inicial de conocimiento durable del proyecto
  source: "Hermes + archivos del proyecto"
  affects: [quality-rules]

- time: 2026-07-02T09:49:10
  kind: decision
  summary: "Actualización tras auditoría y mejoras verificadas 2026-07-02"
  source: Hermes audit run
  affects: [quality-rules]
