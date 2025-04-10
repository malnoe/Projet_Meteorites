import pandas as pd
import plotly.graph_objects as go
import numpy as np
import geopandas as gpd
from shapely.geometry import Point


file_path = "Meteorite_Landings.csv"  
df = pd.read_csv(file_path)


df_clean = df.dropna(subset=["reclat", "reclong", "mass (g)", "year"]).copy()
df_clean["year"] = df_clean["year"].astype(int)
df_clean["mass_scaled"] = np.log1p(df_clean["mass (g)"])  

world = gpd.read_file("earth/ne_110m_admin_0_countries.shp") 


df_clean["geometry"] = df_clean.apply(lambda row: Point(row["reclong"], row["reclat"]), axis=1)
gdf = gpd.GeoDataFrame(df_clean, geometry="geometry", crs=world.crs)


df_clean = gpd.sjoin(gdf, world, how="left", predicate="within")
df_clean.rename(columns={"NAME": "country"}, inplace=True)  
df_clean["country"].fillna("Unknown", inplace=True)  

years = sorted(df_clean["year"].unique())


fig = go.Figure()
first_year = years[0]
df_initial = df_clean[df_clean["year"] <= first_year]


country_counts = df_initial["country"].value_counts()
country_text = "<br>".join([f"{c}: {n}" for c, n in country_counts.items()][:10])  


fig.add_trace(go.Scattergeo(
    lon=df_initial["reclong"],
    lat=df_initial["reclat"],
    text=df_initial["name"] + "<br>Masse: " + df_initial["mass (g)"].astype(str) + " g",
    hoverinfo="text",
    mode='markers',
    marker=dict(
        size=df_initial["mass_scaled"],
        color=df_initial["year"],
        colorscale="Viridis",
        opacity=0.7,
        reversescale=True
    )
))


frames = []
for year in years:
    df_cumulative = df_clean[df_clean["year"] <= year]  
    df_current = df_clean[df_clean["year"] == year]  

    country_counts = df_cumulative["country"].value_counts()
    country_text = "<br>".join([f"{c}: {n}" for c, n in country_counts.items()][:10])  

    frames.append(go.Frame(
        data=[
            go.Scattergeo(
                lon=df_cumulative["reclong"],
                lat=df_cumulative["reclat"],
                text=df_cumulative["name"] + "<br>Masse: " + df_cumulative["mass (g)"].astype(str) + " g",
                hoverinfo="text",
                mode='markers',
                marker=dict(
                    size=df_cumulative["mass_scaled"],
                    color=df_cumulative["year"],
                    colorscale="Viridis",
                    opacity=0.3,
                    reversescale=True
                )
            ),
            go.Scattergeo(
                lon=df_current["reclong"],
                lat=df_current["reclat"],
                text=df_current["name"] + "<br>Masse: " + df_current["mass (g)"].astype(str) + " g",
                hoverinfo="text",
                mode='markers',
                marker=dict(
                    size=df_current["mass_scaled"],
                    color=df_current["year"],
                    colorscale="Viridis",
                    opacity=0.9,
                    reversescale=True
                )
            )
        ],
        name=str(year),
        layout=go.Layout(
            annotations=[
                {
                    "x": 0.5, "y": 1.12,  
                    "xref": "paper", "yref": "paper",
                    "text": f"<b>Nombre de météorites :</b> {len(df_cumulative)}",
                    "showarrow": False,
                    "font": {"size": 20, "color": "gray"},
                    "bgcolor": "white",
                    "borderpad": 4
                },
                {
                    "x": 1.0, "y": 0.5,
                    "xref": "paper", "yref": "paper",
                    "text": f"<b>🌍 Météorites par Pays</b><br>{country_text}",
                    "showarrow": False,
                    "font": {"size": 16, "color": "black"},
                    "align": "left",
                    "bgcolor": "lightgray",
                    "borderpad": 6
                }
            ]
        )
    ))

fig.update(frames=frames)


fig.update_geos(
    projection_type="orthographic",
    showcoastlines=True,
    coastlinecolor="Black",
    showcountries=True,
    countrycolor="gray"
)


fig.update_layout(
    title="🌍 Évolution des Chutes de Météorites",
    geo=dict(
        showland=True,
        landcolor="lightgreen",
        showlakes=True,
        lakecolor="lightblue"
    ),
    updatemenus=[
        {
            "buttons":  [
                {
                    "args": [None, {"frame": {"duration": 500, "redraw": True}, "fromcurrent": True}],
                    "label": "▶️ Play",
                    "method": "animate"
                },
                {
                    "args": [[None], {"frame": {"duration": 0, "redraw": True}, "mode": "immediate", "transition": {"duration": 0}}],
                    "label": "⏸️ Pause",
                    "method": "animate"
                }
            ],
            "direction": "left",
            "pad": {"r": 10, "t": 87},
            "showactive": False,
            "type": "buttons",
            "x": 0.1,
            "xanchor": "right",
            "y": 0,
            "yanchor": "top"
        }
    ],
    sliders=[{
        "active": 0,
        "yanchor": "top",
        "xanchor": "left",
        "currentvalue": {"font": {"size": 20}, "prefix": "Année: ", "visible": True, "xanchor": "right"},
        "transition": {"duration": 300, "easing": "cubic-in-out"},
        "pad": {"b": 10, "t": 50},
        "len": 0.9,
        "x": 0.1,
        "y": 0,
        "steps": [{"args": [[str(year)], {"frame": {"duration": 300, "redraw": True}, "mode": "immediate"}], 
                   "label": str(year), "method": "animate"} for year in years]
    }]
)

fig.show()
