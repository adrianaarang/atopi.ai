# Requirements Document

## Introduction

RADIANT es una aplicación web de soporte a la decisión clínica para la detección de dermatitis atópica (DA) infradiagnosticada en población pediátrica. El proyecto se desarrolla para Sanofi, en solitario y en un plazo de 5 meses.

Al no disponerse de historias clínicas reales, RADIANT construye un sistema completo de punta a punta sobre datos sintéticos en formato FHIR generados con Synthea. La detección se organiza por capas, de menor a mayor complejidad: (1) baseline por reglas clínicas (Hanifin-Rajka / UK Working Party y fenotipo por prescripciones), (2) modelo de aprendizaje automático sobre datos estructurados con explicabilidad SHAP y (3) NLP en español sobre notas clínicas. Como extras priorizados por detrás del núcleo, el sistema incorpora un RAG de tratamientos sobre guías clínicas y ficha técnica, cuestionarios POEM y un módulo de imagen con evaluación por fototipo Fitzpatrick.

El objetivo clínico es identificar a los pacientes con DA de gravedad moderada o grave que no tienen diagnóstico y que, por su patrón (brotes recurrentes, escalado de corticoides, comorbilidades atópicas, alteración del sueño), podrían beneficiarse de una derivación a dermatología. Por ello, además de la presencia de DA, el sistema modela su gravedad.

Un panel web presenta los pacientes priorizados con su score, la explicación de la alerta y las acciones de aceptar o rechazar. El sistema da soporte a la decisión y no diagnostica. Los datos sintéticos validan el pipeline, no el rendimiento clínico real, y esta limitación debe quedar declarada de forma explícita.

### Prioridades y orden de entrega

| Fase | Contenido | Prioridad |
|------|-----------|-----------|
| 1 | Generador sintético FHIR + baseline por reglas + panel web mínimo | Núcleo (MVP) |
| 2 | NLP y ML con explicabilidad + evaluación | Núcleo |
| 3 | RAG de tratamientos | Extra priorizado |
| 4 | Módulo de imagen, cuestionarios y modelo multimodal | Extra opcional |

### Alcance por fase de los criterios de aceptación

| Fase | Criterios de aceptación incluidos |
|------|-----------------------------------|
| 1 | Req. 1 (completo), Req. 2 (criterios 2.1 a 2.5, notas por plantillas), Req. 3, Req. 4, Req. 7 (con Score_Riesgo derivado del Baseline), Req. 8 (criterios 8.1, 8.3, 8.4, 8.6, 8.8, 8.9 y 8.10; el detalle del criterio 8.2 solo con el Baseline y el Criterio_Derivacion), Req. 10 (criterios 10.1, 10.2, 10.3, 10.8, 10.9), Req. 11 (criterios 11.1, 11.2, 11.3, 11.7, 11.8 y 11.9), Req. 16 (criterios 16.1, 16.3 y 16.4) |
| 2 | Req. 2 (criterios 2.6 y 2.7), Req. 5, Req. 6, Req. 7 (con el Modelo_ML), Req. 8 (criterio 8.2 completo, 8.5 y 8.7), Req. 9 (incluido el criterio 9.12), Req. 10 (criterios 10.4 y 10.5), Req. 11 (criterios 11.4, 11.5 y 11.6), Req. 16 (criterio 16.2) |
| 3 | Req. 12 |
| 4 | Req. 13, 14 y 15 |
| Todas | Criterios 10.6, 10.7, 10.10 y 16.5 (Memoria_Proyecto): se actualizan al cerrar cada fase |

En la fase 1, hasta que exista el Modelo_ML, el Score_Riesgo toma el valor 1 cuando el Baseline sospecha un Caso_Objetivo y 0 en caso contrario, para poder probar de extremo a extremo el flujo de alertas.

### Supuestos y riesgos

- **Synthea:** los módulos de Synthea son máquinas de estados en JSON y no todo lo necesario (notas clínicas, gradación fina de la gravedad) podrá expresarse en ellos. El Generador_Sintetico aplica un posprocesado propio para esos aspectos. Se reserva tiempo al inicio de la fase 1 para construir y validar el Modulo_DA_Synthea.
- **Notas:** las notas se generan por plantillas deterministas. El uso de un LLM para parafrasear es opcional y, si se usa, sus salidas se guardan en caché para conservar la reproducibilidad.
- **Criterio de derivación:** el Criterio_Derivacion se basa en fuentes clínicas documentadas, pero no es un criterio oficial validado y debe revisarlo un profesional clínico.
- **Despliegue:** la decisión de despliegue (por defecto local con Docker Compose) se documenta en el diseño técnico.
- **Frontend:** el Panel_Web se construye con React y TypeScript, con estilos propios, para poder cumplir WCAG 2.1 AA y la identidad visual de atopi.ai. La justificación se recoge en el diseño técnico.
- **Circularidad:** la gravedad deriva de una variable latente no visible en los datos, hay casos atípicos y ruido de etiquetas, y el Criterio_Derivacion procede de una fuente clínica externa. Aun así, el rendimiento medido sobre datos sintéticos no es extrapolable a la práctica clínica real.
- **Marca:** el nombre atopi.ai, su dominio y el tono visual están pendientes de confirmar con la mentoría; el Panel_Web usa una versión sobria de la identidad por ser su usuario un profesional sanitario.

