# Design Document: RADIANT (fase 1)

Documento de diseño de la fase 1 (MVP): generador sintético FHIR, baseline por reglas y panel web mínimo. Las fases 2 a 4 se diseñarán al cerrar la anterior.

## Overview


Disponer de un sistema ejecutable de extremo a extremo que genere una cohorte pediátrica sintética en FHIR, evalúe el baseline por reglas, genere alertas priorizadas y las muestre en un panel donde el profesional pueda aceptarlas o rechazarlas, con auditoría y aviso de soporte a la decisión.

En esta fase el `Score_Riesgo` se deriva del baseline (1 si sospecha de Caso_Objetivo, 0 si no), hasta que exista el Modelo_ML en la fase 2.

## Architecture

### Decisiones técnicas


| Ámbito | Decisión | Motivo |
|---|---|---|
| Lenguaje | Python 3.11 | Stack conocido y ecosistema de ML |
| Dependencias | `uv` con archivo de bloqueo | Reproducibilidad (Req. 16.3) |
| Generación | Synthea (Java) + posprocesado en Python | Synthea da FHIR realista; la gravedad, las notas y el ruido se añaden aparte |
| FHIR | FHIR R4; validación con `fhir.resources`; modelo interno propio | Evita escribir un validador FHIR desde cero |
| Almacenamiento | Bundles JSON en disco; SQLite para alertas, decisiones, usuarios y auditoría | Sencillo para un MVP en solitario |
| API | FastAPI | Stack conocido |
| Frontend | React + TypeScript + Vite, CSS propio con variables `--atopi-*` | Control total de foco, tamaños y tipografía para WCAG AA |
| Accesibilidad | `eslint-plugin-jsx-a11y`, pruebas con axe y revisión manual con teclado | Req. 8.9 |
| Autenticación | Sesión con cookie HttpOnly y SameSite, token CSRF en las peticiones que modifican datos, contraseñas con hash y sal (argon2 o bcrypt). El usuario inicial se crea con un script a partir de variables de entorno (`.env`, no versionado), sin credenciales en el repo | Req. 11.1 a 11.3 y 11.7 a 11.9 |
| Tests | pytest + Hypothesis para propiedades | Ida y vuelta FHIR, determinismo |
| Despliegue | Docker Compose en local; AWS solo si hay tiempo | Reduce riesgo y coste |

### Por qué React y no Streamlit

El panel debe cumplir WCAG 2.1 AA y la identidad visual propia (Fredoka, anillo de foco de 3 px, botones de 44 px, aviso fijo en todas las pantallas). Streamlit ofrece poco control sobre el foco, la estructura semántica y los componentes, y forzarlo con CSS es frágil. React permite construir los controles con HTML semántico y probarlos con herramientas de accesibilidad.

### Diagrama de componentes


```
Synthea ──► posprocesado ──► data/fhir/*.json ──► Parser_FHIR ──► modelo interno
(módulo DA)  (gravedad        + metadatos de                          │
              latente,         verdad-terreno                         ▼
              notas, ruido)    y notas                          Motor_Reglas
                                                                      │
                                                                      ▼
                          Panel React ◄── API FastAPI ◄── Alertas + Auditoría (SQLite)
```

Módulos principales en `src/radiant/`: `generator`, `fhir`, `rules`, `alerts`, `audit`; la API vive en `api/` y el panel en `web/`.

## Components and Interfaces

### Generador y control de la circularidad


1. Se muestrea una **Gravedad_Latente** continua por cada paciente con DA. No se escribe en el Bundle_FHIR ni se entrega a los modelos.
2. La **Gravedad_DA** (leve, moderada, grave) se obtiene de la latente con umbrales y algo de aleatoriedad.
3. Las **señales observables** (brotes, potencia de corticoides, comorbilidad atópica, alteración del sueño) se generan de forma probabilística a partir de la latente, de modo que dos pacientes con la misma gravedad pueden mostrar señales distintas.
4. Se añade una proporción configurable de **casos atípicos** (moderados-graves con pocas señales visibles y leves con muchas).
5. Se aplica **ruido de etiquetas** configurable a la etiqueta de entrenamiento; la etiqueta original (limpia) se guarda en metadatos separados.
6. Las notas se generan por plantillas deterministas con la semilla; un LLM opcional solo parafrasea y sus salidas se guardan en caché.

