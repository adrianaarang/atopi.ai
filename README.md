# RADIANT

Sistema web de soporte a la decisión clínica para detectar dermatitis atópica (DA) moderada-grave infradiagnosticada en población pediátrica, sobre datos sintéticos en formato FHIR. Proyecto para Sanofi (mentoría Saturno Academy). Marca de la aplicación: **atopi.ai**.

> Soporte a la decisión clínica. No constituye un diagnóstico. Datos sintéticos.

## Documentos clave

- Requisitos: `.kiro/specs/radiant/requirements.md`
- Diseño técnico de la fase 1: `.kiro/specs/radiant/design.md`
- Descripción inicial del proyecto: `docs/ideas/ideas-deteccion-dermatitis-atopica.md`
- Hoja de estilos de marca: `docs/brand/hoja-de-estilos-atopi-ai.md`
- Logotipos (SVG): `docs/brand/assets/`

## Fases

1. Generador sintético FHIR, baseline por reglas y panel web mínimo (MVP).
2. NLP y ML con explicabilidad, y evaluación.
3. RAG de tratamientos.
4. Imagen, cuestionarios y modelo multimodal (opcionales).

## Estructura

Los archivos con "Pendiente de implementar" o "Pendiente de completar" son esqueletos; los documentos clave (requisitos, diseño y tareas de la fase 1, contexto del agente, ideas, hoja de estilos y logotipos) ya tienen contenido.