## Glossary

- **RADIANT**: Sistema completo objeto de este documento, compuesto por el generador de datos, los motores de detección, el RAG y el panel web.
- **Panel_Web**: Interfaz web de RADIANT utilizada por el profesional sanitario.
- **Profesional_Sanitario**: Usuario del Panel_Web (pediatra, médico de familia o dermatólogo) que revisa las alertas.
- **DA**: Dermatitis atópica.
- **Paciente_Sintetico**: Registro de paciente pediátrico generado artificialmente, sin vínculo con una persona real.
- **Generador_Sintetico**: Componente que produce cohortes de Pacientes_Sinteticos en formato FHIR mediante Synthea y un módulo propio de DA, con posprocesado propio para los aspectos que Synthea no pueda modelar (gravedad, notas clínicas).
- **Cohorte**: Conjunto de Pacientes_Sinteticos generado con una misma configuración y semilla.
- **Modulo_DA_Synthea**: Módulo propio de Synthea que modela brotes, escalado de corticoides, comorbilidades (asma, rinitis), consultas y derivaciones de DA.
- **Caso_Infradiagnosticado**: Paciente_Sintetico con patrón clínico compatible con DA y sin código CIE-10 L20 en su historia.
- **Etiqueta_Verdad_Terreno**: Atributo asignado por el Generador_Sintetico que indica si un Paciente_Sintetico tiene DA, si está diagnosticada o infradiagnosticada y, cuando tiene DA, su Gravedad_DA.
- **Gravedad_DA**: Clasificación de la DA de un Paciente_Sintetico en "leve", "moderada" o "grave", derivada por el Generador_Sintetico de una Gravedad_Latente.
- **Gravedad_Latente**: Variable continua que el Generador_Sintetico no incluye en los Bundle_FHIR ni en los datos de entrada de los modelos, y a partir de la cual deriva de forma probabilística la Gravedad_DA y las señales observables (brotes, potencia de los corticoides, comorbilidad atópica, alteración del sueño).
- **Caso_Objetivo**: Caso_Infradiagnosticado con Gravedad_DA "moderada" o "grave". Es el caso positivo que RADIANT debe detectar.
- **Criterio_Derivacion**: Conjunto configurable de condiciones clínicas documentadas (brotes recurrentes, escalado de corticoides tópicos, comorbilidad atópica, alteración del sueño) que sugieren la conveniencia de derivar al paciente a dermatología, basadas en una fuente clínica externa e independiente de las reglas internas del Generador_Sintetico.
- **Bundle_FHIR**: Recurso FHIR de tipo Bundle en formato JSON que contiene los recursos clínicos de un Paciente_Sintetico.
- **Parser_FHIR**: Componente que lee un Bundle_FHIR y lo convierte en el modelo interno de paciente.
- **Serializador_FHIR**: Componente que convierte el modelo interno de paciente en un Bundle_FHIR en formato JSON.
- **Motor_Reglas**: Componente que evalúa criterios de Hanifin-Rajka, criterios del UK Working Party, el fenotipo por prescripciones y el Criterio_Derivacion.
- **Fenotipo_Prescripciones**: Regla basada en corticoides tópicos repetidos, inhibidores de calcineurina y antihistamínicos prescritos por prurito.
- **Baseline**: Resultado del Motor_Reglas, utilizado como referencia de comparación para los demás modelos.
- **Modelo_ML**: Modelo de aprendizaje automático (scikit-learn o XGBoost) entrenado sobre variables estructuradas.
- **Explicador_SHAP**: Componente que calcula la contribución de cada variable a un score mediante SHAP.
- **Extractor_NLP**: Componente que extrae señales clínicas estructuradas de notas clínicas en español.
- **Senal_Clinica**: Dato estructurado extraído de una nota, como prurito nocturno, sueño alterado o localización en pliegues.
- **Conjunto_Notas_Externo**: Conjunto de al menos 30 notas clínicas en español escritas a mano o revisadas por un profesional clínico, no generadas por las plantillas, usado solo para evaluación.
- **Score_Riesgo**: Valor numérico entre 0 y 1 que indica la probabilidad estimada de que un paciente sea un Caso_Objetivo (DA moderada-grave no diagnosticada).
- **Alerta**: Aviso generado por RADIANT para un Paciente_Sintetico cuyo Score_Riesgo supera el umbral configurado.
- **Umbral_Alerta**: Valor del Score_Riesgo a partir del cual se genera una Alerta.
- **Decision_Alerta**: Acción registrada por el Profesional_Sanitario sobre una Alerta: aceptar o rechazar.
- **Evaluador**: Componente que calcula métricas de rendimiento y análisis por subgrupos.
- **Subgrupo**: Partición de la Cohorte por sexo o rango de edad y, solo para el Modulo_Imagen, por fototipo Fitzpatrick (los Pacientes_Sinteticos de Synthea no tienen fototipo).
- **Motor_RAG**: Componente que recupera fragmentos de guías clínicas y ficha técnica y genera una propuesta de siguiente escalón terapéutico con citas.
- **Corpus_Documental**: Conjunto de documentos indexados por el Motor_RAG: guías AEDV, guías EADV y ficha técnica de Dupixent obtenida de CIMA.
- **Cita_Fuente**: Referencia que identifica documento, sección y fragmento del Corpus_Documental que respalda una afirmación.
- **POEM**: Cuestionario Patient-Oriented Eczema Measure de siete ítems.
- **Modulo_Imagen**: Componente que estima la gravedad de la DA (tipo EASI/IGA) a partir de una fotografía de una lesión.
- **Fototipo_Fitzpatrick**: Clasificación de la piel en seis fototipos (I a VI) según su respuesta a la radiación ultravioleta.
- **Modelo_Multimodal**: Componente que fusiona señales de historial estructurado, notas e imagen en un único Score_Riesgo.
- **Registro_Auditoria**: Registro cronológico de eventos relevantes del sistema (generación de alertas, decisiones, accesos).
- **Memoria_Proyecto**: Documento de documentación del proyecto que recoge metodología, resultados, limitaciones y gobernanza.