Con esto se **reduce**, sin eliminarla, la posibilidad de que el baseline y el modelo recuperen la etiqueta casi perfecta: las condiciones del criterio de derivación y las señales del generador siguen siendo las mismas cuatro, y los resultados no son extrapolables a la práctica clínica real.

El informe de evaluación calcula las métricas contra la etiqueta limpia y contra la etiqueta con ruido, y las repite en los casos atípicos y con distintos niveles de ruido (Req. 9.12).

### Baseline por reglas


- Hanifin-Rajka y UK Working Party, con criterios "no evaluable" cuando falta el dato.
- Fenotipo por prescripciones con umbrales y ventana temporal en `configs/thresholds.yaml`.
- **Criterio_Derivacion** con condiciones y umbrales tomados de una fuente clínica externa (guía de derivación a dermatología). El borrador de condiciones y fuentes está en la subsección «Borrador del criterio de derivación pediátrico». **Pendiente (necesario antes de la semana 5):** que el revisor clínico lo valide y decida los umbrales.
- Resultado: sospecha binaria, lista de criterios cumplidos y sospecha de Caso_Objetivo.

#### Borrador del criterio de derivación pediátrico

Borrador elaborado a partir de fuentes publicadas. **No está validado clínicamente**: es una adaptación propuesta que debe aprobar el revisor clínico, y así debe declararse en la memoria y en el panel. Los umbrales viven en `configs/thresholds.yaml` y se pueden cambiar sin tocar código.

No he encontrado ninguna fuente que defina umbrales de *infradiagnóstico* de DA moderada-grave en niños ni cuándo derivar para valorar biológicos en pediatría. Todas las fuentes son criterios de derivación para pacientes con DA o sospecha de DA, de modo que el criterio resultante es una combinación y adaptación de ellas.

| Id | Condición | Fuentes | Adaptación pediátrica propuesta | Evaluable con los datos | Estado |
|---|---|---|---|---|---|
| D1 | Sospecha de eccema herpético | NICE 1.7.1.1; AEPap; SEMERGEN | Aviso de urgencia (mismo día); no es objetivo de detección de infradiagnóstico | Solo si el generador modela infección herpética (hoy no) | Pendiente |
| D2 | Eccema grave sin respuesta a tratamiento tópico óptimo tras 1 semana | NICE (urgente); SEMERGEN | Umbral de 1 semana configurable | Fase 1, con gravedad observada, prescripciones y consultas | Pendiente |
| D3 | Eccema con infección bacteriana que no responde al tratamiento | NICE (urgente); AEPap (sin mejoría tras 7 días de antibiótico); SEMERGEN | Mantener 7 días como umbral configurable | Solo si el generador modela infección bacteriana (hoy no) | Pendiente |
| D4 | Diagnóstico incierto | NICE; AEPap; SEMERGEN | Sin umbral numérico | No evaluable en datos sintéticos salvo que se modele | Pendiente |
| D5 | Brotes frecuentes: no controlado (1 a 2 semanas de brotes al mes) | NICE (estándar); SEMERGEN (recidivas frecuentes); GEIDAC (recaída precoz) | Número de brotes por mes y ventana configurables | Fase 1, con consultas y condiciones | Pendiente |
| D6 | Sin respuesta a la terapia adecuada o sin mejoría tras 1-2 meses | AEPap; GEIDAC | Revisar el plazo para niños (el de GEIDAC procede de un documento centrado en adultos) | Fase 1, con prescripciones y consultas | Pendiente |
| D7 | Eccema facial que no responde al tratamiento | NICE | Localización facial | Fase 2, con NLP (localización en las notas) | Pendiente |
| D8 | Considerar corticoides tópicos de alta potencia en cara o pliegues, o inmunosupresores sistémicos | AEPap | Derivar antes de iniciarlos | Fase 1, con prescripciones | Pendiente |
| D9 | Alteración del sueño o problemas sociales y psicológicos (por ejemplo, absentismo escolar) | NICE (estándar); GEIDAC (prurigo que impide dormir o la actividad diaria) | Alteración del sueño como señal; el absentismo solo si se modela | Fase 2, con NLP (sueño alterado) | Pendiente |
| D10 | Infecciones graves y recurrentes asociadas al eccema | NICE | Solo si se modela | Solo si el generador lo modela (hoy no) | Pendiente |
| D11 | Gravedad moderada o grave por PGA/IGA | GEIDAC; categorías de gravedad de NICE y AEPap | Gravedad observada a partir de variables visibles, nunca de la Gravedad_Latente | Fase 1, con proxies estructurados | Pendiente |
| D12 | Más de 2 ciclos de corticoides orales en el último año | GEIDAC | No usar hasta que el revisor confirme que aplica a niños | Fase 1, con prescripciones | Pendiente |

