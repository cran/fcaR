#' @title
#' R6 class for a formal context
#'
#' @description
#' This class implements the data structure and methods for formal contexts.
#'
#' @section Public fields:
#' * `I`: the table for the formal context.
#' * `attributes`: name of the attributes in the formal context.
#' * `objects`: name of the objects in the context.
#' * `grades_set`: set of grades (in \[0, 1\]) of the attributes.
#' * `concepts`: list of concepts (extent, intent).
#' * `implications`: extracted implications as an \code{ImplicationSet}.
#'
#' @examples
#' # Build and print the formal context
#' fc_planets <- FormalContext$new(planets)
#' print(fc_planets)
#'
#' # Define a set of attributes
#' S <- SparseSet$new(attributes = fc_planets$attributes)
#' S$assign(moon = 1, large = 1)
#'
#' # Compute the closure of S
#' Sc <- fc_planets$closure(S)
#' # Is Sc a closed set?
#' fc_planets$is_closed(Sc)
#'
#' # Clarify and reduce the formal context
#' fc2 <- fc_planets$reduce(TRUE)
#'
#' # Find implications
#' fc_planets$find_implications()
#'
#' @references
#'
#' Guigues J, Duquenne V (1986). “Familles minimales d'implications informatives résultant d'un tableau de données binaires.” _Mathématiques et Sciences humaines_, *95*, 5-18.
#'
#' Ganter B, Wille R (1999). _Formal concept analysis : mathematical foundations_. Springer. ISBN 3540627715.
#'
#' Belohlavek R (2002). “Algorithms for fuzzy concept lattices.” In _Proc. Fourth Int. Conf. on Recent Advances in Soft Computing_. Nottingham, United Kingdom, 200-205.
#'
#' Hahsler M, Grun B, Hornik K (2005). “arules - a computational environment for mining association rules and frequent item sets.” _J Stat Softw_, *14*, 1-25.
#'
#' @export
FormalContext <- R6::R6Class(

  classname = "FormalContext",

  public = list(

    I = NULL,

    attributes = NULL,

    objects = NULL,

    grades_set = NULL,

    expanded_grades_set = NULL,

    concepts = NULL,

    implications = NULL,

    #' @description
    #' Creator for the Formal Context class
    #'
    #' @param I           (numeric matrix) The table of the formal context.
    #' @param remove_const (logical) If \code{TRUE}, remove constant columns. The default is \code{FALSE}.
    #'
    #' @details
    #' Columns of \code{I} should be named, since they are the names of the attributes of the formal context.
    #'
    #' If no \code{I} is used, the resulting \code{FormalContext} will be empty and not usable unless for loading a previously saved one.
    #'
    #' @return An object of the \code{FormalContext} class.
    #' @export
    #'
    initialize = function(I,
                          remove_const = FALSE) {

      if (missing(I)) {

        return(invisible(self))

      }

      if (!capabilities()["long.double"]) {

        private$can_plot <- FALSE

      }

      # Transform the formal context to sparse
      if (inherits(I, "transactions")) {

        # If it comes from the arules package
        attributes <- I@itemInfo$labels
        I <- methods::as(I@data, "dgCMatrix")
        objects <- paste0(seq(ncol(I)))
        dimnames(I) <- list(attributes, objects)

      } else {

        # Or if it comes from a numeric table
        if (length(colnames(I)) > 0) {

          attributes <- colnames(I)

        } else {

          attributes <- paste0("A", seq(ncol(I)))

        }

        if (length(rownames(I)) > 0) {

          objects <- rownames(I)

        } else {

          objects <- paste0("A", seq(nrow(I)))

        }

        # Remove the constant columns
        if (remove_const) {

          constant_cols <- which(apply(I, 2, max) == apply(I, 2, min))

          if (length(constant_cols) > 0) {

            str <- paste0("Removed constant columns: ", stringr::str_flatten(attributes[constant_cols], collapse = ", "))

            message(stringr::str_wrap(str,
                                      exdent = 2,
                                      width = 75))

            I <- I[, -constant_cols]
            attributes <- attributes[-constant_cols]

          }

        }

        I <- methods::as(Matrix::Matrix(t(I),
                                        sparse = TRUE), "dgCMatrix")

      }

      # Assign everything to its corresponding field
      expanded_grades_set <- compute_grades(Matrix::t(I))
      grades_set <- sort(unique(unlist(expanded_grades_set)))

      self$I <- I
      self$grades_set <- unique(c(0, grades_set, 1))
      self$expanded_grades_set <- expanded_grades_set
      self$objects <- objects
      self$attributes <- attributes

      colnames(self$I) <- self$objects
      rownames(self$I) <- self$attributes

      # Is the FormalContext binary?
      private$is_binary <- length(self$grades_set) == 2

      # Create a new empty implication set inside
      self$implications <- ImplicationSet$new(attributes = attributes, I = self$I)

      # Create a new empty ConceptLattice inside
      self$concepts <- ConceptLattice$new(extents = NULL,
                                          intents = NULL,
                                          objects = self$objects,
                                          attributes = self$attributes,
                                          I = self$I)

    },

    #' @description
    #' Check if the \code{FormalContext} is empty
    #'
    #' @return \code{TRUE} if the \code{FormalContext} is empty, that is, has not been provided with a matrix, and \code{FALSE} otherwise.
    #'
    #' @export
    is_empty = function() {

      return(is.null(self$I))

    },

    #' @description
    #' Get the intent of a fuzzy set of objects
    #'
    #' @param S   (\code{SparseSet}) The set of objects to compute the intent for.
    #'
    #' @return A \code{SparseSet} with the intent.
    #'
    #' @export
    intent = function(S) {

      if (inherits(S, "SparseSet")) {

        if (all(S$get_attributes() == self$objects)) {

          S <- S$get_vector()

        } else {

          stop("It is not a set of the required type (set of objects).", call. = FALSE)

        }

      }

      if (length(S) == length(self$objects)) {

        R <- compute_intent(S,
                            Matrix::as.matrix(Matrix::t(self$I)))

        if (length(R@i) > 0) {

          # Non-empty set:
          R <- Matrix::sparseMatrix(i = R@i + 1,
                                    j = rep(1, length(R@i)),
                                    x = R@x,
                                    dims = c(length(self$attributes), 1))

          R <- SparseSet$new(attributes = self$attributes,
                             M = R)
        } else {

          # Empty intent
          R <- SparseSet$new(attributes = self$attributes)

        }

        return(R)

      } else {

        stop("It is not a set of the required type (set of objects).", call. = FALSE)

      }

    },

    #' @description
    #' Get the extent of a fuzzy set of attributes
    #'
    #' @param S   (\code{SparseSet}) The set of attributes to compute the extent for.
    #'
    #' @return A \code{SparseSet} with the intent.
    #'
    #' @export
    extent = function(S) {

      if (inherits(S, "SparseSet")) {

        if (all(S$get_attributes() == self$attributes)) {

          S <- S$get_vector()

        } else {

          stop("It is not a set of the required type (set of attributes).", call. = FALSE)

        }

      }

      if (length(S) == length(self$attributes)) {

        R <- compute_extent(S,
                            Matrix::as.matrix(Matrix::t(self$I)))

        if (length(R@i) > 0) {

          # Non-empty set:
          R <- Matrix::sparseMatrix(i = R@i + 1,
                                    j = rep(1, length(R@i)),
                                    x = R@x,
                                    dims = c(length(self$objects), 1))

          R <- SparseSet$new(attributes = self$objects,
                             M = R)
        } else {

          # Empty extent
          R <- SparseSet$new(attributes = self$objects)

        }

        return(R)

      } else {

        stop("It is not a set of the required type (set of objects).", call. = FALSE)

      }

    },

    #' @description
    #' Get the closure of a fuzzy set of attributes
    #'
    #' @param S   (\code{SparseSet}) The set of attributes to compute the closure for.
    #'
    #' @return A \code{SparseSet} with the closure.
    #'
    #' @export
    closure = function(S) {

      if (inherits(S, "SparseSet")) {

        if (all(S$get_attributes() == self$attributes)) {

          S <- S$get_vector()

        } else {

          stop("It is not a set of the required type (set of attributes).", call. = FALSE)

        }

      }

      if (length(S) == length(self$attributes)) {

        R <- compute_closure(S,
                             Matrix::as.matrix(Matrix::t(self$I)))

        if (length(R@i) > 0) {

          # Non-empty set:
          R <- Matrix::sparseMatrix(i = R@i + 1,
                                    j = rep(1, length(R@i)),
                                    x = R@x,
                                    dims = c(length(self$attributes), 1))

          R <- SparseSet$new(attributes = self$attributes,
                             M = R)
        } else {

          # Empty closure
          R <- SparseSet$new(attributes = self$attributes)

        }

        return(R)

      } else {

        stop("It is not a set of the required type (set of objects).", call. = FALSE)

      }

    },

    #' @description
    #' Object Concept
    #'
    #' @param object (character) Name of the object to compute its associated concept
    #'
    #' @return
    #' The object concept associated to the object given.
    #'
    #' @export
    obj_concept = function(object) {

      S <- SparseSet$new(attributes = self$objects)
      S$assign(attributes = object, values = 1)

      B <- self$intent(S)
      A <- self$extent(B)

      C <- SparseConcept$new(extent = A, intent = B)

      return(C)

    },

    #' @description
    #' Attribute Concept
    #'
    #' @param attribute (character) Name of the attribute to compute its associated concept
    #'
    #' @return
    #' The attribute concept associated to the attribute given.
    #'
    #' @export
    att_concept = function(attribute) {

      S <- SparseSet$new(attributes = self$attributes)
      S$assign(attributes = attribute, values = 1)

      A <- self$extent(S)
      B <- self$intent(A)

      C <- SparseConcept$new(extent = A, intent = B)

      return(C)

    },

    #' @description
    #' Is a Concept?
    #'
    #' @param C A \code{SparseConcept} object
    #'
    #' @return
    #' \code{TRUE} if \code{C} is a concept.
    #'
    #' @export
    is_concept = function(C) {

      O <- C$get_extent()
      A <- C$get_intent()

      # O should be the extent of A, and A should be intent of O
      return((self$extent(A) %==% O) && (self$intent(O) %==% A))

    },

    #' @description
    #' Testing closure of attribute sets
    #'
    #' @param S A \code{SparseSet} of attributes
    #'
    #' @return
    #' \code{TRUE} if the set \code{S} is closed in this formal context.
    #' @export
    is_closed = function(S) {

      Sc <- self$closure(S)
      return(S %==% Sc)

    },

    #' @description
    #' Clarify a formal context
    #'
    #' @param copy   (logical) If \code{TRUE}, a new \code{FormalContext} object is created with the clarified context, otherwise the current one is overwritten.
    #'
    #' @return The clarified \code{FormalContext}.
    #'
    #' @export
    clarify = function(copy = FALSE) {

      # Redundant attributes
      my_I <- .clarify_matrix(Matrix::t(self$I),
                              rows = self$objects,
                              cols = self$attributes)

      # And redundant objects
      my_I <- .clarify_matrix(Matrix::t(my_I),
                              rows = colnames(my_I),
                              cols = self$objects)
      my_I <- Matrix::as.matrix(Matrix::t(my_I))

      if (copy) {

        fc2 <- FormalContext$new(my_I)

        return(fc2)

      } else {

        self$initialize(my_I)

        return(invisible(self))

      }

    },

    #' @description
    #' Reduce a formal context
    #'
    #' @param copy   (logical) If \code{TRUE}, a new \code{FormalContext} object is created with the clarified and reduced context, otherwise the current one is overwritten.
    #'
    #' @return The clarified and reduced \code{FormalContext}.
    #'
    #' @export
    reduce = function(copy = FALSE) {

      if (!private$is_binary) {

        stop("This FormalContext is not binary. Reduction is not implemented for fuzzy contexts.", call. = FALSE)

      }

      # Make a copy with the clarified context
      fc2 <- self$clarify(TRUE)

      my_I <- Matrix::as.matrix(Matrix::t(fc2$I))

      att <- fc2$attributes

      Z <- SparseSet$new(attributes = att)

      for (y in att) {

        R <- SparseSet$new(attributes = fc2$objects)
        R$assign(attributes = fc2$objects,
                 values = rep(1, length(fc2$objects)))

        R <- R$get_vector()

        yv <- SparseSet$new(attributes = att)
        yv$assign(attributes = y, values = 1)
        y_down <- fc2$extent(yv)

        for (yp in setdiff(att, y)) {

          ypv <- SparseSet$new(attributes = att)
          ypv$assign(attributes = yp, values = 1)
          yp_down <- fc2$extent(ypv)

          S <- .subset(y_down$get_vector(),
                       yp_down$get_vector())

          if (S[1]) {

            R[Matrix::which(yp_down$get_vector() < R)] <- yp_down$get_vector()[Matrix::which(yp_down$get_vector() < R)]

          }

        }

        if (!.equal_sets(R, y_down$get_vector())[1]) {

          Z$assign(attributes = y, values = 1)

        }

      }

      new_att <- Z$get_attributes()[Matrix::which(Z$get_vector() > 0)]

      idx <- match(new_att, att)
      my_I <- my_I[, idx]
      colnames(my_I) <- new_att
      rownames(my_I) <- fc2$objects

      if (copy) {

        fc3 <- FormalContext$new(my_I)

        return(fc3)

      } else {

        self$initialize(my_I)

        return(invisible(self))

      }

    },

    #' @description
    #' Build the Standard Context
    #'
    #' @details
    #' All concepts must be previously computed.
    #'
    #' @return
    #' The standard context using the join- and meet- irreducible elements.
    #' @export
    standardize = function() {

      if (self$concepts$is_empty()) {

        stop("Concepts must be computed beforehand.\n", call. = FALSE)

      }

      join_irr <- self$concepts$join_irreducibles()
      meet_irr <- self$concepts$meet_irreducibles()

      nj <- length(join_irr)
      nm <- length(meet_irr)

      I <- matrix(0, nrow = nj, ncol = nm)

      for (i in seq(nj)) {

        for (j in seq(nm)) {

          I[i, j] <- ifelse(join_irr[[i]] %<=% meet_irr[[j]], 1, 0)

        }

      }

      colnames(I) <- paste0("M", seq(nm))
      rownames(I) <- paste0("J", seq(nj))

      return(FormalContext$new(I))

    },

    #' @description
    #' Use Ganter Algorithm to compute concepts
    #'
    #' @param verbose   (logical) TRUE will provide a verbose output.
    #'
    #' @return A list with all the concepts in the formal context.
    #'
    #' @export
    find_concepts = function(verbose = FALSE) {

      private$check_empty()

      my_I <- Matrix::as.matrix(Matrix::t(self$I))
      grades_set <- rep(list(self$grades_set), length(self$attributes))
      # grades_set <- self$expanded_grades_set
      attrs <- self$attributes

      L <- next_closure_concepts(I = my_I,
                                 grades_set = grades_set,
                                 attrs = attrs,
                                 verbose = verbose)

      # Since the previous function gives the list of intents of
      # the computed concepts, now we will compute the corresponding
      # extents.

      if (length(self$attributes) == 1) {


        my_intents <- Matrix::Matrix(t(as.vector(L$intents)), sparse = TRUE)

        my_extents <- Matrix::Matrix(t(as.vector(L$extents)), sparse = TRUE)

      } else {

        my_intents <- L$intents

        my_extents <- L$extents

      }


      self$concepts <- ConceptLattice$new(extents = my_extents,
                                          intents = my_intents,
                                          objects = self$objects,
                                          attributes = self$attributes,
                                          I = self$I)

      if (verbose) {

        cat("Number of closures", L$closure_count, "\n")

      }

      # return(invisible(self$concepts))
      return(invisible(self))

    },

    #' @description
    #' Use modified Ganter algorithm to compute both concepts and implications
    #'
    #' @param save_concepts (logical) \code{TRUE} will also compute and save the concept lattice. \code{FALSE} is usually faster, since it only computes implications.
    #' @param verbose   (logical) \code{TRUE} will provide a verbose output.
    #'
    #' @return Nothing, just updates the internal fields \code{concepts} and \code{implications}.
    #'
    #'
    #' @export
    find_implications = function(save_concepts = TRUE,
                                 verbose = FALSE) {

      private$check_empty()

      my_I <- Matrix::as.matrix(Matrix::t(self$I))
      grades_set <- rep(list(self$grades_set), length(self$attributes))
      # grades_set <- self$expanded_grades_set
      attrs <- self$attributes

      L <- next_closure_implications(I = my_I,
                                     grades_set = grades_set,
                                     attrs = attrs,
                                     save_concepts = save_concepts,
                                     verbose = verbose)

      # Since the previous function gives the list of intents of
      # the computed concepts, now we will compute the corresponding
      # extents.
      if (save_concepts) {

        my_intents <- L$concepts
        my_extents <- L$extents

      }

      if (save_concepts) {

        self$concepts <- ConceptLattice$new(extents = my_extents,
                                            intents = my_intents,
                                            objects = self$objects,
                                            attributes = self$attributes,
                                            I = self$I)

      }

      # Now, add the computed implications
      if (ncol(L$LHS) > 1) {

        # There are implications (the first one is dummy
        # emptyset -> emptyset )
        my_LHS <- L$LHS
        my_RHS <- L$RHS

        extracted_implications <- ImplicationSet$new(attributes = self$attributes,
                                                     lhs = my_LHS,
                                                     rhs = my_RHS,
                                                     I = self$I)

      } else {

        extracted_implications <- ImplicationSet$new(attributes = self$attributes,
                                                     I = self$I)

      }

      self$implications <- extracted_implications

    },

    #' @description
    #' Convert the formal context to object of class \code{transactions} from the \code{arules} package
    #'
    #' @return A \code{transactions} object.
    #'
    #' @export
    to_transactions = function() {

      private$check_empty()

      return(methods::as(methods::as(self$I, "ngCMatrix"), "transactions"))

    },

    #' @description
    #' Save a \code{FormalContext} to RDS format
    #'
    #' @param filename   (character) Path of the RDS file where to store the \code{FormalContext}.
    #'
    #' @return Invisibly the current \code{FormalContext}.
    #'
    #' @export
    save = function(filename = tempfile(fileext = ".rds")) {

      private$check_empty()

      if (!self$concepts$is_empty()) {

        extents <- self$concepts$extents()
        intents <- self$concepts$intents()

      } else {

        extents <- NULL
        intents <- NULL

      }

      L <- list(I = self$I,
                extents = extents,
                intents = intents,
                attributes = self$attributes,
                objects = self$objects,
                expanded_grades_set = self$expanded_grades_set,
                grades_set = self$grades_set,
                implications = self$implications)

      saveRDS(L, file = filename)

      return(invisible(self))

    },

    #' @description
    #' Load a \code{FormalContext} from a RDS file
    #'
    #' @param filename   (character) Path of the RDS file to load the \code{FormalContext} from.
    #'
    #' @return The loaded \code{FormalContext}.
    #'
    #' @export
    load = function(filename) {

      L <- readRDS(filename)

      self$I <- L$I
      self$attributes <- L$attributes
      self$objects <- L$objects
      self$expanded_grades_set <- L$expanded_grades_set
      self$grades_set <- L$grades_set
      self$implications <- L$implications

      if (!is.null(L$extents)) {

        self$concepts <- ConceptLattice$new(extents = L$extents,
                                            intents = L$intents,
                                            objects = L$objects,
                                            attributes = L$attributes,
                                            I = L$I)

      }

      return(invisible(self))

    },

    #' @description
    #' Dimensions of the formal context
    #'
    #' @return A vector with (number of objects, number of attributes).
    #'
    #' @export
    dim = function() {

      return(c(length(self$objects), length(self$attributes)))

    },

    #' @description
    #' Prints the formal context
    #'
    #' @return Prints information regarding the formal context.
    #' @export
    print = function() {

      if (self$is_empty()) {

        cat("Empty FormalContext.\n")

        return(invisible(self))

      }

      dims <- self$dim()

      I <- Matrix::as.matrix(Matrix::t(self$I))

      if (private$is_binary) {

        I <- .print_binary(I, latex = FALSE)

      }

      objects <- self$objects
      if (nrow(I) > 10) {

        I <- I[1:10, ]
        objects <- objects[1:10]

      }


      matp <- .print_matrix(I,
                            objects = objects,
                            attributes = self$attributes)
      M <- matp$mat
      ids <- matp$att_id
      last_attribute <- max(ids) - 1

      str <- paste0("FormalContext with ", dims[1],
                    " objects and ",
                    dims[2], " attributes.") %>%
        stringr::str_wrap(width = getOption("width"))

      cat(str)
      cat("\n")

      cat(M)
      cat("\n")

      if (last_attribute < length(self$attributes)) {

        remaining <- self$attributes[-seq(last_attribute)]

        if (length(remaining) > 6) {

          remaining <- c(remaining[1:6], "...")

        }

        remaining <- remaining %>%
          stringr::str_flatten(", ")

        str <- paste0("Other attributes are: ", remaining) %>%
          stringr::str_wrap(width = getOption("width"))

        cat(str, "\n")

      }

    },


    #' @description
    #' Write the context in LaTeX format
    #'
    #' @param label (character) The label for the table environment.
    #' @param caption (character) The caption of the table.
    #' @param fraction (character) If \code{none}, no fractions are produced. Otherwise, if it is \code{frac}, \code{dfrac} or \code{sfrac}, decimal numbers are represented as fractions with the corresponding LaTeX typesetting.
    #'
    #' @return
    #' A table environment in LaTeX.
    #'
    #' @export
    #'
    to_latex = function(label = "", caption = "", fraction = c("none", "frac", "dfrac", "sfrac")) {

      fraction <- match.arg(fraction)

      I <- Matrix::as.matrix(Matrix::t(self$I))

      if (private$is_binary) {

        I <- .print_binary(I, latex = TRUE)


      } else {

        if (fraction != "none") {

          I <- .to_fraction(I,
                            latex = TRUE,
                            type = fraction)

        }

      }

      str <- context_to_latex(I,
                              objects = self$objects,
                              attributes = self$attributes)

      str <- c("\\begin{table}",
               "\\centering",
               str)

      my_caption <- paste0("\\caption{\\label{",
                           label, "}",
                           caption, "}")

      str <- c(str, my_caption, "\\end{table}")

      cat(str)

      return(invisible(str))

    },

    #' @description
    #' Plot the formal context table
    #'
    #' @param to_latex      (logical) If \code{TRUE}, export the plot as a \code{tikzpicture} environment that can be included in a \code{LaTeX} file.
    #' @param ...          Other parameters to be passed to the \code{tikzDevice} that renders the lattice in \code{LaTeX}, or for the figure caption. See \code{Details}.
    #'
    #' @details
    #' Particular parameters that control the size of the \code{tikz} output are: \code{width}, \code{height} (both in inches), and \code{pointsize} (in points), that should be set to the font size used in the \code{documentclass} header in the \code{LaTeX} file where the code is to be inserted.
    #'
    #' If a \code{caption} is provided, the whole \code{tikz} picture will be wrapped by a \code{figure} environment and the caption set.
    #'
    #' @return If \code{to_latex} is \code{FALSE}, it returns nothing, just plots the graph of the formal context. Otherwise, this function returns the \code{LaTeX} code to reproduce the formal context plot.
    #'
    #' @export
    plot = function(to_latex = FALSE,
                    ...) {

      private$check_empty()
      if (!private$can_plot) {

        warning("The R system has not the needed capabilities to plot.",
                call. = FALSE)
        return(invisible(FALSE))

      }

      plot_context(self$I, to_latex, ...)

    }

  ),

  private = list(

    is_binary = FALSE,
    can_plot = TRUE,

    check_empty = function() {

      if (self$is_empty()) {

        stop("The formal context is empty. The only allowed method is 'load' to import from a previously saved RDS file.", call. = FALSE)

      }

      return(invisible(NULL))

    }

  )

)
