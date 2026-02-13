## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
    collapse = TRUE,
    comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(fcaR)

## -----------------------------------------------------------------------------
# 100 Patients
# 50 Treated, 50 Untreated
# Treated: 90% Recovery
# Untreated: 20% Recovery

n <- 100
treated <- c(rep(1, 45), rep(1, 5), rep(0, 10), rep(0, 40))
recovered <- c(rep(1, 45), rep(0, 5), rep(1, 10), rep(0, 40))

I <- matrix(c(treated, recovered), ncol = 2)
colnames(I) <- c("Treatment", "Recovery")

fc <- FormalContext$new(I)

## -----------------------------------------------------------------------------
rules <- fc$find_causal_rules(
    response_var = "Recovery",
    min_support = 0.1,
    confidence_level = 0.95
)

rules$print()

## -----------------------------------------------------------------------------
set.seed(123)
n <- 200
# Heat: 50% Hot, 50% Cold
heat <- c(rep(1, 100), rep(0, 100))

# Ice Cream: Strongly dependent on Heat (80% if Hot, 20% if Cold)
ic <- numeric(200)
ic[1:100] <- rbinom(100, 1, 0.8)
ic[101:200] <- rbinom(100, 1, 0.2)

# Drowning: Strongly dependent on Heat (80% if Hot, 20% if Cold)
drown <- numeric(200)
drown[1:100] <- rbinom(100, 1, 0.8)
drown[101:200] <- rbinom(100, 1, 0.2)

I <- matrix(c(heat, ic, drown), ncol = 3)
colnames(I) <- c("Heat", "IceCream", "Drowning")

fc_spurious <- FormalContext$new(I)

## -----------------------------------------------------------------------------
causal_rules <- fc_spurious$find_causal_rules(
    response_var = "Drowning",
    min_support = 0.5
)

# Should contain "Heat" but NOT "IceCream"
print(causal_rules)

