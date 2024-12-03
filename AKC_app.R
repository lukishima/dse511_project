#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

# Load libraries
library(shiny)
library(dplyr)
library(ggplot2)
library(caret) # For scaling
library(FNN) # For nearest neighbors
library(plotly) # For interactive plots

# Load the dataset and check structure
akc_data <- read.csv("/Users/lindseyukishima/DSE511/cleaned_data.csv", header = TRUE, stringsAsFactors = FALSE)

colnames(akc_data)[colnames(akc_data) == "...1"] <- "Breed"

# Remove rows with any missing values in the columns of interest
akc_data_clean <- akc_data %>%
    filter(!is.na(popularity) & !is.na(trainability_value) & !is.na(demeanor_value) & !is.na(energy_level_value) &
               !is.na(min_height) & !is.na(max_height))

# Convert columns to numeric if needed
akc_data_clean <- akc_data_clean %>%
    mutate(across(c(popularity, trainability_value, demeanor_value, energy_level_value, min_height, max_height), as.numeric))


# Remove duplicates for breed similarity
unique_breeds <- akc_data %>%
    distinct(Breed, .keep_all = TRUE)

# Define UI
ui <- fluidPage(
    titlePanel("Dog Breed Explorer"),
    
    sidebarLayout(
        sidebarPanel(
            h3("Explore Breed Similarity"),
            selectInput(
                "breed_name",
                "Select a Breed:",
                choices = unique(unique_breeds$Breed),
                selected = "Golden Retriever"
            ),
            numericInput("n_neighbors_breed", "Number of Similar Breeds:", 5, min = 1, max = 10),
            actionButton("find_breed", "Find Similar Breeds"),
            
            h3("Find Breeds by Features"),
            sliderInput("popularity", "Popularity:", min = 0, max = 100, value = 50),
            sliderInput("trainability", "Trainability:", min = 0, max = 1, value = 0.5, step = 0.1),
            sliderInput("demeanor", "Demeanor:", min = 0, max = 1, value = 0.5, step = 0.1),
            sliderInput("energy_level", "Energy Level:", min = 0, max = 1, value = 0.5, step = 0.1),
            sliderInput("min_height", "Min Height (inches):", min = 5, max = 35, value = 20),
            sliderInput("max_height", "Max Height (inches):", min = 10, max = 40, value = 30),
            numericInput("n_neighbors_features", "Number of Breeds to Match:", 5, min = 1, max = 10),
            actionButton("find_features", "Find by Features")
        ),
        
        mainPanel(
            h4("Results"),
            tabsetPanel(
                tabPanel("Similar Breeds",
                         tableOutput("breed_results"),
                         plotlyOutput("breed_plot")
                ),
                tabPanel("Feature-Based Matches",
                         tableOutput("feature_results"),
                         plotlyOutput("feature_plot")
                )
            )
        )
    )
)