Las condiciones que no sean evaluables se marcan como "no evaluable" y se excluyen del recuento (Req. 4.4).

**Lo que debe decidir el revisor clínico**

- Qué condiciones se aplican a niños y con qué umbrales (en particular D2, D5, D6 y D12).
- Cómo cubrir los 12 a 17 años, que NICE no incluye (solo menores de 12) y las demás fuentes no tratan de forma específica.
- Si D1 y D3 se muestran como avisos de urgencia aparte de la alerta de infradiagnóstico.
- Qué variables visibles se aceptan como "gravedad observada" para D11.
- Si el generador debe modelar infecciones (D1, D3 y D10); hoy no están en el Req. 1.3.

**Fuentes**

- **NICE CG57**, *Atopic eczema in under 12s: diagnosis and management*. Publicada el 12 de diciembre de 2007 y actualizada el 2 de marzo de 2021. Cubre menores de 12 años; la sección 1.7 recoge las indicaciones de derivación. https://www.nice.org.uk/guidance/cg57
- **AEPap**: Ruiz-Canela Cáceres J, Bernabéu Wittel J. *Guía de Algoritmos en Pediatría de Atención Primaria. Dermatitis atópica.* AEPap, 2015. https://algoritmos.aepap.org/adjuntos/dermatitis_atopica.pdf
- **SEMERGEN**, Grupo de Trabajo de Dermatología: *Criterios de derivación en dermatitis atópica* (autores indicados en el documento: David Morena López e Itziar Reinoso Fernández; verificar la grafía). No he podido datarlo. La asignación de los criterios a cada nivel de urgencia en el texto extraído es orientativa y hay que comprobarla en el original. No indica si aplica a niños. https://semergen.es/files/docs/grupos/dermatologia/criteriosderivacionDA.pdf
- **SEMERGEN DoC 2022** (*Dermatitis atópica*, área de dermatología, CNC 0012-2022): documento clínico fechado con apartados de clasificación de la gravedad y diagnóstico diferencial. No he revisado si incluye criterios de derivación; puede ser una alternativa datada al documento anterior. https://semergen.es/files/docs/biblioteca/semDoc/017-2022dertmatitisAtopica.pdf
- **GEIDAC (AEDV)**: Figueras I, Armario JC, Curto L, Flórez A, Serra E, Silvestre JF y cols. *Recomendaciones para el manejo de la dermatitis atópica en Atención Primaria*. Comunicación en el 67.º Congreso GEIDAC, Pamplona, 2022 (P40), según la cita que aparece en material de Sanofi de 2022; no he encontrado un artículo en revista. Centrado en adultos y con financiación de Sanofi (debe declararse). Copia consultada alojada en un portal de Sanofi.
- **No usadas:** el protocolo de la AEP de 2019 (Escarrer y Guerra), que no he podido revisar en lo relativo a derivación, y el consenso de indicadores de calidad de la AEDV de 2020, que mide calidad asistencial y no cuándo derivar.

### Frontend


Pantallas de la fase 1: inicio de sesión, lista de alertas ordenada por score con filtros, y detalle de alerta con criterios del baseline, criterio de derivación y botones de aceptar y rechazar (con motivo predefinido).

- Todo en español y con el aviso "Soporte a la decisión clínica. No constituye un diagnóstico. Datos sintéticos." visible en todas las pantallas.
- Paleta y tipografía de atopi.ai en versión sobria (sección 8 de la hoja de estilos): la gotita solo en cabecera, inicio de sesión y favicon.
- El estado de las alertas se indica con texto e iconos, no solo con color.
- Navegación completa por teclado, anillo de foco visible y objetivos táctiles de 44 px.

