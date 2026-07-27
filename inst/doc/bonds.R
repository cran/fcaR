## -----------------------------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  warning = FALSE,
  message = FALSE
)

## -----------------------------------------------------------------------------
library(fcaR)

## -----------------------------------------------------------------------------
set.seed(42)
# Context 1
mat1 <- matrix(sample(0:1, 16, replace = TRUE), nrow = 4, ncol = 4)
rownames(mat1) <- paste0("O", 1:4)
colnames(mat1) <- paste0("A", 1:4)
fc1 <- FormalContext$new(mat1)
print(fc1)

# Context 2
mat2 <- matrix(sample(0:1, 16, replace = TRUE), nrow = 4, ncol = 4)
rownames(mat2) <- paste0("P", 1:4)
colnames(mat2) <- paste0("B", 1:4)
fc2 <- FormalContext$new(mat2)
print(fc2)

## -----------------------------------------------------------------------------
bl <- bonds(fc1, fc2, method = "conexp")
bl

## -----------------------------------------------------------------------------
# Using the backtracking method
bl_mcis <- bonds(fc1, fc2, method = "mcis")
bl_mcis$size()

## -----------------------------------------------------------------------------
bl$plot()

## -----------------------------------------------------------------------------
# Get all bonds as a list of FormalContexts
all_bonds <- bl$get_bonds()
length(all_bonds)

# Inspect the first non-trivial bond
# (Note: Bond 1 is usually the "Core" or minimal bond)
all_bonds[[1]]

## -----------------------------------------------------------------------------
core <- bl$get_core()
core$plot()

## -----------------------------------------------------------------------------
# Take an existing bond and check it
mat_bond <- methods::as(all_bonds[[1]]$incidence(), "matrix")
is_bond(fc1, fc2, mat_bond)

# Check an arbitrary (likely invalid) relation
random_rel <- matrix(0, nrow = nrow(mat_bond), ncol = ncol(mat_bond))
is_bond(fc1, fc2, random_rel)

## -----------------------------------------------------------------------------
# 1. Logical Affinity (Log-Bond)
# Measures how much the two contexts share a common logical structure.
# 1.0 means perfect affinity.
bl$similarity("log-bond")

# 2. Structural Complexity
# Ratio of irreducible bonds to total bonds.
# Lower values indicate more emergent structural properties.
bl$similarity("complexity")

# 3. Core Agreement
# Ratio of filled cells in the Core bond versus the Top (largest) bond.
bl$similarity("core-agreement")

# 4. Interaction Entropy
# Based on the log-size of the lattices.
bl$similarity("entropy")

## -----------------------------------------------------------------------------
# Dilworth's Width
bl$similarity("width")

# Order Dimension (estimated via heuristic)
bl$similarity("dimension")

## -----------------------------------------------------------------------------
bl$similarity("width-index")
bl$similarity("dimension-index")

