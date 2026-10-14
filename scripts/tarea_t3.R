# Tarea 3 — Regresión económica: CASEN y ENE
# Autor: Francisco Inostroza
# Fecha: Octubre 2026
# Objetivo: Estimar, extraer, comparar, diagnosticar e interpretar modelos de regresión.

library(dplyr)
library(broom)
library(modelsummary)

# PARTE A — CASEN

# A1. Dos modelos
casen <- read.csv("data/raw/casen_reducido.csv") |>
  mutate(experiencia = pmax(edad - educ - 6, 0))

m1 <- lm(ingreso ~ educ, data = casen)
m2 <- lm(ingreso ~ educ + experiencia + genero, data = casen)

# A2. La tabla de coeficientes, con broom + dplyr
tabla_m2 <- tidy(m2, conf.int = TRUE) |>
  filter(term != "(Intercept)") |>
  mutate(significativo_5 = p.value < 0.05) |>
  arrange(p.value)
print(tabla_m2)

# A3. Comparar modelos
# Agregamos la experiencia al cuadrado para capturar el perfil cóncavo de Mincer.
m3 <- lm(ingreso ~ educ + experiencia + I(experiencia^2) + genero, data = casen)

modelos_casen <- list(simple = m1, controles = m2, mio = m3)
comparacion_r2 <- lapply(modelos_casen, glance) |> bind_rows(.id = "modelo")
print(comparacion_r2)

# Al agregar la experiencia al cuadrado en m3, el R² sube levemente de 
# 0.458 a 0.481, pero el R² ajustado cae de 0.448 a 0.440. Nuestro modelo no mejora ya 
# que la penalización por agregar variables es mayor que su aporte explicativo debido 
# a la muestra pequeña (n=55).

# A4. ¿Cambió el coeficiente de educación?
bind_rows(simple = tidy(m1), controles = tidy(m2), mio = tidy(m3), .id = "modelo") |>
  filter(term == "educ")

# El coeficiente de educación cambia al agregar controles porque 'experiencia' y 
# 'género' están relacionadas con ella. Al incluirlas en el modelo, limpiamos el 
# efecto y aislamos mejor cuánto influye realmente la educación.

# A5. Diagnóstico
# 1. Las tres personas peor predichas

peor_predichas <- augment(m2) |> arrange(desc(abs(.resid))) |> slice(1:3)
peor_predichas
# Las tres personas con las peores predicciones del modelo son hombres. 
# Lo que tienen en común es que sus residuos son fuertemente negativos.
# esto significa que el modelo sobreestimó por mucho sus ingresos.

# 2. Máxima distancia de Cook y apalancamiento
augment(m2) |> summarise(max_cook = max(.cooksd, na.rm = TRUE), 
              max_hat = max(.hat, na.rm = TRUE))
# Calcula la máxima distancia de Cook y el máximo apalancamiento para revisar 
# si existe algún caso extremo que esté alterando demasiado los resultados del modelo.

# 3. Re-estimar m2 sin la observación más influyente

m2_sin_influyente <- casen |> 
  filter(row_number() != 43) |> 
  lm(ingreso ~ educ + experiencia + genero, data = _)

bind_rows(con_todos = tidy(m2), sin_influyente = tidy(m2_sin_influyente), .id = "muestra") |>
  filter(term == "educ")


# A6. Interpretación de la Parte A

tabla_m2

# En el modelo con controles, cada año adicional de educación se asocia con
# $42.246  más de ingreso mensual, en promedio, manteniendo experiencia y
# género constantes (IC 95 %: 29.487 a 55.004).
# El coeficiente de generoM es 55.686. Esto significa que ser hombre se asocia
# a un ingreso promedio $55.686 mayor que el de las mujeres, comparando a igual 
# nivel educativo y años de experiencia.
# El coeficiente de género es económicamente importante ($55.686), pero no es significativo 
# (p=0.204). Con n=55 falta poder estadístico para confirmar esta diferencia.


#
# PARTE B — ENE: tu pregunta
# 

# B1. Pregunta declarada:
# ¿La brecha de género en las horas habituales trabajadas cambia a medida
# que aumenta la edad, manteniendo constante el nivel educacional?
  
# B2. Prepara la base

ene <- read.csv2("data/raw/ene-2026-06-mjj.csv")
# Mi ene_a3.csv no conservó habituales, edad, cine11_1d, región ni categoría
# Asi que repito la limpieza desde el archivo Raw.

