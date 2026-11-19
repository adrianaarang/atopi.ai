# Ideas para RADIANT: detección de dermatitis atópica con IA

Sin acceso a historias clínicas reales, el enfoque es convertir esa limitación en una ventaja: construir un sistema completo y riguroso con datos sintéticos, combinar varias fuentes de señal y evaluar con honestidad.hola

## 1. Datos sintéticos realistas en FHIR (la base)

- Generar cohortes pediátricas con **Synthea**, añadiendo un módulo propio de dermatitis atópica: brotes, escalado de corticoides, comorbilidades (asma, rinitis), consultas y derivaciones.
- Generar las notas de texto libre en español con un LLM. Los casos infradiagnosticados serían los que tienen el patrón clínico pero sin código L20 en la historia.
- Pedir a un dermatólogo o pediatra (o a la mentoría) que revise una muestra de 20-30 casos para dar credibilidad clínica.
- **Limitación a declarar:** los datos sintéticos validan el pipeline, no el rendimiento clínico real. Si el modelo aprende las reglas con las que se generaron los datos, el resultado es circular. Debe constar en la memoria del proyecto.

## 2. Detección por capas, de más simple a más compleja

1. **Baseline por reglas:** criterios de Hanifin-Rajka o del UK Working Party, más un fenotipo basado en prescripciones (corticoides tópicos repetidos, inhibidores de calcineurina, antihistamínicos por prurito). Es la referencia contra la que comparar.
2. **ML sobre datos estructurados:** scikit-learn o XGBoost, con SHAP para explicar cada alerta.
3. **NLP sobre las notas:** extracción de señales como prurito nocturno, sueño alterado o localización en pliegues. Opciones: modelos clínicos en español (PlanTL-GOB-ES / BSC) o un LLM con salida estructurada.

## 3. El "algo más" (lo que diferencia el proyecto)

- **Módulo de imagen:** foto de la lesión (la que podría subir un padre o un pediatra desde el móvil) para estimar gravedad, tipo EASI/IGA. El dataset **SCIN** de Google incluye eccema con variedad de tonos de piel, lo que permite evaluar sesgo por fototipo (Fitzpatrick).
- **Modelo multimodal:** combinar historial, notas e imagen en un único score. Aunque las imágenes y las historias no sean del mismo paciente, se puede diseñar la arquitectura y mostrar cómo fusionaría las señales.
- **Cuestionarios de síntomas:** POEM o ítems de calidad de vida y sueño.
- **RAG de tratamientos:** sobre guías clínicas (AEDV, EADV) y la ficha técnica de Dupixent en CIMA, proponiendo el siguiente escalón terapéutico con cita de la fuente. Se puede reutilizar el pipeline del proyecto de fichas técnicas.

## 4. Qué impresiona en una demo

- Panel (Streamlit o React) con pacientes priorizados, score, explicación y botones aceptar/rechazar alerta.
- Evaluación honesta: métricas, matriz de errores, análisis por subgrupos y apartado de limitaciones.
- Nota de gobernanza: el sistema da soporte a la decisión y no diagnostica; RGPD y anonimización.

## 5. Orden recomendado (5 meses, en solitario)

1. Generador sintético FHIR + baseline por reglas (sistema completo y funcionando pronto).
2. NLP y ML con explicabilidad.
3. RAG de tratamientos.
4. Módulo de imagen como extra si da tiempo.

Mejor un pipeline sólido de punta a punta que muchos módulos a medias.

## Próximos pasos posibles

- Esqueleto del generador sintético FHIR.
- Diseño del baseline de reglas.
