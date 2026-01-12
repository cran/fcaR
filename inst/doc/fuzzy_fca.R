## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 5,
  warning = FALSE
)

## ----setup--------------------------------------------------------------------
library(fcaR)

## ----fuzzy_context------------------------------------------------------------
# Matrix with membership degrees
I <- matrix(c(
  0.9, 0.1, 0.8, 0.0,
  0.2, 1.0, 0.0, 0.9,
  0.5, 0.5, 0.5, 0.5,
  0.0, 0.8, 0.1, 1.0
), nrow = 4, byrow = TRUE)

rownames(I) <- c("User1", "User2", "User3", "User4")
colnames(I) <- c("Action", "Romance", "SciFi", "Drama")

fc <- FormalContext$new(I)
print(fc)

## ----set_logic----------------------------------------------------------------
# Switch to Lukasiewicz logic
fc$use_logic("Lukasiewicz")
fc$get_logic()

## ----find_concepts------------------------------------------------------------
fc$find_concepts()
fc$concepts

## ----inspect------------------------------------------------------------------
# Select a concept (e.g., the 4th one)
C <- fc$concepts$sub(4)

# Extent (Degrees of objects)
C$get_extent()

# Intent (Degrees of attributes)
C$get_intent()

## ----plot, fig.height=6, fig.width=6------------------------------------------
fc$concepts$plot(mode = "reduced", method = "sugiyama")

## ----implications-------------------------------------------------------------
fc$find_implications()
fc$implications

## ----filter-------------------------------------------------------------------
# Filter strong rules
fc$implications[fc$implications$support() > 0.2]

## ----closure------------------------------------------------------------------
# Define a new user profile
S <- Set$new(attributes = fc$attributes)
# Likes Action very much, Drama somewhat
S$assign(Action = 1.0, Drama = 0.5)

# Compute the semantic closure using Lukasiewicz logic
closure_S <- fc$implications$closure(S)

# What do we infer about Romance or SciFi?
print(closure_S)