## Data Models


| Tabla | Contenido |
|---|---|
| `users` | Identificador, nombre de usuario, hash con sal, rol |
| `alerts` | Paciente, score, estado, criterios cumplidos, fecha de creación |
| `decisions` | Alerta, usuario, decisión (aceptar o rechazar), motivo, fecha y hora |
| `audit_log` | Fecha, usuario, paciente, evento. Solo se añaden filas; un disparador impide modificar o borrar |

## Correctness Properties

Propiedades que el sistema debe cumplir para cualquier entrada válida. Cada una se verifica con un test de propiedades (ver Testing Strategy).

- **P1. Ida y vuelta FHIR:** para todo modelo interno de paciente válido, serializar, parsear y volver a serializar produce un resultado equivalente. *Valida: Req. 3.4.*
- **P2. Determinismo de la generación:** con la misma configuración y la misma semilla, la cohorte (incluidas las notas) es idéntica. *Valida: Req. 1.2 y 2.6.*
- **P3. Determinismo del motor de reglas:** el mismo Bundle y la misma configuración dan el mismo resultado. *Valida: Req. 4.6.*
- **P4. Infradiagnóstico sin código L20:** ningún recurso de un paciente "DA infradiagnosticada", ni sus notas, contiene el código L20 ni menciona el diagnóstico. *Valida: Req. 1.5 y 2.3.*
- **P5. Rango de edad:** todo paciente generado tiene entre 0 y 17 años. *Valida: Req. 1.1.*
- **P6. Prevalencia y gravedad dentro de tolerancia:** para N ≥ 1000, las proporciones configuradas se respetan con una desviación máxima de 2 puntos porcentuales. *Valida: Req. 1.6 y 1.10.*
- **P7. Sin fuga de la gravedad latente:** la Gravedad_Latente no aparece en ningún Bundle ni en las entradas de los modelos. *Valida: Req. 1.12 y 6.1.*
- **P8. Criterios no evaluables excluidos:** un criterio sin dato disponible se marca "no evaluable" y no cuenta como cumplido. *Valida: Req. 4.4.*
- **P9. Sin alerta para diagnosticados:** un paciente con código L20 nunca genera una alerta. *Valida: Req. 4.5 y 7.1.*
- **P10. Orden de alertas:** la lista siempre está ordenada por Score_Riesgo descendente. *Valida: Req. 7.2.*
- **P11. Rechazo persistente:** una alerta rechazada no vuelve a la lista activa mientras no haya información clínica nueva. *Valida: Req. 7.5.*
- **P12. Auditoría de solo añadir:** las entradas existentes del registro de auditoría no se pueden modificar ni borrar desde el panel. *Valida: Req. 10.4.*
- **P13. Rango del score:** todo Score_Riesgo está entre 0 y 1. *Valida: Req. 6.3 (fase 2).*
- **P14. Aditividad de SHAP:** la contribución base más las contribuciones de las variables coincide con la salida del modelo (tolerancia 1e-6). *Valida: Req. 6.5 (fase 2).*
- **P15. Partición por paciente:** ningún paciente aparece en más de un conjunto (entrenamiento, validación, prueba). *Valida: Req. 6.2 (fase 2).*

## Error Handling

| Situación | Comportamiento | Req. |
|---|---|---|
| Parámetro inválido en la configuración de generación | Se rechaza la solicitud, se indica el parámetro y no se escriben archivos parciales | 1.8 |
| Falla la generación de una nota | Se registra el paciente y la consulta afectados y se continúa con la cohorte | 2.5 |
| Bundle FHIR con sintaxis o estructura inválidas | Error descriptivo con el recurso y el campo afectados | 3.2 |
| Recurso FHIR de un tipo no soportado | Se ignora, se registra el tipo y se continúa | 3.5 |
| Dato ausente para un criterio | El criterio se marca "no evaluable" y no cuenta | 4.4 |
| Identificador que no cumple el formato sintético | Se rechaza la carga y se informa del motivo | 10.2 |
| Rechazo de una alerta sin motivo | No se registra la decisión hasta elegir un motivo | 8.4 |
| Credenciales inválidas | Mensaje de error genérico, sin indicar qué campo falla | 11.3 |
| Petición que modifica datos sin token CSRF válido | Respuesta 403 y entrada en el registro de auditoría | 11.8 |
| Falla la carga de datos en el panel | Mensaje de error en español con opción de reintentar | 8.8 |
| Entrada en el registro de auditoría que no se puede escribir | La operación que la originó se cancela (no hay acciones sin traza) | 10.3 |

