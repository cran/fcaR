## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(fcaR)

## -----------------------------------------------------------------------------
fc <- FormalContext$new(planets)
fc$find_concepts()

stab <- fc$concepts$stability()
head(stab)

## -----------------------------------------------------------------------------
sep <- fc$concepts$separation()
head(sep)

## -----------------------------------------------------------------------------
# For binary data, density is always 1 (or 0 for empty concepts)
# We need to pass the original matrix I
dens <- fc$concepts$density(I = fc$incidence())
head(dens)

## -----------------------------------------------------------------------------
df <- data.frame(
  Concept = 1:fc$concepts$size(),
  Support = fc$concepts$support(),
  Stability = stab,
  Separation = sep,
  Density = dens
)

# Concepts with high stability and separation
subset(df, Stability > 0.8 & Separation > 0)