## Requirements

### Requirement 1: Generación de cohortes sintéticas FHIR

**User Story:** Como desarrollador del proyecto, quiero generar cohortes pediátricas sintéticas en formato FHIR con un módulo propio de DA, para disponer de datos realistas sin acceder a historias clínicas reales.

#### Acceptance Criteria

1. WHEN se solicita la generación de una Cohorte con un tamaño N y una semilla, THE Generador_Sintetico SHALL producir N Bundle_FHIR de Pacientes_Sinteticos pediátricos con edad comprendida entre 0 y 17 años.
2. WHEN se solicita la generación con la misma configuración y la misma semilla, THE Generador_Sintetico SHALL producir Cohortes idénticas, incluidas sus notas clínicas.
3. THE Modulo_DA_Synthea SHALL modelar brotes de DA, escalado de corticoides tópicos, comorbilidades de asma y rinitis, consultas y derivaciones.
4. THE Generador_Sintetico SHALL asignar a cada Paciente_Sintetico una Etiqueta_Verdad_Terreno con los valores "sin DA", "DA diagnosticada" o "DA infradiagnosticada" y, para los pacientes con DA, una Gravedad_DA con los valores "leve", "moderada" o "grave".
5. WHEN un Paciente_Sintetico tiene la Etiqueta_Verdad_Terreno "DA infradiagnosticada", THE Generador_Sintetico SHALL omitir el código CIE-10 L20 de todos los recursos de su Bundle_FHIR y mantener el patrón clínico de DA.
6. WHERE se configura una prevalencia de Casos_Infradiagnosticados, THE Generador_Sintetico SHALL generar una Cohorte cuya proporción de Casos_Infradiagnosticados difiera de la prevalencia configurada en un máximo de 2 puntos porcentuales para N mayor o igual a 1000.
7. THE Generador_Sintetico SHALL generar Pacientes_Sinteticos con identificadores y datos demográficos que no correspondan a ninguna persona real.
8. IF la configuración de generación contiene un parámetro inválido, THEN THE Generador_Sintetico SHALL rechazar la solicitud e informar del parámetro inválido sin generar archivos parciales.
9. WHEN el Generador_Sintetico asigna una Gravedad_DA, THE Generador_Sintetico SHALL derivarla de una Gravedad_Latente y generar a partir de ella, de forma probabilística, las señales observables (brotes, potencia de los corticoides, comorbilidad atópica y alteración del sueño), de modo que pacientes con la misma Gravedad_DA puedan mostrar combinaciones y cantidades distintas de señales.
10. WHERE se configura la distribución de Gravedad_DA entre los pacientes con DA, THE Generador_Sintetico SHALL generar la Cohorte respetando esa distribución con una tolerancia máxima de 2 puntos porcentuales para N mayor o igual a 1000, y documentar la distribución por defecto.
11. THE Generador_Sintetico SHALL generar una proporción configurable de casos atípicos (Gravedad_DA "moderada" o "grave" con pocas señales observables, o "leve" con muchas) y aplicar un ruido configurable a la etiqueta de entrenamiento, conservando la Etiqueta_Verdad_Terreno original (limpia) en metadatos separados.
12. THE Generador_Sintetico SHALL almacenar la Gravedad_Latente fuera de los Bundle_FHIR y de los datos de entrada de los modelos.

### Requirement 2: Notas clínicas sintéticas en español

**User Story:** Como desarrollador del proyecto, quiero generar notas clínicas de texto libre en español para cada paciente sintético, para poder desarrollar y evaluar la extracción de señales por NLP.

#### Acceptance Criteria

