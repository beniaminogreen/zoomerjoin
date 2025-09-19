multi_by_validate <- function(a, b, by) {
  # first pass to handle dplyr::join_by() call
  if (inherits(by, "dplyr_join_by")) {
    if (any(by$condition != "==")) {
      stop("Inequality joins are not supported.")
    }
    new_by <- by$y
    names(new_by) <- by$x
    by <- new_by
  }

  if (is.null(by)) {
    by_a <- intersect(names(a), names(b))
    by_b <- by_a
    stopifnot("Can't Determine columns to match on" = length(by_a)!=0)
  } else {
    if (!is.null(names(by))) {
      by_a <- names(by)
      by_b <- by
    } else {
      by_a <- by
      by_b <- by
    }
    stopifnot(by_a %in% names(a))
    stopifnot(by_b %in% names(b))
  }
  return(list(
    by_a,
    by_b
  ))
}


#' Perform a Fuzzy-Join With an Arbitrary Distance Metric
#'
#' Code used by zoomerjoin to perform dplyr-style joins. Users wishing to write
#' their own joining functions can extend zoomerjoin's functionality by writing
#' joining functions to use with `fuzzy_join_core`.
#'
#' @param a,b The two dataframes to join.
#' @param by A named vector indicating which columns to join on. Format should
#'   be the same as dplyr: `by = c("column_name_in_df_a" =
#'   "column_name_in_df_b")`, but two columns must be specified in each dataset
#'   (x column and y column). Specification made with `dplyr::join_by()` are
#'   also accepted.
#' @param block_by A named vector indicating which columns to 'block' (perform exact joining) on. Format should
#'   be the same as dplyr: `by = c("column_name_in_df_a" =
#'   "column_name_in_df_b")`, but two columns must be specified in each dataset
#'   (x column and y column). Specification made with `dplyr::join_by()` are
#'   also accepted.
#' @param similarity_column An optional character vector. If provided, the data
#'   frame will contain a column with this name giving the similarity
#'   between the two fields. Extra column will not be present if anti-joining.
#' @param join_func the joining function responsible for performing the join.
#' @param mode the dplyr-style type of join you want to perform
#' @param ... Other parameters to be passed to the joining function
#'
#' @importFrom dplyr pull %>%
#' @export
fuzzy_join_core <- function(a, b, by, join_func, mode, block_by = NULL, similarity_column = NULL, ...) {
  a <- tibble::as_tibble(a)
  b <- tibble::as_tibble(b)

  by <- multi_by_validate(a, b, by)
  by_a <- by[[1]]
  by_b <- by[[2]]

  if (!is.null(block_by)) {
      block_by <- multi_by_validate(a, b, block_by)
      block_by_a <- block_by[[1]]
      block_by_b <- block_by[[2]]
  } else {
      block_by_a <- NULL
      block_by_b <- NULL
  }

  match_result <- join_func(
                           a=a, b=b,
                           by_a = by_a,by_b = by_b,
                           block_by_a = block_by_a ,block_by_b = block_by_b,
                           ...)

  match_table <- match_result[['match_table']]
  similarities <- match_result[['similarities']]

  # Rename Columns in Both Tables
  names_in_both <- intersect(names(a), names(b))
  names(a)[names(a) %in% names_in_both] <- paste0(names(a)[names(a) %in% names_in_both], ".x")
  names(b)[names(b) %in% names_in_both] <- paste0(names(b)[names(b) %in% names_in_both], ".y")

  matches <- dplyr::bind_cols(a[match_table[, 1], ], b[match_table[, 2], ])

  if (!is.null(similarity_column)) {
    matches[, similarity_column] <- similarities
  }

  # No need to look for rows that don't match
  if (mode == "inner") {
    return(matches)
  }

  switch(mode,
    "left" = {
      not_matched_a <- collapse::`%!iin%`(seq_len(nrow(a)), match_table[, 1])
      matches <- dplyr::bind_rows(matches, a[not_matched_a, ])
    },
    "right" = {
      not_matched_b <- collapse::`%!iin%`(seq_len(nrow(b)), match_table[, 2])
      matches <- dplyr::bind_rows(matches, b[not_matched_b, ])
    },
    "full" = {
      not_matched_a <- collapse::`%!iin%`(seq_len(nrow(a)), match_table[, 1])
      not_matched_b <- collapse::`%!iin%`(seq_len(nrow(b)), match_table[, 2])
      matches <- dplyr::bind_rows(matches, a[not_matched_a, ], b[not_matched_b, ])
    },
    "anti" = {
      not_matched_a <- collapse::`%!iin%`(seq_len(nrow(a)), match_table[, 1])
      not_matched_b <- collapse::`%!iin%`(seq_len(nrow(b)), match_table[, 2])
      matches <- dplyr::bind_rows(a[not_matched_a, ], b[not_matched_b, ])
    }
  )

  matches
}

