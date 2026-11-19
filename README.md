# RADIANT · atopi.ai

![Logotipo de atopi.ai: una gotita azul sonriente con una estrella amarilla](docs/brand/assets/atopi-logo.svg)

Panel web que avisa al personal sanitario de niños con posible dermatitis atópica moderada-grave que aún no tienen el diagnóstico en su historia clínica.

> Soporte a la decisión clínica. No constituye un diagnóstico. Todos los datos son sintéticos.

**Estado:** en desarrollo. Los requisitos, el diseño y el plan de la fase 1 están cerrados. Todavía no hay nada ejecutable: la implementación empieza por la tarea 1 de `.kiro/specs/radiant/tasks.md`.

## El problema

La dermatitis atópica (DA) pediátrica moderada-grave se queda sin diagnosticar con frecuencia. Los niños acumulan consultas por picor, infecciones de piel y tratamientos tópicos sin que nadie junte las piezas ni los derive a tiempo.

Las historias clínicas reales no se pueden usar en un proyecto así. Por eso trabajo con datos sintéticos y construyo un sistema que se pueda evaluar sin exponer a ningún paciente.

## Qué hace

La fase 1 (MVP) entrega:

- Una cohorte pediátrica sintética en FHIR R4, con notas clínicas en español.
- Un motor de reglas que aplica un criterio de derivación basado en fuentes clínicas publicadas.
- Una lista de alertas ordenada por riesgo, cada una con los criterios que la explican.
- Un registro de auditoría de cada decisión del profesional (aceptar o rechazar con motivo).
- Un panel en español, accesible (WCAG 2.1 AA) y con el aviso de uso visible en todas las pantallas.

Las fases 2 a 4 añaden modelos con explicabilidad, un asistente de tratamientos con RAG y un módulo de imagen opcional.

## Cómo lo construí

- **Datos:** Synthea con un módulo propio de DA y posprocesado en Python.
- **Núcleo:** Python 3.11, `fhir.resources`, pytest y Hypothesis.
- **API:** FastAPI con SQLite y autenticación por cookie con protección CSRF.
- **Panel:** React, TypeScript y Vite, con estilos propios.

Decisión clave: el generador no puede regalar la respuesta. La gravedad real del niño no aparece en los datos, las señales observables son probabilísticas y el ruido de etiqueta solo afecta al entrenamiento. Las métricas se dan con la etiqueta limpia y con la ruidosa, y declaro que el riesgo de circularidad se reduce, no se elimina.

Más decisiones, con su porqué y lo que cedí en cada una, en [`docs/decisiones.md`](docs/decisiones.md).

## Aprendizajes

- Con datos sintéticos, el mayor riesgo es evaluar al sistema con la misma lógica que generó los datos. Una revisión me señaló que aplicaba el ruido a la etiqueta de evaluación; lo moví solo al entrenamiento.
- Un criterio de derivación pediátrico no se improvisa. Las guías disponibles son sobre todo para adultos o están sin fechar, y por eso el borrador de criterios está pendiente de validación clínica.
- Escribir los requisitos con un formato validable (EARS y encabezados estándar) me hizo detectar contradicciones antes de escribir código.

## Próximos pasos

1. Que un revisor clínico valide el criterio de derivación antes de la tarea 5.3.
2. Decidir si el generador simula infecciones cutáneas, que tres condiciones del criterio necesitan.
3. Implementar la fase 1 por semanas (8 en total) y publicar la primera demo.
4. Fases 2 a 4, solo si la fase 1 está cerrada.

## Documentación

- Requisitos: [`.kiro/specs/radiant/requirements.md`](.kiro/specs/radiant/requirements.md)
- Diseño técnico: [`.kiro/specs/radiant/design.md`](.kiro/specs/radiant/design.md)
- Plan de tareas: [`.kiro/specs/radiant/tasks.md`](.kiro/specs/radiant/tasks.md)
- Mapa de carpetas y archivos: [`docs/estructura.md`](docs/estructura.md)
- Marca y hoja de estilos: [`docs/brand/`](docs/brand/)

## Quién lo mantiene

Adriana Aránguez García, en solitario, como proyecto de mentoría con Sanofi (Saturno Academy). [LinkedIn](https://www.linkedin.com/in/adriana-aranguez/)