1. WHEN se genera un Paciente_Sintetico con consultas, THE Generador_Sintetico SHALL generar, mediante plantillas parametrizadas con la semilla de la Cohorte, al menos una nota clínica en español por consulta y almacenarla como recurso FHIR DocumentReference dentro del Bundle_FHIR del paciente.
2. WHEN se genera la nota de una consulta de un paciente con DA, THE Generador_Sintetico SHALL registrar en metadatos separados de la nota las Senales_Clinicas que la nota contiene de forma explícita.
3. WHEN se genera la nota de una consulta de un Caso_Infradiagnosticado, THE Generador_Sintetico SHALL redactar la nota sin mencionar el diagnóstico de DA ni el código L20.
4. THE Generador_Sintetico SHALL incluir variabilidad de redacción entre notas para una misma Senal_Clinica, mediante al menos 8 formulaciones distintas por Senal_Clinica, e incorporar abreviaturas clínicas, errores tipográficos, formas de negación y texto clínico irrelevante en una proporción configurable de las notas.
5. IF la generación de una nota falla, THEN THE Generador_Sintetico SHALL registrar el identificador del paciente y de la consulta afectados y continuar con el resto de la Cohorte.
6. WHERE se utiliza un LLM para parafrasear notas, THE Generador_Sintetico SHALL guardar cada nota generada en una caché identificada por su contenido de entrada y reutilizarla en generaciones posteriores, de modo que la misma configuración y la misma semilla produzcan las mismas notas.
7. THE RADIANT SHALL disponer de un Conjunto_Notas_Externo que no se utilice para ajustar plantillas, reglas ni modelos y se emplee solo en la evaluación del Extractor_NLP.

### Requirement 3: Lectura y escritura de Bundles FHIR

**User Story:** Como desarrollador del proyecto, quiero leer y escribir Bundles FHIR de forma fiable, para que el resto de componentes trabaje sobre un modelo interno consistente.

#### Acceptance Criteria

1. WHEN se proporciona un Bundle_FHIR válido, THE Parser_FHIR SHALL convertirlo en el modelo interno de paciente con demografía, condiciones, prescripciones, encuentros, observaciones y notas.
2. WHEN se proporciona un Bundle_FHIR con sintaxis o estructura inválidas, THE Parser_FHIR SHALL devolver un error descriptivo que indique el recurso y el campo afectados.
3. THE Serializador_FHIR SHALL convertir el modelo interno de paciente en un Bundle_FHIR en formato JSON válido.
4. FOR ALL modelos internos de paciente válidos, serializar, parsear y volver a serializar SHALL producir un resultado equivalente al original (propiedad de ida y vuelta), entendiendo por equivalente que contiene los mismos recursos con los mismos valores en los campos clínicos, sin considerar el orden de las claves ni los espacios en blanco.
5. IF un Bundle_FHIR contiene un recurso de un tipo no soportado, THEN THE Parser_FHIR SHALL ignorar ese recurso, registrar su tipo y continuar con el resto del Bundle_FHIR.

### Requirement 4: Baseline por reglas clínicas

**User Story:** Como investigador, quiero un baseline basado en criterios clínicos reconocidos, para disponer de una referencia explicable contra la que comparar los modelos de ML y NLP.

#### Acceptance Criteria

1. WHEN se evalúa un Paciente_Sintetico, THE Motor_Reglas SHALL calcular el cumplimiento de los criterios de Hanifin-Rajka y de los criterios del UK Working Party a partir de los datos disponibles.
2. WHEN se evalúa un Paciente_Sintetico, THE Motor_Reglas SHALL aplicar el Fenotipo_Prescripciones con umbrales de número de prescripciones y ventana temporal configurables.
3. WHEN el Motor_Reglas evalúa un Paciente_Sintetico, THE Motor_Reglas SHALL devolver un resultado binario de sospecha de DA y la lista de criterios y reglas que se han cumplido.
4. WHILE un criterio requiere un dato ausente en el Bundle_FHIR del paciente, THE Motor_Reglas SHALL marcar ese criterio como "no evaluable" y excluirlo del recuento de criterios cumplidos.
5. WHEN el Motor_Reglas evalúa un Paciente_Sintetico con código CIE-10 L20 en su historia, THE Motor_Reglas SHALL clasificarlo como "DA diagnosticada" y excluirlo de la lista de candidatos a Alerta.
6. THE Motor_Reglas SHALL producir el mismo resultado para el mismo Bundle_FHIR y la misma configuración.
7. WHEN el Motor_Reglas evalúa un Paciente_Sintetico, THE Motor_Reglas SHALL evaluar el Criterio_Derivacion con umbrales configurables e indicar si el paciente lo cumple y cuáles de sus condiciones se cumplen. Las condiciones y los umbrales del Criterio_Derivacion proceden de una fuente clínica externa documentada y no de las reglas del Generador_Sintetico.
8. WHEN el Motor_Reglas evalúa un Paciente_Sintetico sin código CIE-10 L20 que cumple el Criterio_Derivacion y las condiciones de sospecha de DA, THE Motor_Reglas SHALL clasificarlo como sospecha de Caso_Objetivo.

