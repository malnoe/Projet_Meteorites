import pandas as pd
import plotly.express as px

# Charger les données
file_path = 'Meteorite_Landings.csv'  # Chemin vers le fichier
meteorite_data = pd.read_csv(file_path)

# Nettoyer les données
meteorite_data_clean = meteorite_data.dropna(subset=['year', 'reclat', 'reclong', 'mass (g)'])
meteorite_data_clean['year'] = meteorite_data_clean['year'].astype(int)

# Filtrer les années valides
meteorite_data_clean = meteorite_data_clean[
    (meteorite_data_clean['year'] > 0) & (meteorite_data_clean['year'] <= 2023)
]

# Trier les données par ordre croissant des années
meteorite_data_clean = meteorite_data_clean.sort_values(by='year')

# Créer une animation
fig = px.scatter_geo(
    meteorite_data_clean,
    lat='reclat',
    lon='reclong',
    hover_name='name',
    animation_frame='year',
    title="Animation des impacts de météorites (année par année)",
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
    )
)

# Afficher l'animation dans le notebook
fig.show()
