# Estructura y convenciones de nombres

Contexto fijo para el agente. La estructura completa está en el `README.md` de la raíz.

## Organización

- `src/radiant/`: paquete Python, un subpaquete por componente (`generator`, `fhir`, `rules`, `nlp`, `ml`, `evaluation`, `alerts`, `audit`, `rag`, `questionnaires`, `imaging`, `multimodal`).
- `api/`: servicio FastAPI que usa el paquete `radiant`.
- `web/`: panel React con TypeScript.
- `configs/`: configuración en YAML.
- `data/`: datos generados y externos; no se versiona su contenido.
- `tests/`: `unit/`, `property/` e `integration/`.
- `docs/`: documentación en español (memoria, marca, ideas, revisión clínica).
- `.kiro/`: especificación (requisitos, diseño, tareas) y contexto fijo.

## Idioma

- **Código, nombres de archivos de código, configuración y tests: en inglés.** Por ejemplo `rules_engine.py`, `small_cohort.yaml`, `thresholds.yaml`, `test_rules_engine.py`.
- **Documentación, interfaz y mensajes al usuario: en español.**
- Los términos clínicos del dominio pueden mantener el nombre en español dentro del código solo si no tienen traducción clara; en ese caso se documentan en el glosario de los requisitos.

## Nombres

- Python: `snake_case` para módulos, funciones y variables; `PascalCase` para clases.
- Tests: `test_<modulo>.py`, con una función por comportamiento.
- Configuración: `snake_case.yaml`.
- React: componentes en `PascalCase.tsx`; el resto en `camelCase.ts`.
- Variables CSS con el prefijo `--atopi-`.

## Reglas

- Ningún secreto en el repositorio: se usan variables de entorno y `.env` (ignorado por Git).
- Cada proceso aleatorio recibe su semilla de la configuración.
- Los datos generados no se versionan; se regeneran con el comando del pipeline.