## Testing Strategy

- **Pruebas unitarias (pytest):** una por regla del baseline, por plantilla de nota y por función del generador, con casos límite (datos ausentes, edades extremas, umbrales exactos).
- **Pruebas de propiedades (Hypothesis):** una por cada propiedad de la sección Correctness Properties, con al menos 100 iteraciones y una etiqueta del tipo `Feature: radiant, Property N`.
- **Pruebas de integración:** el pipeline completo de cada fase (generación, lectura FHIR, reglas, alertas y API) con una cohorte pequeña de `configs/small_cohort.yaml`.
- **Pruebas de la API:** autenticación, CSRF, alertas, decisiones y auditoría.
- **Accesibilidad del panel:** `eslint-plugin-jsx-a11y`, pruebas con axe y revisión manual de navegación por teclado, foco visible y tamaño de los controles.
- **Reproducibilidad:** ejecutar el pipeline dos veces con la misma configuración y semilla y comprobar que las métricas son idénticas (Req. 16.2, fase 2).
- **Evaluación:** pruebas de las métricas con datos de juguete cuyo resultado se conoce, antes de aplicarlas a la cohorte.
- **Revisión clínica:** la muestra de 20-30 casos de la semana 3 y la validación del criterio de derivación por un revisor clínico. No son pruebas automáticas, pero condicionan la tarea 5.3.

## Plan por semanas (fase 1: 8 semanas)


| Semana | Entregable | Requisitos |
|---|---|---|
| 1 | Entorno, repo, Docker; Synthea funcionando y esqueleto del módulo DA | 1 |
| 2 | Módulo DA y posprocesado: gravedad latente, etiquetas, atípicos y ruido | 1 |
| 3 | Notas por plantillas y exportación de la muestra de 20-30 casos al revisor clínico | 2, 10.9 |
| 4 | Parser, serializador y modelo interno; tests de ida y vuelta | 3 |
| 5 | Motor de reglas y criterio de derivación | 4 |
| 6 | API, alertas, auditoría y autenticación básica con CSRF y alta de usuario por script | 7, 10.3, 11 |
| 7 | Panel React: inicio de sesión, lista con filtros, detalle, decisiones con motivo y aviso fijo; pruebas de accesibilidad (axe y teclado) | 8, 11 |
| 8 | Integración de extremo a extremo, pipeline con comando único, comentarios del revisor clínico y primera versión de la memoria | 16, 10 |

Plan orientativo del proyecto completo (5 meses): fase 1 en 8 semanas, fase 2 en 6, fase 3 en 2-3 y fase 4 en 2, con el resto para la memoria y margen.

### Reglas de recorte si hay retraso

1. Reducir la cohorte de desarrollo a unos cientos de pacientes.
2. Implementar primero dos o tres reglas del baseline y ampliar después.
3. Dejar la exportación CSV de auditoría y los filtros del panel para la fase 2.
4. La fase 4 es la primera en descartarse.

## Riesgos y decisiones pendientes


- Validar con el revisor clínico el borrador del criterio de derivación pediátrico (subsección «Borrador del criterio de derivación pediátrico») y decidir si una comunicación de congreso (GEIDAC) basta como fuente y revisar el SEMERGEN DoC 2022 como alternativa datada.
- Disponer de un revisor clínico para la muestra de la semana 3.
- Confirmar con la mentoría el nombre, el dominio y el tono visual.
- Comprobar licencias de Synthea, CIMA y SCIN y registrarlas en `data/DATA_SOURCES.md`.
- La limitación de los datos sintéticos y la circularidad se declaran en la memoria y en los informes.
