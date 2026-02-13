## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
    collapse = TRUE,
    comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(fcaR)
# install.packages("jsonlite")

## ----context------------------------------------------------------------------
data("planets")
fc <- FormalContext$new(planets)
print(fc)

## ----export_context-----------------------------------------------------------
json_str <- fc$to_json()
cat(substr(json_str, 1, 200), "...") # Print first 200 chars

## ----export_file, eval=FALSE--------------------------------------------------
# fc$to_json(file = "context.json")

## ----import_context-----------------------------------------------------------
fc2 <- context_from_json(json_str)
print(fc2)

## ----verify_context-----------------------------------------------------------
all(fc$objects == fc2$objects)
all(fc$attributes == fc2$attributes)
all(as.matrix(fc$I) == as.matrix(fc2$I))

## ----recursive----------------------------------------------------------------
fc$find_concepts()
fc$find_implications()

# Export with nested concepts and implications
json_full <- fc$to_json()

# Import back
fc_full <- context_from_json(json_full)

# Check if concepts are present
fc_full$concepts$size()

## ----lattice------------------------------------------------------------------
cl <- fc$concepts
json_lattice <- cl$to_json()

## ----import_lattice-----------------------------------------------------------
cl2 <- lattice_from_json(json_lattice)
print(cl2)

## ----implications-------------------------------------------------------------
imps <- fc$implications
json_imps <- imps$to_json()

## ----import_imps--------------------------------------------------------------
imps2 <- implications_from_json(json_imps)
print(imps2)

## ----rules--------------------------------------------------------------------
# Assuming we have a RuleSet, e.g. from arules or created manually
# Here we'll just demonstrate the syntax
rs <- RuleSet$new(attributes = fc$attributes)
# ... populate rules ...
# json_rules <- rs$to_json()
# rs2 <- rules_from_json(json_rules)