#' @importFrom dplyr pull %>%
jaccard_join <- function(a, b, by_a, by_b, block_by_a, block_by_b, n_gram_width, n_bands,
                          band_width, threshold, progress = FALSE, a_salt = NULL, b_salt = NULL,
                         clean = FALSE, nthread = NULL) {

  stopifnot("'threshold' must be of length 1" = length(threshold) == 1)
  stopifnot("'threshold' must be between 0 and 1" = threshold <= 1 & threshold >= 0)

  stopifnot("'by_a' must be of length 1" = length(by_a) == 1)
  stopifnot("'by_b' must be of length 1" = length(by_b) == 1)

  stopifnot("'n_bands' must be greater than 0" = n_bands > 0)
  stopifnot("'n_bands' must be length than 1" = length(n_bands) == 1)

  stopifnot("'band_width' must be greater than 0" = band_width > 0)
  stopifnot("'band_width' must be length than 1" = length(band_width) == 1)

  stopifnot("'n_gram_width' must be greater than 0" = n_gram_width > 0)
  stopifnot("'n_gram_width' must be length than 1" = length(n_gram_width) == 1)

  thresh_prob <- jaccard_probability(threshold, n_bands, band_width)

  if (thresh_prob < .95) {
    str <- paste0(
      "A pair of records at the threshold (", threshold,
      ") have only a ", round(thresh_prob * 100), "% chance of being compared.\n",
      "Please consider changing `n_bands` and `band_width`."
    )
    warning(str)
  }

  stopifnot("'by' vectors must have length 1" = length(by_a) == 1)
  stopifnot("'by' vectors must have length 1" = length(by_b) == 1)

  stopifnot("There should be no NA's in by_a" = !anyNA(a[[by_a]]))
  stopifnot("There should be no NA's in by_b" = !anyNA(b[[by_b]]))

  # Clean strings that are matched on
  if (clean) {
    a_col <- tolower(gsub("[[:punct:] ]", "", dplyr::pull(a, by_a)))
    b_col <- tolower(gsub("[[:punct:] ]", "", dplyr::pull(b, by_b)))

    if (!is.null(block_by_a) && !is.null(block_by_b)) {
      a_salt_col <- tidyr::unite(a, "block_by_a", dplyr::all_of(block_by_a)) %>%
        dplyr::pull("block_by_a")
      b_salt_col <- tidyr::unite(b, "block_by_b", dplyr::all_of(block_by_b)) %>%
        dplyr::pull("block_by_b")

      a_salt_col <- tolower(gsub("[[:punct:] ]", "", a_salt_col))
      b_salt_col <- tolower(gsub("[[:punct:] ]", "", b_salt_col))
    }
  } else {
    a_col <- dplyr::pull(a, by_a)
    b_col <- dplyr::pull(b, by_b)

    if (!is.null(block_by_a) && !is.null(block_by_b)) {
      a_salt_col <- tidyr::unite(a, "block_by_a", dplyr::all_of(block_by_a)) %>%
        dplyr::pull("block_by_a")

      b_salt_col <- tidyr::unite(b, "block_by_b", dplyr::all_of(block_by_b)) %>%
        dplyr::pull("block_by_b")
    }
  }

  if (is.null(block_by_a) || is.null(block_by_b)) {
    match_table <- rust_jaccard_join(
      a_col, b_col,
      n_gram_width, n_bands, band_width, threshold,
      progress,
      seed = 1,
      nthread = nthread
    )
  } else {
    match_table <- rust_salted_jaccard_join(
      a_col, b_col,
      a_salt_col, b_salt_col,
      n_gram_width, n_bands, band_width, threshold,
      progress,
      seed = round(runif(1, 0, 2^64)),
      nthread = nthread
    )
  }

  similarities <- jaccard_similarity(
      pull(a[match_table[, 1], ], by_a),
      pull(b[match_table[, 2], ], by_b),
       n_gram_width,
      nthread = nthread
     )

  return(list(
              match_table = match_table,
              similarities = similarities
    ))
}



