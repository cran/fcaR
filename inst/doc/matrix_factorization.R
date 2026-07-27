## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(fcaR)

## ----data_creation------------------------------------------------------------
# Create a binary matrix (5 breeds x 5 attributes)
I <- matrix(c(
  1, 1, 0, 0, 0, # Labrador: Friendly, Playful
  1, 1, 0, 0, 0, # Golden Retriever: Friendly, Playful
  0, 0, 1, 1, 0, # German Shepherd: Guard, Aggressive
  0, 0, 1, 1, 0, # Rottweiler: Guard, Aggressive
  1, 0, 0, 0, 1  # Chihuahua: Friendly, Small
), nrow = 5, byrow = TRUE)

rownames(I) <- c("Labrador", "Golden Ret.", "G. Shepherd", "Rottweiler", "Chihuahua")
colnames(I) <- c("Friendly", "Playful", "Guard", "Aggressive", "Small")

# Initialize the FormalContext
fc <- FormalContext$new(I)
print(fc)

## ----factorization------------------------------------------------------------
# Factorize using GreConD
factors <- fc$factorize(method = "GreConD")

# The result contains two new FormalContext objects
A <- factors$object_factor
B <- factors$factor_attribute

## ----print_A------------------------------------------------------------------
print(A$incidence())

## ----print_B------------------------------------------------------------------
print(B$incidence())

## ----rsf_example--------------------------------------------------------------
# Factorize using RSF
res_rsf <- fc$factorize(method = "RSF")
print(res_rsf$factor_attribute$incidence())

# Factorize using RSF-ES (Highly optimized)
res_rsfes <- fc$factorize(method = "RSF-ES")
print(res_rsfes$factor_attribute$incidence())

## ----asso_example-------------------------------------------------------------
# Factorize using ASSO
res_asso <- fc$factorize(method = "ASSO", threshold = 0.6)

# Print the resulting factor-attribute matrix
print(res_asso$factor_attribute$incidence())

