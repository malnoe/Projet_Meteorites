import pandas as pd
import plotly.express as px

# Charger les données
file_path = 'Meteorite_Landings.csv'  # Chemin vers le fichier
meteorite_data = pd.read_csv(file_path)

# Nettoyer les données
meteorite_data_clean = meteorite_data.dropna(subset=['year', 'reclat', 'reclong'])
meteorite_data_clean['year'] = meteorite_data_clean['year'].astype(int)

# Filtrer les années valides
meteorite_data_clean = meteorite_data_clean[
    (meteorite_data_clean['year'] > 0) & (meteorite_data_clean['year'] <= 2023)
]

# Trier les données par ordre croissant des années
meteorite_data_clean = meteorite_data_clean.sort_values(by='year')

# Ajouter une colonne cumulative pour garder en mémoire les météorites déjà tombées
cumulative_data = pd.DataFrame()
frames = []

for year in sorted(meteorite_data_clean['year'].unique()):
    # Ajouter les météorites de l'année actuelle
    yearly_data = meteorite_data_clean[meteorite_data_clean['year'] == year]
    cumulative_data = pd.concat([cumulative_data, yearly_data])

    # Marquer les données avec l'année courante
    cumulative_data['current_year'] = year

    # Sauvegarder un snapshot des données pour l'animation
    frames.append(cumulative_data.copy())

# Créer une DataFrame finale pour l'animation
final_data = pd.concat(frames)

# Créer une animation avec Plotly Express
fig = px.scatter_geo(
    final_data,
    lat='reclat',
    lon='reclong',
    color='year',
    hover_name='name',
    animation_frame='current_year',
    title="Animation des impacts cumulés de météorites",
    template='plotly_white'
)

# Personnalisation de la carte
fig.update_layout(
    geo=dict(
        showland=True,  # Afficher la terre
        landcolor="lightgray",  # Couleur des terres
        showlakes=True,  # Afficher les lacs
        lakecolor="white",  # Couleur des lacs
        projection_type="natural earth",  # Type de projection pour afficher la carte
        showcoastlines=True,  # Afficher les côtes
        coastlinecolor="black",  # Couleur des côtes
        showcountries=True,  # Afficher les frontières des pays
        countrycolor="black",  # Couleur des frontières des pays
        showocean=True,  # Afficher les océans
        oceancolor="lightblue"  # Couleur de l'océan
    ),
    coloraxis_colorbar=dict(title="Annnée")  # Légende pour la masse des météorites
)

# Afficher l'animation
fig.show()
