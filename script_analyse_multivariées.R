library(corrr)
library(xtable)

Meteorite_Landings <- read.csv("~/Ecole/M1/Projet/Projet_Meteorites/Données/Meteorite_Landings.csv")
Meteorite_Landings <- na.omit(Meteorite_Landings)
col_quanti <- c(5,7,8,9)
col_quali <- c(3,4,6)

# Test du chi-deux pour les variables qualitatives
chi_results <- data.frame(
  Variables = c("nametype - recclass", "nametype - fall", "recclass - fall"),
  p_value = c(
    chisq.test(Meteorite_Landings$nametype, Meteorite_Landings$recclass)$p.value,
    chisq.test(Meteorite_Landings$nametype, Meteorite_Landings$fall)$p.value,
    chisq.test(Meteorite_Landings$recclass, Meteorite_Landings$fall)$p.value
  )
)

# Corrélations entre variables quantitatives
cor_matrix <- corrr::correlate(Meteorite_Landings[,col_quanti])

# Test de la normalité des échantillons
shapiro.test(sample(Meteorite_Landings$mass..g., 5000))
shapiro.test(sample(Meteorite_Landings$year, 5000))
shapiro.test(sample(Meteorite_Landings$reclat, 5000))
shapiro.test(sample(Meteorite_Landings$reclong, 5000))

# Tests de Kruskal-Wallis
kruskal_results <- expand.grid(
  Variable_Quanti = c("mass..g.", "year", "reclat", "reclong"),
  Variable_Quali = c("nametype", "recclass", "fall")
)

kruskal_results$p_value <- mapply(function(x, g) {
  kruskal.test(as.formula(paste(x, "~", g)), data = Meteorite_Landings)$p.value
}, kruskal_results$Variable_Quanti, kruskal_results$Variable_Quali)


# Export en LaTeX
print(xtable(chi_results, digits = 4), type = "latex")
print(xtable(cor_matrix, digits = 4), type = "latex")
print(xtable(kruskal_results, digits = 4), type = "latex")

