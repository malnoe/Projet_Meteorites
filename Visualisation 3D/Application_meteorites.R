library(shiny)
library(shinydashboard)
library(shinyjs)
library(threejs)
library(scales)
library(countrycode)
library(sf)
library(rnaturalearth)

# 🌐 Préparation des données géographiques
meteorite <- read.csv("C:/Users/garan/Documents/Ecole/M1/Projet/Projet_Meteorites/Données/Meteorite_Landings.csv")
earth <- "http://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73909/world.topo.bathy.200412.3x5400x2700.jpg"
meteorite <- na.omit(meteorite)
meteorite <- meteorite[meteorite$year != 860,]
world <- ne_countries(scale = "medium", returnclass = "sf")
meteorite <- st_as_sf(meteorite, coords = c("reclong", "reclat"), crs = 4326, remove = FALSE)
meteorite <- st_join(meteorite, world["name"])
names(meteorite)[names(meteorite) == "name.y"] <- "pays"
meteorite$pays_fr <- countrycode(meteorite$pays, origin = "country.name", destination = "cldr.name.fr")

# 🖼️ Interface
ui <- dashboardPage(
  dashboardHeader(title = "Visualisation"),
  
  dashboardSidebar(
    useShinyjs(),
    h4("Filtres", align = "center"),
    sliderInput("year_range", "Intervalle d'années :", min = 1900, max = 2013, value = c(1900, 2013), step = 10),
    selectInput("mass_category", "Plage de masse :", 
                choices = c("Toutes les masses", "0 - 10g", "10 - 100g", "100g - 1kg", 
                            "1kg - 10kg", "10kg - 100kg", "100kg - 1T", 
                            "1T - 10T", "10T - 100T"),
                selected = "Toutes les masses"),
    selectInput("pays_filter", "Pays :", 
                choices = sort(unique(na.omit(meteorite$pays_fr))),
                selected = NULL, multiple = TRUE)
  ),
  
  dashboardBody(
    tags$head(
      tags$style(HTML("
        .skin-blue .main-header .logo {
          background-color: #1a1a1a;
          color: white;
          font-weight: bold;
        }
        .skin-blue .main-header .navbar {
          background-color: #1a1a1a;
        }
        .skin-blue .main-sidebar {
          background-color: #2c3e50;
        }
        .box {
          border-radius: 10px;
          box-shadow: 0 2px 10px rgba(0,0,0,0.15);
        }
        .color-bar {
          width: 100%;
          height: 20px;
          margin-top: 20px;
        }
        .color-bar div {
          height: 100%;
          display: inline-block;
        }
        .color-bar-label {
          display: flex;
          justify-content: space-between;
          margin-top: 5px;
          margin-bottom: 15px;
        }
      ")),
    ),
    
    fluidRow(
      box(width = 12,
          uiOutput("globe"),
          br(),
          textOutput("meteorite_count"),
          br(),
          div(id = "mass_bar", class = "color-bar"),
          div(id = "mass_bar_labels", class = "color-bar-label"),
          br(),
          uiOutput("meteorite_info")
      )
    )
  )
)

# ⚙️ Serveur
server <- function(input, output, session) {
  
  mass_ranges <- list(
    "0 - 10g" = c(0, 10),
    "10 - 100g" = c(10, 100),
    "100g - 1kg" = c(100, 1000),
    "1kg - 10kg" = c(1000, 10000),
    "10kg - 100kg" = c(10000, 100000),
    "100kg - 1T" = c(100000, 1000000),
    "1T - 10T" = c(1000000, 10000000),
    "10T - 100T" = c(10000000, 100000000)
  )
  
  filtered_data <- reactive({
    data <- meteorite[meteorite$year >= input$year_range[1] & 
                        meteorite$year <= input$year_range[2], ]
    
    if (input$mass_category != "Toutes les masses") {
      range <- mass_ranges[[input$mass_category]]
      data <- subset(data, mass..g. >= range[1] & mass..g. <= range[2])
    }
    
    if (!is.null(input$pays_filter) && length(input$pays_filter) > 0) {
      data <- data[data$pays_fr %in% input$pays_filter, ]
    }
    
    return(data)
  })
  
  output$globe <- renderUI({
    data <- filtered_data()
    log_masses <- log10(pmax(data$mass..g., 1))
    mass_scaled <- rescale(log_masses, to = c(1, 100))
    palette <- colorRampPalette(c("green", "yellow", "red"))(100)
    colors <- palette[round(mass_scaled)]
    
    globejs(
      img = earth,
      lat = data$reclat, 
      long = data$reclong, 
      color = colors, 
      arcsHeight = 0.3, 
      pointsize = 1, 
      atmosphere = TRUE
    )
  })
  
  output$meteorite_count <- renderText({
    count <- nrow(filtered_data())
    paste("Nombre de météorites :", count)  
  })
  
  output$meteorite_info <- renderUI({
    req(input$meteorite_click)
    meteorite <- input$meteorite_click
    if (!is.null(meteorite)) {
      selected <- filtered_data()[filtered_data()$reclat == meteorite$lat & 
                                    filtered_data()$reclong == meteorite$lng, ]
      if (nrow(selected) > 0) {
        HTML(paste0(
          "Nom : ", selected$name, "<br>",
          "Masse : ", selected$mass..g., "g<br>",
          "Année de chute : ", selected$year, "<br>",
          "Pays : ", selected$pays_fr
        ))
      } else {
        "Aucune information trouvée."
      }
    }
  })
  
  # Légende du gradient avec les vraies valeurs de masse
  observe({
    range <- if (input$mass_category == "Toutes les masses") {
      c(0, 100000000)
    } else {
      mass_ranges[[input$mass_category]]
    }
    
    format_mass <- function(x) {
      if (x >= 1e6) {
        paste0(x / 1e6, "T")
      } else if (x >= 1000) {
        paste0(x / 1000, "kg")
      } else {
        paste0(x, "g")
      }
    }
    
    min_label <- format_mass(range[1])
    max_label <- format_mass(range[2])
    
    js_code <- sprintf("
      document.getElementById('mass_bar').setAttribute('style', 'background: linear-gradient(to right, green, yellow, red);');
      document.getElementById('mass_bar_labels').innerHTML = '<div>%s</div><div style=\"text-align: right;\">%s</div>';
    ", min_label, max_label)
    
    shinyjs::runjs(js_code)
  })
}

options(shiny.port = 5133)
shinyApp(ui = ui, server = server)
