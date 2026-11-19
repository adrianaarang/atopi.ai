# Diario de decisiones

Cada decisión sigue el mismo formato: qué se decidió, por qué, qué se cedió y qué se haría distinto.

## Panel en React en lugar de Streamlit

**Por qué.** El panel debe cumplir WCAG 2.1 AA y la identidad visual propia: foco visible de 3 px, botones de 44 px y aviso fijo. Streamlit da poco control sobre el foco y la estructura semántica, y forzarlo con CSS es frágil.

**Qué cedí.** Más código y más tiempo que con Streamlit, en un proyecto de un solo desarrollador y 5 meses.

**Qué haría distinto.** Aún no lo sé. Lo revisaré al probar el panel con teclado y lector de pantalla.

## Ruido de etiqueta solo en el entrenamiento

**Por qué.** Si el ruido también afecta a la etiqueta con la que se evalúa, las métricas dejan de medir nada fiable. Se aplica solo a la etiqueta de entrenamiento y las métricas se informan con la etiqueta limpia y con la ruidosa.

**Qué cedí.** Una evaluación más compleja de explicar y dos conjuntos de cifras en lugar de una.

**Qué haría distinto.** Plantearlo así desde el primer diseño. Lo corregí tras una revisión externa.

## Criterio de derivación tomado de fuentes clínicas

**Por qué.** Si invento el criterio y luego genero los datos para que lo cumplan, el sistema solo reconoce mi propia regla. El criterio sale de guías publicadas y el generador no lo conoce.

**Qué cedí.** Tiempo: las guías pediátricas son escasas, hay que contrastarlas y falta un revisor clínico que valide el borrador.

**Qué haría distinto.** Buscar antes un revisor clínico, porque condiciona la tarea 5.3.

## Auditoría de solo añadir

**Por qué.** Cada decisión sobre una alerta debe quedar trazada y no poder editarse después. Si no se puede escribir la entrada de auditoría, la operación se cancela.

**Qué cedí.** Algo de flexibilidad: una corrección se registra como una entrada nueva, nunca como una edición.

**Qué haría distinto.** Aún no lo sé; depende de cómo lo use el panel.