### Requirement 5: Extracción de señales clínicas por NLP

**User Story:** Como investigador, quiero extraer señales clínicas de las notas en español, para aportar información que no figura en los datos estructurados.

#### Acceptance Criteria

1. WHEN se proporciona una nota clínica en español, THE Extractor_NLP SHALL devolver una lista de Senales_Clinicas con su tipo y el fragmento de texto que la respalda.
2. THE Extractor_NLP SHALL detectar como mínimo las Senales_Clinicas de prurito nocturno, sueño alterado y localización en pliegues.
3. WHEN una nota niega una Senal_Clinica (por ejemplo, "sin prurito nocturno"), THE Extractor_NLP SHALL marcar esa Senal_Clinica como negada.
4. IF una nota no contiene ninguna Senal_Clinica, THEN THE Extractor_NLP SHALL devolver una lista vacía sin error.
5. IF la nota proporcionada está vacía o no contiene texto, THEN THE Extractor_NLP SHALL devolver una lista vacía e indicar que la nota no tiene contenido.
6. WHEN se evalúa el Extractor_NLP sobre el conjunto de notas de prueba, THE Evaluador SHALL calcular precisión, exhaustividad y F1 por tipo de Senal_Clinica, y calcularlos también por separado sobre el Conjunto_Notas_Externo e informar de la diferencia entre ambos conjuntos.

### Requirement 6: Modelo de ML sobre datos estructurados con explicabilidad

**User Story:** Como investigador, quiero un modelo de ML que estime el riesgo de DA no diagnosticada y explique cada predicción, para que el profesional pueda entender por qué se genera una alerta.

#### Acceptance Criteria

1. WHEN se entrena el Modelo_ML, THE Modelo_ML SHALL utilizar variables derivadas de datos estructurados y de las Senales_Clinicas extraídas por el Extractor_NLP, y no utilizar la Etiqueta_Verdad_Terreno ni el código CIE-10 L20 como variables de entrada.
2. WHEN se entrena el Modelo_ML, THE Modelo_ML SHALL dividir la Cohorte en conjuntos de entrenamiento, validación y prueba a nivel de paciente, sin que un mismo paciente aparezca en más de un conjunto.
3. WHEN se solicita el Score_Riesgo de un paciente, THE Modelo_ML SHALL devolver un valor entre 0 y 1.
4. WHEN se solicita la explicación de un Score_Riesgo, THE Explicador_SHAP SHALL devolver las contribuciones de las variables ordenadas por magnitud absoluta, con el signo de cada contribución.
5. FOR ALL pacientes, la suma de la contribución base y las contribuciones SHAP de sus variables SHALL coincidir con la salida del modelo en el espacio de explicación, con una tolerancia de 1e-6.
6. WHEN se entrena el Modelo_ML con la misma semilla y los mismos datos, THE Modelo_ML SHALL producir los mismos Scores_Riesgo, con el entrenamiento configurado en modo determinista (sin paralelismo no determinista).
7. IF faltan valores en una variable de entrada, THEN THE Modelo_ML SHALL aplicar la estrategia de imputación definida durante el entrenamiento y registrar el número de valores imputados.
8. WHEN se entrena el Modelo_ML, THE Modelo_ML SHALL predecir si un paciente es Caso_Objetivo, utilizando como población de entrenamiento y evaluación únicamente a los pacientes sin código CIE-10 L20, con los Casos_Objetivo como positivos y el resto como negativos.

### Requirement 7: Generación y priorización de alertas

**User Story:** Como profesional sanitario, quiero recibir una lista priorizada de pacientes con sospecha de DA no diagnosticada, para centrar mi revisión en los casos con mayor probabilidad.

#### Acceptance Criteria

1. WHEN el Score_Riesgo de un paciente sin diagnóstico L20 supera el Umbral_Alerta, THE RADIANT SHALL generar una Alerta para ese paciente.
2. THE RADIANT SHALL ordenar las Alertas por Score_Riesgo descendente.
3. WHEN se genera una Alerta, THE RADIANT SHALL asociarle el Score_Riesgo, la explicación del Explicador_SHAP, las Senales_Clinicas con su fragmento de texto, el resultado del Baseline y el resultado del Criterio_Derivacion.
4. WHEN el Profesional_Sanitario modifica el Umbral_Alerta, THE RADIANT SHALL recalcular la lista de Alertas con el nuevo umbral en un máximo de 2 segundos para una Cohorte de hasta 10 000 pacientes.
5. IF un paciente tiene una Decision_Alerta de rechazo registrada, THEN THE RADIANT SHALL excluirlo de la lista activa de Alertas hasta que se registre nueva información clínica para ese paciente.

### Requirement 8: Panel web de pacientes priorizados

**User Story:** Como profesional sanitario, quiero un panel web con los pacientes priorizados y la explicación de cada alerta, para decidir con rapidez si acepto o rechazo la alerta.

#### Acceptance Criteria