ene_ocup <- ene |>
  filter(activ == 1) |>
  mutate(mujer      = sexo == 2,
         nivel_educ = ifelse(cine11_1d == 9, NA, cine11_1d)) |>
  filter(!is.na(nivel_educ))

ene_limpia <- ene_ocup |>
  mutate(habituales = na_if(na_if(habituales, 888), 999)) |>
  filter(!is.na(habituales), !is.na(edad))

nrow(ene_ocup) 
nrow(ene_limpia)

# B3. Los dos modelos
mod_base <- lm(habituales ~ mujer + edad, 
               data = ene_limpia, weights = fact_cal)

mod_controles <- lm(habituales ~ mujer * edad + as.factor(nivel_educ) 
                 + as.factor(categoria_ocupacion), 
                 data = ene_limpia, weights = fact_cal)

# B4. Extrae y compara resultados
# 1. Una tabla con el coeficiente de tu variable de interés

bind_rows(base = tidy(mod_base), controles = tidy(mod_controles), .id = "modelo") |>
  filter(term == "mujerTRUE") |>
  select(modelo, estimate, std.error, p.value)

# 2. glance() de ambos modelos apilados para comparar ajuste
lapply(list(base = mod_base, controles = mod_controles), glance) |>
  bind_rows(.id = "modelo") |>
  select(modelo, r.squared, adj.r.squared, nobs)

# 3. Interacción: poner a prueba si la brecha difiere según la edad
tidy(mod_controles, conf.int = TRUE) |>
  filter(term == "mujerTRUE:edad") |>
  select(term, estimate, conf.low, conf.high, p.value)
  
b_mujer <- coef(mod_controles)["mujerTRUE"]
b_inter <- coef(mod_controles)["mujerTRUE:edad"]

resultado_edad <- data.frame(edad = c(25, 40, 55, 65)) |>
  mutate(brecha_horas = round(b_mujer + (b_inter * edad), 2))

# B5. Sensibilidad: con y sin los mayores de 65 

mod_controles_65 <- ene_limpia |>
  filter(edad <= 65) |>
  lm(habituales ~ mujer * edad + as.factor(nivel_educ) + as.factor(categoria_ocupacion), 
     data = _, weights = fact_cal)

bind_rows(todos = tidy(mod_controles), hasta_65 = tidy(mod_controles_65), 
          .id = "muestra") |>
  filter(term == "mujerTRUE:edad") |>
  select(muestra, estimate, std.error, p.value)

# Estimamos el mismo modelo con controles, pero filtrando hasta los 65 años

# B6. Interpretación de la Parte B
resultado_edad
# El modelo base responde a cuál es la brecha de género general: vemos que 
# ser mujer se asocia con 4.15 horas habituales menos a la semana (resultado 
# significativo con un p muy cercano a 0). Al meter los controles, el modelo 
# ahora responde a si esta desventaja se mantiene al comparar personas con perfiles
# iguales (misma educación y ocupación), y notamos que la brecha persiste.
# 
# Respecto a la interacción con la edad, la brecha aumenta -0.0079 horas por 
# cada año extra (pasando de -3.85 horas a los 25 años a -4.09 a los 55). Dado 
# el tamaño de la ENE (n > 40.000), este coeficiente es marginal (menos de 1 hora de 
# diferencia en 30 años) y carece de relevancia práctica. Además, la evidencia 
# estadística es débil, ya que no es significativo al 5% (p = 0.388). Al excluir 
# a los mayores de 65 años (p = 0.0997) no altera esta conclusión, pues el 
# efecto sigue sin ser significativo al 5%.
# 
# Limitaciones:
# 1) Los errores estándar de lm() con weights asumen muestreo aleatorio simple, 
# ignorando el diseño muestral complejo de la ENE e invalidando la inferencia.
# 2) El modelo deja fuera variables clave como el trabajo doméstico y de cuidados. 
# Como las mujeres suelen asumir más estas tareas, les queda menos tiempo para 
# el mercado laboral. Al faltar esta información, la brecha es solo una 
# "asociación" y no podemos afirmar que el hecho de ser mujer "causa" trabajar 
# menos horas.

## Parte C — Comunicar 

modelsummary(list("Base" = mod_base, "Con controles" = mod_controles),
             stars = TRUE,
             gof_map = c("nobs", "r.squared"))
#
dir.create("data/processed", showWarnings = FALSE)
tidy(mod_controles, conf.int = TRUE) |>
  write.csv("data/processed/t3_coeficientes_ene.csv", row.names = FALSE)
