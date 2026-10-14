# Brecha de Género en la Jornada Laboral
Análisis de la brecha de género en horas trabajadas usando datos de la ENE.

## Pregunta y Respuesta Parte B
#¿Existe brecha de género en la jornada habitual y cómo interactúa con la edad?
Ser mujer se asocia con 4.15 horas menos de jornada, desventaja que persiste con 
perfiles similares. Si bien la brecha aumenta levísimamente con la edad, este efecto 
extra no tiene importancia económica ni es significativo al 5%. 

## Datos
Encuesta Nacional de Empleo (ENE). Archivo en `ene-2026-06-mjj`.

## Cómo correrlo
Abrir el proyecto `tarea_t3.Rproj` y
ejecutar `scripts/tarea_a3.R`

## Estructura
```
├── data/
│   ├── raw/
│   │   ├── casen_reducido.csv
│   │   └── ene-2026-06-mjj.csv
│   └── processed/
│       ├── ene_a3.csv
│       └── t3_coeficientes_ene.csv
├── scripts/
│   └── tarea_t3.R
├── tarea_t3.Rproj
└── README.md
```
##Autor

#Francisco Inostroza — Octubre 2026

## Declaración de autoría y uso de IA

Copia este bloque al final de tu `README.md` y complétalo:

```markdown
## Declaración de autoría y uso de IA
- Herramienta utilizada: Gemini(o «ninguna»)
- Para qué la usé: Ayuda para corregir la redaccion, en la pregunta B4.3 le pedi recomendaciones 
- para dar con el resultado_edad
- Qué hice yo: Verifique que lograba entenderlo y intentar replicarlo 
- Verificación: confirmo que entiendo y puedo explicar todo lo que entrego.
```

**Uso permitido:** pedir que te expliquen un error, preguntar qué hace una función
o un argumento (`weights`, `conf.int`, `group_modify`), pedir alternativas a un
código que ya escribiste, revisar la redacción.

**Uso no permitido:** pegar este enunciado y entregar lo que devuelva; entregar
código que no puedes explicar línea por línea; pedirle que **interprete** los
coeficientes por ti — esa es justamente la habilidad que se evalúa.

Un aviso concreto: si le pides a un chatbot que «haga una regresión con la ENE», te
va a inventar variables (`ingreso`, `salario`, `años_educ`) que **no existen** en
este archivo. El manual manda sobre el chatbot.

Declarar el uso **no baja la nota**; ocultarlo constituye falta a la ética
académica (Guía de uso ético de tecnologías digitales, UdeC).

