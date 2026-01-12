## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(fcaR)

## ----dirichlet----------------------------------------------------------------
# Uniform Context (Standard)
# All objects have roughly 20% of attributes
fc_uni <- RandomContext(n_objects = 20, n_attributes = 10, density = 0.2, distribution = "uniform")

# Dirichlet Context (Realistic)
# Some objects will be empty, some full, some in between.
# alpha = 0.1 -> High skewness (Very sparse or very dense rows)
# alpha = 1.0 -> Uniform distribution of row sizes
fc_dir <- RandomContext(n_objects = 20, n_attributes = 10, distribution = "dirichlet", alpha = 0.2)

# Compare Row Sums
barplot(rowSums(fc_uni$incidence()), main = "Uniform: Row Sums", ylim = c(0, 10))
barplot(rowSums(fc_dir$incidence()), main = "Dirichlet: Row Sums", ylim = c(0, 10))

## ----swapping-----------------------------------------------------------------
data(planets)
fc <- FormalContext$new(planets)

# Original Marginals
orig_col_sums <- colSums(fc$incidence())
print(orig_col_sums)

# Randomize using Swap
fc_random <- randomize_context(fc, method = "swap")

# Verify Marginals are preserved
new_col_sums <- colSums(fc_random$incidence())
print(new_col_sums)

# But the structure is different
print(all(fc$incidence() == fc_random$incidence()))

## ----distributive_gen---------------------------------------------------------
# Generate a random distributive context based on a Poset with 15 elements
fc_dist <- RandomDistributiveContext(n_elements = 15, density = 0.2)
fc_dist$find_concepts()

# Verify the mathematical guarantee
print(paste("Is Distributive?", fc_dist$concepts$is_distributive()))
print(paste("Is Modular?",      fc_dist$concepts$is_modular()))

