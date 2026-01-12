## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(fcaR)

## ----properties_planets-------------------------------------------------------
fc <- FormalContext$new(planets)
fc$find_concepts()

# Check properties
print(paste("Is Distributive?", fc$concepts$is_distributive()))
print(paste("Is Modular?",      fc$concepts$is_modular()))
print(paste("Is Semimodular?",  fc$concepts$is_semimodular()))
print(paste("Is Atomic?",       fc$concepts$is_atomic()))

## ----m3_example---------------------------------------------------------------
# Context for M3 (The Diamond)
# 3 objects, 3 attributes. Objects have 2 attributes each.
I_m3 <- matrix(c(
  0, 1, 1,
  1, 0, 1,
  1, 1, 0
), nrow = 3, byrow = TRUE)

fc_m3 <- FormalContext$new(I_m3)
fc_m3$find_concepts()

# M3 is Modular but NOT Distributive
print(paste("M3 Distributive:", fc_m3$concepts$is_distributive()))
print(paste("M3 Modular:",      fc_m3$concepts$is_modular()))