1. WHEN el Profesional_Sanitario abre el Panel_Web, THE Panel_Web SHALL mostrar la lista de Alertas ordenadas por Score_Riesgo descendente con identificador de paciente, edad, Score_Riesgo y estado de la Alerta.
2. WHEN el Profesional_Sanitario selecciona una Alerta, THE Panel_Web SHALL mostrar el detalle del paciente con el Score_Riesgo, el gráfico de contribuciones SHAP, las Senales_Clinicas con el fragmento de nota resaltado, los criterios del Baseline cumplidos y el resultado del Criterio_Derivacion.
3. WHEN el Profesional_Sanitario pulsa el botón de aceptar o de rechazar una Alerta, THE Panel_Web SHALL registrar la Decision_Alerta con fecha, hora e identificador del usuario.
4. WHEN el Profesional_Sanitario rechaza una Alerta, THE Panel_Web SHALL solicitar un motivo de rechazo seleccionable de una lista predefinida antes de registrar la decisión.
5. WHEN el Profesional_Sanitario aplica un filtro por rango de edad, sexo o estado de la Alerta, THE Panel_Web SHALL mostrar únicamente las Alertas que cumplen el filtro.
6. THE Panel_Web SHALL mostrar de forma visible en todas las pantallas el aviso "Soporte a la decisión clínica. No constituye un diagnóstico. Datos sintéticos."
7. WHEN el Panel_Web carga la lista de Alertas de una Cohorte de hasta 10 000 pacientes, THE Panel_Web SHALL mostrar la primera página de resultados en un máximo de 3 segundos.
8. IF la carga de datos desde el servicio de RADIANT falla, THEN THE Panel_Web SHALL mostrar un mensaje de error en español con la opción de reintentar.
9. THE Panel_Web SHALL cumplir las pautas WCAG 2.1 nivel AA en contraste de color, navegación por teclado y etiquetas de los controles.
10. THE Panel_Web SHALL mostrar toda su interfaz en español.

### Requirement 9: Evaluación honesta del rendimiento

**User Story:** Como investigador, quiero evaluar el Baseline, el Modelo_ML y el Extractor_NLP con métricas y análisis por subgrupos, para documentar con rigor su rendimiento y sus limitaciones.

#### Acceptance Criteria

1. WHEN se ejecuta una evaluación sobre el conjunto de prueba, THE Evaluador SHALL calcular para el Baseline y para el Modelo_ML la matriz de confusión, sensibilidad, especificidad, valor predictivo positivo, F1, AUROC y AUPRC.
2. WHEN se ejecuta una evaluación, THE Evaluador SHALL calcular un intervalo de confianza del 95 % para AUROC mediante remuestreo bootstrap con al menos 1000 réplicas.
3. WHEN se ejecuta una evaluación, THE Evaluador SHALL calcular las métricas del criterio 1 para cada Subgrupo definido por sexo y rango de edad.
4. WHERE el Modulo_Imagen está activo, THE Evaluador SHALL calcular las métricas del Modulo_Imagen por Fototipo_Fitzpatrick.
5. WHEN se ejecuta una evaluación, THE Evaluador SHALL comparar el Modelo_ML frente al Baseline y reportar la diferencia de cada métrica.
6. WHEN un Subgrupo contiene menos de 30 pacientes, THE Evaluador SHALL marcar sus métricas como "baja fiabilidad por tamaño muestral".
7. WHEN el Evaluador genera un informe, THE Evaluador SHALL incluir un apartado de limitaciones que declare que los datos son sintéticos y que el rendimiento no es extrapolable a la práctica clínica real.
8. WHEN el Evaluador genera un informe, THE Evaluador SHALL incluir una prueba de circularidad que compare el rendimiento del Modelo_ML con el del Baseline y señale si el Modelo_ML reproduce las reglas de generación de datos.
9. THE Evaluador SHALL guardar cada informe con la versión del código, la semilla, la configuración de la Cohorte y la fecha de ejecución.
10. THE Panel_Web SHALL mostrar el último informe de evaluación con las métricas globales y por Subgrupo.
11. WHEN se ejecuta una evaluación, THE Evaluador SHALL tomar como casos positivos a los Casos_Objetivo y como negativos al resto de pacientes sin código CIE-10 L20, e informar de la prevalencia de positivos en el conjunto de prueba.
12. WHEN se ejecuta una evaluación, THE Evaluador SHALL repetir las métricas principales sobre el subconjunto de casos atípicos y sobre Cohortes generadas con distintos niveles de ruido de etiquetas, e informar de cuánto se degrada el rendimiento. Las métricas principales se calculan tanto contra la etiqueta limpia como contra la etiqueta con ruido.

### Requirement 10: Gobernanza, privacidad y trazabilidad

**User Story:** Como responsable del proyecto, quiero que el sistema cumpla principios de gobernanza, protección de datos y trazabilidad, para que sea defendible ante un revisor de Sanofi y compatible con el RGPD.

#### Acceptance Criteria

