# Load necessary libraries
library(dplyr)
library(readr)
library(tidyr)
library(recommenderlab)
library(ggplot2)

# Define the path to the dataset
data_path <- "/Users/mitchellparker/Documents/AAA Studies/Personal Projects/movie-recommendation-system/data"

# Load ratings data
ratings <- read_csv(file.path(data_path, "ratings.csv"))

# Load movies data
movies <- read_csv(file.path(data_path, "movies.csv"))

# Preview the datasets
head(ratings)
head(movies)

# Preprocess the data: Join ratings and movies data
movie_ratings <- ratings %>%
    left_join(movies, by = "movieId")

# Preview the joined data
head(movie_ratings)

# Ensure the rating data is correctly structured
ratings_matrix <- movie_ratings %>%
    select(userId, movieId, rating) %>%
    spread(movieId, rating)

# Replace NA values with 0
ratings_matrix[is.na(ratings_matrix)] <- 0

# Convert the data frame to a realRatingMatrix
rating_matrix <- as(as.matrix(ratings_matrix[, -1]), "realRatingMatrix")

# Check the structure of the rating matrix
str(rating_matrix)

# Plot distribution of ratings and save as image
ggplot(movie_ratings, aes(x = rating)) +
    geom_histogram(binwidth = 0.5, fill = "blue", color = "black") +
    labs(title = "Distribution of Movie Ratings", x = "Rating", y = "Count") +
    ggsave("rating_distribution.png")

# Plot top 10 most rated movies and save as image
top_movies <- movie_ratings %>%
    group_by(title) %>%
    summarise(count = n()) %>%
    top_n(10, count) %>%
    arrange(desc(count))

ggplot(top_movies, aes(x = reorder(title, count), y = count)) +
    geom_bar(stat = "identity", fill = "blue", color = "black") +
    labs(title = "Top 10 Most Rated Movies", x = "Movie", y = "Count") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    ggsave("top_10_movies.png")

# Create a user-based collaborative filtering model
ubcf_model <- Recommender(rating_matrix, method = "UBCF")

# Make recommendations for the first user
recommendations <- predict(ubcf_model, rating_matrix[1, ], n = 10)
print(as(recommendations, "list"))

# Create an item-based collaborative filtering model
ibcf_model <- Recommender(rating_matrix, method = "IBCF")

# Make recommendations for the first user
recommendations_ibcf <- predict(ibcf_model, rating_matrix[1, ], n = 10)
print(as(recommendations_ibcf, "list"))

# Load necessary library
library(recosystem)

# Convert the rating matrix to a data frame
ratings_df <- as(rating_matrix, "data.frame")

# Create a data set object
train_set <- data_file(ratings_df, data_info = list(row = "userId", col = "movieId", value = "rating"))

# Initialize the recommender
recommender <- Reco()

# Train the model using SVD
recommender$train(train_set, opts = list(dim = 20, lrate = 0.1, costp_l2 = 0.01, costq_l2 = 0.01, niter = 20))

# Make predictions
pred <- recommender$predict(train_set, out_memory())

# Load necessary library
library(Metrics)

# Calculate RMSE for User-Based Collaborative Filtering
rmse_ubcf <- rmse(movie_ratings$rating[1:1000], as.numeric(pred[1:1000]))
print(paste("RMSE for UBCF:", rmse_ubcf))

# Calculate MAE for User-Based Collaborative Filtering
mae_ubcf <- mae(movie_ratings$rating[1:1000], as.numeric(pred[1:1000]))
print(paste("MAE for UBCF:", mae_ubcf))

# Load necessary library
library(caret)

# Define a grid of hyperparameters
param_grid <- expand.grid(dim = c(10, 20, 30), lrate = c(0.01, 0.1), costp_l2 = c(0.01, 0.1), costq_l2 = c(0.01, 0.1), niter = c(10, 20))

# Train the model using cross-validation
train_control <- trainControl(method = "cv", number = 5)
tuned_model <- train(train_set, method = "svd", tuneGrid = param_grid, trControl = train_control)

# Load necessary library
library(parallel)

# Parallel processing setup
num_cores <- detectCores() - 1
cl <- makeCluster(num_cores)
clusterEvalQ(cl, library(recommenderlab))

# Parallelize the recommendation process
recommendations_parallel <- parLapply(cl, 1:nrow(rating_matrix), function(i) {
    predict(ubcf_model, rating_matrix[i, ], n = 10)
})

# Stop the cluster
stopCluster(cl)

# Precompute recommendations and store them for real-time access
precomputed_recommendations <- predict(ubcf_model, rating_matrix, n = 10)

# Function to get recommendations for a specific user in real-time
get_recommendations <- function(user_id) {
    as(precomputed_recommendations[user_id, ], "list")
}

# Example usage for the first user
print(get_recommendations(1))