```
atopi.ai/
  .gitignore  — Excluye datos generados, entornos virtuales y secretos
  .kiro/
    specs/
      radiant/
        design.md  — Diseño de la fase 1: decisiones técnicas (React, FastAPI, SQLite), arquitectura, control de circularidad y plan por semanas [fase 1]
        requirements.md  — Requisitos del sistema (16 requisitos, formato EARS), con gravedad, alcance por fase y supuestos
        tasks.md  — Plan de tareas derivado de los requisitos, ordenado por fase [fase 1]
    steering/
      product.md  — Contexto fijo para el agente: objetivo clínico, usuarios, aviso de soporte a la decisión y límites
      structure.md  — Contexto fijo para el agente: organización del repositorio y convenciones de nombres
      tech.md  — Contexto fijo para el agente: stack, convenciones y reglas que no se deben romper
  Makefile  — Atajos de comandos: pipeline completo, tests, API y panel [fase 1]
  api/
    __init__.py  — Servicio web [fase 1]
    auth.py  — Inicio de sesión, hash de contraseñas con sal y roles (Req. 11) [fase 1]
    main.py  — Aplicación FastAPI y configuración general [fase 1]
    routers/
      alerts.py  — Endpoints de alertas, detalle y decisiones [fase 1]
      audit.py  — Endpoint de exportación del registro de auditoría [fase 2]
      evaluation.py  — Endpoint del último informe de evaluación [fase 2]
      rag.py  — Endpoint de propuesta terapéutica [fase 3]
    schemas.py  — Esquemas de entrada y salida de la API [fase 1]
  configs/
    default.yaml  — Configuración por defecto del pipeline: tamaño de cohorte, semilla, rutas y fases activas [fase 1]
    small_cohort.yaml  — Cohorte reducida para desarrollo y tests rápidos [fase 1]
    thresholds.yaml  — Umbral de alerta, fenotipo por prescripciones y condiciones del criterio de derivación [fase 1]
  data/
    DATA_SOURCES.md  — Registro de fuentes externas: origen, fecha de obtención y licencia (Req. 10.8) [fase 1]
    README.md  — Qué hay en cada subcarpeta de datos y cómo se regeneran (no se versiona el contenido)
    external/
      cima/
        .gitkeep  — Fichas técnicas de CIMA para el RAG [fase 3]
      scin/
        .gitkeep  — Dataset SCIN para el módulo de imagen [fase 4]
    external_notes/
      .gitkeep  — Conjunto_Notas_Externo: notas escritas a mano o revisadas por un clínico, solo para evaluación [fase 2]
    fhir/
      .gitkeep  — Bundles FHIR finales de la cohorte [fase 1]
    notes/
      .gitkeep  — Notas clínicas sintéticas y sus metadatos de señales [fase 1]
    processed/
      .gitkeep  — Variables derivadas y particiones de entrenamiento, validación y prueba [fase 2]
    synthea_raw/
      .gitkeep  — Salida cruda de Synthea [fase 1]
  docs/
    brand/
      README.md  — Índice de la marca: logotipos incluidos, cuándo usar cada versión y enlace al lienzo de diseño
      assets/
        atopi-icono-app.svg  — Icono de app: gotita sobre fondo amarillo con esquinas redondeadas
        atopi-logo.svg  — Logotipo principal horizontal (símbolo + atopi.ai) sobre fondo claro
        atopi-simbolo-oscuro.svg  — Símbolo solo con contorno blanco para fondo oscuro
        atopi-simbolo.svg  — Símbolo solo (gotita sonriente con estrella) para fondo claro
      hoja-de-estilos-atopi-ai.md  — Hoja de estilos de atopi.ai: paleta accesible, tipografía, logotipo, componentes y variables CSS
    ideas/
      ideas-deteccion-dermatitis-atopica.md  — Descripción inicial del proyecto: enfoque, capas de detección, extras y orden recomendado
    memoria/
      README.md  — Índice de la Memoria_Proyecto y estado de cada apartado
      gobernanza.md  — Soporte a la decisión, RGPD, anonimización y fuentes del criterio de derivación (Req. 10.6 y 10.10)
      limitaciones.md  — Limitaciones: datos sintéticos, circularidad y no extrapolación clínica (Req. 10.7)
      metodologia.md  — Metodología de generación de datos y diseño de cada capa de detección (Req. 16.5)
      resultados.md  — Resultados de la evaluación: métricas globales, por subgrupo y comparación con el baseline [fase 2]
    revision_clinica/
      README.md  — Formato de la muestra de 20-30 casos para el revisor clínico y registro de sus comentarios (Req. 10.9) [fase 1]
  infra/
    Dockerfile  — Imagen de la aplicación [fase 1]
    docker-compose.yml  — Servicios locales: API y panel [fase 1]
  notebooks/
    README.md  — Exploración y análisis; los resultados finales viven en reports/
  pyproject.toml  — Configuración del paquete Python y dependencias; con el archivo de bloqueo fija las versiones (Req. 16.3)
  reports/
    .gitkeep  — Informes de evaluación versionados [fase 2]
  src/
    radiant/
      __init__.py  — Paquete principal de RADIANT [fase 1]
      alerts/
        __init__.py  — Alertas y decisiones [fase 1]
        decisions.py  — Registro de aceptar o rechazar con motivo [fase 1]
        service.py  — Generación, priorización y exclusión de alertas por umbral (Req. 7) [fase 1]
      audit/
        __init__.py  — Auditoría [fase 1]
        log.py  — Registro de auditoría de solo añadir y exportación CSV (Req. 10.3 a 10.5) [fase 1]
      cli.py  — Comando único que ejecuta el pipeline completo con configuración y semilla (Req. 16.1) [fase 1]
      config.py  — Carga y validación de la configuración y de las semillas [fase 1]
      evaluation/
        __init__.py  — Evaluación honesta [fase 2]
        bootstrap.py  — Intervalos de confianza por remuestreo bootstrap (Req. 9.2) [fase 2]
        circularity.py  — Prueba de circularidad frente al baseline (Req. 9.8) [fase 2]
        metrics.py  — Matriz de confusión, sensibilidad, especificidad, VPP, F1, AUROC y AUPRC (Req. 9.1) [fase 2]
        report.py  — Informe versionado con semilla, configuración y limitaciones (Req. 9.7, 9.9) [fase 2]
        subgroups.py  — Métricas por sexo y edad, con aviso de baja fiabilidad (Req. 9.3, 9.6) [fase 2]
      fhir/
        __init__.py  — Lectura y escritura de FHIR [fase 1]
        models.py  — Modelo interno de paciente: demografía, condiciones, prescripciones, encuentros, observaciones y notas [fase 1]
        parser.py  — Convierte un Bundle FHIR en el modelo interno con errores descriptivos (Req. 3.1, 3.2, 3.5) [fase 1]
        serializer.py  — Convierte el modelo interno en un Bundle FHIR JSON (Req. 3.3) [fase 1]
      generator/
        __init__.py  — Generador sintético [fase 1]
        cohort.py  — Genera la cohorte con Synthea y posprocesa los bundles (Req. 1) [fase 1]
        ground_truth.py  — Asigna la etiqueta de verdad-terreno y la gravedad de la DA (Req. 1.4, 1.9) [fase 1]
        notes.py  — Genera notas clínicas en español por plantillas, con variabilidad y caché opcional de LLM (Req. 2) [fase 1]
        templates.py  — Plantillas y formulaciones de cada señal clínica, con abreviaturas, erratas y negaciones [fase 1]
      imaging/
        __init__.py  — Módulo de imagen [fase 4]
        fitzpatrick_eval.py  — Evaluación por fototipo Fitzpatrick (Req. 14.4) [fase 4]
        model.py  — Estimación de gravedad tipo IGA con imágenes SCIN (Req. 14) [fase 4]
      ml/
        __init__.py  — Modelo de ML y explicabilidad [fase 2]
        explain.py  — Explicaciones SHAP ordenadas por magnitud (Req. 6.4, 6.5) [fase 2]
        features.py  — Variables derivadas de datos estructurados y señales, sin fuga de etiqueta (Req. 6.1) [fase 2]
        split.py  — Partición por paciente en entrenamiento, validación y prueba (Req. 6.2) [fase 2]
        train.py  — Entrenamiento determinista del modelo para predecir el caso objetivo (Req. 6.6, 6.8) [fase 2]
      multimodal/
        __init__.py  — Fusión multimodal [fase 4]
        fusion.py  — Combina historial, notas e imagen en un único score (Req. 15) [fase 4]
      nlp/
        __init__.py  — Extracción de señales clínicas [fase 2]
        extractor.py  — Extrae señales con su fragmento y negación desde notas en español (Req. 5) [fase 2]
        signals.py  — Definición de los tipos de señal clínica [fase 2]
      questionnaires/
        __init__.py  — Cuestionarios [fase 4]
        poem.py  — Cálculo y categorías de gravedad del POEM (Req. 13) [fase 4]
      rag/
        __init__.py  — RAG de tratamientos [fase 3]
        engine.py  — Propuesta de siguiente escalón terapéutico con citas y rechazo sin evidencia (Req. 12) [fase 3]
        indexer.py  — Indexación reproducible del corpus documental (Req. 12.1, 12.6) [fase 3]
      rules/
        __init__.py  — Baseline por reglas clínicas [fase 1]
        engine.py  — Motor de reglas: resultado binario, criterios cumplidos y sospecha de caso objetivo (Req. 4) [fase 1]
        hanifin_rajka.py  — Criterios de Hanifin-Rajka con estado no evaluable [fase 1]
        phenotype.py  — Fenotipo por prescripciones con umbrales y ventana temporal configurables [fase 1]
        referral.py  — Criterio de derivación a dermatología (Req. 4.7) [fase 1]
        uk_wp.py  — Criterios del UK Working Party [fase 1]
  synthea/
    README.md  — Cómo ejecutar Synthea, versión usada y notas sobre el módulo propio [fase 1]
    modules/
      .gitkeep  — Aquí va el módulo atopic_dermatitis.json de Synthea (Req. 1.3) [fase 1]
  tests/
    integration/
      test_pipeline.py  — Pipeline de extremo a extremo por fase (Req. 16.4) [fase 1]
    property/
      test_determinism.py  — Misma semilla y configuración, mismos resultados (Req. 1.2, 4.6, 6.6) [fase 1]
      test_fhir_roundtrip.py  — Propiedad de ida y vuelta del serializador y el parser (Req. 3.4) [fase 1]
      test_shap_additivity.py  — La suma de contribuciones SHAP coincide con la salida del modelo (Req. 6.5) [fase 2]
    unit/
      test_generator.py  — Tests unitarios del generador y de las etiquetas [fase 1]
      test_rules_engine.py  — Tests unitarios del motor de reglas [fase 1]
  web/
    README.md  — Panel web en español con aviso fijo, WCAG AA y estilo atopi.ai; estructura del frontend [fase 1]
    public/
      favicon.svg  — Favicon del panel web (icono de app) [fase 1]
```