# Define Server
server <- function(input, output, session) {
    
    # Helper function to scale data
    scale_data <- function(data) {
        scaled_data <- scale(data)
        return(scaled_data)
    }
    
    # Find similar breeds by breed name
    find_similar_breeds <- reactive({
        req(input$breed_name)
        
        breed_features <- unique_breeds %>%
            select(popularity, trainability_value, demeanor_value, energy_level_value, min_height, max_height) %>%
            mutate(across(everything(), as.numeric))
        
        scaled_features <- scale_data(breed_features)
        breed_index <- which(unique_breeds$Breed == input$breed_name)
        
        # Use the scaled features to find the nearest neighbors
        knn <- get.knnx(data = scaled_features, query = scaled_features[breed_index, , drop = FALSE], k = input$n_neighbors_breed)
        
        similar_breeds <- unique_breeds[knn$nn.index, ]
        similar_breeds
    })
    
    # Find breeds by feature preferences
    find_breeds_by_features <- reactive({
        # Create the user preferences data frame
        user_preferences <- data.frame(
            popularity = input$popularity,
            trainability_value = input$trainability,
            demeanor_value = input$demeanor,
            energy_level_value = input$energy_level,
            min_height = input$min_height,
            max_height = input$max_height
        )
        
        # Step 1: Check if there are any NA values in the user input
        if (any(is.na(user_preferences))) {
            return("Please ensure all user inputs are filled and not missing.")  # Return a message if NA is found
        }
        
        # Step 2: Check for NAs in the breed features dataset
        breed_features <- unique_breeds %>%
            select(popularity, trainability_value, demeanor_value, energy_level_value, min_height, max_height)
        
        # If there are NA values in breed features, you can either remove them or impute them
        if (any(is.na(breed_features))) {
            breed_features <- na.omit(breed_features)  # Remove rows with NA values (this will affect the matching)
            # Alternatively, you can impute missing values using methods like mean imputation:
            # breed_features[is.na(breed_features)] <- mean(breed_features, na.rm = TRUE)
        }
        
        # Step 3: Ensure the features are numeric and scale the data
        breed_features <- mutate_all(breed_features, as.numeric)
        
        # Scale breed features
        scaled_features <- scale_data(breed_features)
        
        # Scale the user preferences (ensure both are scaled to the same range)
        scaled_user <- scale_data(user_preferences)
        
        # Find the nearest neighbors using KNN
        knn <- get.knnx(data = scaled_features, query = scaled_user, k = input$n_neighbors_features)
        
        # Return matched breeds based on the KNN result
        matched_breeds <- unique_breeds[knn$nn.index, ]
        matched_breeds
    })
    
    # Render feature-based results
    output$feature_results <- renderTable({
        input$find_features
        isolate({
            # Check if any results were found
            matched_breeds <- find_breeds_by_features()
            
            if (is.null(matched_breeds)) {
                return("No matches found (check inputs for NA values).")
            }
            
            # If matches are found, render the breed info
            matched_breeds %>%
                select(Breed, popularity, trainability_value, demeanor_value, energy_level_value)
        })
    })
    
    
    
    
    # Plot breed similarity
    output$breed_plot <- renderPlotly({
        input$find_breed
        isolate({
            similar_breeds <- find_similar_breeds()
            
            breed_features <- unique_breeds %>%
                select(popularity, trainability_value, demeanor_value, energy_level_value, min_height, max_height)
            
            pca <- prcomp(scale_data(breed_features), center = TRUE)
            pca_data <- as.data.frame(pca$x)
            pca_data$Breed <- unique_breeds$Breed
            
            plot_data <- pca_data %>%
                filter(Breed %in% c(input$breed_name, similar_breeds$Breed))
            
            plot_ly(plot_data, x = ~PC1, y = ~PC2, text = ~Breed, color = ~Breed, type = 'scatter', mode = 'markers') %>%
                layout(title = "Breed Similarity (PCA)", xaxis = list(title = "PC1"), yaxis = list(title = "PC2"))
        })
    })
    
    # Plot feature-based similarity
    output$feature_plot <- renderPlotly({
        input$find_features
        isolate({
            matched_breeds <- find_breeds_by_features()
            
            if (is.null(matched_breeds)) {
                return(NULL)
            }
            
            breed_features <- unique_breeds %>%
                select(popularity, trainability_value, demeanor_value, energy_level_value, min_height, max_height)
            
            pca <- prcomp(scale_data(breed_features), center = TRUE)
            pca_data <- as.data.frame(pca$x)
            pca_data$Breed <- unique_breeds$Breed
            
            plot_data <- pca_data %>%
                filter(Breed %in% matched_breeds$Breed)
            
            plot_ly(plot_data, x = ~PC1, y = ~PC2, text = ~Breed, color = ~Breed, type = 'scatter', mode = 'markers') %>%
                layout(title = "Feature-Based Matches (PCA)", xaxis = list(title = "PC1"), yaxis = list(title = "PC2"))
        })
    })
}

# Run the App
shinyApp(ui = ui, server = server)
