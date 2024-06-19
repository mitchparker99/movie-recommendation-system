library(shiny)
library(dplyr)
library(readr)
library(tidyr)
library(recommenderlab)
library(ggplot2)

# Load data
data_path <- "/Users/mitchellparker/Documents/AAA Studies/Personal Projects/movie-recommendation-system/data"
ratings <- read_csv(file.path(data_path, "ratings.csv"))
movies <- read_csv(file.path(data_path, "movies.csv"))
movie_ratings <- ratings %>%
    left_join(movies, by = "movieId")
ratings_matrix <- movie_ratings %>%
    select(userId, movieId, rating) %>%
    spread(movieId, rating)
ratings_matrix[is.na(ratings_matrix)] <- 0
rating_matrix <- as(as.matrix(ratings_matrix[, -1]), "realRatingMatrix")

# Create a user-based collaborative filtering model
ubcf_model <- Recommender(rating_matrix, method = "UBCF")
precomputed_recommendations <- predict(ubcf_model, rating_matrix, n = 10)

get_recommendations <- function(user_id) {
    as(precomputed_recommendations[user_id, ], "list")
}

ui <- fluidPage(
    titlePanel("Movie Recommendation System"),
    sidebarLayout(
        sidebarPanel(
            numericInput("user_id", "User ID:", 1, min = 1, max = nrow(rating_matrix)),
            actionButton("recommend", "Get Recommendations")
        ),
        mainPanel(
            tableOutput("recommendations"),
            plotOutput("ratingDistPlot"),
            plotOutput("topMoviesPlot")
        )
    )
)

server <- function(input, output) {
    output$recommendations <- renderTable({
        input$recommend
        isolate({
            req(input$user_id)
            user_recommendations <- get_recommendations(input$user_id)
            data.frame(MovieID = unlist(user_recommendations))
        })
    })

    output$ratingDistPlot <- renderPlot({
        ggplot(movie_ratings, aes(x = rating)) +
            geom_histogram(binwidth = 0.5, fill = "blue", color = "black") +
            labs(title = "Distribution of Movie Ratings", x = "Rating", y = "Count")
    })

    output$topMoviesPlot <- renderPlot({
        top_movies <- movie_ratings %>%
            group_by(title) %>%
            summarise(count = n()) %>%
            top_n(10, count) %>%
            arrange(desc(count))

        ggplot(top_movies, aes(x = reorder(title, count), y = count)) +
            geom_bar(stat = "identity", fill = "blue", color = "black") +
            labs(title = "Top 10 Most Rated Movies", x = "Movie", y = "Count") +
            theme(axis.text.x = element_text(angle = 45, hjust = 1))
    })
}

shinyApp(ui = ui, server = server)
