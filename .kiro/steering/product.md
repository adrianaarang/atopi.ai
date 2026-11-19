# Producto

Contexto fijo para el agente.

## Qué es

RADIANT es un sistema web de soporte a la decisión clínica que detecta dermatitis atópica (DA) moderada-grave infradiagnosticada en población pediátrica, para alertar al profesional de una posible derivación a dermatología. Se desarrolla para Sanofi, con mentoría de Saturno Academy, en solitario y en 5 meses. La marca de la aplicación es **atopi.ai**.

## Usuarios

- **Profesional sanitario** (pediatra, médico de familia o dermatólogo): revisa alertas y acepta o rechaza.
- **Lector**: consulta alertas sin registrar decisiones (fase 2).
- **Responsable del proyecto**: desarrolla, evalúa y documenta.

## Principios

- El sistema **da soporte a la decisión y no diagnostica**; la decisión clínica es siempre del profesional.
- Trabaja **solo con datos sintéticos**. Los resultados validan el pipeline, no el rendimiento clínico real, y esa limitación se declara siempre.
- Cada alerta es **explicable**: score, contribuciones de las variables, señales y criterios cumplidos.
- Todo es **trazable**: auditoría de solo añadir y informes versionados.
- La interfaz está en español y cumple WCAG 2.1 AA.

## Fuera de alcance

- Uso con historias clínicas reales.
- Diagnóstico automático o prescripción.
- Cualquier afirmación de eficacia clínica.

## Fases

1. Generador sintético FHIR, baseline por reglas y panel mínimo.
2. NLP y ML con explicabilidad, y evaluación.
3. RAG de tratamientos.
4. Imagen, cuestionarios y modelo multimodal (opcionales).
