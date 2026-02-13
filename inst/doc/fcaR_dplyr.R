## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, message=FALSE, warning=FALSE--------------------------------------
library(fcaR)
library(dplyr)

data("planets")
# Create the initial Formal Context
fc <- FormalContext$new(planets)

## ----mutate_rename------------------------------------------------------------
# Let's clean up the context
fc_clean <- fc %>% 
  rename(
    has_moon = moon,
    no_moon  = no_moon,
    is_large = large,
    is_small = small
  ) %>%
  mutate(
    # Create a new binary attribute 'giant_loner'
    # (A planet that is large but has no moon)
    giant_loner = is_large == 1 & no_moon == 1,
    
    # Create 'extreme_size' (either small or large)
    extreme_size = is_small == 1 | is_large == 1
  )

# Check the new attributes
print(fc_clean$attributes)

## ----filter_select------------------------------------------------------------
# Focus only on 'extreme' sized planets and keep specific attributes
fc_focused <- fc_clean %>%
  filter(extreme_size == 1) %>% 
  select(has_moon, giant_loner, is_large)

fc_focused$print()

## ----mining-------------------------------------------------------------------
# We use the original context for more results
fc$find_implications()
rules <- fc$implications

cat("Total rules found:", rules$cardinality(), "\n")

## ----filter_metrics-----------------------------------------------------------
# Get strong rules (support > 0.2) that are not trivial (size > 2)
strong_rules <- rules %>% 
  filter(support > 0.2, size > 2) %>% 
  arrange(desc(support))

strong_rules$print()

## ----filter_semantic----------------------------------------------------------
# Find rules that imply 'moon'
moon_rules <- rules %>% 
  filter(rhs("moon"))

cat("Rules implying 'moon':\n")
moon_rules$print()

## ----complex_query------------------------------------------------------------
specific_rules <- rules %>% 
  filter(
    lhs("large"),     # Must be about large planets
    not_lhs("far"),    # Ignore far planets
    support >= 0.2    # Minimum support threshold
  ) %>% 
  arrange(desc(support)) %>% 
  slice(1:3)          # Take the top 3

specific_rules$print()

