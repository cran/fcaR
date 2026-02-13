## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, echo = FALSE------------------------------------------------------
library(fcaR)

## ----echo = FALSE-------------------------------------------------------------
# Nominal
A_nom <- matrix(c("yes", "yes", "no", "yes", "no"), ncol = 1)
colnames(A_nom) <- "Grant"
rownames(A_nom) <- paste0("Student ", seq_len(nrow(A_nom)))

# Ordinal
A_ord <- matrix(c(7, 10, 5, 8, 4), ncol = 1)
colnames(A_ord) <- "Intern"
rownames(A_ord) <- paste0("Student ", seq_len(nrow(A_ord)))

# Interordinal
A_int <- matrix(c("agree", "strongly agree", "neither agree nor disagree", "agree", "disagree"), ncol = 1)
colnames(A_int) <- "Agreement"
rownames(A_int) <- paste0("Student ", seq_len(nrow(A_int)))

# Biordinal
A_bi <- matrix(c("working", "hard working", "working", "working", "lazy"), ncol = 1)
colnames(A_bi) <- "Attitude"
rownames(A_bi) <- paste0("Student ", seq_len(nrow(A_bi)))

# Interval
A_interv <- matrix(c(2.7, 4.1, 3.6, 4, 3.6), ncol = 1)
colnames(A_interv) <- "Score"
rownames(A_interv) <- paste0("Student ", seq_len(nrow(A_interv)))

# Aposition
A <- data.frame(A_nom, A_ord, A_int, A_bi, A_interv)
fc <- FormalContext$new(A)

## ----echo = FALSE-------------------------------------------------------------
fc$incidence() |>  
  knitr::kable(
    format = "html",
    align = "rcccc"
  )

## ----echo = FALSE-------------------------------------------------------------
fc_nom <- FormalContext$new(A_nom)
fc_nom$incidence() |> 
  knitr::kable(
    format = "html",
    align = "r"
  )

## ----echo = FALSE-------------------------------------------------------------
fc_nom$scale("Grant", type = "nominal")
fc_nom$incidence() |> 
  knitr::kable(
    format = "html",
    align = "cc"
  )

## ----echo = FALSE-------------------------------------------------------------
fc_nom$get_scales("Grant")$incidence() |> 
  knitr::kable(
    format = "html",
    align = "cc"
  )

## ----echo = FALSE-------------------------------------------------------------
fc_nom <- FormalContext$new(A_ord)
fc_nom$incidence() |> 
  knitr::kable(
    format = "html",
    align = "c"
  )

## ----echo = FALSE-------------------------------------------------------------
fc_nom$scale("Intern", type = "ordinal")
fc_nom$incidence() |> 
  knitr::kable(
    format = "html",
    align = "cc"
  )

## ----echo = FALSE-------------------------------------------------------------
fc_nom$get_scales("Intern")$incidence() |> 
  knitr::kable(
    format = "html",
    align = "cc"
  )

## ----echo = FALSE-------------------------------------------------------------
fc_nom <- FormalContext$new(A_int)
fc_nom$incidence() |> 
  knitr::kable(
    format = "html",
    align = "c"
  )

## ----echo = FALSE-------------------------------------------------------------
fc_nom$scale("Agreement",
  type = "interordinal",
  values = c(
    "strongly disagree",
    "disagree",
    "neither agree nor disagree",
    "agree",
    "strongly agree"
  )
)
fc_nom$incidence() |> 
  knitr::kable(
    format = "html",
    align = "cc"
  )

## ----echo = FALSE-------------------------------------------------------------
fc_nom$get_scales("Agreement")$incidence() |> 
  knitr::kable(
    format = "html",
    align = "cc"
  )

## ----echo = FALSE-------------------------------------------------------------
fc_nom <- FormalContext$new(A_bi)
fc_nom$incidence() |> 
  knitr::kable(
    format = "html",
    align = "c"
  )

## ----echo = FALSE-------------------------------------------------------------
fc_nom$scale("Attitude",
  type = "biordinal",
  values_le = c("hard working", "working"),
  values_ge = c("lazy", "very lazy")
)
fc_nom$incidence() |> 
  knitr::kable(
    format = "html",
    align = "cc"
  )

## ----echo = FALSE-------------------------------------------------------------
fc_nom$get_scales("Attitude")$incidence() |> 
  knitr::kable(
    format = "html",
    align = "cc"
  )

## ----echo = FALSE-------------------------------------------------------------
fc_nom <- FormalContext$new(A_interv)
fc_nom$incidence() |> 
  knitr::kable(
    format = "html",
    align = "c"
  )

## ----echo = FALSE-------------------------------------------------------------
fc_nom$scale("Score",
  type = "interval",
  values = c(2, 3, 4, 5), interval_names = c("C", "B", "A")
)
fc_nom$incidence() |> 
  knitr::kable(
    format = "html",
    align = "cc"
  )

## ----echo = FALSE-------------------------------------------------------------
fc_nom$get_scales("Score")$incidence() |> 
  knitr::kable(
    format = "html",
    align = "cc"
  )

## -----------------------------------------------------------------------------
scalingRegistry$get_entry_names()

## -----------------------------------------------------------------------------
fc$scale("Grant", type = "nominal")
fc

## -----------------------------------------------------------------------------
fc$scale("Intern", type = "ordinal")
fc

## -----------------------------------------------------------------------------
fc$scale("Agreement",
  type = "interordinal",
  values = c(
    "strongly disagree",
    "disagree",
    "neither agree nor disagree",
    "agree",
    "strongly agree"
  )
)

## -----------------------------------------------------------------------------
fc$scale("Attitude",
  type = "biordinal",
  values_le = c("hard working", "working"),
  values_ge = c("lazy", "very lazy")
)

## -----------------------------------------------------------------------------
fc$scale("Score",
  type = "interval",
  values = c(2, 3, 4, 5),
  interval_names = c("C", "B", "A")
)

## -----------------------------------------------------------------------------
fc$get_scales(c("Grant", "Score"))

## -----------------------------------------------------------------------------
fc$background_knowledge()

## ----imps, warning=FALSE------------------------------------------------------
fc$find_implications()
fc$implications

## ----echo = FALSE-------------------------------------------------------------
filename <- system.file("contexts",
  "aromatic.csv",
  package = "fcaR"
)

fc_orig <- FormalContext$new(filename)

## -----------------------------------------------------------------------------
filename <- system.file("contexts",
  "aromatic.csv",
  package = "fcaR"
)

fc <- FormalContext$new(filename)

## -----------------------------------------------------------------------------
fc$incidence() |>
  knitr::kable(
    format = "html",
    align = "c"
  )

## -----------------------------------------------------------------------------
fc$scale(
  attributes = "nitro",
  type = "ordinal",
  comparison = `>=`,
  values = 1:3
)
fc$scale(
  attributes = "OS",
  type = "nominal",
  c("O", "S")
)
fc$scale(
  attributes = "ring",
  type = "nominal"
)

## ----echo = FALSE-------------------------------------------------------------
fc$incidence() |>
  knitr::kable(
    format = "html",
    align = "c"
  )

## -----------------------------------------------------------------------------
fc$background_knowledge()

## ----warning=FALSE------------------------------------------------------------
fc$find_implications()
fc$implications

## -----------------------------------------------------------------------------
fc$concepts