1. THE RADIANT SHALL operar exclusivamente con Pacientes_Sinteticos durante todo el alcance de este proyecto.
2. IF un Bundle_FHIR cargado en el sistema contiene un identificador que no cumple el formato de identificadores sintéticos de RADIANT, THEN THE RADIANT SHALL rechazar la carga e informar del motivo.
3. WHEN se genera una Alerta o se registra una Decision_Alerta, THE RADIANT SHALL añadir una entrada al Registro_Auditoria con fecha, hora, identificador de usuario, identificador de paciente y evento.
4. THE RADIANT SHALL almacenar el Registro_Auditoria de forma que las entradas existentes no puedan modificarse desde el Panel_Web.
5. WHEN el Profesional_Sanitario solicita exportar el Registro_Auditoria, THE Panel_Web SHALL generar un archivo CSV con todas las entradas del periodo seleccionado.
6. THE Memoria_Proyecto SHALL incluir un apartado de gobernanza que describa el carácter de soporte a la decisión, la ausencia de diagnóstico automático, el tratamiento conforme al RGPD y las medidas de anonimización requeridas en caso de uso futuro con datos reales.
7. THE Memoria_Proyecto SHALL incluir un apartado que declare la limitación de los datos sintéticos y el riesgo de circularidad entre generación y modelo.
8. WHEN se obtienen datos de fuentes externas (CIMA, SCIN), THE RADIANT SHALL registrar la fuente, la fecha de obtención y la licencia de uso de cada conjunto de datos.
9. WHEN los Pacientes_Sinteticos de una muestra se someten a revisión clínica, THE Generador_Sintetico SHALL exportar una muestra de entre 20 y 30 casos en un formato legible para el revisor clínico.
10. THE Memoria_Proyecto SHALL documentar la fuente clínica de cada condición del Criterio_Derivacion y declarar que debe ser validado por un profesional clínico antes de cualquier uso real.

### Requirement 11: Acceso y autenticación al panel

**User Story:** Como responsable del proyecto, quiero que el panel requiera autenticación y asigne roles, para que solo usuarios autorizados vean las alertas y registren decisiones.

#### Acceptance Criteria

1. WHEN un usuario no autenticado solicita cualquier pantalla del Panel_Web, THE Panel_Web SHALL redirigirlo a la pantalla de inicio de sesión.
2. WHEN un usuario introduce credenciales válidas, THE Panel_Web SHALL iniciar una sesión y mostrar la lista de Alertas.
3. IF un usuario introduce credenciales inválidas, THEN THE Panel_Web SHALL mostrar un mensaje de error genérico sin indicar qué campo es incorrecto.
4. WHILE un usuario tiene el rol "lector", THE Panel_Web SHALL permitir la consulta de Alertas y deshabilitar los botones de aceptar y rechazar.
5. WHILE un usuario tiene el rol "profesional", THE Panel_Web SHALL permitir registrar Decisiones_Alerta.
6. WHEN una sesión permanece inactiva durante 30 minutos, THE Panel_Web SHALL cerrar la sesión.
7. THE Panel_Web SHALL almacenar las contraseñas de usuario mediante un algoritmo de hash con sal.
8. THE Panel_Web SHALL proteger las peticiones que modifican datos frente a la falsificación de petición en sitios cruzados (CSRF) y emitir las cookies de sesión con los atributos HttpOnly y SameSite.
9. THE RADIANT SHALL crear los usuarios iniciales mediante un script de alta que lea las credenciales de variables de entorno, sin credenciales fijas en el repositorio.

### Requirement 12: RAG de tratamientos sobre guías clínicas (extra priorizado)

**User Story:** Como profesional sanitario, quiero una propuesta de siguiente escalón terapéutico con cita de la fuente, para consultar las guías y la ficha técnica sin buscar manualmente.

#### Acceptance Criteria

1. THE Motor_RAG SHALL indexar un Corpus_Documental que incluya guías AEDV, guías EADV y la ficha técnica de Dupixent obtenida de CIMA.
2. WHEN el Profesional_Sanitario solicita una propuesta terapéutica para una Alerta aceptada, THE Motor_RAG SHALL generar en español una propuesta de siguiente escalón terapéutico basada en el perfil del paciente.
3. WHEN el Motor_RAG genera una propuesta, THE Motor_RAG SHALL asociar cada afirmación terapéutica con al menos una Cita_Fuente que identifique documento, sección y fragmento.
4. IF el Motor_RAG no recupera ningún fragmento del Corpus_Documental con relevancia superior al umbral configurado, THEN THE Motor_RAG SHALL indicar que no dispone de evidencia suficiente y no generar una propuesta terapéutica.
5. WHEN el Motor_RAG genera una propuesta, THE Panel_Web SHALL mostrar el aviso de que la propuesta es orientativa y requiere validación del Profesional_Sanitario.
6. WHEN el Corpus_Documental se reindexa con los mismos documentos, THE Motor_RAG SHALL producir el mismo conjunto de fragmentos indexados.
7. WHEN se evalúa el Motor_RAG sobre un conjunto de preguntas de referencia, THE Evaluador SHALL calcular la proporción de afirmaciones con Cita_Fuente verificable en el Corpus_Documental.
8. WHEN el Motor_RAG genera una propuesta, THE Motor_RAG SHALL completarla en un máximo de 15 segundos.

