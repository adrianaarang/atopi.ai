# Diseño técnico · RADIANT (fase 1)

Documento de diseño de la fase 1 (MVP): generador sintético FHIR, baseline por reglas y panel web mínimo. Las fases 2 a 4 se diseñarán al cerrar la anterior.

## 1. Objetivo de la fase 1

Disponer de un sistema ejecutable de extremo a extremo que genere una cohorte pediátrica sintética en FHIR, evalúe el baseline por reglas, genere alertas priorizadas y las muestre en un panel donde el profesional pueda aceptarlas o rechazarlas, con auditoría y aviso de soporte a la decisión.

En esta fase el `Score_Riesgo` se deriva del baseline (1 si sospecha de Caso_Objetivo, 0 si no), hasta que exista el Modelo_ML en la fase 2.

## 2. Decisiones técnicas

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

## 3. Arquitectura

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

## 4. Generador y control de la circularidad

1. Se muestrea una **Gravedad_Latente** continua por cada paciente con DA. No se escribe en el Bundle_FHIR ni se entrega a los modelos.
2. La **Gravedad_DA** (leve, moderada, grave) se obtiene de la latente con umbrales y algo de aleatoriedad.
3. Las **señales observables** (brotes, potencia de corticoides, comorbilidad atópica, alteración del sueño) se generan de forma probabilística a partir de la latente, de modo que dos pacientes con la misma gravedad pueden mostrar señales distintas.
4. Se añade una proporción configurable de **casos atípicos** (moderados-graves con pocas señales visibles y leves con muchas).
5. Se aplica **ruido de etiquetas** configurable a la etiqueta de entrenamiento; la etiqueta original (limpia) se guarda en metadatos separados.
6. Las notas se generan por plantillas deterministas con la semilla; un LLM opcional solo parafrasea y sus salidas se guardan en caché.

Con esto se **reduce**, sin eliminarla, la posibilidad de que el baseline y el modelo recuperen la etiqueta casi perfecta: las condiciones del criterio de derivación y las señales del generador siguen siendo las mismas cuatro, y los resultados no son extrapolables a la práctica clínica real.

El informe de evaluación calcula las métricas contra la etiqueta limpia y contra la etiqueta con ruido, y las repite en los casos atípicos y con distintos niveles de ruido (Req. 9.12).

## 5. Baseline por reglas

- Hanifin-Rajka y UK Working Party, con criterios "no evaluable" cuando falta el dato.
- Fenotipo por prescripciones con umbrales y ventana temporal en `configs/thresholds.yaml`.
- **Criterio_Derivacion** con condiciones y umbrales tomados de una fuente clínica externa (guía de derivación a dermatología). El borrador de condiciones y fuentes está en la subsección 5.1. **Pendiente (necesario antes de la semana 5):** que el revisor clínico lo valide y decida los umbrales.
- Resultado: sospecha binaria, lista de criterios cumplidos y sospecha de Caso_Objetivo.

### 5.1 Borrador del criterio de derivación pediátrico

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
- **SEMERGEN**, Grupo de Trabajo de Dermatología: *Criterios de derivación en dermatitis atópica*. Sin fecha en el documento; la asignación de los criterios a cada nivel de urgencia en el texto extraído es orientativa y hay que comprobarla en el original. No indica si aplica a niños. https://semergen.es/files/docs/grupos/dermatologia/criteriosderivacionDA.pdf
- **GEIDAC (AEDV)**: Figueras Nart I. y cols., *Recomendaciones para el manejo de la dermatitis atópica en Atención Primaria*. Centrado en adultos, con financiación de Sanofi (debe declararse). Falta localizar la publicación original (revista y fecha); la copia consultada está alojada en un portal de Sanofi.
- **No usadas:** el protocolo de la AEP de 2019 (Escarrer y Guerra), que no he podido revisar en lo relativo a derivación, y el consenso de indicadores de calidad de la AEDV de 2020, que mide calidad asistencial y no cuándo derivar.

## 6. Modelo de datos (SQLite)

| Tabla | Contenido |
|---|---|
| `users` | Identificador, nombre de usuario, hash con sal, rol |
| `alerts` | Paciente, score, estado, criterios cumplidos, fecha de creación |
| `decisions` | Alerta, usuario, decisión (aceptar o rechazar), motivo, fecha y hora |
| `audit_log` | Fecha, usuario, paciente, evento. Solo se añaden filas; un disparador impide modificar o borrar |

## 7. Frontend

Pantallas de la fase 1: inicio de sesión, lista de alertas ordenada por score con filtros, y detalle de alerta con criterios del baseline, criterio de derivación y botones de aceptar y rechazar (con motivo predefinido).

- Todo en español y con el aviso "Soporte a la decisión clínica. No constituye un diagnóstico. Datos sintéticos." visible en todas las pantallas.
- Paleta y tipografía de atopi.ai en versión sobria (sección 8 de la hoja de estilos): la gotita solo en cabecera, inicio de sesión y favicon.
- El estado de las alertas se indica con texto e iconos, no solo con color.
- Navegación completa por teclado, anillo de foco visible y objetivos táctiles de 44 px.

## 8. Plan por semanas (fase 1: 8 semanas)

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

## 9. Riesgos y decisiones pendientes

- Validar con el revisor clínico el borrador del criterio de derivación pediátrico (sección 5.1) y localizar la publicación original de GEIDAC.
- Disponer de un revisor clínico para la muestra de la semana 3.
- Confirmar con la mentoría el nombre, el dominio y el tono visual.
- Comprobar licencias de Synthea, CIMA y SCIN y registrarlas en `data/DATA_SOURCES.md`.
- La limitación de los datos sintéticos y la circularidad se declaran en la memoria y en los informes.
