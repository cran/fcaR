.Rsimplification_bg <- function(LHS, RHS,
                                fixed = 0) {

  LHS <- convert_to_sparse(LHS)
  RHS <- convert_to_sparse(RHS)

  LRHS_subsets <- Matrix::Matrix(FALSE, sparse = TRUE,
                                 ncol = ncol(LHS),
                                 nrow = ncol(LHS))
  intersections <- .self_intersection(LHS, RHS)

  id_inter <- Matrix::which(intersections == 0)

  # This gives the union of LHS and RHS

  LRHS_subsets[, id_inter] <- Matrix::t(.subset(Matrix::Matrix(LHS[, id_inter],
                                                               sparse = TRUE),
                                                .union(LHS,RHS)))

  # This gives the LRHS that are subsets of other LHS
  col_values <- Matrix::colSums(LRHS_subsets)
  condition1 <- col_values > 1

  # This gives those LHS which are disjoint to their RHS
  condition2 <- intersections == 0

  are_subset <- which(condition1 & condition2)
  are_subset <- intersect(are_subset, seq(fixed))

  black_list <- rep(FALSE, ncol(LHS))

  count <- 0

  while (length(are_subset) > 0) {

    count <- count + 1

    id1 <- which.max(col_values[are_subset])
    this_row <- are_subset[id1]

    my_idx <- which_at_col(LRHS_subsets@i,
                           LRHS_subsets@p,
                           this_row)

    # this_row <- id_inter[this_row]
    my_idx <- setdiff(my_idx, this_row)
    if (fixed > 0)
      my_idx <- setdiff(my_idx, seq(fixed))

    if (length(my_idx) == 0) {

      black_list[this_row] <- TRUE
      are_subset <- Matrix::which(condition1 & condition2 & (!black_list))
      are_subset <- intersect(are_subset, seq(fixed))

      next

    }

    # this_row is subset of all my_idx
    # So, we must do C -> D-B in every my_idx rule.

    if (length(my_idx) > 1) {

      C <- LHS[, my_idx]
      D <- RHS[, my_idx]

    } else {

      C <- Matrix::Matrix(LHS[, my_idx], sparse = TRUE)
      D <- Matrix::Matrix(RHS[, my_idx], sparse = TRUE)

    }
    B <- Matrix::Matrix(RHS[, this_row], sparse = TRUE)
    newRHS <- set_difference_single(D@i, D@p, D@x,
                                    B@i, B@p, B@x,
                                    nrow(D))

    RHS[, my_idx] <- newRHS

    intersections[my_idx] <- .self_intersection(C, newRHS)
    id_inter <- Matrix::which(intersections == 0)

    # browser()
    LRHS_subsets[my_idx, id_inter] <- Matrix::t(.subset(Matrix::Matrix(LHS[, id_inter],
                                                                       sparse = TRUE),
                                                        .union(C, newRHS)))
    col_values <- Matrix::colSums(LRHS_subsets)
    condition1 <- col_values > 1

    condition2 <- (intersections == 0) & (Matrix::colSums(RHS) > 0)

    black_list[this_row] <- TRUE
    are_subset <- Matrix::which(condition1 & condition2 & (!black_list))
    are_subset <- intersect(are_subset, seq(fixed))

  }

  # Cleaning phase
  idx_to_remove <- Matrix::which(Matrix::colSums(RHS) == 0)

  if (length(idx_to_remove) > 0) {

    LHS <- LHS[, -idx_to_remove]
    RHS <- RHS[, -idx_to_remove]

  }

  if (fixed > 0) {

    LHS <- LHS[, -seq(fixed)]
    RHS <- RHS[, -seq(fixed)]

  }

  return(list(lhs = LHS, rhs = RHS))

}

