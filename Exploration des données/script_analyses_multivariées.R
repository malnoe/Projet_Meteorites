# Packages
library(corrr)
library(xtable)
library(ggplot2)
library(dplyr)

Meteorite_Landings <- read.csv("~/Ecole/M1/Projet/Projet_Meteorites/Données/Meteorite_Landings.csv")

# Analyses univariées

# Name - Première lettre
Meteorite_Landings <- Meteorite_Landings %>%
  mutate(first_letter = substr(name, 1, 1))
# Compter le nombre d'occurrences de chaque première lettre et trier par ordre décroissant
letter_counts <- Meteorite_Landings %>%
  group_by(first_letter) %>%
  summarise(count = n()) %>%
  arrange(desc(count))  # Trier par ordre décroissant
# Créer l'histogramme
ggplot(letter_counts, aes(x = reorder(first_letter, -count), y = count)) +
  geom_bar(stat = "identity") +
  labs(title = "Histogramme des premières lettres des noms de météorites",
       x = "Première lettre",
       y = "Nombre de météorites") +
  theme_minimal()

#Recclass
# Calcul pourcentage en ne gardant que ceux > 4%
recclass_counts <- Meteorite_Landings %>%
  group_by(recclass) %>%
  summarise(count = n()) %>%
  mutate(percentage = count / sum(count) * 100) %>%
  filter(percentage >= 4)

# Trier par pourcentage
recclass_counts <- recclass_counts %>%
  arrange(desc(percentage))

# Définir les couleurs des barres
bar_colors <- c("deepskyblue4", "springgreen4", "deepskyblue4", "springgreen4", "springgreen4", "tan4", "tan4")

# Diagramme en barres avec couleurs personnalisées
ggplot(recclass_counts, aes(x = reorder(recclass, percentage), y = percentage, fill = recclass)) +
  geom_bar(stat = "identity", fill = bar_colors[1:nrow(recclass_counts)]) +
  labs(title = "Répartition des classes de recclass (> 4%)",
       x = "Classe",
       y = "Pourcentage",
       fill = "Classe") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

# Year
# Filtrer les données pour ne garder que les années > 1963 et < 2026
filtered_data <- Meteorite_Landings %>%
  filter(year > 1963 & year <2026)
# Compter le nombre d'occurrences de chaque année
year_counts <- filtered_data %>%
  group_by(year) %>%
  summarise(count = n())
# Créer le barplot
ggplot(year_counts, aes(x = year, y = count)) +
  geom_bar(stat = "identity") +
  labs(title = "Nombre de météorites tombées chaque année (après 1963)",
       x = "Année",
       y = "Nombre de météorites") +
  theme_minimal()

# Latitude
# Arrondir les valeurs de reclat au degré le plus proche et compter les occurrences
latitude_counts <- Meteorite_Landings %>%
  mutate(rounded_lat = round(reclat)) %>%  # Arrondir au degré le plus proche
  group_by(rounded_lat) %>%
  summarise(count = n())
# Barplot
ggplot(latitude_counts, aes(x = rounded_lat, y = count)) +
  geom_bar(stat = "identity") +
  labs(title = "Météorites tombées par degré de latitude",
       x = "Latitude (degré arrondi à l'unité)",
       y = "Nombre de météorites") +
  theme_minimal()

# Longitude
# Arrondir les valeurs de reclat au degré le plus proche et compter les occurrences
longitude_counts <- Meteorite_Landings %>%
  filter(reclong >= -180 & reclong <= 180)
longitude_counts <- longitude_counts %>%
  mutate(rounded_long = round(reclong)) %>%  # Arrondir au degré le plus proche
  group_by(rounded_long) %>%
  summarise(count = n())
# Barplot
ggplot(longitude_counts, aes(x = rounded_long, y = count)) +
  geom_bar(stat = "identity") +
  labs(title = "Météorites tombées par degré de longitude",
       x = "Longitude (degré arrondi à l'unité)",
       y = "Nombre de météorites") +
  theme_minimal()


# Analyses multivariées
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

