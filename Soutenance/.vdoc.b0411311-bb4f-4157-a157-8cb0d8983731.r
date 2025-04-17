#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#| echo: false
#| fig-align: left
#| fig-height: 3.8
#| fig-width: 6.2

library(corrr)
library(xtable)
library(ggplot2)
library(dplyr)

Meteorite_Landings <- read.csv("../Données/Meteorite_Landings.csv")

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
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#| echo: false
#| fig-height: 5
#| fig-width: 7

library(rnaturalearth)
library(sf)

# Charger les contours des pays (projection WGS84 par défaut)
world <- ne_countries(scale = "medium", returnclass = "sf")

# Charger les données de météorites (exemple : colonnes reclat, reclong)
df <- read.csv("Données/Meteorite_Landings.csv", stringsAsFactors = FALSE) |>
  na.omit() |>  # Supprimer les NA
  dplyr::select(reclat, reclong)  # Sélectionner les colonnes pertinentes

ggplot() +
  geom_sf(data = world, fill = "lightgray", color = "black", linewidth = 0.1) +
  geom_point(data = df, aes(x = reclong, y = reclat), 
             color = "red", alpha = 0.3, size = 0.5) +
  labs(title = "Emplacement des données") +
  theme_minimal()
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#| echo: false
#| fig-height: 3
#| fig-width: 5
#| fig-align: center

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
  theme_minimal() +
  theme(
    plot.title = element_text(size = 10),  # Réduire la hauteur du titre
    axis.title = element_text(size = 8)    # Réduire la hauteur des axes
  )
```
#
#
#
#
#| echo: false
#| fig-height: 3
#| fig-width: 5
#| fig-align: center

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
  theme_minimal() +
  theme(
    plot.title = element_text(size = 10),  # Réduire la hauteur du titre
    axis.title = element_text(size = 8)    # Réduire la hauteur des axes
  )
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
