# Plan de implementación · Fase 1

Tareas de la fase 1 (MVP), siguiendo el plan por semanas de `design.md`. Cada tarea indica los requisitos que cubre. Las fases 2 a 4 se desglosarán al cerrar la anterior.

- [ ] 1. Entorno y base del proyecto (semana 1)
  - [ ] 1.1 Crear el repositorio con la estructura de carpetas, `pyproject.toml` y archivo de bloqueo (`uv lock`)
  - [ ] 1.2 Preparar Docker Compose para el entorno local
  - [ ] 1.3 Ejecutar Synthea y revisar un Bundle FHIR de salida
  - [ ] 1.4 Crear el esqueleto del módulo `atopic_dermatitis.json`
  - _Requisitos: 1, 16.3_

- [ ] 2. Generador sintético con gravedad latente (semana 2)
  - [ ] 2.1 Completar el módulo de DA en Synthea: brotes, corticoides, comorbilidades, consultas y derivaciones
  - [ ] 2.2 Posprocesado: Gravedad_Latente, Gravedad_DA y señales observables probabilísticas
  - [ ] 2.3 Etiqueta de verdad-terreno, casos infradiagnosticados sin código L20 y casos atípicos
  - [ ] 2.4 Ruido de etiquetas y almacenamiento de la etiqueta limpia en metadatos separados
  - [ ] 2.5 Validación de parámetros y generación sin archivos parciales
  - [ ] 2.6 Tests: misma semilla, mismas cohortes; tolerancia de prevalencia
  - _Requisitos: 1.1 a 1.12_

- [ ] 3. Notas clínicas y muestra para revisión (semana 3)
  - [ ] 3.1 Plantillas con al menos 8 formulaciones por señal, abreviaturas, erratas y negaciones
  - [ ] 3.2 Notas como `DocumentReference` dentro del Bundle y metadatos de señales por separado
  - [ ] 3.3 Registro de fallos de generación sin detener la cohorte
  - [ ] 3.4 Exportar la muestra de 20-30 casos en un formato legible para el revisor clínico
  - _Requisitos: 2.1 a 2.5, 10.9_

- [ ] 4. Lectura y escritura FHIR (semana 4)
  - [ ] 4.1 Modelo interno de paciente
  - [ ] 4.2 Parser con validación (`fhir.resources`) y errores descriptivos
  - [ ] 4.3 Serializador a Bundle JSON; recursos no soportados ignorados y registrados
  - [ ] 4.4 Test de propiedades de ida y vuelta con Hypothesis
  - _Requisitos: 3_

- [ ] 5. Motor de reglas (semana 5)
  - [ ] 5.1 Criterios de Hanifin-Rajka y UK Working Party, con estado "no evaluable"
  - [ ] 5.2 Fenotipo por prescripciones con umbrales configurables en `configs/thresholds.yaml`
  - [ ] 5.3 Criterio de derivación a partir de la fuente clínica elegida
  - [ ] 5.4 Clasificación de DA diagnosticada (L20) y sospecha de Caso_Objetivo
  - [ ] 5.5 Tests de determinismo y unitarios por criterio
  - _Requisitos: 4_

- [ ] 6. API, alertas, auditoría y autenticación (semana 6)
  - [ ] 6.1 Esquema SQLite: usuarios, alertas, decisiones y auditoría de solo añadir
  - [ ] 6.2 Generación y priorización de alertas con umbral configurable
  - [ ] 6.3 Decisiones de aceptar y rechazar con motivo y exclusión de alertas rechazadas
  - [ ] 6.4 Autenticación con sesión, hash con sal, protección CSRF y alta de usuario por script
  - [ ] 6.5 Tests de integración de la API
  - _Requisitos: 7, 10.3, 11.1 a 11.3, 11.7 a 11.9_

- [ ] 7. Panel web (semana 7)
  - [ ] 7.1 Proyecto React, TypeScript y Vite con las variables de estilo de atopi.ai
  - [ ] 7.2 Inicio de sesión, lista de alertas con filtros y detalle de alerta
  - [ ] 7.3 Aceptar y rechazar con motivo; aviso fijo en todas las pantallas
  - [ ] 7.4 Mensajes de error en español con opción de reintentar
  - [ ] 7.5 Pruebas de accesibilidad (axe) y revisión manual con teclado
  - _Requisitos: 8.1, 8.3, 8.4, 8.6, 8.8 a 8.10_

- [ ] 8. Integración y cierre de la fase (semana 8)
  - [ ] 8.1 Comando único del pipeline con archivo de configuración y semilla
  - [ ] 8.2 Test de extremo a extremo de la fase 1
  - [ ] 8.3 Incorporar los comentarios del revisor clínico
  - [ ] 8.4 Primera versión de la memoria: metodología, limitaciones y gobernanza
  - _Requisitos: 16.1, 16.4, 10.6, 10.7, 10.10_