### Requirement 13: Cuestionarios de síntomas POEM (extra opcional)

**User Story:** Como profesional sanitario, quiero registrar el cuestionario POEM de un paciente, para incorporar la percepción de síntomas al score y al seguimiento.

#### Acceptance Criteria

1. WHERE el módulo de cuestionarios está activo, THE Panel_Web SHALL permitir registrar las respuestas de los siete ítems del POEM, cada una con un valor entero entre 0 y 4.
2. WHEN se completan los siete ítems del POEM, THE Panel_Web SHALL calcular la puntuación total como la suma de los ítems, con un valor entre 0 y 28.
3. WHEN se calcula la puntuación POEM, THE Panel_Web SHALL mostrar la categoría de gravedad correspondiente: 0-2 "piel clara o casi clara", 3-7 "leve", 8-16 "moderada", 17-24 "grave", 25-28 "muy grave".
4. IF falta alguna respuesta de los siete ítems del POEM, THEN THE Panel_Web SHALL impedir el cálculo de la puntuación total e indicar los ítems pendientes.
5. WHERE el módulo de cuestionarios está activo, THE Modelo_ML SHALL aceptar la puntuación POEM como variable de entrada opcional.

### Requirement 14: Módulo de imagen y evaluación por fototipo (extra opcional)

**User Story:** Como investigador, quiero estimar la gravedad de la lesión a partir de una fotografía y evaluar su rendimiento por fototipo, para detectar sesgos en tonos de piel distintos.

#### Acceptance Criteria

1. WHERE el Modulo_Imagen está activo, THE Modulo_Imagen SHALL entrenarse y evaluarse con imágenes del dataset SCIN con diagnóstico de eccema y con etiqueta de Fototipo_Fitzpatrick.
2. WHERE el Modulo_Imagen está activo, WHEN el Profesional_Sanitario sube una imagen en formato JPEG o PNG de hasta 10 MB, THE Modulo_Imagen SHALL devolver una estimación de gravedad en una escala de 0 a 4 (tipo IGA).
3. IF el archivo subido no es una imagen JPEG o PNG válida o supera los 10 MB, THEN THE Panel_Web SHALL rechazar la carga e indicar el motivo.
4. WHERE el Modulo_Imagen está activo, THE Evaluador SHALL reportar el rendimiento del Modulo_Imagen para cada Fototipo_Fitzpatrick disponible en el conjunto de prueba y la diferencia máxima entre fototipos.
5. WHERE el Modulo_Imagen está activo, WHEN se sube una imagen, THE Panel_Web SHALL mostrar junto a la estimación el aviso de que la estimación es orientativa y no constituye un diagnóstico.
6. WHERE el Modulo_Imagen está activo, THE RADIANT SHALL eliminar las imágenes subidas por el Profesional_Sanitario al cerrar su sesión.

### Requirement 15: Modelo multimodal (extra opcional)

**User Story:** Como investigador, quiero una arquitectura que fusione historial, notas e imagen en un único score, para demostrar cómo se combinarían las señales en un caso real.

#### Acceptance Criteria

1. WHERE el Modelo_Multimodal está activo, THE Modelo_Multimodal SHALL combinar las señales del Modelo_ML, del Extractor_NLP y del Modulo_Imagen en un único Score_Riesgo entre 0 y 1.
2. WHERE el Modelo_Multimodal está activo, WHEN no hay imagen disponible para un paciente, THE Modelo_Multimodal SHALL calcular el Score_Riesgo con las señales restantes.
3. WHERE el Modelo_Multimodal está activo, THE Modelo_Multimodal SHALL emparejar de forma sintética imágenes y pacientes mediante una regla documentada y declarar en la Memoria_Proyecto que el emparejamiento es artificial.
4. WHERE el Modelo_Multimodal está activo, THE Explicador_SHAP SHALL indicar la contribución de cada modalidad al Score_Riesgo.

### Requirement 16: Reproducibilidad y entrega

**User Story:** Como desarrollador del proyecto, quiero que el pipeline sea reproducible y esté documentado, para poder presentarlo y repetir los resultados.

#### Acceptance Criteria

1. THE RADIANT SHALL ofrecer un comando único que ejecute el pipeline completo (generación, extracción, entrenamiento, evaluación) a partir de un archivo de configuración y una semilla.
2. WHEN se ejecuta el pipeline completo dos veces con la misma configuración, la misma semilla y las mismas versiones de dependencias, THE RADIANT SHALL producir las mismas métricas de evaluación.
3. THE RADIANT SHALL fijar las versiones de todas las dependencias en un archivo de bloqueo de dependencias.
4. WHEN se completa cada fase de la tabla de prioridades, THE RADIANT SHALL disponer de una versión ejecutable de extremo a extremo con las funciones de esa fase y de las anteriores.
5. THE Memoria_Proyecto SHALL documentar la metodología de generación de datos, el diseño de cada capa de detección, los resultados de evaluación, las limitaciones y la gobernanza.
