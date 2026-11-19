# Hoja de estilos · atopi.ai

Guía rápida de marca para **atopi.ai**: un estilo tierno, infantil y accesible, sobre fondo blanco.

---

## 1. Concepto

- **Nombre:** atopi.ai (juego con "atopía" + IA).
- **Símbolo:** una gotita sonriente (cuidado e hidratación de la piel) con una estrellita (la IA).
- **Personalidad:** cercana, amable, tranquilizadora. Pensada para familias y pediatría.
- **Lema:** *cuidamos la piel de los peques*.
- **Fondo por defecto:** blanco.

---

## 2. Paleta de color

| Nombre | HEX | Uso |
|---|---|---|
| **Índigo** | `#2D2A6E` | Texto, contornos del símbolo, fondos oscuros |
| **Azul cielo** | `#5BB5F7` | Relleno de la gotita |
| **Azul intenso** | `#1F6FD1` | ".ai", enlaces, botones |
| **Amarillo sol** | `#FFD23F` | Estrella, fondo del icono de app |
| **Coral** | `#FF8A96` | Mejillas y pequeños detalles |
| **Azul nube** | `#EAF5FF` | Tarjetas y fondos suaves |
| **Gris texto** | `#5B5F7A` | Texto secundario y lemas |
| **Blanco** | `#FFFFFF` | Fondo principal |

### Contrastes (WCAG 2.1)

AA exige 4,5:1 en texto normal y 3:1 en texto grande y gráficos.

| Combinación | Ratio | Uso permitido |
|---|---|---|
| Índigo sobre blanco | 12,6:1 | Todo tipo de texto |
| Gris texto sobre blanco | 6,2:1 | Todo tipo de texto |
| Azul intenso sobre blanco | 4,9:1 | Texto, enlaces y botones |
| Blanco sobre azul intenso | 4,9:1 | Texto en botones |
| Índigo sobre azul nube | 11,4:1 | Todo tipo de texto |
| Gris texto sobre azul nube | 5,7:1 | Todo tipo de texto |
| Azul intenso sobre azul nube | 4,5:1 | Solo texto grande (24 px o más) |
| Índigo sobre azul cielo | 5,6:1 | Todo tipo de texto |
| Índigo sobre amarillo sol | 8,7:1 | Todo tipo de texto |
| Índigo sobre coral | 5,6:1 | Todo tipo de texto |
| Blanco sobre índigo | 12,6:1 | Todo tipo de texto |
| Amarillo sol sobre índigo | 8,7:1 | Texto y detalles sobre fondo oscuro |
| Azul cielo sobre índigo | 5,6:1 | Texto y detalles sobre fondo oscuro |

**Reglas importantes**

- **Nunca** uses azul cielo, amarillo o coral como color de texto sobre blanco (contraste insuficiente).
- Los rellenos claros del símbolo se mantienen legibles gracias al **contorno índigo**; no los uses sin contorno sobre fondo blanco.
- No transmitas información solo con el color: acompáñala de texto o icono.

---

## 3. Tipografía

