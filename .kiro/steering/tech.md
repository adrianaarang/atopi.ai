# Stack técnico y convenciones

Contexto fijo para el agente. Detalles y justificación en `.kiro/specs/radiant/design.md`.

## Stack

- Python 3.11, gestionado con `uv` y archivo de bloqueo de dependencias.
- Synthea (Java) para la generación base y posprocesado en Python.
- FHIR R4, validación con `fhir.resources`.
- API con FastAPI; almacenamiento en SQLite en el MVP.
- Frontend con React, TypeScript y Vite, con CSS propio y variables `--atopi-*`.
- Tests con pytest y Hypothesis; accesibilidad con `eslint-plugin-jsx-a11y` y axe.
- Docker Compose para el entorno local.

## Convenciones

- Código y comentarios técnicos en inglés; interfaz, documentación y mensajes de usuario en español.
- Todo es reproducible: cada proceso aleatorio recibe una semilla de la configuración.
- Nunca usar la etiqueta de verdad-terreno, el código CIE-10 L20 ni la gravedad latente como entrada de un modelo.
- Cada pantalla del panel muestra el aviso "Soporte a la decisión clínica. No constituye un diagnóstico. Datos sintéticos."
- El registro de auditoría es de solo añadir.
- Los estilos y componentes siguen `docs/brand/hoja-de-estilos-atopi-ai.md`.
