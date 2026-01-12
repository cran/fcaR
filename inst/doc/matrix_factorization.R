## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(fcaR)

## ----data_creation------------------------------------------------------------
# Create a fuzzy matrix (6 breeds x 5 attributes)
I <- matrix(c(
  0.9, 0.9, 0.0, 0.0, 0.2, # Labrador
  0.8, 0.9, 0.1, 0.0, 0.1, # Golden Ret.
  0.2, 0.2, 0.9, 0.9, 0.8, # German Shepherd
  0.1, 0.1, 0.8, 0.9, 0.9, # Rottweiler
  0.9, 0.2, 0.2, 0.1, 0.2, # Beagle
  0.2, 0.1, 0.1, 0.1, 0.9  # Chihuahua
), nrow = 6, byrow = TRUE)

rownames(I) <- c("Labrador", "Golden Ret.", "G. Shepherd", "Rottweiler", "Beagle", "Chihuahua")
colnames(I) <- c("Friendly", "Playful", "Guard", "Aggressive", "Small")

fc <- FormalContext$new(I)
# Use Lukasiewicz logic for fuzzy operations
fc$use_logic("Lukasiewicz") 

## ----factorization------------------------------------------------------------
# Factorize using GreConD+
factors <- fc$factorize(method = "GreConD", w = 1.0)

# The result contains two new FormalContext objects
A <- factors$object_factor
B <- factors$factor_attribute

print("Matrix A (Object-Factor):")
print(A$incidence())

print("Matrix B (Factor-Attribute):")
print(B$incidence())

## ----verification-------------------------------------------------------------
# Reconstruct I' = A o B
rec_I <- A$incidence() %*% B$incidence() # Note: standard matrix product is just an approximation
# For exact fuzzy reconstruction we would loop using the T-norm, but let's check the error:

# (In a real scenario, we use the logic's operators)
mae <- mean(abs(I - A$incidence() %*% B$incidence())) # Simplified check
# For exact reconstruction, GreConD+ guarantees I <= A o B if w is high.

## ----asso_example-------------------------------------------------------------
# Create a binary dataset
I_bin <- matrix(c(
  1, 1, 1, 0, 0,
  1, 1, 1, 0, 0,
  0, 0, 0, 1, 1,
  0, 0, 0, 1, 1,
  1, 0, 0, 0, 1
), nrow = 5, byrow = TRUE)
rownames(I_bin) <- paste0("O", 1:5)
colnames(I_bin) <- paste0("A", 1:5)

fc_bin <- FormalContext$new(I_bin)

# Factorize using ASSO
# threshold: confidence threshold for candidate generation
res_asso <- fc_bin$factorize(method = "ASSO", threshold = 0.6)

print(res_asso$factor_attribute$incidence())

