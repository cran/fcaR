## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(fcaR)

## ----matrix-------------------------------------------------------------------
# Create a binary matrix
M <- matrix(c(1, 0, 1,
              1, 1, 0,
              0, 1, 1), 
            nrow = 3, 
            byrow = TRUE)

# Assign row and column names (Objects and Attributes)
rownames(M) <- c("Object1", "Object2", "Object3")
colnames(M) <- c("Attribute1", "Attribute2", "Attribute3")

# Create the FormalContext object
fc <- FormalContext$new(M)

# Print the context
fc

## ----dataframe----------------------------------------------------------------
df <- data.frame(
  has_wings = c(TRUE, TRUE, FALSE),
  can_fly   = c(TRUE, FALSE, FALSE),
  has_legs  = c(TRUE, TRUE, TRUE),
  row.names = c("Eagle", "Penguin", "Dog")
)

fc_df <- FormalContext$new(df)
fc_df

## ----cxt----------------------------------------------------------------------
# We use an example file included in the package
cxt_file <- system.file("contexts", "lives_in_water.cxt", package = "fcaR")

# Load the context
fc_cxt <- FormalContext$new(cxt_file)
fc_cxt

## ----csv----------------------------------------------------------------------
# We use an example file included in the package
csv_file <- system.file("contexts", "airlines.csv", package = "fcaR")

# Load from CSV
# Note: Ensure your CSV contains binary data
fc_csv <- FormalContext$new(csv_file)

# Inspect dimensions
dim(fc_csv)

## ----repo_browse--------------------------------------------------------------
# Get the list of available contexts
meta <- get_fcarepository_contexts()

# Print a detailed summary to the console
# (Shows Title, Dimensions, and Description for each entry)
print_repo_details(meta)

## ----fetch--------------------------------------------------------------------
# Download and load the 'Planets' context
fc_planets <- fetch_context("planets_en.cxt")

# The object is ready for analysis
fc_planets$find_concepts()
fc_planets$concepts$size()

## ----addin, eval=FALSE--------------------------------------------------------
# select_repository_context_addin()

