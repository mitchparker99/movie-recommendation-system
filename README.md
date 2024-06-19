# Movie Recommendation System

Developed an advanced movie recommendation system using R and the MovieLens dataset, providing personalized movie recommendations to users based on their preferences and viewing history. The system was implemented as an interactive Shiny web application, allowing users to input their user ID and receive a list of recommended movies. The application also includes visualizations of movie rating distributions and the most popular movies.

# Key Features:

User-Based Collaborative Filtering: Utilized collaborative filtering to recommend movies based on user similarities.
Data Preprocessing: Employed dplyr and tidyr for data cleaning and transformation.
Matrix Factorization: Implemented matrix factorization using recommenderlab for improved recommendation accuracy.
Interactive Visualizations: Used ggplot2 to create dynamic plots displaying the distribution of movie ratings and the top 10 most rated movies.
Shiny Web Application: Developed an interactive web interface with shiny, enabling users to get real-time recommendations and visualize data insights.

# Technologies Used:

R Programming Language: For implementing the recommendation algorithms and data processing.
Shiny: To build the interactive web application.
ggplot2: For creating data visualizations.
dplyr and tidyr: For data manipulation and preprocessing.
recommenderlab: For collaborative filtering and matrix factorization.
readr: For reading CSV files and handling datasets.

# Responsibilities:

Designed and implemented the recommendation algorithm using collaborative filtering and matrix factorization.
Preprocessed and cleaned the MovieLens dataset to ensure data quality.
Created interactive visualizations to provide insights into the data.
Developed a Shiny web application to provide a user-friendly interface for recommendations and visualizations.
Conducted model evaluation and tuning to optimize recommendation accuracy.

## Setup

1. Install the required R packages:
   ```r
   install.packages("dplyr")
   install.packages("tidyr")
   install.packages("ggplot2")
   install.packages("recommenderlab")
   install.packages("recosystem")
   install.packages("Metrics")
   install.packages("parallel")
   install.packages("caret")
   ```

### SHINY APP

Shiny is an R package that makes it easy to build interactive web applications directly from R. You can use Shiny to create a local app or deploy it as a web application.

install.packages("shiny")

then run app.R and wait

Listening on http://127.0.0.1:54542

### ---- ----