- **Fuente:** [Fredoka](https://fonts.google.com/specimen/Fredoka) (Google Fonts), redondeada y amable.
- **Peso principal:** 600 (semibold) para el logo y los títulos; 500 para texto de apoyo.
- **Alternativa de respaldo:** `sans-serif` del sistema.

| Elemento | Tamaño | Peso | Color |
|---|---|---|---|
| Título (H1) | 36–48 px | 600 | Índigo |
| Subtítulo (H2) | 24–28 px | 600 | Índigo |
| Texto | 16–18 px | 500 | Índigo o gris texto |
| Texto pequeño | 15 px mínimo | 500 | Gris texto |
| Lema | 22 px | 600 | Gris texto |

Interlineado recomendado: 1,35–1,5 para texto corrido.

---

## 4. Logotipo

### Versiones

1. **Principal (sobre blanco):** símbolo azul cielo con contorno índigo + "atopi" en índigo + ".ai" en azul intenso.
2. **Sobre fondo oscuro (índigo):** contorno y texto en blanco, ".ai" y estrella en amarillo sol.
3. **Sobre azul nube:** igual que la principal.
4. **Icono de app:** fondo amarillo sol con esquinas muy redondeadas, símbolo con contorno índigo y estrella blanca.
5. **Con lema:** versión principal con "cuidamos la piel de los peques" debajo, en gris texto.

### Anatomía del símbolo

- Gotita azul cielo con contorno índigo de 4 unidades (sobre un lienzo de 120).
- Brillo blanco en el lado izquierdo.
- Cara: dos ojos redondos, sonrisa suave y dos mejillas coral.
- Estrella de cuatro puntas amarilla con contorno índigo, arriba a la derecha.

### Uso correcto

- Deja alrededor del logo un margen libre de, al menos, la mitad del ancho de la gotita.
- Tamaño mínimo recomendado del símbolo: **32 px** en pantalla.
- Usa siempre el nombre en minúsculas: `atopi.ai`.

### Evita

- Cambiar los colores del símbolo o del nombre.
- Estirar o deformar el logo.
- Colocarlo sobre fondos con poco contraste o con imágenes recargadas.
- Quitar el contorno de la gotita sobre fondo claro.
- Añadir sombras, degradados o efectos.

---

## 5. Formas y componentes

- **Esquinas redondeadas:** 20 px en tarjetas pequeñas, 32 px en tarjetas grandes, 56 px en iconos de app.
- **Botones:** fondo azul intenso, texto blanco, esquinas muy redondeadas (999 px) y mínimo 44 px de alto.
- **Tarjetas:** fondo azul nube, sin bordes duros.
- **Enlaces:** azul intenso, subrayados al pasar el cursor o recibir el foco.
- **Foco de teclado:** anillo visible de 3 px en azul intenso con separación de 2 px.
- **Iconos:** trazo redondeado, sin esquinas afiladas, acompañados de texto o etiqueta accesible.

---

## 6. Accesibilidad

- Objetivos táctiles de al menos **44 × 44 px**.
- Texto con contraste AA o superior (ver tabla).
- Imágenes con texto alternativo. Ejemplo para el logo: *"atopi.ai: gotita sonriente con una estrella"*.
- Respeta la preferencia de movimiento reducido en cualquier animación.
- Idioma de la página declarado (`lang="es"`).

---

## 7. Variables CSS

```css
:root {
  /* Color */
  --atopi-indigo: #2D2A6E;
  --atopi-sky: #5BB5F7;
  --atopi-blue: #1F6FD1;
  --atopi-sun: #FFD23F;
  --atopi-coral: #FF8A96;
  --atopi-cloud: #EAF5FF;
  --atopi-gray: #5B5F7A;
  --atopi-white: #FFFFFF;

  /* Tipografía */
  --atopi-font: "Fredoka", system-ui, sans-serif;

  /* Forma */
  --atopi-radius-sm: 20px;
  --atopi-radius-md: 32px;
  --atopi-radius-pill: 999px;
}

body {
  background: var(--atopi-white);
  color: var(--atopi-indigo);
  font-family: var(--atopi-font);
  font-weight: 500;
  line-height: 1.45;
}

a { color: var(--atopi-blue); }

.button {
  background: var(--atopi-blue);
  color: var(--atopi-white);
  border-radius: var(--atopi-radius-pill);
  min-height: 44px;
  padding: 0 24px;
  font-weight: 600;
}

.button:focus-visible {
  outline: 3px solid var(--atopi-blue);
  outline-offset: 2px;
}
```

---

## 8. Pendiente antes de usarlo

- Comprobar que el nombre, el dominio `atopi.ai` y los usuarios en redes estén libres.
- Revisar si existe alguna marca registrada parecida en el sector salud.
- Si se usa en el reto con Sanofi, confirmar con la mentoría que el nombre no se confunda con un producto comercial.
