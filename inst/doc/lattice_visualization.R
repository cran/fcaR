## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 7,
  warning = FALSE,
  message = FALSE
)

## ----setup--------------------------------------------------------------------
library(fcaR)

## ----data_setup---------------------------------------------------------------
# Load the context and find concepts
fc <- FormalContext$new(planets)
fc$find_concepts()

## ----basic_plot---------------------------------------------------------------
fc$concepts$plot()

## ----sugiyama-----------------------------------------------------------------
fc$concepts$plot(method = "sugiyama")

## ----force--------------------------------------------------------------------
fc$concepts$plot(method = "force")

## ----reduced------------------------------------------------------------------
fc$concepts$plot(mode = "reduced")

## ----full---------------------------------------------------------------------
fc$concepts$plot(mode = "full")

## ----empty--------------------------------------------------------------------
fc$concepts$plot(mode = "empty")

## ----tikz_console-------------------------------------------------------------
# Generate TikZ code
tikz_code <- fc$concepts$plot(to_latex = TRUE)

# The object prints cleanly to the console
tikz_code

## ----save_file, eval=FALSE----------------------------------------------------
# # Save to a local file
# fc$concepts$plot(to_latex = TRUE) |>
#   save_tikz("lattice_diagram.tex")

