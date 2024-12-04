# Introduction to Data Science Final Project
## American Kennel Club and Westminster Best in Show Analysis
### Overview
This project aims to help users find similar dog breeds based on a selected breed or specified preferences. It includes a data preprocessing step, an interactive R Shiny app, and a Python-based analysis script.

### File Structure
* cleaned_data.csv : The pre-generated, cleaned dataset (originally from https://github.com/tmfilho/akcdata/tree/master/data) for analysis. This was generated using the R Markdown file.
* westminster_best_in_show.csv : The pre-generated, cleaned dataset web-scraped from https://en.wikipedia.org/wiki/List_of_Best_in_Show_winners_of_the_Westminster_Kennel_Club_Dog_Show.
* Analysis of AKC Data and Westminster Winners.Rmd : An R Markdown file that processes raw data and generates cleaned datasets for analysis. It should be run first to create up-to-date data files. Performs linear regression analysis, ANOVAs, and visualizations.
* Analysis of AKC Data and Westminster Winners.ipynb : A Python notebook for running machine learning algorithms for clustering dog breeds and finding similar dog breeds based on name or user-defined features.
* AKC_app.R : An R Shiny app for interactive exploration of similar dog breeds based on name or user-defined features. The app is functional for similarity based on name, but contains unresolved bugs with user-defined features.

### Prerequisites
#### R Environment
* tidyverse
* knitr
* shiny (for the app)
#### Python Environment
* pandas
* numpy
* scikit-learn
### Instructions
1. Run the R Markdown File (`Analysis of AKC Data and Westminster Winners.Rmd`)
The R Markdown file preprocesses raw data and generates cleaned datasets for analysis. Running this file will create the necessary .csv files in the data/ directory.

Note: If you prefer not to run the R file, pre-generated .csv datasets are provided in the data/ directory.

2. Run the Python Notebook (Analysis of `AKC Data and Westminster Winners.ipynb`)
Open the notebook and execute its cells to analyze the data and find similar dog breeds based on:

* Selected breed name
* User-defined features such as popularity, trainability, or energy level.
3. Optional: Use the R Shiny App (AKC_app.R)
The R Shiny app allows for interactive exploration of the dataset. While the app is functional, it currently has unresolved bugs that may impact its usability.

#### Known Issues
* Shiny App Bugs: Some features in the R Shiny app may not work as expected. Bug fixes are ongoing.
* Cross-Platform Dependencies: Ensure all required packages for both R and Python environments are installed before running the files.
### Notes
The repository includes pre-generated datasets (.csv files) for convenience, but running Analysis of `AKC Data and Westminster Winners.Rmd` ensures that these files are up-to-date.
