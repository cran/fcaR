## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 5,
  warning = FALSE
)

## ----setup--------------------------------------------------------------------
library(fcaR)

## -----------------------------------------------------------------------------
fc <- FormalContext$new(planets)
fc$find_implications()

## -----------------------------------------------------------------------------
equivalencesRegistry$get_entry_names()

## -----------------------------------------------------------------------------
equivalencesRegistry$get_entry("Composition")

## -----------------------------------------------------------------------------
equivalencesRegistry$get_entry("comp")

## ----eval = FALSE-------------------------------------------------------------
#  fc$implications$apply_rules(c("comp", "simp"))

## ----eval = FALSE-------------------------------------------------------------
#  equivalencesRegistry$set_entry(method = "Method name",
#                                 fun = method_function,
#                                 description = "Method description")

## ----eval = FALSE-------------------------------------------------------------
#  method_function <- function(LHS, RHS, attributes) {
#  
#    # LHS and RHS are the sparse matrices of the left-hand and
#    # right-hand sides of the implications
#    # attributes is the vector of attribute names
#    # The three arguments are mandatory
#  
#    # Perform operations on LHS and RHS
#    # ...
#  
#    # Must return a list with two components: lhs and rhs
#    return(list(lhs = LHS,
#                rhs = RHS))
#  
#  }

## -----------------------------------------------------------------------------
random_reorder <- function(LHS, RHS, attributes) {
  
  # Remember: attributes are in rows, implications are
  # in columns.
  # Random order for columns:
  o <- sample(ncol(LHS), ncol(LHS))
  
  # Return the reordered implications
  return(list(lhs = LHS[, o],
              rhs = RHS[, o]))
  
}

## -----------------------------------------------------------------------------
equivalencesRegistry$set_entry(method = "Randomize",
                               fun = random_reorder,
                               description = "Randomize the order of the implications.")

## -----------------------------------------------------------------------------
equivalencesRegistry$get_entry_names()

## -----------------------------------------------------------------------------
# Original implications
fc$implications

## -----------------------------------------------------------------------------
# Apply the randomize method
fc$implications$apply_rules("randomize")

## -----------------------------------------------------------------------------
# Reordered implications
fc$implications

